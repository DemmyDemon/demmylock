local visible = false

local BUTTONS = {
    key_1 = {
        at = vector2(0.4555,0.542),
        size = vector2(0.025,0.025),
        action = function(code)
            code = code .. '1'
            return code
        end,
    },
    key_2 = {
        at = vector2(0.4855, 0.542),
        size = vector2(0.025, 0.025),
        action = function(code)
            code = code .. '2'
            return code
        end,
    },
    key_3 = {
        at = vector2(0.5145, 0.542),
        size = vector2(0.025, 0.025),
        action = function(code)
            code = code .. '3'
            return code
        end,
    },
    key_red = {
        at = vector2(0.5445, 0.542),
        size = vector2(0.025, 0.025),
        action = function(code)
            return false
        end,
    },
    key_4 = {
        at = vector2(0.4555, 0.593),
        size = vector2(0.025,0.025),
        action = function(code)
            code = code .. '4'
            return code
        end,
    },
    key_5 = {
        at = vector2(0.4855, 0.593),
        size = vector2(0.025, 0.025),
        action = function(code)
            code = code .. '5'
            return code
        end,
    },
    key_6 = {
        at = vector2(0.5145, 0.593),
        size = vector2(0.025, 0.025),
        action = function(code)
            code = code .. '6'
            return code
        end,
    },
    key_green = {
        at = vector2(0.5445, 0.593),
        size = vector2(0.025, 0.025),
        action = function(code)
            return true
        end,
    },
    key_7 = {
        at = vector2(0.4555, 0.642),
        size = vector2(0.025,0.025),
        action = function(code)
            code = code .. '7'
            return code
        end,
    },
    key_8 = {
        at = vector2(0.4855, 0.642),
        size = vector2(0.025, 0.025),
        action = function(code)
            code = code .. '8'
            return code
        end,
    },
    key_9 = {
        at = vector2(0.5145, 0.642),
        size = vector2(0.025, 0.025),
        action = function(code)
            code = code .. '9'
            return code
        end,
    },
    key_blue = {
        at = vector2(0.5445, 0.642),
        size = vector2(0.025, 0.025),
        action = function(code)
            code = string.sub(code, 1, -2)
            return code
        end,
    },
    key_asterisk = {
        at = vector2(0.4555, 0.693),
        size = vector2(0.025,0.025),
        action = function(code)
            code = code .. '*'
            return code
        end,
    },
    key_0 = {
        at = vector2(0.4855, 0.693),
        size = vector2(0.025, 0.025),
        action = function(code)
            code = code .. '0'
            return code
        end,
    },
    key_pound = {
        at = vector2(0.5145, 0.693),
        size = vector2(0.025, 0.025),
        action = function(code)
            code = code .. '#'
            return code
        end,
    },
    key_yellow = {
        at = vector2(0.5445, 0.693),
        size = vector2(0.025, 0.025),
        action = function(code)
            return ''
        end,
    },
}

function loadTxd(txdName)
    if not HasStreamedTextureDictLoaded(txdName) then
        RequestStreamedTextureDict(txdName, true)
        while not HasStreamedTextureDictLoaded(txdName) do
            Citizen.Wait(0)
        end
    end
end

function disableControlsExcept(...)
    for group=0, 31 do
        DisableAllControlActions(group)
    end
    for _,control in ipairs({...}) do
        EnableControlAction(0, control, true)
    end
end

function IsKeypadShown()
    return visible
end

function ShowKeypad(area, door, lastKey, nextState)
    if visible then
        return
    end
    visible = true
    Citizen.CreateThread(function()
        local code = lastKey or ''
        while visible do
            disableControlsExcept(245, 249) -- Enable chat and voice PTT. TODO: Anything else?
            SetMouseCursorActiveThisFrame()
            loadTxd('demmylock')
            local aspect_ratio = GetAspectRatio(true)
            DrawSprite(
                'demmylock',
                'keypad',
                0.5, -- X
                0.5, -- Y
                0.5 / aspect_ratio, -- Width
                0.5, -- Height
                0.0, -- Rotation
                255, 255, 255, 255, -- Color
                true -- Dunno
            )

            local cursorX = GetDisabledControlNormal(0, 239)
            local cursorY = GetDisabledControlNormal(0, 240)
            local action = nil

            for name, data in pairs(BUTTONS) do
                local adjustedSize = vector2(data.size.x, data.size.y*aspect_ratio) / 2
                if 
                    cursorX > data.at.x - adjustedSize.x
                    and cursorX < data.at.x + adjustedSize.x
                    and cursorY > data.at.y - adjustedSize.y
                    and cursorY < data.at.y + adjustedSize.y
                then
                    --DrawRect(data.at, adjustedSize * 2, 255, 0, 0, 128)
                    action = data.action
                else
                    --DrawRect(data.at, adjustedSize * 2, 255, 255, 255, 128)
                end
            end

            if IsDisabledControlPressed(0, 177) then -- INPUT_CELLPHONE_CANCEL, Backspace
                visible = false
            elseif IsDisabledControlJustPressed(0, 24) then
                -- Citizen.Trace(cursorX..'/'..cursorY.."\n")
                if action then
                    local result = action(code)
                    if (type(result) == 'string') then
                        code = result
                        code = string.sub(code,-4)
                    elseif (type(result) == 'boolean') then
                        setLastKey(area, door, code)
                        TriggerServerEvent('demmylock:entered-pin', area, door, code, not result)
                        visible = false
                    end
                end
            elseif IsDisabledControlJustPressed(0, 51) then
                setLastKey(area, door,code)
                TriggerServerEvent('demmylock:entered-pin', area, door, code, nextState)
                visible = false
            end

            BeginTextCommandDisplayText('STRING')
            SetTextColour(0,0,0,200)
            SetTextScale(1.0,1.0)
            SetTextFont(0)
            SetTextCentre(true)
            AddTextComponentSubstringPlayerName(code)
            EndTextCommandDisplayText(0.5,0.37)

            Citizen.Wait(0)
        end
        SetStreamedTextureDictAsNoLongerNeeded('demmylock')
    end)
end
