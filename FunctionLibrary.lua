-- @noindex

function msg(x)
	reaper.ShowConsoleMsg(tostring(x).."\n")
end

function msgBox(msg)
	reaper.ShowMessageBox(msg,"Title",0)
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