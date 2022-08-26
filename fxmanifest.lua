fx_version 'cerulean'
game 'gta5'

description 'Renewed Banking'
Author "uShifty#1733"
version '1.0.0'

lua54 'yes'

shared_script {
    'config.lua'
}

client_scripts {
    'client/*.lua'
}

server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'server/*.lua'
}

ui_page 'web/public/index.html'

files {
  'web/public/index.html',
  'web/public/**/*'
}