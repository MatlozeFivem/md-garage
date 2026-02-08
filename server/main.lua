local ESX = exports["es_extended"]:getSharedObject()

-- Handlers for MySQL compatibility
-- This ensures we use the best available method (lib or export)
local function Query(query, params, cb)
    if MySQL and MySQL.query then
        MySQL.query(query, params, cb)
    else
        exports.oxmysql:query(query, params, cb)
    end
end

local function Update(query, params, cb)
    if MySQL and MySQL.update then
        MySQL.update(query, params, cb)
    else
        if cb then
            exports.oxmysql:update(query, params, cb)
        else
            exports.oxmysql:update(query, params)
        end
    end
end

ESX.RegisterServerCallback('md_garage:getVehicles', function(source, cb, garageName)
    local xPlayer = ESX.GetPlayerFromId(source)
    print("^2[Garage]^7 Fetching vehicles for identifier: " .. xPlayer.identifier .. " in garage: " .. garageName)
    Query('SELECT * FROM owned_vehicles WHERE owner = ? AND lb_garage = ?', {
        xPlayer.identifier,
        garageName
    }, function(results)
        local vehicles = {}
        if results then
            print("^2[Garage]^7 Found " .. #results .. " vehicles")
            for _, v in pairs(results) do
                table.insert(vehicles, {
                    plate = v.plate,
                    props = json.decode(v.vehicle),
                    stored = v.stored,
                    image = v.image or "default.png"
                })
            end
        else
            print("^1[Garage]^7 No results or query failed")
        end
        cb(vehicles)
    end)
end)

ESX.RegisterServerCallback('md_garage:spawnVehicle', function(source, cb, plate)
    Query('SELECT * FROM owned_vehicles WHERE plate = ?', {
        plate
    }, function(results)
        if results and results[1] then
            Update('UPDATE owned_vehicles SET stored = 0 WHERE plate = ?', {
                plate
            }, function(rowsChanged)
                cb(rowsChanged > 0, json.decode(results[1].vehicle))
            end)
        else
            cb(false)
        end
    end)
end)

ESX.RegisterServerCallback('md_garage:isOwner', function(source, cb, plate)
    local xPlayer = ESX.GetPlayerFromId(source)
    Query('SELECT * FROM owned_vehicles WHERE plate = ? AND owner = ?', {
        plate,
        xPlayer.identifier
    }, function(results)
        cb(results and results[1] ~= nil)
    end)
end)

RegisterServerEvent('md_garage:storeVehicle')
AddEventHandler('md_garage:storeVehicle', function(plate, props)
    Update('UPDATE owned_vehicles SET stored = 1, vehicle = ? WHERE plate = ?', {
        json.encode(props),
        plate
    })
end)

RegisterServerEvent('md_garage:transferVehicle')
AddEventHandler('md_garage:transferVehicle', function(plate, targetGarage)
    local src = source
    local xPlayer = ESX.GetPlayerFromId(src)
    
    Update('UPDATE owned_vehicles SET lb_garage = ? WHERE plate = ? AND owner = ?', {
        targetGarage,
        plate,
        xPlayer.identifier
    }, function(rowsChanged)
        if rowsChanged > 0 then
            TriggerClientEvent('esx:showNotification', src, "Véhicule transféré vers " .. targetGarage)
        else
            TriggerClientEvent('esx:showNotification', src, "Échec du transfert")
        end
    end)
end)

ESX.RegisterCommand('givecar', 'admin', function(xPlayer, args, showError)
    xPlayer.triggerEvent('md_garage:saveVehicle')
end, false, {help = "Donner le véhicule actuel à soi-même"})

RegisterServerEvent('md_garage:saveVehicleDB')
AddEventHandler('md_garage:saveVehicleDB', function(props)
    local xPlayer = ESX.GetPlayerFromId(source)
    print("^2[Garage]^7 Saving vehicle " .. props.plate .. " for " .. xPlayer.identifier)
    
    Update('INSERT INTO owned_vehicles (owner, plate, vehicle, stored, lb_garage) VALUES (?, ?, ?, ?, ?)', {
        xPlayer.identifier,
        props.plate,
        json.encode(props),
        1,
        'Main'
    }, function(rowsChanged)
        if rowsChanged > 0 then
            TriggerClientEvent('esx:showNotification', xPlayer.source, "Véhicule enregistré à votre nom !")
        else
            TriggerClientEvent('esx:showNotification', xPlayer.source, "Erreur lors de l'enregistrement")
        end
    end)
end)
ESX.RegisterServerCallback('md_garage:getImpoundedVehicles', function(source, cb)
    local xPlayer = ESX.GetPlayerFromId(source)
    Query('SELECT * FROM owned_vehicles WHERE owner = ? AND stored = 0', {
        xPlayer.identifier
    }, function(results)
        local vehicles = {}
        if results then
            for _, v in pairs(results) do
                table.insert(vehicles, {
                    plate = v.plate,
                    props = json.decode(v.vehicle),
                    stored = v.stored,
                    image = v.image or "default.png"
                })
            end
        end
        cb(vehicles)
    end)
end)

RegisterServerEvent('md_garage:payImpound')
AddEventHandler('md_garage:payImpound', function(plate, price)
    local xPlayer = ESX.GetPlayerFromId(source)
    
    if xPlayer.getMoney() >= price then
        xPlayer.removeMoney(price)
        Update('UPDATE owned_vehicles SET stored = 1 WHERE plate = ? AND owner = ?', {
            plate,
            xPlayer.identifier
        }, function(rowsChanged)
            if rowsChanged > 0 then
                TriggerClientEvent('esx:showNotification', xPlayer.source, "Vous avez payé $" .. price .. " pour récupérer votre véhicule.")
                TriggerClientEvent('md_garage:impoundSpawned', xPlayer.source, plate)
            end
        end)
    else
        TriggerClientEvent('esx:showNotification', xPlayer.source, "Vous n'avez pas assez d'argent ($" .. price .. ")")
    end
end)
