-- @description CS_Extend selected item to fill time Selection
-- @version 1.0
-- @author Claudiohbsantos
-- @link http://claudiohbsantos.com
-- @date 2017 03 28
-- @about
--   # CS_Extend selected item to fill time Selection
--   Extends selected item to fill time selection. Time selection must overlap at least partially with selected item.
-- @changelog
--   - Initial Release


function msg(msg)
	reaper.ShowConsoleMsg(msg.."\n")
end

function msgBox(msg)
	reaper.ShowMessageBox(msg,"Title",0)
end

function getItemStartAndEnd(item)
	local startPos = reaper.GetMediaItemInfo_Value(item,"D_POSITION")
	local endPos = reaper.GetMediaItemInfo_Value(item,"D_LENGTH") + startPos
	return startPos,endPos
end

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

end

function moreThanOneItemPerTrack(nSelectedItems)
	local repeatedTrack = false
	local firstItem = reaper.GetSelectedMediaItem(0,0)
	previousTrack = reaper.GetMediaItem_Track(firstItem)
	for i=1,nSelectedItems-1, 1 do
		local item = reaper.GetSelectedMediaItem(0,i)
		local itemTrack = reaper.GetMediaItem_Track(item)
		if itemTrack == previousTrack then
			repeatedTrack = true
			break
		end
		previousTrack = itemTrack
	end
	return repeatedTrack
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

function extendItemToFillTimeSelection(item,timeSelStart,timeSelEnd)
	local itemStart,itemEnd = getItemStartAndEnd(item)
	local editCursorPos = reaper.GetCursorPositionEx(0)
	local originalSelItemsList = saveSelectedItems()

	reaper.SelectAllMediaItems(0,false)
	reaper.SetMediaItemSelected(item,true)

	if timeSelStart < itemStart and timeSelEnd > itemStart and timeSelEnd < itemEnd then
		reaper.SetEditCurPos2(0,timeSelStart,false,false)
		reaper.Main_OnCommand(41305,0) -- trim left edge of item to edit cursor
	end

	if timeSelStart > itemStart and timeSelEnd > itemEnd and timeSelStart < itemEnd then
		reaper.SetEditCurPos2(0,timeSelEnd,false,false)
		reaper.Main_OnCommand(41311,0) -- trim right of item to edit cursor
	end

	if timeSelStart < itemStart and timeSelEnd > itemEnd then
		reaper.SetEditCurPos2(0,timeSelStart,false,false)
		reaper.Main_OnCommand(41305,0) -- trim left edge of item to edit cursor
		reaper.SetEditCurPos2(0,timeSelEnd,false,false)
		reaper.Main_OnCommand(41311,0) -- trim right of item to edit cursor
	end

	restoreSelectedItems(originalSelItemsList)
	reaper.SetEditCurPos2(0,editCursorPos,false,false)
end

reaper.Undo_BeginBlock()
reaper.PreventUIRefresh(1)
local originalState = saveOriginalState()




local nSelectedItems = reaper.CountSelectedMediaItems(0)
local timeSelStart,timeSelEnd = reaper.GetSet_LoopTimeRange2(0,false,false,0,0,false)

if timeSelStart ~= timeSelEnd then
	if nSelectedItems > 0 and not moreThanOneItemPerTrack(nSelectedItems) then
		for i=0,nSelectedItems-1,1 do
			local item = reaper.GetSelectedMediaItem(0,i)
			extendItemToFillTimeSelection(item,timeSelStart,timeSelEnd)
		end	
	end
end

restoreOriginalState(originalState)
reaper.PreventUIRefresh(-1)
reaper.UpdateArrange()
reaper.Undo_EndBlock("CS_Extend selected item to fill time Selection", 0)
