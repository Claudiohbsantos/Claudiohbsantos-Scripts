--[[
@description CS_Smart Trim Right Edge
@version 1.1
@author Claudiohbsantos
@link http://claudiohbsantos.com
@date 2018 01 30
@about
  # CS_Smart Trim Right Edge
  Trims behind item under mouse cursor, 
@changelog
  - Updated Dependency loading
@provides
	. > CS_Smart Trim Right Edge/CS_Smart Trim Right Edge.lua
	../Libraries/CS_Library.lua > CS_Smart Trim Right Edge/CS_Library.lua  
--]]					

------------ settings
followSnapping = false
undoName = "Smart Trim Right Edge"
---------------------
local function get_script_path()
		local info = debug.getinfo(1,'S');
		local script_path = info.source:match[[^@?(.*[\/])[^\/]-$]]
		return script_path
	end 

function prequire(...)
    local status, lib = pcall(require, ...)
    if(status) then return lib end
    --Library failed to load, so perhaps return `nil` or something?
    reaper.ShowMessageBox("Missing Assets. Please Uninstall and Reinstall via Reapack","ERROR",0)
    return nil
end

local function loadFromFolder(file)
	local scriptPath = get_script_path()
	package.path = package.path .. ";" .. scriptPath .. "?.lua"
	return prequire(file)
end

local cs = loadFromFolder("CS_Library")

---------------------------------------------------------------

function saveOriginalState()
	local originalState = {}
	originalState.arrangeStart,originalState.arrangeEnd = reaper.BR_GetArrangeView(0)

	originalState.editCur = reaper.GetCursorPositionEx(0)
	originalState.timeSelStart,originalState.timeSelEnd = reaper.GetSet_LoopTimeRange2(0,false,true,0,0,false)

	originalState.selTracks = {}
	for i=1,reaper.CountSelectedTracks2(0,true),1 do
		originalState.selTracks[#originalState.selTracks+1] = reaper.GetSelectedTrack2(0,i-1,true)
	end

	originalState.selItems = {}
	for i=1, reaper.CountSelectedMediaItems(0),1 do
		originalState.selItems[i] = reaper.GetSelectedMediaItem(0,i-1)
	end

	originalState.lockWasEnabled = reaper.GetToggleCommandStateEx(0,1135) -- toggle lock
	reaper.Main_OnCommand(40570,0) -- disable locking

	originalState.autoFadeWasEnabled = reaper.GetToggleCommandStateEx(0,40041) -- if auto-crossfade is enabled
	reaper.Main_OnCommand(reaper.NamedCommandLookup("_SWS_XFDOFF"),0) -- turn off auto-crssfade

	return originalState
end

function restoreEditCursor()
	reaper.SetEditCurPos2(0,originalState.editCur,false,false)
end

function restoreOriginalState(originalState)
	restoreEditCursor()

	reaper.GetSet_LoopTimeRange2(0,true,true,originalState.timeSelStart,originalState.timeSelEnd,false)

	reaper.Main_OnCommand(40297,0) -- unselect all tracks
	for i=1, #originalState.selTracks,1 do
		reaper.SetTrackSelected(originalState.selTracks[i],true)
	end

	reaper.SelectAllMediaItems(0,false)
	-- for i=1,#originalState.selItems,1 do
	-- 	reaper.SetMediaItemSelected(originalState.selItems[i],true)
	-- end

	if originalState.lockWasEnabled == 1 then reaper.Main_OnCommand(40569,0) end -- set locking
	-- if originalState.autoFadeWasEnabled == 1 then reaper.Main_OnCommand(reaper.NamedCommandLookup("_SWS_XFDON"),0) end-- toggle auto-crossfade
	reaper.BR_SetArrangeView(0,originalState.arrangeStart,originalState.arrangeEnd )
end

function saveSelectedItems()
	local nSelectedItems = reaper.CountSelectedMediaItems(0)
	local selItems = {}
	for i=1, nSelectedItems,1 do
		selItems[i] = reaper.GetSelectedMediaItem(0,i-1)
	end

	return selItems
end	

function restoreSelectedItems(originalSelItemsList)
	reaper.SelectAllMediaItems(0,false)
	for i=1,#originalSelItemsList,1 do
		reaper.SetMediaItemSelected(originalSelItemsList[i],true)
	end
end

function saveSelectedItemsTracks(originalState)
	local originalState = originalState or {}

	if not originalState.selItems then
		originalState.selItems = {}
		for i=1, reaper.CountSelectedMediaItems(0),1 do
			originalState.selItems[i] = reaper.GetSelectedMediaItem(0,i-1)
		end
	end

	originalState.selItemsTracks = {}
	for i=1,#originalState.selItems,1 do
		originalState.selItemsTracks[i] = reaper.GetMediaItem_Track(originalState.selItems[i])
	end

	return originalState
end

function restoreSelectedItemsTracks(originalState)
	for i=1,#originalState.selItems,1 do
		reaper.MoveMediaItemToTrack(originalState.selItems[i], originalState.selItemsTracks[i])
	end
end

local function getMousePos(mouse)
	if mouse.window == "ruler" or mouse.window == "transport" then 
		reaper.Main_OnCommand(40514,0) -- move edit cursor to mouse position
		mouse.pos = reaper.GetCursorPositionEx(0)
		restoreEditCursor()
		return mouse.pos
	end

	if mouse.window == "arrange" then
		mouse.pos = reaper.BR_GetMouseCursorContext_Position()
		return mouse.pos
	end
end


function trimRightEdgeOfItemUnderMouse(mouse)
	mouse.item = reaper.BR_GetMouseCursorContext_Item()

	reaper.SetEditCurPos2(0,mouse.pos,false,false)

	for i=1,#originalState.selItems,1 do
		if mouseItem == originalState.selItems[i] then
			reaper.Main_OnCommand(40512,0) -- trim right edge of item
			return
		end
	end	

	reaper.SelectAllMediaItems(0,false)
	reaper.SetMediaItemSelected(mouse.item,true)
	reaper.Main_OnCommand(40512,0) -- trim right edge of item
	return
end

function trimRightEdgeOfPreviousItem(mouse)
	reaper.SetEditCurPos2(0,mouse.pos,false,false)
	reaper.Main_OnCommand(41110,0) -- select track under mouse
	reaper.Main_OnCommand(40416,0) -- select and move to previous item
	reaper.SetEditCurPos2(0,mouse.pos,false,false)
	reaper.Main_OnCommand(41311,0) -- trim right edge to edit cursor
end

local function trimRightEdgeOfSelItemsToMouse(mousePos)
	reaper.SetEditCurPos2(0,mousePos,false,false)
	reaper.Main_OnCommand(41311,0) -- trim right edge of sel items to edit cursor
end

local function Run()
	local proximity = 0.01
	mouse = {}
	mouse.window,mouse.context,mouse.details = reaper.BR_GetMouseCursorContext()
	mouse.pos = getMousePos(mouse)
	if mouse.pos then
		mouse.pos = cs.checkMouseSnappingPositions(proximity,mouse) or mouse.pos
	
		mouseCase = cs.initMouseCaseTables()

		if reaper.CountSelectedMediaItems(0) == 0 then
			mouseCase.arrange.track.item = {trimRightEdgeOfItemUnderMouse,mouse}
			mouseCase.arrange.track.item_stretch_marker = {trimRightEdgeOfItemUnderMouse,mouse}
			mouseCase.arrange.track.empty = {trimRightEdgeOfPreviousItem,mouse}
		else
			mouseCase.default = {trimRightEdgeOfSelItemsToMouse,mouse.pos}
		end
			
		cs.executeMouseContextFunction(mouseCase)
	end
end

local function main()
	originalState = saveOriginalState()
	Run()
	restoreOriginalState(originalState)
end

---------------------------------------------------------------
local reaper = reaper

reaper.PreventUIRefresh(1)
reaper.Undo_BeginBlock2(0)

-- if not cs.notRunningOnWindows() then
	main()
-- end

reaper.Undo_EndBlock2(0,"Smart Trim Right Edge",0)
reaper.PreventUIRefresh(-1)
reaper.UpdateArrange()				


