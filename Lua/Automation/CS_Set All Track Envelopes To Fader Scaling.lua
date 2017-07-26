--[[
@description Set All Track Envelopes To Fader Scaling
@version 1.0beta
@author Claudiohbsantos
@link http://claudiohbsantos.com
@date 
@about
  # Set All Track Envelopes To Fader Scaling
  - 
@changelog
  - Initial Release
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

function setTrackEnvToFaderScaling(track)
	local name = ""

	local env = reaper.GetTrackEnvelope(track, 0)
	local hideEnvAtEnd = false
	if not env then 
		hideEnvAtEnd = true
		reaper.SetOnlyTrackSelected(track)
		reaper.Main_OnCommand(40406,0) -- toggle vol env visible
		env = reaper.GetTrackEnvelope(track, 0)
	end

	local brENV = reaper.BR_EnvAlloc(env,false)
	local active, visible, armed, inLane, laneHeight, defaultShape, minValue, maxValue, centerValue, type, faderscaling = reaper.BR_EnvGetProperties(brENV)
	reaper.BR_EnvSetProperties(brENV, active, visible, armed, inLane, laneHeight, defaultShape, true)
	reaper.BR_EnvFree(brENV,true)

	if hideEnvAtEnd then
		reaper.Main_OnCommand(40406,0) -- toggle vol env visible
	end
end

function forEachTrack(func)
	local tTracks = reaper.CountTracks(0)
	for i=1,tTracks, 1 do
		local track = reaper.GetTrack(0,i-1)
		func(track)
	end
end

--------------
reaper.Undo_BeginBlock()
reaper.PreventUIRefresh(1)

originalState = saveOriginalState()

	forEachTrack(setTrackEnvToFaderScaling)

restoreOriginalState(originalState)

reaper.PreventUIRefresh(-1)
reaper.Undo_EndBlock("Set All Track Envelopes to Fader Scaling", 0)