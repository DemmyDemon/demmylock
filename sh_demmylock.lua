
LOCKS = {}
CENTERS = {}
SIZES = {}

function CalculateSizeAndCenter(area)
    if LOCKS[area] then
        local center = vector3(0,0,0)
        local itemCount = 0
        for lockName, lockData in pairs(LOCKS[area]) do
            if lockData.doors then
                for _, door in pairs(lockData.doors) do
                    itemCount = itemCount + 1
                    center = center + door.coords
                end
            end
            if lockData.keypads then
                for _, keypad in pairs(lockData.keypads) do
                    if keypad.coords then
                        itemCount = itemCount + 1
                        center = center + keypad.coords
                    end
                end
            end
        end
        if itemCount > 0 then
            center = center / itemCount
            CENTERS[area] = center
        end
        
        
        local maxDistance = 0
        for lockName, lockData in pairs(LOCKS[area]) do
            if lockData.doors then
                for _, door in pairs(lockData.doors) do
                    local distance = #( door.coords - CENTERS[area] )
                    if distance > maxDistance then
                        maxDistance = distance
                    end
                end
            end
            if lockData.keypads then
                for _, keypad in pairs(lockData.keypads) do
                    if keypad.coords then
                        local distance = #( keypad.coords - CENTERS[area] )
                        if distance > maxDistance then
                            maxDistance = distance
                        end
                    end
                end
            end
        end
        SIZES[area] = maxDistance + CONFIG.range.areaMargin
    end
end

function AddLocks(area, locks)
    if not LOCKS[area] then
        LOCKS[area] = {}
    end
    local added = 0
    local doorCount = 0
    for name, data in pairs(locks) do
        if LOCKS[area][name] then
            Citizen.Trace('DEMMYLOCK WARNING: Duplicate lock definiton for '..area..'/'..name..'\n')
        else
            if data.doors then
                doorCount = doorCount + #data.doors
            end
            added = added + 1
        end
        LOCKS[area][name] = data
    end
    if IsDuplicityVersion() then
        Citizen.Trace('Demmylock added '..added..' locks with '..doorCount..' doors to '..area..'\n')
    else
        CalculateSizeAndCenter(area)
    end
end
