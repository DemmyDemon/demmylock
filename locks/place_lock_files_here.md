# Lock files

Any files in this directory with a name that ends in .lua will automatically be loaded on both the client and the server. That makes this a great place to put your `AddLocks()` files!

For example, if you want to define the `Playboy Perimeter` locks, you make a file called `playboy.lua` and put this in it:

```lua
AddLocks('Playboy Perimeter',{
    ['Main Gate'] = {
        locked = true,
        groupcode = true,
        doors = {
            {model=-2125423493,coords=vector3(-1474.131, 68.388, 52.526),open=-1.0},
        },
        keypads = {
            {coords=vector3(-1467.704, 68.563, 53.653),rot=vector3(0.012, 0.265, -175.035)},
            {coords=vector3(-1467.732, 67.965, 53.653),rot=vector3(-0.012, 0.000, 4.965)},
        },
    },
    ['Side Gate'] = {
        locked = true,
        groupcode = true,
        doors = {
            {model=-2125423493,coords=vector3(-1616.233, 79.781, 60.775),open=-1.0},
        },
        keypads = {
            {coords=vector3(-1611.336, 75.693, 61.969),rot=vector3(0.016, 0.004, -30.984)},
            {coords=vector3(-1610.887, 76.130, 61.969),rot=vector3(-0.016, 0.058, 149.016)},
        },
    },
    ['Gate A'] = {
        locked = true,
        groupcode = true,
        doors = {
            {model=-1859471240,coords=vector3(-1462.425, 65.716, 53.387)},
        },
        keypads = {
            {coords=vector3(-1460.995, 65.902, 52.828),rot=vector3(0.015, -0.001, 9.460)},
            {coords=vector3(-1460.802, 66.003, 53.039),rot=vector3(-0.015, -0.183, -170.540)},
        }
    },
    ['Gate B'] = {
        locked = true,
        groupcode = true,
        doors = {
            {model=-1859471240,coords=vector3(-1441.727, 171.910, 56.065)},
        },
        keypads = {
            {coords=vector3(-1441.000, 173.252, 55.830),rot=vector3(0.017, 0.030, -119.595)},
            {coords=vector3(-1440.943, 173.195, 55.552),rot=vector3(-0.017, 0.010, 60.405)},
        }
    },
    ['Gate C'] = {
        locked = true,
        doors = {
            {model=-1859471240,coords=vector3(-1434.006, 235.013, 60.371)},
        },
        keypads = {
            {coords=vector3(-1435.013, 236.195, 60.126),rot=vector3(-0.001, -0.000, -50.532)},
            {coords=vector3(-1434.893, 236.182, 59.834),rot=vector3(0.001, -0.002, 129.468)},
        },
    },
})
```

Now all you have to do is define the codes over in the [codes directory](../codes/place_code_files_here.md)!

# Match your codes!

Make absolutely sure that the area name (`Playboy Perimeter` in this example) matches the [code file](../locks/place_lock_files_here.md) you set up **exactly**. It's even CaSe SeNsItIvE!