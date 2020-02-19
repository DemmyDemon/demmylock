local CODES = {}

function AddCodes(area, codes)
    if not CODES[area] then
        CODES[area] = {}
    end
    for name, data in pairs(codes) do
        -- No dupe notification because they probably *want* to override the "metagaming" file
        CODES[area][name] = data
    end
end

function verifyPin(area, lock, pin)

    if CODES[area] and CODES[area][lock] then
        return (pin == CODES[area][lock])
    elseif CODES and CODES[area] and CODES[area]._default then
        return (pin == CODES[area]._default)
    end

end
function matchDestination(area, lock, pin)
    if not CODES then
        CODES = loadCodes()
    end
    if CODES and CODES[area] and CODES[area][lock] then
        for destination,code in ipairs(CODES[area][lock]) do
            if pin == code then
                return destination
            end
        end
    end
end
RegisterNetEvent('demmylock:entered-pin')
AddEventHandler ('demmylock:entered-pin', function(area, lock, pin, locked)
    local source = source
    if LOCKS[area] and LOCKS[area][lock] then
        local lockData = LOCKS[area][lock]

        if lockData.teleport then

            local destination = matchDestination(area, lock, pin)
            if destination then
                lockStateCache = nil -- void lock cache because we're changing the lock state!
                lockData.locked = false
                TriggerClientEvent('demmylock:unlock', -1, area, lock, destination)
                Citizen.Trace(source..'/'..GetPlayerName(source)..' opened a magic portal from '..area..' '..lock..' to destination '..destination..'\n')
            else
                TriggerClientEvent('demmylock:wrong-code', source, area, lock)
            end
            SetTimeout(CONFIG.teleportTime, function()
                lockStateCache = nil -- void lock cache because we're changing the lock state!
                lockData.locked = true
                TriggerClientEvent('demmylock:lock', -1, area, lock)
                Citizen.Trace('The magic portal from '..area..' '..lock..' has closed.\n')
            end)

        elseif verifyPin(area, lock, pin) then

            lockStateCache = nil -- void lock cache because we're changing the lock state!

            lockData.locked = locked
            if locked then
                TriggerClientEvent('demmylock:lock', -1, area, lock)
                Citizen.Trace(source..'/'..GetPlayerName(source)..' locked '..area..' '..lock..'\n')
            else
                if lockData.relock then
                    SetTimeout(LOCKS[area][lock].relock, function()
                        if not lockData.locked then
                            lockStateCache = nil
                            lockData.locked = true
                            Citizen.Trace(area..' '..lock..' was automatically relocked\n')
                            TriggerClientEvent('demmylock:lock', -1, area, lock)
                        end
                    end)
                end
                TriggerClientEvent('demmylock:unlock', -1, area, lock)
                Citizen.Trace(source..'/'..GetPlayerName(source)..' unlocked '..area..' '..lock..'\n')
            end
        else
            TriggerClientEvent('demmylock:wrong-code', source, area, lock)
        end
    else
        TriggerClientEvent('demmylock:wrong-code', source, area, lock)
    end
end)

local lockStateCache = nil
RegisterNetEvent('demmylock:request-lock-state')
AddEventHandler ('demmylock:request-lock-state', function()
    local source = source
    -- Citizen.Trace(source..'/'..GetPlayerName(source)..' requests lock state\n')
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
