-- @noindex

-- local colors = {}
-- local trackBanks

-- function getSelectionColorsFromFile()
-- 	local colorFile = io.open(rl.userSettingsPath.."\\selectionColors.txt","r")
-- 	for color in colorFile:lines() do 
-- 		local shortcut,name,r,g,b = string.match(color,"(%a)=(%a+)=(%d+) (%d+) (%d+)")
-- 		if shortcut and name and r and g and b then
-- 			colors[shortcut] = {}
-- 			colors[shortcut].name = name
-- 			colors[shortcut].r = r
-- 			colors[shortcut].g = g
-- 			colors[shortcut].b = b
-- 			colors[#colors+1] = colors[shortcut]
-- 		end
-- 	end
-- 	return colors
-- end

-- function getVisibleTracks ()
-- 	local visibleTracks = {}
-- 	for track in cs.allTracks(0) do
-- 		if reaper.IsTrackVisible(track,false) then
-- 			table.insert(visibleTracks,track)
-- 		end
-- 	end
-- 	local i = 0

-- 	return function () i = i + 1 return visibleTracks[i] end
-- end

-- function assignBanksToColors(iterator,colorsTable)
-- 	local banks = {{}}
-- 	for element in iterator() do
-- 			table.insert(banks[#banks],element)
-- 			if #banks[#banks] == #colorsTable then 
-- 				table.insert(banks,{})
-- 			end
-- 	end
-- 	return banks
-- end

-- function highlightTracks(banks)
-- 	for i,track in ipairs(banks[banks.current]) do
-- 		local r,g,b = colors[i].r,colors[i].g,colors[i].b
-- 		colors[i].target = track
-- 		colors[i].origColor = reaper.GetMediaTrackInfo_Value(track,"I_CUSTOMCOLOR")
-- 		color = cs.rgbToColor(r,g,b)
-- 		reaper.SetMediaTrackInfo_Value(track,"I_CUSTOMCOLOR",color)
-- 	end
-- end

-- function restoreColors ()
-- 	for i in ipairs(colors) do
-- 		if colors[i].target then 
-- 			reaper.SetMediaTrackInfo_Value(colors[i].target,"I_CUSTOMCOLOR",(colors[i].origColor))		
-- 			colors[i].target = nil
-- 		end
-- 	end
-- end

-- function setTracksSelected()
-- 	reaper.Main_OnCommand(40297,0) -- unselect all tracks
-- 	for shortcut in string.gmatch(rl.arguments,"(%a)") do
-- 		if colors[shortcut] and colors[shortcut].target then
-- 			reaper.SetTrackSelected(colors[shortcut].target,true)
-- 		end
-- 	end
-- end

-- function selectTrack()

-- 	cs.doOnce(getSelectionColorsFromFile)
-- 	trackBanks = trackBanks or cs.doOnce(assignBanksToColors,getVisibleTracks,colors)
-- 	if not trackBanks.current then trackBanks.current = 1 end

-- 	cs.doOnce(highlightTracks,trackBanks)		
 	
-- 	if char == kbInput.downArrow then
-- 		trackBanks.current = trackBanks.current + 1 
-- 		if trackBanks.current > #trackBanks then trackBanks.current = trackBanks.current - 1 end
-- 		restoreColors()
-- 		highlightTracks(trackBanks)			
-- 	end

-- 	if char == kbInput.upArrow  then
-- 		trackBanks.current = trackBanks.current - 1 
-- 		if trackBanks.current < 1 then trackBanks.current = 1 end
-- 		restoreColors()
-- 		highlightTracks(trackBanks)			
-- 	end

--  	if char == kbInput.enter then
--  		setTracksSelected()
-- 	end

-- 	rl.executeOnExit = restoreColors
-- end

-- rl.registeredCommands.selectTrack = {main = selectTrack,waitForEnter = false,description = "Quick Select Track"}


local function loadGUIModule()
	package.cpath = package.cpath .. ";" .. rl.scriptPath .. "3rdparty\\?.dll"
	require("AutoHotkey")
	return
end

local function getScreenCoordinates()
	local cmd = rl.scriptPath.."\\3rdparty\\GetArrangeCoordinates.exe"
	local windowCoords = {}
	windowCoords.x,windowCoords.y,windowCoords.w,windowCoords.h = reaper.ExecProcess(cmd,0):match("^.*\n(%d+)%s(%d+)%s(%d+)%s(%d+)")
	return windowCoords
end

local function labelItems(ItemCoordinates)
	-- local windowCoords = getScreenCoordinates()	
	-- -- cs.msg(windowCoords.x,windowCoords.y,windowCoords.w,windowCoords.h)

	-- local tooltips = {}
	-- for i=1,60 do
	-- 	table.insert(tooltips,i*23)
	-- end

	-- for i=1,60 do
	-- 	table.insert(tooltips,i*23 + 15)
	-- end

	-- cs.msg(tooltips)

	-- reaper.ExecProcess(rl.scriptPath.."\\3rdparty\\SetTooltips.exe "..table.concat(tooltips," ",1,60),-1)
	-- reaper.ExecProcess(rl.scriptPath.."\\3rdparty\\SetTooltips.exe "..table.concat(tooltips," ",61,120),-1)

	local ahk = loadGUIModule()


end

local function getItemsOnScreen()
	-- getItemsInTime()
end

local function jumpToItem(i)
	getItemsOnScreen()
	labelItems()
end

rl.registeredUtils.jumptoitem = {onEnter = jumpToItem}