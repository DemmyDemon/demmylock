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
        },
    },
    closeSpeed = 200.0,
    range = {
        areaMargin = 20.0,
        interact = 0.7,
    },
}
