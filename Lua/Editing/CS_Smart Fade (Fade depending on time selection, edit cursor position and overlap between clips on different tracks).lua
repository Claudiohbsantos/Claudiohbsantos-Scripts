-- @description CS_Smart Fade (Fade depending on time selection, edit cursor position and overlap between clips on different tracks)
-- @version 2.3beta
-- @author Claudiohbsantos
-- @link http://claudiohbsantos.com
-- @date 2017 03 28
-- @about
--   # CS_Smart Fade (Fade depending on time selection, edit cursor position and overlap between clips)
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
--   - Fixed conditional for case os 2 items on same track with containing time selection

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

function getEdgesOf2ItemsInOrder(item1,item2)
	local item1Start,item1End = getItemStartAndEnd(item1)
	local item2Start,item2End = getItemStartAndEnd(item2)
	local earlyItemStart,earlyItemEnd,lateItemStart,lateItemEnd

	if item1Start < item2Start then 
		earlyItemStart = item1Start
		earlyItemEnd = item1End
		lateItemStart = item2Start
		lateItemEnd = item2End
	else
		earlyItemStart = item2Start
		earlyItemEnd = item2End
		lateItemStart = item1Start
		lateItemEnd = item1End
	end
	return earlyItemStart,earlyItemEnd,lateItemStart,lateItemEnd
end

function noItemsSelected()
	if mouseDetails == "item" then
		local item = reaper.BR_GetMouseCursorContext_Item()
		reaper.SetMediaItemSelected(item,true)
			itemsSelected1()	
	end
end


function itemsSelected1()
	local item = reaper.GetSelectedMediaItem(0,0)
	local startPos,endPos = getItemStartAndEnd(item)

	if timeSelStart ~= timeSelEnd then 
		if timeSelEnd < startPos or timeSelStart > endPos or (timeSelStart < startPos and timeSelEnd > endPos) then -- time selection doesn't overlap with item
			fadeToMouse(startPos,endPos)
		else
			reaper.Main_OnCommand(reaper.NamedCommandLookup("_SWS_AWFADESEL"),0) -- fade time selection
		end
	else
		fadeToMouse(startPos,endPos)
	end
end

function fadeOverlapofSelectedItems()
	saveSelectedItemsTracks(originalState)
	reaper.Main_OnCommand(40644,0) -- implode items across tracks into items on one track
	reaper.Main_OnCommand(41059,0) -- crossfade any overlapping items
	restoreSelectedItemsTracks(originalState)
end

function timeSelectionIsContainedByItems(timeSelStart,earlyItemStart,lateItemStart,timeSelEnd,earlyItemEnd,lateItemEnd)
	if timeSelStart > earlyItemStart and timeSelEnd > earlyItemEnd and timeSelStart < lateItemStart and timeSelEnd > lateItemStart and timeSelEnd < lateItemEnd then
		return true
	else
		return false
	end
end

function timeSelectionCoversEndsOfItems(timeSelStart,earlyItemStart,lateItemStart,timeSelEnd,earlyItemEnd,lateItemEnd)
	if timeSelStart > earlyItemStart and timeSelStart > lateItemStart and timeSelEnd > earlyItemEnd and timeSelEnd > lateItemEnd then
		return true
	else
		return false
	end
end

function timeSelectionCoversStartsOfItems(timeSelStart,earlyItemStart,lateItemStart,timeSelEnd,earlyItemEnd,lateItemEnd)
	if timeSelStart < earlyItemStart and timeSelStart < lateItemStart and timeSelEnd < earlyItemEnd and timeSelEnd < lateItemEnd then
		return true
	else
		return false
	end
end

function itemsSelected2()
	local item1 = reaper.GetSelectedMediaItem(0,0)
	local item2 = reaper.GetSelectedMediaItem(0,1)
	local item1Start,item1End = getItemStartAndEnd(item1)
	local item2Start,item2End = getItemStartAndEnd(item2)
	local item1Track = reaper.GetMediaItem_Track(item1)
	local item2Track = reaper.GetMediaItem_Track(item2)

	if item1Track ~= item2Track then -- if on different tracks
		local earlyItemStart,earlyItemEnd,lateItemStart,lateItemEnd = getEdgesOf2ItemsInOrder(item1,item2)
		if timeSelStart ~= timeSelEnd then
			if timeSelectionIsContainedByItems(timeSelStart,earlyItemStart,lateItemStart,timeSelEnd,earlyItemEnd,lateItemEnd) then
				extendItemToFillTimeSelection(item1,timeSelStart,timeSelEnd)
				extendItemToFillTimeSelection(item2,timeSelStart,timeSelEnd)
				reaper.Main_OnCommand(40020,0) -- remove time selection
				fadeOverlapofSelectedItems()
			else
				if timeSelectionCoversEndsOfItems(timeSelStart,earlyItemStart,lateItemStart,timeSelEnd,earlyItemEnd,lateItemEnd) then
					reaper.Main_OnCommand(reaper.NamedCommandLookup("_SWS_AWFADESEL"),0) -- SWS fade
				else
					if timeSelectionCoversStartsOfItems(timeSelStart,earlyItemStart,lateItemStart,timeSelEnd,earlyItemEnd,lateItemEnd) then
						reaper.Main_OnCommand(reaper.NamedCommandLookup("_SWS_AWFADESEL"),0) -- SWS fade
					else
						if mouseDetails == "item" then
							local itemUnderMouse = reaper.BR_ItemAtMouseCursor()
								if itemUnderMouse == item1 or itemUnderMouse == item2 then
									fadeToMouse(earlyItemStart,lateItemEnd)
								else
									fadeOverlapofSelectedItems()
								end
						else
							fadeOverlapofSelectedItems()
						end
					end
				end
			end	
		else
			if mouseDetails == "item" then
				local itemUnderMouse = reaper.BR_ItemAtMouseCursor()
					if itemUnderMouse == item1 or itemUnderMouse == item2 then
						fadeToMouse(earlyItemStart,lateItemEnd)
					else
						fadeOverlapofSelectedItems()
					end
			else
				fadeOverlapofSelectedItems()
			end
		end
	else
		if timeSelStart ~= timeSelEnd then
			if item1End > item2Start then-- if both items overlap
				if timeSelStart < item1End and timeSelStart > item1Start and timeSelEnd > item2Start and timeSelEnd < item2End then
					reaper.Main_OnCommand(40916,0) -- crossfade items within time selection
				else	
					reaper.Main_OnCommand(41059,0) -- crossfade any overlapping items
				end
			else
				if timeSelStart > item1Start and timeSelStart < item1End and timeSelEnd > item2Start and timeSelEnd < item2End then -- if time selection contained by items
					extendItemToFillTimeSelection(item1,timeSelStart,timeSelEnd)
					extendItemToFillTimeSelection(item2,timeSelStart,timeSelEnd)
					reaper.Main_OnCommand(41059,0) -- crossfade any overlapping items
				end
			end 
		else
			reaper.Main_OnCommand(41059,0) -- crossfade any overlapping items
		end
	end
end

function itemsSelected3()
	local item1 = reaper.GetSelectedMediaItem(0,0)
	local item2 = reaper.GetSelectedMediaItem(0,1)
	local item3 = reaper.GetSelectedMediaItem(0,2)
	local item1Start,item1End = getItemStartAndEnd(item1)
	local item2Start,item2End = getItemStartAndEnd(item2)
	local item3Start,item3End = getItemStartAndEnd(item3)


	if timeSelStart ~= timeSelEnd then
		if timeSelStart > item1Start and timeSelStart < item1End and timeSelStart < item3Start and timeSelEnd > item3End and timeSelEnd > item2Start and timeSelEnd < item2End and item1End < item2Start then
			extendItemToFillTimeSelection(item3,timeSelStart,timeSelEnd)
		end

		if timeSelStart > item2Start and timeSelStart < item2End and timeSelStart < item1Start and timeSelEnd > item1End and timeSelEnd > item3Start and timeSelEnd < item3End and item2End < item3Start then
			extendItemToFillTimeSelection(item1,timeSelStart,timeSelEnd)
		end
		fadeOverlapofSelectedItems()
	else
		fadeOverlapofSelectedItems()	
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

if nSelectedItems == 0 then
	noItemsSelected()
end

if nSelectedItems == 1 then
	itemsSelected1()
end

if nSelectedItems == 2 then
	itemsSelected2()
end

if nSelectedItems == 3 then
	itemsSelected3()
end

if nSelectedItems > 3 then
	fadeOverlapofSelectedItems()
end


setFadeShapeOfSelectedItems(2)
restoreOriginalState(originalState)

reaper.PreventUIRefresh(-1)
reaper.Undo_EndBlock("Smart Fade", 0)