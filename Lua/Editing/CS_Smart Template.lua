-- @noindex
-- @description CS_Smart 
-- @version 
-- @author Claudiohbsantos
-- @link http://claudiohbsantos.com
-- @date 
-- @about
--   # CS_Smart 
-- @changelog
--   --  

function saveOriginalState()
	local originalState = {}

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

function restoreOriginalState(originalState)
	reaper.SetEditCurPos2(0,originalState.editCur,false,false)

	reaper.GetSet_LoopTimeRange2(0,true,true,originalState.timeSelStart,originalState.timeSelEnd,false)

	reaper.Main_OnCommand(40297,0) -- unselect all tracks
	for i=1, #originalState.selTracks,1 do
		reaper.SetTrackSelected(originalState.selTracks[i],true)
	end

	reaper.SelectAllMediaItems(0,false)
	for i=1,#originalState.selItems,1 do
		reaper.SetMediaItemSelected(originalState.selItems[i],true)
	end

	if originalState.lockWasEnabled == 1 then reaper.Main_OnCommand(40569,0) end -- set locking
	if originalState.autoFadeWasEnabled == 1 then reaper.Main_OnCommand(reaper.NamedCommandLookup("_SWS_XFDON"),0) end-- toggle auto-crossfade
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

function timeSelectionisContainedByAllItems(items)
	local isContained = true
	for i=1,#items,1 do
		if not (timeSelStart > items[i].start and timeSelEnd < items[i].limit) then
			isContained = false
			break
		end
	end

	return isContained
end 

function timeSelectionIsAtEndOfAllItems(item)
	local isEnd = true
	for i=1,#item,1 do
		if not (timeSelStart > item[i].start and timeSelStart < item[i].limit and timeSelEnd > item[i].limit) then
			isEnd = false
			break
		end
	end

	return isEnd
end

function  timeSelectionIsAtBeginningOfAllItems(item) 
	local isStart = true
	for i=1,#item,1 do
		if not (timeSelStart < item[i].start and timeSelEnd < item[i].limit and timeSelEnd > item[i].start) then
			isStart = false
			break
		end
	end

	return isStart
end

function timeSelectionContainsAllItems(item)
	if timeSelStart <= item.firstEdge and timeSelEnd >= item.lastEdge then 
		return true
	else
		return false
	end
end

function timeSelectionDoesntOverlapItems(item)
	if timeSelStart > item.lastEdge or timeSelEnd < item.firstEdge then 
		return true
	else
		return false
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

	for file in io.popen([[dir "]]..scriptPath..[[" /b]]):lines() do 
		if string.match(file,"_Library.lua$") then 
			local library = string.match(file,"(.*)%.lua")
			require(library)
		end
	end
end

local function Run()
	local functionToRun = defaultFunction



end

reaper.Undo_BeginBlock()
reaper.PreventUIRefresh(1)
originalState = saveOriginalState()

loadCSLibrary()

Run()

restoreOriginalState(originalState)
reaper.PreventUIRefresh(-1)
reaper.Undo_EndBlock("Smart Fade", 0)


-- -- Mouse Context
-- mouse.unknown
-- mouse.transport
-- mouse.ruler.region_lane
-- mouse.ruler.marker_lane
-- mouse.ruler.tempo_lane
-- mouse.ruler.timeline
-- mouse.tcp.track
-- mouse.tcp.envelope
-- mouse.tcp.empty
-- mouse.mcp.track
-- mouse.mcp.empty
-- mouse.arrange.track.empty
-- mouse.arrange.track.item
-- 						overFade
-- 						overFirstHalf
-- 						overSecondHalf	
-- mouse.arrange.track.item_strech_marker
-- mouse.arrange.track.env_point
-- mouse.arrange.track.env_segment
-- mouse.arrange.envelope.empty
-- mouse.arrange.envelope.env_point
-- mouse.arrange.envelope.env_segment
-- mouse.arrange.empty
-- mouse.midi_editor.unknown
-- mouse.midi_editor.rules
-- mouse.midi_editor.piano
-- mouse.midi_editor.notes
-- mouse.midi_editor.cc_lane
-- -- Items Selected
-- noItemsSelected
-- oneItemSelected
-- 	mouseOverItem
-- 	mouseOverOtherItem
-- 	mouseNotOverItem
-- multipleItemsSelected
-- 	multipleItemsOnSameTrack
-- 	multipleItemsOnDifferentTracks
-- -- Tracks Selected
-- noTracksSelected
-- oneTrackSelected
-- 	mouseOverTrack
-- 	mouseOverOtherTrack
-- 	mouseNotOverTracks
-- multipleTracksSelected
-- -- Markers
-- mouseCloseToMarker
-- mouseOnTopOfMarker
-- mouseInsideRegion
-- mouseCloseToRegionEnd
-- -- Time Selection
-- noTimeSelection
-- mouseInsideTimeSelection
-- mouseOutsideTimeSelection


