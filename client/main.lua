local ESX = exports["es_extended"]:getSharedObject()

-- Markers and Blips configuration
local garages = {
    {
        name = "Main", 
        coords = vector3(215.12, -810.12, 30.73), 
        spawn = vector4(221.78, -791.73, 30.2, 160.0),
        delete = vector3(211.23, -794.61, 30.85)
    },
    {
        name = "Sandy Shores", 
        coords = vector3(1877.2, 3696.8, 33.6), 
        spawn = vector4(1883.3, 3689.6, 33.6, 210.0),
        delete = vector3(1889.3, 3696.0, 33.6)
    },
    {
        name = "Paleto Bay", 
        coords = vector3(-73.3, 6400.2, 31.5), 
        spawn = vector4(-66.2, 6393.3, 31.5, 200.0),
        delete = vector3(-60.2, 6400.0, 31.5)
    },
    {
        name = "Vinewood", 
        coords = vector3(603.6, 92.2, 93.0), 
        spawn = vector4(608.2, 85.5, 92.3, 160.0),
        delete = vector3(615.1, 91.5, 92.5)
    },
    {
        name = "South LS", 
        coords = vector3(-1147.2, -1994.4, 13.1), 
        spawn = vector4(-1141.4, -2002.3, 13.1, 310.0),
        delete = vector3(-1135.5, -1994.6, 13.1)
    },
}

local impound = {
    name = "Fourrière",
    coords = vector3(408.8, -1622.9, 29.2),
    spawn = vector4(404.9, -1632.7, 29.2, 230.0),
    price = 500 -- Price to retrieve
}

-- Create Blips
Citizen.CreateThread(function()
    for _, garage in pairs(garages) do
        local blip = AddBlipForCoord(garage.coords.x, garage.coords.y, garage.coords.z)
        SetBlipSprite(blip, 357)
        SetBlipDisplay(blip, 4)
        SetBlipScale(blip, 0.7)
        SetBlipColour(blip, 3)
        SetBlipAsShortRange(blip, true)
        BeginTextCommandSetBlipName("STRING")
        AddTextComponentString("Garage: " .. garage.name)
        EndTextCommandSetBlipName(blip)
    end

    -- Impound Blip
    local impoundBlip = AddBlipForCoord(impound.coords.x, impound.coords.y, impound.coords.z)
    SetBlipSprite(impoundBlip, 67)
    SetBlipDisplay(impoundBlip, 4)
    SetBlipScale(impoundBlip, 0.8)
    SetBlipColour(impoundBlip, 64)
    SetBlipAsShortRange(impoundBlip, true)
    BeginTextCommandSetBlipName("STRING")
    AddTextComponentString("Fourrière")
    EndTextCommandSetBlipName(impoundBlip)
end)

-- Main Loop for Markers
Citizen.CreateThread(function()
    while true do
        local wait = 1000
        local playerPed = PlayerPedId()
        local coords = GetEntityCoords(playerPed)

        for _, garage in pairs(garages) do
            -- Garage Access Marker (Blue)
            local dist = #(coords - garage.coords)
            if dist < 10.0 then
                wait = 0
                DrawMarker(27, garage.coords.x, garage.coords.y, garage.coords.z - 0.95, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 1.0, 1.0, 1.0, 52, 152, 219, 150, false, false, 2, false, nil, nil, false)
                
                if dist < 1.5 then
                    ESX.ShowHelpNotification("Appuyez sur ~INPUT_CONTEXT~ pour accéder au garage")
                    if IsControlJustReleased(0, 38) then
                        OpenGarageMenu(garage.name)
                    end
                end
            end

            -- Delete Marker (Red)
            local storeDist = #(coords - garage.delete)
            if storeDist < 10.0 then
                wait = 0
                DrawMarker(27, garage.delete.x, garage.delete.y, garage.delete.z - 0.95, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 2.0, 2.0, 2.0, 231, 76, 60, 150, false, false, 2, false, nil, nil, false)
                
                if storeDist < 3.0 then
                    if IsPedInAnyVehicle(playerPed, false) then
                        ESX.ShowHelpNotification("Appuyez sur ~INPUT_CONTEXT~ pour ranger le véhicule")
                        if IsControlJustReleased(0, 38) then
                            StoreVehicle()
                        end
                    end
                end
            end
        end

        local impoundDist = #(coords - impound.coords)
        if impoundDist < 10.0 then
            wait = 0
            -- Ground marker (Green circle)
            DrawMarker(27, impound.coords.x, impound.coords.y, impound.coords.z - 0.95, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 1.0, 1.0, 1.0, 46, 204, 113, 150, false, false, 2, false, nil, nil, false)
            -- Floating marker (Green arrow)
            DrawMarker(20, impound.coords.x, impound.coords.y, impound.coords.z + 0.2, 0.0, 0.0, 0.0, 0.0, 180.0, 0.0, 0.5, 0.5, 0.5, 46, 204, 113, 200, true, true, 2, false, nil, nil, false)
            
            if impoundDist < 1.5 then
                ESX.ShowHelpNotification("Appuyez sur ~INPUT_CONTEXT~ pour accéder à la fourrière")
                if IsControlJustReleased(0, 38) then
                    OpenImpoundMenu()
                end
            end
        end

        Citizen.Wait(wait)
    end
end)

function OpenGarageMenu(garageName)
    ESX.TriggerServerCallback('md_garage:getVehicles', function(vehicles)
        print("^2[Garage]^7 Received " .. #vehicles .. " vehicles from server")
        for _, vehicle in pairs(vehicles) do
            local modelName = vehicle.props.model
            local displayName = GetDisplayNameFromVehicleModel(modelName)
            vehicle.name = GetLabelText(displayName)
            if vehicle.name == "NULL" then vehicle.name = displayName end
            vehicle.model = modelName
            print("^2[Garage]^7 Data: " .. vehicle.name .. " (" .. vehicle.plate .. ")")
        end
        
        SendNUIMessage({
            action = "open",
            garage = garageName,
            vehicles = vehicles
        })
        SetNuiFocus(true, true)
    end, garageName)
end

function OpenImpoundMenu()
    ESX.TriggerServerCallback('md_garage:getImpoundedVehicles', function(vehicles)
        for _, vehicle in pairs(vehicles) do
            local modelName = vehicle.props.model
            local displayName = GetDisplayNameFromVehicleModel(modelName)
            vehicle.name = GetLabelText(displayName)
            if vehicle.name == "NULL" then vehicle.name = displayName end
            vehicle.model = modelName
        end
        
        SendNUIMessage({
            action = "openImpound",
            garage = "Fourrière",
            vehicles = vehicles,
            price = impound.price
        })
        SetNuiFocus(true, true)
    end)
end

function StoreVehicle()
    local playerPed = PlayerPedId()
    local vehicle = GetVehiclePedIsIn(playerPed, false)
    local vehicleProps = ESX.Game.GetVehicleProperties(vehicle)
    
    ESX.TriggerServerCallback('md_garage:isOwner', function(isOwner)
        if isOwner then
            TriggerServerEvent('md_garage:storeVehicle', vehicleProps.plate, vehicleProps)
            ESX.Game.DeleteVehicle(vehicle)
            ESX.ShowNotification("Véhicule rangé !")
        else
            ESX.ShowNotification("Ce véhicule ne vous appartient pas")
        end
    end, vehicleProps.plate)
end

-- NUI Callbacks
RegisterNUICallback('close', function(data, cb)
    SetNuiFocus(false, false)
    cb('ok')
end)

RegisterNUICallback('spawnVehicle', function(data, cb)
    ESX.TriggerServerCallback('md_garage:spawnVehicle', function(success, props)
        if success then
            local garage = nil
            for _, g in pairs(garages) do
                if g.name == data.garage then
                    garage = g
                    break
                end
            end

            if garage then
                ESX.Game.SpawnVehicle(props.model, vector3(garage.spawn.x, garage.spawn.y, garage.spawn.z), garage.spawn.w, function(vehicle)
                    ESX.Game.SetVehicleProperties(vehicle, props)
                    TaskWarpPedIntoVehicle(PlayerPedId(), vehicle, -1)
                    SetEntityAsMissionEntity(vehicle, true, true)
                    ESX.ShowNotification("Véhicule sorti !")
                end)
            end
        else
            ESX.ShowNotification("Erreur lors de la sortie du véhicule")
        end
    end, data.plate)
    
    SetNuiFocus(false, false)
    cb('ok')
end)

RegisterNUICallback('payImpound', function(data, cb)
    TriggerServerEvent('md_garage:payImpound', data.plate, data.price)
    cb('ok')
end)

RegisterNetEvent('md_garage:impoundSpawned')
AddEventHandler('md_garage:impoundSpawned', function(plate)
    ESX.TriggerServerCallback('md_garage:spawnVehicle', function(success, props)
        if success then
            ESX.Game.SpawnVehicle(props.model, vector3(impound.spawn.x, impound.spawn.y, impound.spawn.z), impound.spawn.w, function(vehicle)
                ESX.Game.SetVehicleProperties(vehicle, props)
                TaskWarpPedIntoVehicle(PlayerPedId(), vehicle, -1)
                SetEntityAsMissionEntity(vehicle, true, true)
                ESX.ShowNotification("Véhicule récupéré de la fourrière !")
            end)
        end
    end, plate)
end)

RegisterNUICallback('transferVehicle', function(data, cb)
    TriggerServerEvent('md_garage:transferVehicle', data.plate, data.target)
    cb('ok')
end)

-- Admin / GiveCar event
RegisterNetEvent('md_garage:saveVehicle')
AddEventHandler('md_garage:saveVehicle', function()
    local playerPed = PlayerPedId()
    if IsPedInAnyVehicle(playerPed, false) then
        local vehicle = GetVehiclePedIsIn(playerPed, false)
        local props = ESX.Game.GetVehicleProperties(vehicle)
        TriggerServerEvent('md_garage:saveVehicleDB', props)
    else
        ESX.ShowNotification("Vous devez être dans un véhicule")
    end
end)
