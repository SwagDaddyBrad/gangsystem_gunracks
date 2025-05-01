fx_version   'cerulean'
use_experimental_fxv2_oal 'yes'
lua54        'yes'
game         'gta5'

author "JoeSzymkowiczFiveM, Snipe, FjamZoo"
description 'A script to place a gun rack in the world, and use it for storing weapons.'

shared_scripts {
    '@ox_lib/init.lua',
    'config.lua',
}

client_scripts {
    '@qbx_core/modules/playerdata.lua', -- For QBOX users
    'client/framework.lua',
    'client/main.lua',
}

server_scripts {
    '@oxmysql/lib/MySQL.lua',
    -- '@chiliaddb/init.lua',
    'server/framework.lua',
    'server/main.lua',
}