fx_version 'cerulean'
game 'gta5'

description 'MD-Garage'
version '1.0.0'

ui_page 'ui/index.html'

files {
    'ui/index.html',
    'ui/style.css',
    'ui/script.js',
    'ui/img/*.png',
    'ui/img/*.jpg'
}

client_scripts {
    'client/main.lua'
}

server_scripts {
    '@es_extended/imports.lua',
    '@oxmysql/lib/MySQL.lua',
    'server/main.lua'
}

dependency 'es_extended'
dependency 'oxmysql'

lua54 'yes'
