--[[
@description Add First Marker that crosses item to the take name
@version 1.0
@author Claudiohbsantos
@link http://claudiohbsantos.com
@date 2018 04 23
@about
  # Add First Marker that crosses item to the take name
@changelog
  - 
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

function getFirstOverlappingMarker(time_in,time_out)
	for i=0,reaper.CountProjectMarkers(0) -1 do
		local marker = {}
		marker.retval,marker.isrgn, marker.pos,  marker.rgnend,  marker.name,  marker.markrgnindexnumber,  marker.color = reaper.EnumProjectMarkers3(0,i)
		if not marker.isrgn and marker.pos >= time_in and marker.pos <= time_out then
			return marker
		end
	end
end

reaper.Undo_BeginBlock()
reaper.PreventUIRefresh(1)

originalState = saveOriginalState()

for i=0,reaper.CountSelectedMediaItems(0) -1 do
	local item = reaper.GetSelectedMediaItem(0,i)
	local take = reaper.GetActiveTake(item)

	local pos = reaper.GetMediaItemInfo_Value(item,"D_POSITION")
	local itemEnd = reaper.GetMediaItemInfo_Value(item,"D_LENGTH") + pos

	marker = getFirstOverlappingMarker(pos,itemEnd)
	if marker then
		local _,takeName = reaper.GetSetMediaItemTakeInfo_String(take,"P_NAME","",false)
		reaper.GetSetMediaItemTakeInfo_String(take,"P_NAME",marker.name .. "_".. takeName,true)
	end
end

restoreOriginalState(originalState)

reaper.PreventUIRefresh(-1)
reaper.Undo_EndBlock("CS_Add First Marker that crosses item to the take name.lua", 0)
