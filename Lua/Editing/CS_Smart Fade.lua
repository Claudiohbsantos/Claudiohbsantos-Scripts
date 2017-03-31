-- @description CS_Smart Fade
-- @version 2.6
-- @author Claudiohbsantos
-- @link http://claudiohbsantos.com
-- @date 2017 03 28
-- @about
--   # CS_Smart Fade (Fade depending on time selection, mouse position and overlap between clips)
--   - If a single item is selected:
--     - If edit cursor is closer to start of item : **Fade In**
--     - If edit cursor is closer to end of item : **Fade Out**
--     - If there is a time selection over item : **Fade In/Out in Time selection**
--   - If Two items on same track are selected:
--     - If they overlap and there is no time selection: **Create crossfade on overlap**
--     - If they overlap and there is a time selection that includes the overlap: **Expand items and crossfade on time selection**
--     - If they don't overlap and there is a time selection enveloping their gap/split point: **Expand items and crossfade on time selection**
--   - If two or three items are selected on different tracks and they overlap in time : **Create fades on time overlap**
-- @changelog
--   - Extensive Code Optimizations

function msg(x)
	reaper.ShowConsoleMsg(tostring(x).."\n")
end

function msgBox(msg)
	reaper.ShowMessageBox(msg,"Title",0)
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

function getItemStartAndEnd(item)
	local startPos = reaper.GetMediaItemInfo_Value(item,"D_POSITION")
	local endPos = reaper.GetMediaItemInfo_Value(item,"D_LENGTH") + startPos
	return startPos,endPos
end

function fadeToMouse(startPos,endPos)
	local mousePos = reaper.BR_GetMouseCursorContext_Position()
	if (mousePos - startPos) < (endPos - mousePos) then -- is mouse is before middle of item
		reaper.SetEditCurPos2(0,mousePos,false,false)
		reaper.Main_OnCommand(40509,0) -- fade in
	end

	if (mousePos - startPos) >= (endPos - mousePos) then -- is mouse is before middle of item
		reaper.SetEditCurPos2(0,mousePos,false,false)
		reaper.Main_OnCommand(40510,0) -- fade out
	end
end

function extendItemToFillTimeSelection(item,timeSelStart,timeSelEnd)
	local itemStart,itemEnd = getItemStartAndEnd(item)
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

function fadeOverlapofSelectedItems()
	saveSelectedItemsTracks(originalState)
	reaper.Main_OnCommand(40644,0) -- implode items across tracks into items on one track
	reaper.Main_OnCommand(41059,0) -- crossfade any overlapping items
	restoreSelectedItemsTracks(originalState)
end

function timeSelectionisContainedByAllItems(item)
	local isContained = true
	for i=1,#item,1 do
		if not (timeSelStart > item[i].start and timeSelEnd < item[i].limit) then
			isContained = false
			break
		end
	end

	if isContained then
		return true
	else
		return false
	end
end 

function timeSelectionIsAtEndOfAllItems(item)
	local isEnd = true
	for i=1,#item,1 do
		if not (timeSelStart > item[i].start and timeSelStart < item[i].limit and timeSelEnd > item[i].limit) then
			isEnd = false
			break
		end
	end

	if isEnd then
		return true
	else
		return false
	end
end

function  timeSelectionIsAtBeginningOfAllItems(item) 
	local isStart = true
	for i=1,#item,1 do
		if not (timeSelStart < item[i].start and timeSelEnd < item[i].limit and timeSelEnd > item[i].start) then
			isStart = false
			break
		end
	end

		if isStart then
			return true
		else
			return false
	end
end

function checkSpecialCases(item)
	if #item == 2 then
		if timeSelStart > item[item.first].start and timeSelEnd > item[item.first].limit and timeSelStart < item[item.last].start and timeSelEnd > item[item.last].start and timeSelEnd < item[item.last].limit then
			extendItemToFillTimeSelection(item[1].item,timeSelStart,timeSelEnd)
			extendItemToFillTimeSelection(item[2].item,timeSelStart,timeSelEnd)
			reaper.Main_OnCommand(40020,0) -- remove time selection
			fadeOverlapofSelectedItems()
		end
	end

	if #item == 3 then
		if timeSelStart > item[1].start and timeSelStart < item[1].limit and timeSelStart < item[3].start and timeSelEnd > item[3].limit and timeSelEnd > item[2].start and timeSelEnd < item[2].limit and item[1].limit < item[2].start then
			extendItemToFillTimeSelection(item[3].item,timeSelStart,timeSelEnd)
			fadeOverlapofSelectedItems()
			return true
		end

		if timeSelStart > item[2].start and timeSelStart < item[2].limit and timeSelStart < item[1].start and timeSelEnd > item[1].limit and timeSelEnd > item[3].start and timeSelEnd < item[3].limit and item[2].limit < item[3].start then
			extendItemToFillTimeSelection(item[1].item,timeSelStart,timeSelEnd)
			fadeOverlapofSelectedItems()
			return true
		end
	end
end

function fadeSelectedItems(nSelectedItems)
	local item = {}
	local itemUnderMouse
	if mouseDetails == "item" then
		itemUnderMouse = reaper.BR_ItemAtMouseCursor()
	end

	if nSelectedItems == 0 then
		if itemUnderMouse then
			local item = reaper.BR_GetMouseCursorContext_Item()
			reaper.SetMediaItemSelected(item,true)
			nSelectedItems = 1
		end
	end

	-- get items info
	for i=1,nSelectedItems,1 do
		item[i] = {} 
		item[i].item = reaper.GetSelectedMediaItem(0,i-1)
		if itemUnderMouse and item[i].item == itemUnderMouse then
			item.underMouse = item[i].item
		end
		item[i].start,item[i].limit = getItemStartAndEnd(item[i].item)
		if not item.firstEdge or item[i].start < item.firstEdge then
			item.firstEdge = item[i].start
			item.first = i
		end
		if not item.lastEdge or item[i].limit > item.lastEdge then
			item.lastEdge = item[i].limit
			item.last = i
		end
	end

	-- perform appropriate fade
	if timeSelStart ~= timeSelEnd then
		local specialCase = checkSpecialCases(item)

		if not specialCase then
			if timeSelectionisContainedByAllItems(item) or
			   timeSelectionIsAtEndOfAllItems(item) or
	           timeSelectionIsAtBeginningOfAllItems(item) then

				reaper.Main_OnCommand(reaper.NamedCommandLookup("_SWS_AWFADESEL"),0) -- SWS fade
			else
				fadeOverlapofSelectedItems()
			end
		end
	else	
		if item.underMouse then
			fadeToMouse(item.firstEdge,item.lastEdge)
		else
			fadeOverlapofSelectedItems()
		end
	end

end

function setFadeShapeOfSelectedItems(shape)

	if shape == 1 then 
		reaper.Main_OnCommand(41528,0) -- set crossfade to shape 1
		reaper.Main_OnCommand(41514,0) -- set fade in to shape 1
		reaper.Main_OnCommand(41521,0) -- set fade out to shape 1
	end

	if shape == 2 then 
		reaper.Main_OnCommand(41529,0) -- set crossfade to shape 2
		reaper.Main_OnCommand(41515,0) -- set fade in to shape 2
		reaper.Main_OnCommand(41522,0) -- set fade out to shape 2
	end

	if shape == 3 then 
		reaper.Main_OnCommand(41530,0) -- set crossfade to shape 3
		reaper.Main_OnCommand(41516,0) -- set fade in to shape 3
		reaper.Main_OnCommand(41523,0) -- set fade out to shape 3
	end

	if shape == 4 then 
		reaper.Main_OnCommand(41531,0) -- set crossfade to shape 4
		reaper.Main_OnCommand(41517,0) -- set fade in to shape 4
		reaper.Main_OnCommand(41524,0) -- set fade out to shape 4
	end

	if shape == 5 then 
		reaper.Main_OnCommand(41532,0) -- set crossfade to shape 5
		reaper.Main_OnCommand(41518,0) -- set fade in to shape 5
		reaper.Main_OnCommand(41525,0) -- set fade out to shape 5
	end

	if shape == 6 then 
		reaper.Main_OnCommand(41533,0) -- set crossfade to shape 6
		reaper.Main_OnCommand(41519,0) -- set fade in to shape 6
		reaper.Main_OnCommand(41536,0) -- set fade out to shape 6
	end

	if shape == 7 then 
		reaper.Main_OnCommand(41838,0) -- set crossfade to shape 7
		reaper.Main_OnCommand(41836,0) -- set fade in to shape 7
		reaper.Main_OnCommand(41837,0) -- set fade out to shape 7
	end
end

reaper.Undo_BeginBlock()
reaper.PreventUIRefresh(1)
originalState = saveOriginalState()


local nSelectedItems = reaper.CountSelectedMediaItems(0)
timeSelStart,timeSelEnd = reaper.GetSet_LoopTimeRange2(0,false,false,0,0,false)
retval,segment,mouseDetails = reaper.BR_GetMouseCursorContext()

fadeSelectedItems(nSelectedItems)

setFadeShapeOfSelectedItems(0)
restoreOriginalState(originalState)

reaper.PreventUIRefresh(-1)
reaper.Undo_EndBlock("Smart Fade", 0)