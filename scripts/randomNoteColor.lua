---@funkinScript
--[[
	Yknow this Script used to be simple. - Char
]]

-- Variables that controls the scripts behaviours --

	-- Whether to randomize the white color, or leave at what you set in options
local affectWhite = getModSetting('affectWhite')

	-- Whether to randomize the outlines, or just attempt to use a darker version of the main color
local fullRandom = getModSetting('fullRandom')

	-- Whether to randomize hold notes, or use the parent note's color (false = Randomized, true = Parent Note Color.)
local fixHolds = getModSetting('fixHolds')

	-- Whether to pick from a predetermined list
local fromTable = getModSetting('fromTable')

	-- Whether to pick from a list based on note direction
local tableFromNote = getModSetting('tableFromNote')

	-- Whether to refresh every 2 Beats, WARNING: WILL CAUSE OCCASIONAL GLITCHES WITH HOLD NOTES, oh and also POTENTIAL LAG.
local doRefresh = getModSetting('doRefresh')

	-- Randomize Textures
local chaos = getModSetting("chaos")

	-- Chaos, CHAOS!
local trueChaos = getModSetting('trueChaos')

	-- Forces even non default noteType's textures to be random
local forceRandom = getModSetting('forceRandom')

if trueChaos then
	affectWhite = true
	fullRandom = true
	fixHolds = false
	fromTable = false
	tableFromNote = false
	chaos = true
	forceRandom = true
end

if chaos then
	doRefresh = false -- BECAUSE IT WILL LAG IT THE F OUT
end


textures = {
	'noteSkins/NOTE_assets'
}

texturesSplashes = {
	'noteSplashes/noteSplashes'
}

-- Variables required for fixing hold notes
lastRand = '000000'
lastRandWhite = '000000'
lastRandOutline = '000000'

-- Variables required for fixing hold notes while using a specific table per note.
lastRandColorLeft  	  = '000000'
lastRandColorLeftWhite  = '000000'
lastRandColorLeftDark   = '000000'

lastRandColorDown  	  = '000000'
lastRandColorDownWhite  = '000000'
lastRandColorDownDark   = '000000'

lastRandColorUp	      = '000000'
lastRandColorUpWhite	  = '000000'
lastRandColorUpDark	  = '000000'

lastRandColorRight      = '000000'
lastRandColorRightWhite = '000000'
lastRandColorRightDark  = '000000'

-- Variables generally related to above options

	-- For darker version of main color generating for table not from notes
lastTableRand = 1

	-- Same Reason but for note tables
lastLeftRand = 1
lastUpRand = 1
lastRightRand = 1
lastDownRand = 1

require('mods/randomColors/scripts/colorTables')

-- Just leaving this here in case more debugging is required.
--luaDebugMode = true

-- Actual Script now --

function rgbToHex(r,g,b,subtractBrightness)
	if subtractBrightness == true then
		r = r/2
		g = g/2
		b = b/2
	end
    -- EXPLANATION:
    -- The integer form of RGB is 0xRRGGBB
    -- Hex for red is 0xRR0000
    -- Multiply red value by 0x10000(65536) to get 0xRR0000
    -- Hex for green is 0x00GG00
    -- Multiply green value by 0x100(256) to get 0x00GG00
    -- Blue value does not need multiplication.

    -- Final step is to add them together
    -- (r * 0x10000) + (g * 0x100) + b =
    -- 0xRR0000 +
    -- 0x00GG00 +
    -- 0x0000BB =
    -- 0xRRGGBB
    local rgb = (r * 0x10000) + (g * 0x100) + b
    return string.format("%X", rgb)
end

function table_contains(tbl, x)
    found = false
    for _, v in pairs(tbl) do
        if v == x then
            found = true
        end
    end
    return found
end

function randomize_that_shit(returnInt) -- Get a random color fromRGB
	timesAmount = math.random(1, 256)
	math.randomseed(os.time() * timesAmount)
	r = getRandomInt(0, 255)
	g = getRandomInt(0, 255)
	b = getRandomInt(0, 255)
	finalRGB = rgbToHex(r,g,b,false)
	lastRandom = finalRGB
	--debugPrint(finalRGB)
	if returnInt then
		return {r, g, b}
	end
	return finalRGB
end

function tableRandomizeThatShit() -- Get a random color from globalTable
	lastTableRand = getRandomInt(1, #globalTable)
	--debugPrint(globalTable[lastTableRand])
	return globalTable[lastTableRand]
end

function noteTableRandomizeThatShit(noteData) -- Get a random color from a note's table

	if noteData > 4 or noteData < 1 then
		debugPrint(tostring(noteData) + ' IS NOT A VALID OPTION')
		return '000000' -- Return as Black if not valid.
	end

	if noteData == 1 then
		lastLeftRand = getRandomInt(1, #leftArrowTable) -- Assumes that all 3 tables are the same length as the first table.
		return leftArrowTable[lastLeftRand]
	end

	if noteData == 2 then
		lastDownRand = getRandomInt(1, #downArrowTable) -- Assumes that all 3 tables are the same length as the first table.
		return downArrowTable[lastDownRand]
	end

	if noteData == 3 then
		lastUpRand = getRandomInt(1, #upArrowTable) -- Assumes that all 3 tables are the same length as the first table.
		return upArrowTable[lastUpRand]
	end

	if noteData == 4 then
		lastRightRand = getRandomInt(1, #rightArrowTable) -- Assumes that all 3 tables are the same length as the first table.
		return rightArrowTable[lastRightRand]
	end
end

function onCreatePost()
	if songName == 'settings' then -- Settings is broken without these
		close(nil)
	end
	math.randomseed(os.time())
		doNoteRandom()
end

function onBeatHit(elapsed)
	--debugPrint(curBeat % 2)
	if trueChaos then
		if curBeat % 4 then
		 	doNoteRandom()
		end
	end
end

local isNormalNote = false

local normalNoteList = {
	'',
	'Alt Animation',
	'Hey!',
	'GF Sing',
	'No Animation'
}

local skinPostFix = runHaxeCode([[
	import backend.ClientPrefs;

	var finalPostfix = '';

	if (ClientPrefs.data.noteSkin != 'Default')
		finalPostfix = '-' + ClientPrefs.data.noteSkin.toLowerCase();

	return finalPostfix;
	]])

function goodNoteHit(id, noteData, noteType, isSustainNote)
	isNormalNote = table_contains(normalNoteList, noteType) or noteType == nil
	r = getPropertyFromGroup('notes', id, 'rgbShader.r')
	g = getPropertyFromGroup('notes', id, 'rgbShader.g')
	b = getPropertyFromGroup('notes', id, 'rgbShader.b')
	texture = getPropertyFromGroup('notes', id, 'texture')
	if texture == '' or texture == 'noteSkins/NOTE_assets' then
		texture = 'noteSkins/NOTE_assets'..skinPostFix
	end
	if trueChaos then
		r = getRandomInt(-999999, 999999)
		g = getRandomInt(-999999, 999999)
		b = getRandomInt(-999999, 999999)
	end
	--debugPrint(r)
	--debugPrint(g)
	--debugPrint(b)
	if isNormalNote then setPropertyFromGroup('playerStrums', noteData, 'texture', texture) end
	setPropertyFromGroup('playerStrums', noteData, 'rgbShader.r', r)
	setPropertyFromGroup('playerStrums', noteData, 'rgbShader.g', g)
	setPropertyFromGroup('playerStrums', noteData, 'rgbShader.b', b)
end

local noteSkinsuffix = ''
function opponentNoteHit(id, noteData, noteType, isSustainNote)
	isNormalNote = table_contains(normalNoteList, noteType) or noteType == nil
	r = getPropertyFromGroup('notes', id, 'rgbShader.r')
	g = getPropertyFromGroup('notes', id, 'rgbShader.g')
	b = getPropertyFromGroup('notes', id, 'rgbShader.b')
	texture = getPropertyFromGroup('notes', id, 'texture')
	if texture == '' or texture == 'noteSkins/NOTE_assets' then
		texture = 'noteSkins/NOTE_assets'..skinPostFix
	end
	if trueChaos then
		r = getRandomInt(-999999, 999999) * id
		g = getRandomInt(-999999, 999999) * id
		b = getRandomInt(-999999, 999999) * id
	end
	--debugPrint(r)
	--debugPrint(g)
	--debugPrint(b)
	if isNormalNote then setPropertyFromGroup('opponentStrums', noteData, 'texture', texture) end
	setPropertyFromGroup('opponentStrums', noteData, 'rgbShader.r', r)
	setPropertyFromGroup('opponentStrums', noteData, 'rgbShader.g', g)
	setPropertyFromGroup('opponentStrums', noteData, 'rgbShader.b', b)
end

local skinSuffix = noteSkinPostfix
local splashSuffix = splashSkinPostfix
local textureSuffix = ''

local isPixel = getProperty("stageUI") == 'pixel'

if isPixel then
	textureSuffix = 'pixelUI/'
end

local ogNoteSkin = runHaxeCode([[
	import backend.ClientPrefs;

	return ClientPrefs.data.noteSkin;
]])
local filePaths = {
    'global/colors',
    'global/colorsDark',
    'global/colorsWhite',
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
local open = io.open

local function read_file(path)
    local file = open(path, "rb") -- r read mode and b binary mode
    if not file then return nil end
    local content = file:read "*a" -- *a or *all reads the whole file
    file:close()
    return content
end
colorTable = {}
	
function reloadTables()
	for i=1,#filePaths do
		-- Table Setup
		--colorTable = {}

		-- load the file!
		path = 'mods/randomColors/data/colors/'..filePaths[i]..'.txt'
		--debugPrint(filePaths[i])
		colorTable = runHaxeCode([[
			import sys.io.File;

			return File.getContent(']]..path..[[').split('\n');]])
		--debugPrint(colorTable)

        -- Global
        if i == 1 then
            globalTable = colorTable
        end

        if i == 2 then
            globalTableDark = colorTable
        end

        if i == 3 then
            globalTableWhite = colorTable
        end

        -- Left
        if i == 4 then
            leftArrowTable = colorTable
        end

        if i == 5 then
            leftArrowTableDark = colorTable
        end

        if i == 6 then
            leftArrowTableWhite = colorTable
        end

        -- Down
        if i == 7 then
            downArrowTable = colorTable
        end

        if i == 8 then
            downArrowTableDark = colorTable
        end

        if i == 9 then
            downArrowTableWhite = colorTable
        end

        -- Up
        if i == 10 then
            upArrowTable = colorTable
        end

        if i == 11 then
            upArrowTableDark = colorTable
        end

        if i == 12 then
            upArrowTableWhite = colorTable
        end

        -- Right
        if i == 13 then
            rightArrowTable = colorTable
        end

        if i == 14 then
            rightArrowTableDark = colorTable
        end

        if i == 15 then
            rightArrowTableWhite = colorTable
        end
	end
end
function onStartCountdown()
	doNoteRandom()

	if chaos then
	runHaxeCode([[
	import backend.ClientPrefs;

	ClientPrefs.data.noteSkin = 'Default';
	]])
	end

	--[[skin = runHaxeCode([[
		import backend.ClientPrefs

		return ClientPrefs.data.noteSkin;
	)

	if skin ~= 'Default' then
		skinSuffix = skin
	end

	splash = runHaxeCode([[
		import backend.ClientPrefs

		return ClientPrefs.data.splashSkin;
	)]]

	if splash ~= 'Psych' then
		splashSuffix = splash
	end
	if chaos then
		texturesArray = runHaxeCode([[
		import backend.Mods;
		return Mods.mergeAllTextsNamed('images/noteSkins/list.txt');
		]])

		splashesArray = runHaxeCode([[
		import backend.Mods;
		return Mods.mergeAllTextsNamed('images/noteSplashes/list.txt');
		]])

		for i=1,#texturesArray do
			--debugPrint(texturesArray[i])
			var = string.lower(texturesArray[i])
			var = var:gsub(' ', '_')
			table.insert(textures, textureSuffix..'noteSkins/NOTE_assets-'..var)
			--
			precacheImage('noteSkins/NOTE_assets-'..string.lower(texturesArray[i]))
		end
		--debugPrint(textures)
		for i=1,#splashesArray do
			--debugPrint(texturesArray[i])
			var = string.lower(splashesArray[i])
			var = var:gsub(' ', '_')
			table.insert(texturesSplashes, 'noteSplashes/noteSplashes-'..var)
			--debugPrint(texturesSplashes)
			precacheImage('noteSplashes/noteSplashes-'..string.lower(splashesArray[i]))
		end
		--if textureSuffix ~= 'pixelUI/' then doTextureRandom() end
 	end
	 reloadTables()
end

---
--- @param membersIndex int
--- @param noteData int
--- @param noteType string
--- @param isSustainNote bool
--- @param strumTime float
---
local defaultStrumOffsets = {24, -200}

local noteDataToColor = {'purpleholdend', 'blueholdend', 'greenholdend', 'redholdend'}
function onSpawnNote(membersIndex, noteData, noteType, isSustainNote, strumTime)
	isNormalNote = table_contains(normalNoteList, noteType) or noteType == nil
	if forceRandom then isNormalNote = true end
	if chaos and isNormalNote then
		texture = getPropertyFromGroup("notes", i, 'parent.texture')
		isSus = getPropertyFromGroup("notes", i, "isSustainNote")
		if getProperty("stageUI") == 'normal' then setPropertyFromGroup('notes', i, 'noteSplashData.texture', texturesSplashes[getRandomInt(1, #texturesSplashes)]) end
		if not isSus then
			int = getRandomInt(1, #textures)
			--debugPrint('Int got: '..tostring(int)..' which results in: '..textures[int])
			setPropertyFromGroup('notes', i, 'texture', textures[int])
		end
		if isSus then
		if texture == '' or texture == nil then
				texture = 'noteSkins/NOTE_assets'..noteSkinPostfix
		end
			setPropertyFromGroup('notes', i, 'texture', texture)
		end
	end
end

function doTextureRandom()
	for i = 0, getProperty('unspawnNotes.length')-1 do
		if chaos then
			texture = getPropertyFromGroup("unspawnNotes", i, 'parent.texture')
			if texture == '' then
				texture = 'noteSkins/NOTE_assets'..noteSkinPostfix
			end
			isSus = getPropertyFromGroup("unspawnNotes", i, "isSustainNote")
			if getProperty("stageUI") == 'normal' then setPropertyFromGroup("unspawnNotes", i, 'noteSplashData.texture', texturesSplashes[getRandomInt(1, #texturesSplashes)]) end
			if not isSus then
				setPropertyFromGroup('unspawnNotes', i, 'texture', textures[getRandomInt(1, #textures)])
			end
			if isSus then
				setPropertyFromGroup('unspawnNotes', i, 'texture', texture)
			end
		end
	end
end

function doNoteRandom()
	for i = 0, getProperty('unspawnNotes.length')-1 do
		noteData = getPropertyFromGroup('unspawnNotes', i, 'noteData') + 1 -- +1 due to the fact it starts at 0, and tables in lua start from 1.
		isSus = getPropertyFromGroup("unspawnNotes", i, "isSustainNote")
		isNormalNote = table_contains(normalNoteList, getPropertyFromGroup("unspawnNotes", i, "noteType"))
		if forceRandom then
			isNormalNote = true
		end

		if isNormalNote then
			if isSus == false or not fixHolds then


				if noteData == 1 then

					if tableFromNote then
						lastRandColorLeft = getColorFromHex(noteTableRandomizeThatShit(noteData))
					end

					if fromTable and not tableFromNote then
						lastRandColorLeft = getColorFromHex(tableRandomizeThatShit())
					end

					if not fromTable and not tableFromNote then
						if fullRandom then
							lastRandColorLeft = getColorFromHex(randomize_that_shit())
						else
							lastRandColorLeft = randomize_that_shit(true)
							lastRandColorLeftDark = getColorFromHex(rgbToHex(lastRandColorLeft[1], lastRandColorLeft[2], lastRandColorLeft[3], true))
							lastRandColorLeft = getColorFromHex(rgbToHex(lastRandColorLeft[1], lastRandColorLeft[2], lastRandColorLeft[3], false))
						end
					end

					if not fullRandom then

						if tableFromNote then
							lastRandColorLeftDark = getColorFromHex(leftArrowTableDark[lastLeftRand])
						end

						if fromTable and not tableFromNote then
							lastRandColorLeftDark = getColorFromHex(globalTableDark[lastTableRand])
						end

					end

					if tableFromNote then
						noteTableRandomizeThatShit(noteData)
						lastRandColorLeftWhite = getColorFromHex(leftArrowTableWhite[lastLeftRand])
					end

					if fromTable and not tableFromNote then
						tableRandomizeThatShit(noteData)
						lastRandColorLeftWhite = getColorFromHex(globalTableWhite[lastTableRand])
					end

					if not fromTable and not tableFromNote then
						lastRandColorLeftWhite = getColorFromHex(randomize_that_shit())
					end

					if fullRandom then
						random = getRandomInt(0, 10)

						if random >= 5 then

							if tableFromNote then
								lastRandColorLeftDark = getColorFromHex(noteTableRandomizeThatShit(noteData))
							end

							if fromTable and not tableFromNote then
								lastRandColorLeftDark = getColorFromHex(tableRandomizeThatShit(n))
							end

						end

						if random < 5 then

							if tableFromNote then

								noteTableRandomizeThatShit(noteData)
								lastRandColorLeftDark = getColorFromHex(leftArrowTableDark[lastLeftRand])

							end

							if fromTable and not tableFromNote then

								tableRandomizeThatShit(noteData)
								lastRandColorLeftDark = getColorFromHex(globalTableDark[lastTableRand])

							end

							if not fromTable and not tableFromNote then
								lastRandColorLeftDark = getColorFromHex(randomize_that_shit())
							end

						end

					end

				end

				if noteData == 2 then

					if tableFromNote then
						lastRandColorDown = getColorFromHex(noteTableRandomizeThatShit(noteData))
					end

					if fromTable and not tableFromNote then
						lastRandColorDown = getColorFromHex(tableRandomizeThatShit())
					end

					if not fromTable and not tableFromNote then
						if fullRandom then
							lastRandColorDown = getColorFromHex(randomize_that_shit())
						else
							lastRandColorDown = randomize_that_shit(true)
							lastRandColorDownDark = getColorFromHex(rgbToHex(lastRandColorDown[1], lastRandColorDown[2], lastRandColorDown[3], true))
							lastRandColorDown = getColorFromHex(rgbToHex(lastRandColorDown[1], lastRandColorDown[2], lastRandColorDown[3], false))
						end
					end

					if not fullRandom then

						if tableFromNote then
							lastRandColorDownDark = getColorFromHex(downArrowTableDark[lastDownRand])
						end

						if fromTable and not tableFromNote then
							lastRandColorDownDark = getColorFromHex(globalTableDark[lastTableRand])
						end

					end

					if tableFromNote then
						noteTableRandomizeThatShit(noteData)
						lastRandColorDownWhite = getColorFromHex(downArrowTableWhite[lastDownRand])
					end

					if fromTable and not tableFromNote then
						tableRandomizeThatShit(noteData)
						lastRandColorDownWhite = getColorFromHex(globalTableWhite[lastTableRand])
					end

					if not fromTable and not tableFromNote then
						lastRandColorDownWhite = getColorFromHex(randomize_that_shit())
					end

					if fullRandom then
						random = getRandomInt(0, 10)

						if random >= 5 then

							if tableFromNote then
								lastRandColorDownDark = getColorFromHex(noteTableRandomizeThatShit(noteData))
							end

							if fromTable and not tableFromNote then
								lastRandColorDownDark = getColorFromHex(tableRandomizeThatShit(n))
							end

						end

						if random < 5 then

							if tableFromNote then

								noteTableRandomizeThatShit(noteData)
								lastRandColorDownDark = getColorFromHex(downArrowTableDark[lastDownRand])

							end

							if fromTable and not tableFromNote then

								tableRandomizeThatShit(noteData)
								lastRandColorDownDark = getColorFromHex(globalTableDark[lastTableRand])

							end

							if not fromTable and not tableFromNote then
								lastRandColorDownDark = getColorFromHex(randomize_that_shit())
							end

						end

					end

				end

				if noteData == 3 then

					if tableFromNote then
						lastRandColorUp = getColorFromHex(noteTableRandomizeThatShit(noteData))
					end

					if fromTable and not tableFromNote then
						lastRandColorUp = getColorFromHex(tableRandomizeThatShit())
					end

					if not fromTable and not tableFromNote then
						if fullRandom then
							lastRandColorUp = getColorFromHex(randomize_that_shit())
						else
							lastRandColorUp = randomize_that_shit(true)
							lastRandColorUpDark = getColorFromHex(rgbToHex(lastRandColorUp[1], lastRandColorUp[2], lastRandColorUp[3], true))
							lastRandColorUp = getColorFromHex(rgbToHex(lastRandColorUp[1], lastRandColorUp[2], lastRandColorUp[3], false))
						end
					end

					if not fullRandom then

						if tableFromNote then
							lastRandColorUpDark = getColorFromHex(upArrowTableDark[lastUpRand])
						end

						if fromTable and not tableFromNote then
							lastRandColorUpDark = getColorFromHex(globalTableDark[lastTableRand])
						end

					end

					if tableFromNote then
						noteTableRandomizeThatShit(noteData)
						lastRandColorUpWhite = getColorFromHex(upArrowTableWhite[lastUpRand])
					end

					if fromTable and not tableFromNote then
						tableRandomizeThatShit(noteData)
						lastRandColorUpWhite = getColorFromHex(globalTableWhite[lastTableRand])
					end

					if not fromTable and not tableFromNote then
						lastRandColorUpWhite = getColorFromHex(randomize_that_shit())
					end

					if fullRandom then
						random = getRandomInt(0, 10)

						if random >= 5 then

							if tableFromNote then
								lastRandColorUpDark = getColorFromHex(noteTableRandomizeThatShit(noteData))
							end

							if fromTable and not tableFromNote then
								lastRandColorUpDark = getColorFromHex(tableRandomizeThatShit(n))
							end

						end

						if random < 5 then

							if tableFromNote then

								noteTableRandomizeThatShit(noteData)
								lastRandColorUpDark = getColorFromHex(upArrowTableDark[lastUpRand])

							end

							if fromTable and not tableFromNote then

								tableRandomizeThatShit(noteData)
								lastRandColorUpDark = getColorFromHex(globalTableDark[lastTableRand])

							end

							if not fromTable and not tableFromNote then
								lastRandColorUpDark = getColorFromHex(randomize_that_shit())
							end

						end

					end

				end

				if noteData == 4 then

					if tableFromNote then
						lastRandColorRight = getColorFromHex(noteTableRandomizeThatShit(noteData))
					end

					if fromTable and not tableFromNote then
						lastRandColorRight = getColorFromHex(tableRandomizeThatShit())
					end

					if not fromTable and not tableFromNote then
						if fullRandom then
							lastRandColorRight = getColorFromHex(randomize_that_shit())
						else
							lastRandColorRight = randomize_that_shit(true)
							lastRandColorRightDark = getColorFromHex(rgbToHex(lastRandColorRight[1], lastRandColorRight[2], lastRandColorRight[3], true))
							lastRandColorRight = getColorFromHex(rgbToHex(lastRandColorRight[1], lastRandColorRight[2], lastRandColorRight[3], false))
						end
					end

					if not fullRandom then

						if tableFromNote then
							lastRandColorRightDark = getColorFromHex(rightArrowTableDark[lastRightRand])
						end

						if fromTable and not tableFromNote then
							lastRandColorRightDark = getColorFromHex(globalTableDark[lastTableRand])
						end

					end

					if tableFromNote then
						noteTableRandomizeThatShit(noteData)
						lastRandColorRightWhite = getColorFromHex(rightArrowTableWhite[lastTableRand])
					end

					if fromTable and not tableFromNote then
						tableRandomizeThatShit(noteData)
						lastRandColorRightWhite = getColorFromHex(globalTableWhite[lastTableRand])
					end

					if not fromTable and not tableFromNote then
						lastRandColorRightWhite = getColorFromHex(randomize_that_shit())
					end

					if fullRandom then
						random = getRandomInt(0, 10)

						if random >= 5 then

							if tableFromNote then
								lastRandColorRightDark = getColorFromHex(noteTableRandomizeThatShit(noteData))
							end

							if fromTable and not tableFromNote then
								lastRandColorRightDark = getColorFromHex(tableRandomizeThatShit(n))
							end

						end

						if random < 5 then

							if tableFromNote then

								noteTableRandomizeThatShit(noteData)
								lastRandColorRightDark = getColorFromHex(rightArrowTableDark[lastRightRand])

							end

							if fromTable and not tableFromNote then

								tableRandomizeThatShit(noteData)
								lastRandColorRightDark = getColorFromHex(globalTableDark[lastTableRand])

							end

							if not fromTable and not tableFromNote then
								lastRandColorRightDark = getColorFromHex(randomize_that_shit())
							end

						end

					end

				end


			end

				if noteData == 1 then
					setPropertyFromGroup('unspawnNotes', i, 'rgbShader.r', lastRandColorLeft)
					if affectWhite then setPropertyFromGroup('unspawnNotes', i, 'rgbShader.g', lastRandColorLeftWhite) end
					setPropertyFromGroup('unspawnNotes', i, 'rgbShader.b', lastRandColorLeftDark)
				end

				if noteData == 2 then
					setPropertyFromGroup('unspawnNotes', i, 'rgbShader.r', lastRandColorDown)
					if affectWhite then setPropertyFromGroup('unspawnNotes', i, 'rgbShader.g', lastRandColorDownWhite) end
					setPropertyFromGroup('unspawnNotes', i, 'rgbShader.b', lastRandColorDownDark)
				end

				if noteData == 3 then
					setPropertyFromGroup('unspawnNotes', i, 'rgbShader.r', lastRandColorUp)
					if affectWhite then setPropertyFromGroup('unspawnNotes', i, 'rgbShader.g', lastRandColorUpWhite) end
					setPropertyFromGroup('unspawnNotes', i, 'rgbShader.b', lastRandColorUpDark)
				end

				if noteData == 4 then
					setPropertyFromGroup('unspawnNotes', i, 'rgbShader.r', lastRandColorRight)
					if affectWhite then setPropertyFromGroup('unspawnNotes', i, 'rgbShader.g', lastRandColorRightWhite) end
					setPropertyFromGroup('unspawnNotes', i, 'rgbShader.b', lastRandColorRightDark)
				end

			if isSus and fixHolds then
				r = getPropertyFromGroup("unspawnNotes", i, 'parent.rgbShader.r')
				g = getPropertyFromGroup("unspawnNotes", i, 'parent.rgbShader.g')
				b = getPropertyFromGroup("unspawnNotes", i, 'parent.rgbShader.b')
				setPropertyFromGroup('unspawnNotes', i, 'rgbShader.r', r)
				if affectWhite then setPropertyFromGroup('unspawnNotes', i, 'rgbShader.g', g) end
				setPropertyFromGroup('unspawnNotes', i, 'rgbShader.b', b)
			end

			if trueChaos then
				r = getRandomInt(-999999, 999999) * noteData
				g = getRandomInt(-999999, 999999) * noteData
				b = getRandomInt(-999999, 999999) * noteData
				setPropertyFromGroup('unspawnNotes', i, 'noteSplashData.r', r)
				if affectWhite then setPropertyFromGroup('unspawnNotes', i, 'noteSplashData.g', g) end
				setPropertyFromGroup('unspawnNotes', i, 'noteSplashData.b', b)
			end
		end

		end
end

function onEndSong()
	if chaos then
		runHaxeCode([[
		import backend.ClientPrefs;

		ClientPrefs.data.noteSkin = ']]..ogNoteSkin.."';"
		)
	end
end

function onGameOver()
	if chaos then
		runHaxeCode([[
		import backend.ClientPrefs;

		ClientPrefs.data.noteSkin = ']]..ogNoteSkin.."';"
		)
	end
end

function onPause()
	if chaos then
		runHaxeCode([[
		import backend.ClientPrefs;

		ClientPrefs.data.noteSkin = ']]..ogNoteSkin.."';"..[[
		ClientPrefs.saveSettings();]]
		)
	end
end

function onResume()
	if chaos then
		runHaxeCode([[
		import backend.ClientPrefs;

		ClientPrefs.data.noteSkin = 'Default';
		]])
	end
end