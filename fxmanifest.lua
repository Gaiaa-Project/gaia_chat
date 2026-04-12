fx_version 'cerulean'
game 'gta5'

author 'Chaos Studio'
description 'Lua most advance FiveM chat resource — standalone, migration-ready, Vue 3 NUI. Part of the Gaia Project ecosystem.'
version '0.0.1'

name 'gaia_chat'

lua54 'yes'

shared_scripts {
    'config/*.lua',
    'shared/modules/framework.lua',
}

server_scripts {
    'server/main.lua',
    'server/modules/staff_chat.lua',
}

client_scripts {
    'client/main.lua',
    'client/modules/staff_chat.lua',
}

ui_page 'web/dist/index.html'

files {
    'web/dist/index.html',
    'web/dist/**/*.js',
    'web/dist/**/*.css',
    'web/dist/assets/**/*.*',
}
