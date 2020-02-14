LOCKS = {
    ['Rooftop'] = {
        ['Elevator access'] = {
            locked = true,
            teleport = {
                {coords=vector3(-39.115, -1082.494, 26.422),heading=-114.0,ipl='shr_int'},
                {coords=vector3(15.885, -1032.378, 29.431),heading=-160.0},
            },
            keypads = {
                {coords=vector3(4.300, -1000.386, 86.236),rot=vector3(0.000, -0.001, 159.522)},
            },
        },
    },
    ['Alley'] = {
        ['Elevator'] = {
            locked = true,
            teleport = {
                {coords=vector3(3.713, -999.454, 86.035),heading=-20.0},
            },
            keypads = {
                {coords=vector3(15.296, -1031.674, 29.731),rot=vector3(0.000, 0.000, -20.00)},
            },
        },
    },
    ['Car dealership'] = {
        ['Boss office'] = {
            locked = true,
            doors = {
                {model=-2051651622,coords=vector3(-33.810, -1107.579, 26.572),heading=70.000},
            },
            keypads = {
                {door=1,offset=vector3(-1.159, -0.050, 0.068),rot=vector3(0.000, -0.000, 0.000)},
                {door=1,offset=vector3(-1.147, 0.050, 0.073),rot=vector3(-0.000, -0.000, -180.000)},
            },
        },
        ['Sales office'] = {
            locked = true,
            doors = {
                {model=-2051651622,coords=vector3(-31.724, -1101.847, 26.572),heading=70.000},
            },
            keypads = {
                {door=1,offset=vector3(-1.150, 0.050, 0.065),rot=vector3(-0.000, -0.000, -180.000)},
                {door=1,offset=vector3(-1.151, -0.050, 0.069),rot=vector3(0.000, -0.000, 0.000)},
            },
        },
        ['Front door'] = {
            locked = true,
            doors = {
                {model=2059227086,coords=vector3(-39.134, -1108.218, 26.720),heading=340.000},
                {model=1417577297,coords=vector3(-37.331, -1108.873, 26.720),heading=340.000},   
            },
            keypads = {
                {door=1,offset=vector3(0.84, 0.1, 0.034),rot=vector3(0.000, 0.000, 180.000)},
                {door=2,offset=vector3(-0.84, -0.1, 0.031),rot=vector3(0.000, 0.000, 0.000)},
            },
        },
        ['Side door'] = {
            locked = true,
            doors = {
                {model=1417577297,coords=vector3(-60.546, -1094.749, 26.889),heading=250.047},
                {model=2059227086,coords=vector3(-59.893, -1092.952, 26.884),heading=250.154},
            },
            keypads = {
                {door=2,offset=vector3(0.841, 0.105, 0.036),rot=vector3(-0.000, 0.000, 179.955)},
                {door=1,offset=vector3(-0.840, -0.104, 0.044),rot=vector3(-0.000, -0.000, -0.052)},
            },
        },
        ['Back gate'] = {
            locked = true,
            entitySets = {
                interior = vector3(-30.0, -1090.0, 26.0),
                open = {'shutter_open'},
                locked = {'shutter_closed'},
            },
            keypads = {
                {coords=vector3(-31.993, -1085.766, 26.860),rot=vector3(0.000, -0.000, -20.241)},
                {coords=vector3(-31.788, -1085.540, 26.860),rot=vector3(0.000, -0.000, 69.679)},
            },
        },
        ['Magic door'] = {
            locked = true,
            teleport = {
                {coords=vector3(3.713, -999.454, 86.035),heading=-20.0},
            },
            keypads = {
                {coords=vector3(-39.837, -1082.702, 26.730),rot=vector3(0.000, 0.000, 70.000)},
            },
        },
    },
    ['Mission row'] = {
        ['Armory'] = {
            locked = true,
            relock = 5000,
            doors = {
                {model=749848321,coords=vector3(453.079, -983.190, 30.839),heading=270.000},
            },
            keypads = {
                {coords=vector3(452.916, -981.756, 31.032),rot=vector3(-0.000, -0.000, -90.000)},
                {coords=vector3(453.243, -981.664, 30.911),rot=vector3(0.000, 0.000, 90.000)},
            }
        },
        ['Lobby'] = {
            locked = false,
            doors = {
                {model=-1215222675,coords=vector3(434.748, -980.618, 30.839),heading=270.000},
                {model=320433149,coords=vector3(434.748, -983.215, 30.839),heading=270.000},
            },
            keypads = {
                {coords=vector3(434.190, -984.979, 31.005),rot=vector3(0.000, 0.000, -90.000)},
                {coords=vector3(434.969, -985.029, 30.503),rot=vector3(0.000, 0.000, 90.000)},
            },
        },
        ['Lobby stairs'] = {
            locked = true,
            relock = 5000,
            doors = {
                {model=185711165,coords=vector3(446.008, -989.445, 30.839),heading=359.771},
                {model=185711165,coords=vector3(443.408, -989.445, 30.839),heading=180.176},
            },
            keypads = {
                {door=1,offset=vector3(-1.058, -0.049, -0.049),rot=vector3(0.000, -0.039, -0.044)},
                {coords=vector3(446.418, -989.151, 30.898),rot=vector3(0.000, -0.000, 180.000)},
            },
        },
        ['Cell 1'] = {
            locked = true,
            relock = 5000,
            doors = {
                {model=631614199,coords=vector3(461.807, -994.409, 25.064),heading=270.000},
            },
            keypads = {
                {door=1,offset=vector3(-1.116, 0.054, 0.017),rot=vector3(0.000, 0.000, 180.000)},
            },
        },
        ['Cell 2'] = {
            locked = true,
            relock = 5000,
            doors = {
                {model=631614199,coords=vector3(461.806, -997.658, 25.064),heading=90.000},
            },
            keypads = {
                {door=1,offset=vector3(-1.113, -0.054, 0.004),rot=vector3(0.000, 0.000, 0.000)},
            },
        },
        ['Cell 3'] = {
            locked = true,
            relock = 5000,
            doors = {
                {model=631614199,coords=vector3(461.807, -1001.302, 25.064),heading=90.000},
            },
            keypads = {
                {door=1,offset=vector3(-1.112, -0.054, 0.004),rot=vector3(0.000, 0.000, 0.000)},
            },
        },
        ['Cellblock front'] = {
            locked = true,
            relock = 5000,
            doors = {
                {model=631614199,coords=vector3(464.570, -992.664, 25.064),heading=359.727},
            },
            keypads = {
                {door=1,offset=vector3(-1.157, 0.053, 0.011),rot=vector3(0.000, -0.002, 180.042)},
                {door=1,offset=vector3(-1.161, -0.054, 0.003),rot=vector3(-0.000, 0.000, 0.041)},
            },
        },
        ['Backdoor'] = {
            locked = true,
            teleport = {
                {coords=vector3(452.113, -988.510, 26.674),heading=0.0},
            },
            keypads = {
                {coords=vector3(453.191, -993.336, 26.502),rot=vector3(0.000, -0.000, -0.000)},
            },
        },
        ['Garage'] = {
            locked = true,
            teleport = {
                {coords=vector3(452.434, -993.848, 26.004),heading=180.0},
            },
            keypads = {
                {coords=vector3(451.824, -988.983, 26.910),rot=vector3(0.000, -0.000, 180.000)},
            },
        },
    },
}
CENTERS = {}
for locationName, locationData in pairs(LOCKS) do
    local center = vector3(0,0,0)
    local itemCount = 0
    for lockName, lockData in pairs(locationData) do
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
    center = center / itemCount
    CENTERS[locationName] = center
end
SIZES = {}
for locationName, locationData in pairs(LOCKS) do
    local maxDistance = 0
    for lockName, lockData in pairs(locationData) do
        if lockData.doors then
            for _, door in pairs(lockData.doors) do
                local distance = #( door.coords - CENTERS[locationName] )
                if distance > maxDistance then
                    maxDistance = distance
                end
            end
        end
        if lockData.keypads then
            for _, keypad in pairs(lockData.keypads) do
                if keypad.coords then
                    local distance = #( keypad.coords - CENTERS[locationName] )
                    if distance > maxDistance then
                        maxDistance = distance
                    end
                end
            end
        end
    end
    -- Citizen.Trace(string.format("Max distance for %s is %0.2f\n", locationName, maxDistance))
    SIZES[locationName] = maxDistance + CONFIG.range.areaMargin
end
