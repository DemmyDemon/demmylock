name 'DemmyLock'
description 'Less buggy door locking!'
author 'Demonen'

fx_version 'adamant'
games { 'gta5' }

shared_scripts { 'config.lua', 'locks.lua', 'locks/*.lua' }
server_scripts { 'sv_demmylock.lua', 'default_codes.lua', 'codes/*.lua' }
client_scripts { 'keypad.lua', 'cl_demmylock.lua' }
