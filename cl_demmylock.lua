AddTextEntry('DEMMYLOCK_INTERACT', '~a~~n~~INPUT_CONTEXT~ Ange kod')
AddTextEntry('DEMMYLOCK_REUSE', '~a~~n~~INPUT_CONTEXT~ Upprepa kod ~n~~INPUT_CHARACTER_WHEEL~+~INPUT_CONTEXT~ Ange kod')
AddTextEntry('DEMMYLOCK_TELEPORT', '~a~~n~~INPUT_CONTEXT~ Kliv igenom')

local inArea = {}
local gotLockState = false
local DEBUGAREAS = false

local STATE_LOCKED = 4
local STATE_OPEN = 0
local STATE_OPEN_FORCED = -1

local drivingVehicle = false
local playerPed = PlayerPedId()

function getLastKey(areaName, lockName)
    local key
    if LOCKS[areaName] and LOCKS[areaName][lockName] then
        
        if LOCKS[areaName][lockName].lastKey then
            return LOCKS[areaName][lockName].lastKey
        end

        local groupcode = LOCKS[areaName][lockName].groupcode
        if groupcode then
            if type(groupcode) == 'string' then
                key = GetResourceKvpString('demmylock:'..areaName..':'..groupcode)
            else
                key = GetResourceKvpString('demmylock:'..areaName)
            end
        else
            key = GetResourceKvpString('demmylock:'..areaName..':'..lockName)
        end
    end

    if key then
        LOCKS[areaName][lockName].lastKey = key
        return key
    else
        LOCKS[areaName][lockName].lastKey = ''
        return ''
    end
end

function setLastKey(areaName, lockName, key)
    if LOCKS[areaName] and LOCKS[areaName][lockName] then
        local groupcode = LOCKS[areaName][lockName].groupcode
        LOCKS[areaName][lockName].lastKey = key
        Citizen.Trace(string.format("%s/%s/%s = %s\n", areaName, lockName, groupcode, key))
        if groupcode then
            if type(groupcode) == 'string' then
                if key then
                    SetResourceKvp('demmylock:'..areaName..':'..groupcode, key)
                else
                    DeleteResourceKvp('demmylock:'..areaName..':'..groupcode, key)
                end
            else
                if key then
                    SetResourceKvp('demmylock:'..areaName, key)
                else
                    DeleteResourceKvp('demmylock:'..areaName)
                end
            end
        else
            if key then
                SetResourceKvp('demmylock:'..areaName..':'..lockName, key)
            else
                DeleteResourceKvp('demmylock:'..areaName..':'..lockName)
            end
        end

    end
end

function withModel(hash, callback)
    if not HasModelLoaded(hash) then
        RequestModel(hash)
        while not HasModelLoaded(hash) do
            Citizen.Wait(0)
        end
    end
    if callback then
        callback()
        SetModelAsNoLongerNeeded(hash)
    end
end

local enableProfiling = false
local OrigProfilerEnterScope = ProfilerEnterScope
local OrigProfilerExitScope = ProfilerExitScope

function ProfilerEnterScope(scope)
    if enableProfiling then
        OrigProfilerEnterScope(scope)
    end
end
function ProfilerEnterScope()
    if enableProfiling then
        OrigProfilerExitScope()
    end
end

function warningText(where, what)
    ProfilerEnterScope('demmylock:warningText')
    SetDrawOrigin(where)
    BeginTextCommandDisplayText('STRING')
    SetTextCentre(true)
    SetTextOutline()
    SetTextColour(255, 0, 0, 128)
    SetTextScale(0.5, 0.5)
    AddTextComponentSubstringPlayerName(tostring(what))
    EndTextCommandDisplayText(0.0, 0.0)
    ClearDrawOrigin()
    ProfilerExitScope()
end

function adjustRatio(target, current)
    
    local diff = current - target
    if diff < -1.0 or diff > 1.0 then
        return target
    end

    local set = target

    if diff > 0.15 then
        set = current - CONFIG.doorSpeed * GetFrameTime()
    elseif diff < -0.15 then
        set = current + CONFIG.doorSpeed * GetFrameTime()
    end

    return set
end

function getDoorObject(doorData)
    ProfilerEnterScope('demmylock:getDoorObject')
    if not doorData.doorObject or not DoesEntityExist(doorData.doorObject) then
        local candidate = GetClosestObjectOfType(doorData.coords, 0.5, doorData.model, false, false, false)
        if DoesEntityExist(candidate) then
            doorData.doorObject = candidate
        end
    end
    ProfilerExitScope()
    return doorData.doorObject
end

function handleDoorRange(door, pedLocation)
    ProfilerEnterScope('demmylock:handleDoorRange')
    if not door.systemHash then
        return false
    end

    local distance = #(door.coords - pedLocation)
    if door.keeploaded or distance < CONFIG.range.doorLoad then
        if not IsDoorRegisteredWithSystem(door.systemHash) then
            AddDoorToSystem(door.systemHash, door.model, door.coords.x, door.coords.y, door.coords.z,
                false,
                true, -- Force closed when locked?
                true
            )
        end
    else
        if IsDoorRegisteredWithSystem(door.systemHash) then
            RemoveDoorFromSystem(door.systemHash)
        end
        ProfilerExitScope()
        return false
    end

    ProfilerExitScope()
    return true

end

function handleLock(pedLocation, areaName, lockName, data, isInteracting)
    ProfilerEnterScope('demmylock:handleLock')
    local doorCount = 0
    local r,g,b,a = table.unpack(CONFIG.indicator.color.locked)
    local busy = false

    if data.locked then
        ProfilerEnterScope('demmylock:handleLock:locked')
        if data.doors then
            for index, door in ipairs(data.doors) do
                
                local relevant = handleDoorRange(door, pedLocation)
                if relevant then
                    
                    doorCount = doorCount + 1

                    local state = DoorSystemGetDoorState(door.systemHash)

                    if state ~= STATE_LOCKED then
                        DoorSystemSetDoorState(door.systemHash, STATE_LOCKED, true, true)
                    end

                    local ratio = DoorSystemGetOpenRatio(door.systemHash)
                    local adjusted = adjustRatio(0.0, ratio)
                    if not door.wasAdjusted or door.wasAdjusted ~= adjusted then
                        door.wasAdjusted = adjusted
                        DoorSystemSetOpenRatio(door.systemHash, adjusted, false, true)
                    else
                        DoorSystemSetOpenRatio(door.systemHash, 0.0, false, true)
                    end
                end
            end
        end
        if data.entitySets then
            local refresh = false
            if not data.entitySets.interiorID then
                data.entitySets.interiorID = GetInteriorAtCoords(data.entitySets.interior)
            end
            if data.entitySets.open then
                for _, name in ipairs(data.entitySets.open) do
                    if IsInteriorEntitySetActive(data.entitySets.interiorID, name) then
                        DeactivateInteriorEntitySet(data.entitySets.interiorID, name)
                        refresh = true
                    end
                end
            end
            if data.entitySets.locked then
                for _, name in ipairs(data.entitySets.locked) do
                    if not IsInteriorEntitySetActive(data.entitySets.interiorID, name) then
                        ActivateInteriorEntitySet(data.entitySets.interiorID, name)
                        refresh = true
                    end
                end
            end
            if refresh then
                RefreshInterior(data.entitySets.interiorID)
            end
        end
        ProfilerExitScope()
    else
        ProfilerEnterScope('demmylock:handleLock:unlocked')

        if data.doors then
            for index, door in ipairs(data.doors) do

                local relevant = handleDoorRange(door, pedLocation)

                if relevant then
                    doorCount = doorCount + 1
                    local state = DoorSystemGetDoorState(door.systemHash)
                    if door.open then
                        if state ~= STATE_OPEN_FORCED then
                            DoorSystemSetDoorState(door.systemHash, STATE_OPEN_FORCED, true, true)
                        end
                        
                        local ratio = DoorSystemGetOpenRatio(door.systemHash)
                        local adjusted = adjustRatio(door.open, ratio)
                        if not door.wasAdjusted or door.wasAdjusted ~= adjusted then
                            door.wasAdjusted = adjusted
                            DoorSystemSetOpenRatio(door.systemHash, adjusted, false, true)
                        end
                    else
                        if state ~= STATE_OPEN then
                            DoorSystemSetDoorState(door.systemHash, STATE_OPEN, true, true)
                        end
                    end
                end
            end
        end

        if data.entitySets then
            local refresh = false
            local interior = GetInteriorAtCoords(data.entitySets.interior)
            if data.entitySets.open then
                for _, name in ipairs(data.entitySets.open) do
                    if not IsInteriorEntitySetActive(interior, name) then
                        ActivateInteriorEntitySet(interior, name)
                        refresh = true
                    end
                end
            end
            if data.entitySets.locked then
                for _, name in ipairs(data.entitySets.locked) do
                    if IsInteriorEntitySetActive(interior, name) then
                        DeactivateInteriorEntitySet(interior, name)
                        refresh = true
                    end
                end
            end
            if refresh then
                RefreshInterior(interior)
            end
        end

        if data.relock then
            r,g,b,a = table.unpack(CONFIG.indicator.color.busy)
            busy = true
        elseif data.teleport then
            r,g,b,a = table.unpack(CONFIG.indicator.color.magic)
            busy = true
        else
            r,g,b,a = table.unpack(CONFIG.indicator.color.open)
        end
        ProfilerExitScope()
    end

    if drivingVehicle and data.locked and data.vehicleSensors then

        for _, sensor in ipairs(data.vehicleSensors) do

            if DEBUGAREAS then
                warningText(sensor.coords,'SENSOR')
                bubble(sensor.coords, CONFIG.range.vehicleSensor)
            end

            local range = sensor.range
            if not range then
                range = CONFIG.range.vehicleSensors
            end

            if #(pedLocation - sensor.coords) <= CONFIG.range.vehicleSensor then
                if not sensor.tripped then
                    sensor.tripped = true

                    local key = getLastKey(areaName, lockName)
                    if key and string.len(key) > 0 then
                        TriggerServerEvent('demmylock:entered-pin', areaName, lockName, key, false)
                    end
                end
            else
                if sensor.tripped then
                    sensor.tripped = nil
                end
            end
        end

    end

    if data.keypads then
        for _,keypad in ipairs(data.keypads) do
            ProfilerEnterScope('demmylock:handleLock:keypads')
            local markerLocation
            if keypad.markerLocation then
                markerLocation = keypad.markerLocation
            else
                markerLocation = GetOffsetFromEntityInWorldCoords(keypad.object, CONFIG.indicator.offset)
            end

            if keypad.door and not IsEntityAttached(keypad.object) then
                ProfilerEnterScope('demmylock:handleLock:keypads:notAttached')
                local door = data.doors[keypad.door]
                local doorObject = getDoorObject(door)
                if DoesEntityExist(doorObject) then
                    AttachEntityToEntity(
                        keypad.object,
                        doorObject,
                        -1,
                        keypad.offset,
                        keypad.rot,
                        false, --p9 --[[ boolean ]],
                        false, --useSoftPinning --[[ boolean ]],
                        false, --collision --[[ boolean ]],
                        false, --isPed --[[ boolean ]],
                        0, --vertexIndex --[[ integer ]],
                        true --fixedRot --[[ boolean ]]
                    )
                end
                ProfilerExitScope()
            end

            local keypadRotation
            if keypad.markerLocation then
                keypadRotation = keypad.rot
            else
                keypadRotation = GetEntityRotation(keypad.object, 2)
            end

            DrawMarker(
                CONFIG.indicator.type,
                markerLocation,
                0.0, 0.0, 0.0, -- Direction
                keypadRotation,
                CONFIG.indicator.scale.x,
                CONFIG.indicator.scale.y,
                CONFIG.indicator.scale.z,
                r, g, b, a,
                false, -- bob
                false, -- face camera
                2, -- Cargo cult. Rotation order?
                false, -- rotate
                0, 0, -- Texture
                false -- Project
            )

            local keypadLocation
            if keypad.coords then
                keypadLocation = keypad.coords
            else
                keypadLocation = GetEntityCoords(keypad.object,false)
            end

            if not isInteracting and #(keypadLocation - pedLocation) < CONFIG.range.interact then
                if not busy then
                    ProfilerEnterScope('demmylock:handleLocks:interact')
                    isInteracting = true

                    if not data.lastKey then
                        getLastKey(areaName, lockName)
                    end

                    if data.lastKey and string.len(data.lastKey) > 0 then
                        BeginTextCommandDisplayHelp('DEMMYLOCK_REUSE')
                    else
                        BeginTextCommandDisplayHelp('DEMMYLOCK_INTERACT')
                    end
                    AddTextComponentSubstringPlayerName(lockName)
                    EndTextCommandDisplayHelp(0, false, false, 0)

                    if IsControlJustPressed(0, 51) then
                        if data.lastKey and string.len(data.lastKey) > 0 and not IsControlPressed(0, 19) then
                            TriggerServerEvent('demmylock:entered-pin', areaName, lockName, data.lastKey, not data.locked)
                        else
                            ShowKeypad(areaName, lockName, data.lastKey, not data.locked)
                        end
                    end
                    ProfilerExitScope()
                elseif data.teleport and data.destination and data.teleport[data.destination] then
                    local target = data.teleport[data.destination]
                    BeginTextCommandDisplayHelp('DEMMYLOCK_TELEPORT')
                    AddTextComponentSubstringPlayerName(lockName)
                    EndTextCommandDisplayHelp(0, false, false, 0)
                    if IsControlJustPressed(0, 51) then
                        DoScreenFadeOut(CONFIG.fadeTime)
                        if target.ipl then
                            if not IsIplActive(target.ipl) then
                                RequestIpl(target.ipl)
                                while not IsIplActive(target.ipl) do
                                    Citizen.Wait(0)
                                end
                            end
                        end
                        while not IsScreenFadedOut() do
                            Citizen.Wait(0)
                        end
                        local camHeading = GetGameplayCamRelativeHeading()
                        local camPitch = GetGameplayCamRelativePitch()
                        SetEntityCoordsNoOffset(playerPed, target.coords, false, false, false)
                        SetEntityHeading(playerPed, target.heading)
                        SetGameplayCamRelativeHeading(camHeading)
                        SetGameplayCamRelativePitch(camPitch, 1.0)
                        DoScreenFadeIn(CONFIG.fadeTime)
                    end
                end
            end
            ProfilerExitScope()
        end
    end
    ProfilerExitScope()
    return isInteracting, doorCount
end

RegisterNetEvent('demmylock:lock')
AddEventHandler ('demmylock:lock', function(areaName, lockName)
    if LOCKS[areaName] and LOCKS[areaName][lockName] then
        LOCKS[areaName][lockName].locked = true
        LOCKS[areaName][lockName].destination = null
        if LOCKS[areaName][lockName].vehicleSensors then
            for _,sensor in ipairs(LOCKS[areaName][lockName].vehicleSensors) do
                sensor.tripped = nil
            end
        end
    else
        log('Lock could not find lock',areaName,'/',lockName)
    end
end)

RegisterNetEvent('demmylock:unlock')
AddEventHandler ('demmylock:unlock', function(areaName, lockName, destination)
    if LOCKS[areaName] and LOCKS[areaName][lockName] then
        LOCKS[areaName][lockName].locked = false
        LOCKS[areaName][lockName].destination = destination
    else
        log('Unlock could not find lock',areaName,'/',lockName)
    end
end)

RegisterNetEvent('demmylock:wrong-code')
AddEventHandler ('demmylock:wrong-code', function(areaName, lockName)
    if LOCKS[areaName] and LOCKS[areaName][lockName] then
        log('Your code for',areaname, lockName, 'was wrong.')
        setLastKey(areaName, lockName, nil)
    end
end)

RegisterNetEvent('demmylock:lock-state')
AddEventHandler ('demmylock:lock-state', function(lockState)
    gotLockState = true
    log('Got lock state from server')
    for areaName, areaData in pairs(lockState) do
        for lockName, state in pairs(areaData) do
            if LOCKS[areaName] and LOCKS[areaName][lockName] then
                LOCKS[areaName][lockName].locked = state
            end
        end
    end
end)

AddEventHandler('demmylock:enter-area', function(areaName)
    withModel(CONFIG.keypad, function()
        for lockName, lockData in pairs(LOCKS[areaName]) do
            if lockData.keypads then
                for _, keypad in ipairs(lockData.keypads) do
                    local object
                    if keypad.door then
                        local door = lockData.doors[keypad.door]
                        object = CreateObjectNoOffset(CONFIG.keypad, door.coords + keypad.offset, false, false, false)

                        local doorObject = getDoorObject(door)
                        if DoesEntityExist(doorObject) then
                            AttachEntityToEntity(
                                object,
                                doorObject,
                                -1,
                                keypad.offset,
                                keypad.rot,
                                false, --p9 --[[ boolean ]],
                                false, --useSoftPinning --[[ boolean ]],
                                false, --collision --[[ boolean ]],
                                false, --isPed --[[ boolean ]],
                                0, --vertexIndex --[[ integer ]],
                                true --fixedRot --[[ boolean ]]
                            )
                        end
                    else
                        object = CreateObjectNoOffset(CONFIG.keypad, keypad.coords, false, false, false)
                        SetEntityRotation(object, keypad.rot, 2, true)
                        if not keypad.markerLocation then
                            keypad.markerLocation = GetOffsetFromEntityInWorldCoords(object, CONFIG.indicator.offset)
                        end
                    end
                    keypad.object = object
                end
            end
            if lockData.doors then
                for index,door in ipairs(lockData.doors) do
                    if not door.systemHash then
                        door.systemHash = GetHashKey(areaName..'_'..lockName..'_'..index)
                    end
                    if door.keeploaded and not IsDoorRegisteredWithSystem(door.systemHash) then
                        AddDoorToSystem(door.systemHash, door.model, door.coords.x, door.coords.y, door.coords.z,
                            false,
                            true, -- Force closed when locked?
                            false
                        )
                    end
                    DoorSystemSetDoorState(door.systemHash, STATE_LOCKED, true, true)
                    DoorSystemSetOpenRatio(door.systemHash, 0.0, false, true)
                end
            end
        end
    end)
end)

AddEventHandler('demmylock:exit-area', function(areaName)
    for lockName, lockData in pairs(LOCKS[areaName]) do
        if lockData.keypads then
            for _, keypad in ipairs(lockData.keypads) do
                DeleteObject(keypad.object)
                keypad.object = nil
            end
        end
        if lockData.doors then
            for _, door in ipairs(lockData.doors) do
                if IsDoorRegisteredWithSystem(door.systemHash) then
                    RemoveDoorFromSystem(door.systemHash)
                end
            end
        end
    end
end)

AddEventHandler('onResourceStop', function(resoureName)
    if resoureName == GetCurrentResourceName() then
        for areaName, state in pairs(inArea) do
            if state and LOCKS[areaName] then
                for lockName, data in pairs(LOCKS[areaName]) do
                    for _, keypad in ipairs(data.keypads) do
                        if DoesEntityExist(keypad.object) then
                            DeleteObject(keypad.object)
                        end
                    end
                    if data.doors then
                        for _, door in ipairs(data.doors) do
                            if IsDoorRegisteredWithSystem(door.systemHash) then
                                RemoveDoorFromSystem(door.systemHash)
                            end
                        end
                    end
                end
            end
        end
    end
end)

function bubble(center, size, r, g, b, a)
    DrawMarker(
        28,
        center,
        0.0,
        0.0,
        0.0,
        0.0,
        0.0,
        0.0,
        size,
        size,
        size,
        r or 255,
        g or 128,
        b or 0,
        a or 200,
        false, false, 2, 0, 0, false
    )
end

Citizen.CreateThread(function()
    while true do

        if not gotLockState then
            local now = GetGameTimer()
            if not requestedLockState or requestedLockState < now - 5000 then
                requestedLockState = GetGameTimer()
                log('Requesting lock state from server')
                TriggerServerEvent('demmylock:request-lock-state')
            end
        end

        local myLocation = GetFinalRenderedCamCoord()
        for areaName, center in pairs(CENTERS) do
            if DEBUGAREAS then
                bubble(center, SIZES[areaName])
            end
            if #( myLocation - center ) < (SIZES[areaName] or 0) then
                if not inArea[areaName] then
                    TriggerEvent('demmylock:enter-area', areaName)
                    inArea[areaName] = true
                end
            elseif inArea[areaName] then
                TriggerEvent('demmylock:exit-area', areaName)
                inArea[areaName] = nil
            end
            if not DEBUGAREAS then
                Citizen.Wait(0)
            end
        end
        playerPed = PlayerPedId()

        local vehicle = GetVehiclePedIsIn(playerPed, false)
        if vehicle ~= 0 then
            drivingVehicle = ( GetPedInVehicleSeat(vehicle, -1) == playerPed )
        else
            drivingVehicle = false
        end

        if DEBUGAREAS then
            Citizen.Wait(0)
        else
            Citizen.Wait(100)
        end
    end
end)

Citizen.CreateThread(function()
    while true do
        local myLocation = GetEntityCoords(playerPed)
        local isInteracting = IsKeypadShown()
        doorCountThisFrame = 0
        for areaName, state in pairs(inArea) do
            if state and LOCKS[areaName] then
                for lockName, data in pairs(LOCKS[areaName]) do
                    isInteracting, doorCount = handleLock(myLocation, areaName, lockName, data, isInteracting)
                    doorCountThisFrame = doorCountThisFrame + doorCount
                end
            end
        end
        if doorCountThisFrame > 20 then
            warningText(myLocation, 'High door count: '..doorCountThisFrame..'/20')
        end
        Citizen.Wait(0)
    end
end)
