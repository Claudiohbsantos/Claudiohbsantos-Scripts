--[[
@description CS_Smart Trim Left Edge
@version 1.0alpha
@author Claudiohbsantos
@link http://claudiohbsantos.com
@date 2018 01 30
@about
  # CS_Smart Trim Left Edge
  Trims behind item under mouse cursor, 
@changelog
  - Items always end deselected
  - If Mouse is on top of an item and enclosed by the time selection, split item at time selection edges
--]]					

------------ settings
followSnapping = false
undoName = "Smart Trim Left Edge"
---------------------


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
	if originalState.autoFadeWasEnabled == 1 then reaper.Main_OnCommand(reaper.NamedCommandLookup("_SWS_XFDON"),0) end-- toggle auto-crossfade
	reaper.BR_SetArrangeView(0,originalState.arrangeStart,originalState.arrangeEnd)
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

local function loadCSLibrary()
	local function get_script_path()
		local info = debug.getinfo(1,'S');
		local script_path = info.source:match[[^@?(.*[\/])[^\/]-$]]
		return script_path
	end 

	local scriptPath = get_script_path()
	package.path = package.path .. ";" .. scriptPath .. "?.lua"
	local library = "CS_Library"
	require(library)

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

function trimLeftEdgeOfItemUnderMouse(mouse)
	mouse.item = reaper.BR_GetMouseCursorContext_Item()

	reaper.SetEditCurPos2(0,mouse.pos,false,false)

	for i=1,#originalState.selItems,1 do
		if mouseItem == originalState.selItems[i] then
			reaper.Main_OnCommand(40511,0) -- trim left edge of item
			return
		end
	end	

	reaper.SelectAllMediaItems(0,false)
	reaper.SetMediaItemSelected(mouse.item,true)
	reaper.Main_OnCommand(40511,0) -- trim left edge of item
	return
end

function trimLeftEdgeOfNextItem(mouse)
	reaper.SetEditCurPos2(0,mouse.pos,false,false)
	reaper.Main_OnCommand(41110,0) -- select track under mouse
	reaper.Main_OnCommand(reaper.NamedCommandLookup("_XENAKIOS_SELITEMSUNDEDCURSELTX"),0) -- select item under edit cursor 
	if reaper.CountSelectedMediaItems(0) == 0 then reaper.Main_OnCommand(40417,0) end -- select and move to next item
	reaper.SetEditCurPos2(0,mouse.pos,false,false)
	reaper.Main_OnCommand(41305,0) -- trim left edge to edit cursor
end


local function trimLeftEdgeOfSelItemsToMouse(mousePos)
	reaper.SetEditCurPos2(0,mousePos,false,false)
	reaper.Main_OnCommand(41305,0) -- trim left edge of sel items to edit cursor
end

local function Run()
	local proximity = 0.01
	mouse = {}
	mouse.window,mouse.context,mouse.details = reaper.BR_GetMouseCursorContext()
	mouse.pos = getMousePos(mouse)

	mouse.pos = cs.checkMouseSnappingPositions(proximity,mouse) or mouse.pos

	mouseCase = cs.initMouseCaseTables()

	if reaper.CountSelectedMediaItems(0) == 0 then
		mouseCase.arrange.track.item = {trimLeftEdgeOfItemUnderMouse,mouse}
		mouseCase.arrange.track.item_stretch_marker = {trimLeftEdgeOfItemUnderMouse,mouse}
		mouseCase.arrange.track.empty = {trimLeftEdgeOfNextItem,mouse}
	else
		mouseCase.default = {trimLeftEdgeOfSelItemsToMouse,mouse.pos}
	end
	
	cs.executeMouseContextFunction(mouseCase)

end

reaper.Undo_BeginBlock()
reaper.PreventUIRefresh(1)
originalState = saveOriginalState()

loadCSLibrary()

Run()

restoreOriginalState(originalState)
reaper.PreventUIRefresh(-1)
reaper.Undo_EndBlock(undoName, 0)