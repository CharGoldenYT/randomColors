---@funkinScript
luaDebugMode = true

require('mods/randomColors/scripts/colorTables')

--[[
    This script functions as the creation method for the notes settings!
]]
function onCreate()
    setProperty("skipCountdown", true)
    setProperty('boyfriend.visible', false)
    setProperty('dad.visible', false)
    setProperty('gf.visible', false)
    setProperty("camHUD.visible", false)
end

function onSongStart()
    openCustomSubstate('test', true)
end

function onCustomSubstateUpdate(name, elapsed)
     if keyboardJustPressed('BACKSPACE') and name == 'test' then
            exitSong(false)
     end
     if keyboardJustPressed('R') and name == 'test' then
            closeCustomSubstate()
     end
end

function onCustomSubstateDestroy(name)
     if name == 'test' then
        loadColorsToFile()
        restartSong(true)
     end
end

local filePaths = {
    'global/colors',
    'global/colorsWhite',
    'global/colorsDark',
    'left/colors',
    'left/colorsDark',
    'left/colorsWhite',
    'down/colors',
    'down/colorsDark',
    'down/colorsWhite',
    'up/colors',
    'up/colorsDark',
    'up/colorsWhite',
    'right/colors',
    'right/colorsDark',
    'right/colorsWhite'
}

function openSubState(name) {
    --openCustomSubstate(name, true)
}

function loadColorsToFile()
    for i=1,#filePaths do
        -- Table Setup
        colorTable = {}

        -- Global
        if i == 1 then
            colorTable = globalTable
        end

        if i == 2 then
            colorTable = globalTableDark
        end

        if i == 3 then
            colorTable = globalTableWhite
        end

        -- Left
        if i == 4 then
            colorTable = leftArrowTable
        end

        if i == 5 then
            colorTable = leftArrowTableDark
        end

        if i == 6 then
            colorTable = leftArrowTableWhite
        end

        -- Down
        if i == 7 then
            colorTable = downArrowTable
        end

        if i == 8 then
            colorTable = downArrowTableDark
        end

        if i == 9 then
            colorTable = downArrowTableWhite
        end

        -- Up
        if i == 10 then
            colorTable = upArrowTable
        end

        if i == 11 then
            colorTable = upArrowTableDark
        end

        if i == 12 then
            colorTable = upArrowTableWhite
        end

        -- Right
        if i == 13 then
            colorTable = rightArrowTable
        end

        if i == 14 then
            colorTable = rightArrowTableDark
        end

        if i == 15 then
            colorTable = rightArrowTableWhite
        end


        file = io.open('mods/randomColors/data/colors/'..filePaths[i]..'.txt', 'w')
        for i=1,#colorTable do
            file:write(colorTable[i]..'\n')
        end
        file:close()
    end

end