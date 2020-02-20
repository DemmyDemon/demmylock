AddLocks('Tvättaren',{
    ['Ingång'] = {
        locked = true,
        teleport = {
            {coords=vector3(1138.094, -3198.748, -39.661),heading=27.598},
        },
        keypads = {
            {coords=vector3(834.162, -1168.815, 26.024),rot=vector3(0.046, 0.043, -86.968)},
        }
    }
})
AddLocks('Tvättstugan', {
    ['Utgång'] = {
        locked = false, -- Exit is always open!
        destination = 1,
        teleport = {
            {coords=vector3(833.162, -1168.575, 25.268),heading=63.248},
        },
        keypads = {
            {coords=vector3(1137.229, -3199.448, -39.548),rot=vector3(0.000, -0.000, 180.000)},
        },
    },
})