fx_version 'cerulean'
game 'gta5'

description 'Renewed chopshop, You are not allowed to distribute this script without permission from me.'
Author "FjamZoo#0001"
version '1.0.0'

lua54 'yes'

shared_script {
    'config.lua'
}

client_scripts {
    '@PolyZone/client.lua',
    '@PolyZone/BoxZone.lua',
    '@PolyZone/EntityZone.lua',
    '@PolyZone/CircleZone.lua',
    '@PolyZone/ComboZone.lua',
    'client/*.lua' -- Globbing method for multiple files
}

server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'server/*.lua' -- Globbing method for multiple files
}

ui_page 'web/public/index.html'

files {
  'web/public/index.html',
  'web/public/**/*'
}