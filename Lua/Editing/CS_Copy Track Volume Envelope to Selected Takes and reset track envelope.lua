-- @description CS_Copy Track Volume Envelope to Selected Takes and reset track envelope
-- @version 1.0
-- @author Claudiohbsantos
-- @link http://claudiohbsantos.com
-- @date 2017 03 28
-- @about
--   # CS_Copy Track Volume Envelope to Selected Takes and reset track envelope
--   This script copies the volume envelope from the item track and pastes it onto the selected take volume envelope, overwriting it if it already exists. The Track volume envelope in the section is reset to 0.
-- @changelog
--   - Initial Release

function saveOriginalSelection()
	originalState = {}

	originalState.editCur = reaper.GetCursorPositionEx(0)
	originalState.timeSelStart,originalState.timeSelEnd = reaper.GetSet_LoopTimeRange2(0,false,true,0,0,false)

	originalState.selTracks = {}

	for i=1,reaper.CountSelectedTracks2(0,true),1 do
		originalState.selTracks[#originalState.selTracks+1] = reaper.GetSelectedTrack2(0,i-1,true)
	end
end

function restoreOriginalSelection()
	reaper.SetEditCurPos2(0,originalState.editCur,false,false)

	reaper.GetSet_LoopTimeRange2(0,true,true,originalState.timeSelStart,originalState.timeSelEnd,false)
	reaper.Main_OnCommand(40297,0) -- unselect all tracks
	for i=1, #originalState.selTracks,1 do
		reaper.SetTrackSelected(originalState.selTracks[i],true)
	end

end

reaper.Undo_BeginBlock()
reaper.PreventUIRefresh(1)

saveOriginalSelection()

local TotalSelItems = reaper.CountSelectedMediaItems(0)

local selectedItems = {}
for i=1,TotalSelItems,1 do
	local tempSelItem = reaper.GetSelectedMediaItem(0,i-1)
	local nTakes = reaper.CountTakes(tempSelItem)
	if nTakes ~= 0 then 
		selectedItems[#selectedItems+1] = tempSelItem
	end
end

for i=1,#selectedItems,1 do

	reaper.SelectAllMediaItems(0,false)
	reaper.SetMediaItemSelected(selectedItems[i],true)
	reaper.Main_OnCommand(reaper.NamedCommandLookup("_SWS_SELTRKWITEM"),0) -- select track with selected items


	-- check if track has active volume envelope
	local track = reaper.GetMediaItem_Track(selectedItems[i])
	local trackVolEnv =  reaper.GetTrackEnvelopeByName(track, "Volume")

	if trackVolEnv then
		local brTrackEnv = reaper.BR_EnvAlloc(trackVolEnv, false)
		local trackVolEnvIsActive = reaper.BR_EnvGetProperties(brTrackEnv)

		if trackVolEnvIsActive then
			reaper.Main_OnCommand(40290,0) -- set time selection to item and move edit cursor to beginning

			reaper.Main_OnCommand(41866,0) -- show and select Track VOlume envelope
			reaper.Main_OnCommand(40726,0) -- insert 4 points at edges of time selection

			reaper.Main_OnCommand(40324,0) -- Copy points within time selection
			
			reaper.Main_OnCommand(40330,0) -- select points in time selection

			reaper.Main_OnCommand(40415,0) -- set segment to center	

			reaper.Main_OnCommand(reaper.NamedCommandLookup("_BR_ENV_SEL_SHRINK_RIGHT"),0) -- deselect edge point of right
			reaper.Main_OnCommand(reaper.NamedCommandLookup("_BR_ENV_SEL_SHRINK_LEFT"),0) -- deselect edge point of left

			reaper.Main_OnCommand(40333,0) -- delete selected points

			local nTakes = reaper.CountTakes(selectedItems[i])
			for j=1,nTakes,1 do
				reaper.SetMediaItemSelected(selectedItems[i],true)
				reaper.Main_OnCommand(40290,0) -- set time selection to item and move edit cursor to beginning

				local take = reaper.GetTake(selectedItems[i],j-1)

				reaper.SetActiveTake(take)
				local takeVolEnv = reaper.GetTakeEnvelopeByName(take, "Volume")

				if not takeVolEnv then
					reaper.Main_OnCommand(reaper.NamedCommandLookup("_S&M_TAKEENV1"),0) -- activate take vol envelope
					takeVolEnv = reaper.GetTakeEnvelopeByName(take, "Volume")
				end	

				reaper.SetCursorContext(2, takeVolEnv)
				reaper.Main_OnCommand(40058,0) -- Paste points
			end
		end	

		reaper.BR_EnvFree(brTrackEnv,false)
	end
end

restoreOriginalSelection()

reaper.PreventUIRefresh(-1)
reaper.Undo_EndBlock("CS_Copy Track Volume Envelope to Selected Takes and reset track envelope", 0)