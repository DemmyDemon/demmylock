local inArea = {}
local ped = PlayerPedId()
local lastKey
local gotLockState = false

AddTextEntry('DEMMYLOCK_INTERACT', '~a~~n~~INPUT_CONTEXT~ Keypad')
AddTextEntry('DEMMYLOCK_REUSE', '~a~~n~~INPUT_CONTEXT~ Reuse key ~n~~INPUT_SPRINT~+~INPUT_CONTEXT~ Keypad')

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


function adjustDoorAngle(target, current)
    ProfilerEnterScope('demmylock:adjustDoorAngle')

    local diff = current - target
    local set = target
    
    if diff > 180 then
        set = current + CONFIG.closeSpeed * GetFrameTime()
    elseif diff > 2.5 then
        set = current - CONFIG.closeSpeed * GetFrameTime()
    elseif diff < -180 then
        set = current - CONFIG.closeSpeed * GetFrameTime()
    elseif diff < -2.5 then
        set = current + CONFIG.closeSpeed * GetFrameTime()
    end

    ProfilerExitScope()
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

function handleLock(pedLocation, areaName, lockName, data, isInteracting)
    ProfilerEnterScope('demmylock:handleLock')
    local r,g,b,a = table.unpack(CONFIG.indicator.color.locked)
    local busy = false

    if data.locked then
        ProfilerEnterScope('demmylock:handleLock:locked')
        if data.doors then
            for _,doorData in ipairs(data.doors) do
                local door = getDoorObject(doorData)
                local doorAngle = GetEntityHeading(door)
                if doorAngle ~= doorData.heading then
                    FreezeEntityPosition(door, true)
                    SetEntityHeading(door, adjustDoorAngle(doorData.heading, doorAngle))
                end
            end
        end
        if data.entitySets then
            local refresh = false
            local interior = GetInteriorAtCoords(data.entitySets.interior)
            if data.entitySets.open then
                for _, name in ipairs(data.entitySets.open) do
                    if IsInteriorEntitySetActive(interior, name) then
                        DeactivateInteriorEntitySet(interior, name)
                        refresh = true
                    end
                end
            end
            if data.entitySets.locked then
                for _, name in ipairs(data.entitySets.locked) do
                    if not IsInteriorEntitySetActive(interior, name) then
                        ActivateInteriorEntitySet(interior, name)
                        refresh = true
                    end
                end
            end
            if refresh then
                RefreshInterior(interior)
            end
        end
        ProfilerExitScope()
    else
        ProfilerEnterScope('demmylock:handleLock:unlocked')
        if data.doors then
            for _,doorData in ipairs(data.doors) do
                FreezeEntityPosition(getDoorObject(doorData), false)
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
        else
            r,g,b,a = table.unpack(CONFIG.indicator.color.open)
        end
        ProfilerExitScope()
    end

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

        if not busy and not isInteracting and #(keypadLocation - pedLocation) < CONFIG.range.interact then
            ProfilerEnterScope('demmylock:handleLocks:interact')
            isInteracting = true

            if not lastKey then
                lastKey = GetResourceKvpString('demmylock:'..areaName..':'..lockName)
                if not lastKey then
                    lastKey = ''
                end
            end

            if lastKey and string.len(lastKey) > 0 then
                BeginTextCommandDisplayHelp('DEMMYLOCK_REUSE')
            else
                BeginTextCommandDisplayHelp('DEMMYLOCK_INTERACT')
            end
            AddTextComponentSubstringPlayerName(lockName)
            EndTextCommandDisplayHelp(0, false, false, 0)

            if IsControlJustPressed(0, 51) then
                if lastKey and string.len(lastKey) > 0 and not IsControlPressed(0, 21) then
                    TriggerServerEvent('demmylock:entered-pin', areaName, lockName, lastKey, not data.locked)
                else
                    ShowKeypad(areaName, lockName, lastKey, not data.locked)
                end
            end
            ProfilerExitScope()
        elseif lastKey then
            lastKey = nil
        end
        ProfilerExitScope()
    end
    ProfilerExitScope()
    return isInteracting
end

RegisterNetEvent('demmylock:lock')
AddEventHandler ('demmylock:lock', function(areaName, lockName)
    if LOCKS[areaName] and LOCKS[areaName][lockName] then
        LOCKS[areaName][lockName].locked = true
    else
        Citizen.Trace('Lock could not find lock '..tostring(areaName)..'/'..tostring(lockName))
    end
end)

RegisterNetEvent('demmylock:unlock')
AddEventHandler ('demmylock:unlock', function(areaName, lockName)
    if LOCKS[areaName] and LOCKS[areaName][lockName] then
        LOCKS[areaName][lockName].locked = false
    else
        Citizen.Trace('Unlock could not find lock '..tostring(areaName)..'/'..tostring(lockName))
    end
end)

RegisterNetEvent('demmylock:wrong-code')
AddEventHandler ('demmylock:wrong-code', function(areaName, lockName)
    DeleteResourceKvp('demmylock:'..areaName..':'..lockName)
    lastKey = nil
end)

RegisterNetEvent('demmylock:lock-state')
AddEventHandler ('demmylock:lock-state', function(lockState)
    gotLockState = true
    for areaName, areaData in pairs(lockState) do
        for lockName, lockState in pairs(areaData) do
            if LOCKS[areaName] and LOCKS[areaName][lockName] then
                LOCKS[areaName][lockName].locked = lockState
            end
        end
    end
end)

AddEventHandler('demmylock:enter-area', function(areaName)
    withModel(CONFIG.keypad, function()
        for doorName, doorData in pairs(LOCKS[areaName]) do
            for _, keypad in ipairs(doorData.keypads) do
                local object
                if keypad.door then
                    local door = doorData.doors[keypad.door]
                    object = CreateObjectNoOffset(CONFIG.keypad, door.coords + keypad.offset, false, false, false)
                    
                    local doorObject = getDoorObject(door) --GetClosestObjectOfType(door.coords, 0.5, door.model, false, false, false)
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
    end)
end)

AddEventHandler('demmylock:exit-area', function(areaName)
    for doorName, doorData in pairs(LOCKS[areaName]) do
        for _, keypad in ipairs(doorData.keypads) do
            DeleteObject(keypad.object)
            keypad.object = nil
        end
        for _, door in ipairs(doorData) do
            door.doorObject = nil
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
                end
            end
        end
    end
end)

Citizen.CreateThread(function()
    while true do
        if not gotLockState then
            TriggerServerEvent('demmylock:request-lock-state')
        end
        local myLocation = GetFinalRenderedCamCoord()
        for areaName, center in pairs(CENTERS) do
            if #( myLocation - center ) < CONFIG.range.area then
                if not inArea[areaName] then
                    TriggerEvent('demmylock:enter-area', areaName)
                    inArea[areaName] = true
                end
            elseif inArea[areaName] then
                TriggerEvent('demmylock:exit-area', areaName)
                inArea[areaName] = nil
            end
            Citizen.Wait(0)
        end
        Citizen.Wait(1000)
    end
end)

Citizen.CreateThread(function()
    while true do
        local ped = PlayerPedId()
        local myLocation = GetEntityCoords(ped)
        local isInteracting = IsKeypadShown()
        for areaName, state in pairs(inArea) do
            if state and LOCKS[areaName] then
                for lockName, data in pairs(LOCKS[areaName]) do
                    isInteracting = handleLock(myLocation, areaName, lockName, data, isInteracting)
                end
            end
        end
        Citizen.Wait(0)
    end
end)