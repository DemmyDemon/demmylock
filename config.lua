CONFIG = {
    keypad = `prop_ld_keypad_01`,
    indicator = {
        type = 43,
        offset = vector3(0.0,-0.009, 0.017),
        scale = vector3(0.1,0.001,0.07),
        color = {
            locked = {255, 0, 0, 255},
            open = {0, 255, 0, 255},
            busy = {255, 255, 0, 255},
            magic = {200, 00, 255, 255},
        },
    },
    teleportTime = 5000,
    doorSpeed = 1.0,
    fadeTime = 300,
    range = {
        areaMargin = 50.0,
        interact = 1.0,
        doorLoad = 10.0,
        vehicleSensor = 5.0,
    },
}
