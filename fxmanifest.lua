fx_version 'cerulean'
game      'gta5'
lua54     'yes'

author    'Lumen'
description 'Lumen Notify - Notification system styled after LumenUI'
version   '1.0.0'

shared_scripts {
    "@ox_lib/init.lua",
    'config.lua',
}

client_scripts {
    'client/main.lua',
    'client/test.lua',
}

server_scripts {
    'server/main.lua',
}

ui_page 'ui/index.html'

files {
    'ui/index.html',
    'ui/css/style.css',
    'ui/js/main.js',
}
