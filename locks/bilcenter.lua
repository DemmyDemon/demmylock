AddLocks('Bilcenter',{
    ['Huvudingång'] = {
        locked = true,
        groupcode = true,
        doors = {
            {model=2059227086,coords=vector3(-39.134, -1108.218, 26.720)},
            {model=1417577297,coords=vector3(-37.331, -1108.873, 26.720)},
        },
        keypads = {
            {door=1,offset=vector3(0.837, 0.106, 0.053),rot=vector3(0.000, 0.000, 180.000)},
            {door=2,offset=vector3(-0.839, -0.105, 0.047),rot=vector3(0.000, 0.000, 0.000)},
        },
    },
    ['Chefskontoret'] = {
        locked = true,
        doors = {
            {model=-2051651622,coords=vector3(-33.810, -1107.579, 26.572)},
        },
        keypads = {
            {door=1,offset=vector3(-1.154, 0.050, 0.065),rot=vector3(-0.000, -0.000, -180.000)},
            {door=1,offset=vector3(-1.155, -0.050, 0.068),rot=vector3(0.000, -0.000, 0.000)},
        },
    },
    ['Försäljningskontroret'] = {
        locked = true,
        groupcode = true,
        doors = {
            {model=-2051651622,coords=vector3(-31.724, -1101.847, 26.572)},
        },
        keypads = {
            {door=1,offset=vector3(-1.155, 0.050, 0.068),rot=vector3(-0.000, -0.000, -180.000)},
            {door=1,offset=vector3(-1.156, -0.050, 0.068),rot=vector3(0.000, -0.000, 0.000)},
        },
    },
    ['Sidoingång'] = {
        locked = true,
        groupcode = true,
        doors = {
            {model=2059227086,coords=vector3(-59.893, -1092.952, 26.884)},
            {model=1417577297,coords=vector3(-60.546, -1094.749, 26.889)},
        },
        keypads = {
            {door=1,offset=vector3(0.839, 0.106, 0.050),rot=vector3(0.000, 0.000, 180.000)},
            {door=2,offset=vector3(-0.837, -0.105, 0.046),rot=vector3(0.000, 0.000, -0.000)},
        },
    },
    ['Porten'] = {
        locked = true,
        groupcode = true,
        entitySets = {
            interior = vector3(-29.936, -1088.536, 26.422),
            open = {'shutter_open'},
            locked = {'shutter_closed'},
        },
        keypads = {
            {coords=vector3(-32.108, -1085.724, 26.876),rot=vector3(0.000, -0.000, -20.242)},
            {coords=vector3(-31.729, -1085.350, 26.876),rot=vector3(0.028, -0.020, 69.972)},
        },
    },
})