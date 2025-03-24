dependency "PL_PROTECT"
client_script "@PL_PROTECT/lib/plclient.lua"
server_script "@PL_PROTECT/lib/plserver.lua" 

fx_version 'cerulean'
game 'gta5'

author 'Your Name'
description 'Auction System'
version '1.0.0'

ui_page 'web/index.html'

client_scripts {
    'client/client.lua'
}

server_scripts {
    'server/server.lua',
      'lib/Framework.lua'
}

files {
    'web/index.html',
    'web/style.css',
    'web/script.js'
}

shared_scripts {
    "@vrp/lib/utils.lua",
    'lib/Config.lua'
}


escrow_ignore {
    'lib/Config.lua',
    'lib/Framework.lua'
}