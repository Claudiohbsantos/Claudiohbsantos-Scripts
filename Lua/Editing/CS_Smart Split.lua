--[[
@description CS_Smart Split
@version 1.0
@author Claudiohbsantos
@link http://claudiohbsantos.com
@date 2017 06 12
@about
  # CS_Smart Split
  Splits item under mouse cursor, 
@changelog
  - initial release
--]]					

function msg(msg)
	reaper.ShowConsoleMsg(msg.."\n")
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

	-- reaper.Main_OnCommand(40297,0) -- unselect all tracks
	for i=1, #originalState.selTracks,1 do
		reaper.SetTrackSelected(originalState.selTracks[i],true)
	end

	-- reaper.SelectAllMediaItems(0,false)
	for i=1,#originalState.selItems,1 do
		reaper.SetMediaItemSelected(originalState.selItems[i],true)
	end

	if originalState.lockWasEnabled == 1 then reaper.Main_OnCommand(40569,0) end -- set locking
	if originalState.autoFadeWasEnabled == 1 then reaper.Main_OnCommand(reaper.NamedCommandLookup("_SWS_XFDON"),0) end-- toggle auto-crossfade

end

function splitItems()
	local mousePos = reaper.BR_GetMouseCursorContext_Position()
	local mouseItem = reaper.BR_GetMouseCursorContext_Item()

	reaper.SetEditCurPos2(0,mousePos,false,false)

	for i=1,#originalState.selItems,1 do
		if mouseItem == originalState.selItems[i] then
			reaper.Main_OnCommand(40757,0) -- Item: Split items at edit cursor
			return
		end
	end	
	reaper.SelectAllMediaItems(0,false)
	reaper.SetMediaItemSelected(mouseItem,true)
	reaper.Main_OnCommand(40757,0) -- Item: Split items at edit cursor
	return
end


reaper.Undo_BeginBlock()
reaper.PreventUIRefresh(1)

originalState = saveOriginalState()

local mouseRetval,mouseContext,mouseDetails = reaper.BR_GetMouseCursorContext()  

if mouseRetval then
	if mouseContext == "track" then 
		if mouseDetails == "item"or mouseDetails == "item_stretch_marker" then
			splitItems()
		end
		if mouseDetails == "empty" then
			if #originalState.selItems > 0 then
				reaper.Main_OnCommand(40757,0) -- Item: Split items at edit cursor
			end	
		end
	end
end
restoreOriginalState(originalState)

reaper.PreventUIRefresh(-1)
reaper.Undo_EndBlock("Smart Split", 0)
