fx_version 'cerulean'
game 'gta5'

author 'SteakHarpyie59'
description 'Github: SteakHarpyie59'
version '1.0.0'


client_scripts {
    'config.lua',
    'client.lua'
}

server_scripts {
    '@async/async.lua',
    '@mysql-async/lib/MySQL.lua',
    'config.lua',
    'server.lua'
}