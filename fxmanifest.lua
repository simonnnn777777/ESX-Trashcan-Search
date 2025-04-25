fx_version 'cerulean'
game 'gta5'

description 'Müll durchsuchen mit ox_target & ESX'
author 'SM X Simon'

lua54 'yes'

shared_scripts {
    '@es_extended/imports.lua',
    '@ox_lib/init.lua'
}

client_scripts {
    'client.lua'
}

server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'server.lua'
}
