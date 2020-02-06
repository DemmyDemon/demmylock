local CODES = nil
function loadCodes()
    local codes_JSON = LoadResourceFile(GetCurrentResourceName(), 'codes.json')
    local codes_Lua = json.decode(codes_JSON)
    return codes_Lua
end

function verifyPin(area, lock, pin)
    
    if not CODES then
        CODES = loadCodes()
    end

    if CODES and CODES[area] and CODES[area][lock] then
        return (pin == CODES[area][lock])
    end

end
RegisterNetEvent('demmylock:entered-pin')
AddEventHandler ('demmylock:entered-pin', function(area, lock, pin, locked)
    local source = source
    if LOCKS[area] and LOCKS[area][lock] and verifyPin(area, lock, pin) then
        
        lockStateCache = nil -- void lock cache because we're changing the lock state!
        
        LOCKS[area][lock].locked = locked
        if locked then
            TriggerClientEvent('demmylock:lock', -1, area, lock)
            Citizen.Trace(source..'/'..GetPlayerName(source)..' locked '..area..'/'..lock..'\n')
        else
            if LOCKS[area][lock].relock then
                LOCKS[area][lock].timer = SetTimeout(LOCKS[area][lock].relock, function()
                    if not LOCKS[area][lock].locked then
                        lockStateCache = nil
                        LOCKS[area][lock].locked = true
                        Citizen.Trace(area..'/'..lock..' was automatically relocked\n')
                        TriggerClientEvent('demmylock:lock', -1, area, lock)
                    end
                end)
            end
            TriggerClientEvent('demmylock:unlock', -1, area, lock)
            Citizen.Trace(source..'/'..GetPlayerName(source)..' unlocked '..area..'/'..lock..'\n')
        end
    else
        TriggerClientEvent('demmylock:wrong-code', source, area, lock)
    end
end)

local lockStateCache = nil
RegisterNetEvent('demmylock:request-lock-state')
AddEventHandler ('demmylock:request-lock-state', function()
    local source = source
    Citizen.Trace(source..'/'..GetPlayerName(source)..' requests lock state\n')
    if lockStateCache then
        TriggerClientEvent('demmylock:lock-state',source, lockStateCache)
        return
    end

    local lockState = {}
    for areaName, areaData in pairs(LOCKS) do
        lockState[areaName] = {}
        for lockName, lockData in pairs(areaData) do
            lockState[areaName][lockName] = lockData.locked
        end
    end
    TriggerClientEvent('demmylock:lock-state', source, lockState)
    lockStateCache = lockState

end)

-- Technically it doesn't "reload" anything.
-- It just makes the script forget them so they are loaded again
-- the next time they are needed.
RegisterCommand('reloadlockcodes', function(source, args, raw)
    CODES = nil
    if source == 0 then
        Citizen.Trace('DemmyLock codes reloaded by console.\n')
    else
        Citizen.Trace('DemmyLock codes reloaded by '..GetPlayerName(source)..'.\n')
        TriggerClientEvent('chat:addMessage', source, {args={'DemmyLock', 'Codes reloaded!'}})
    end
end,true)