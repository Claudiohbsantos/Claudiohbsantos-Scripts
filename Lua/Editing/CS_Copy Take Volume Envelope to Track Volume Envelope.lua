--[[
@description Copy Take Volume Envelope to Track Volume Envelope
@version 1.1
@author Claudiohbsantos
@link http://claudiohbsantos.com
@date 2018 05 12
@about
  # Copy Take Volume Envelope to Track Volume Envelope
@changelog
  - Updated Dependency Loading
@provides
	. > CS_Copy Take Volume Envelope to Track Volume Envelope/CS_Copy Take Volume Envelope to Track Volume Envelope.lua
	../Libraries/CS_Library.lua > CS_Copy Take Volume Envelope to Track Volume Envelope/CS_Library.lua  
--]]


local function get_script_path()
		local info = debug.getinfo(1,'S');
		local script_path = info.source:match[[^@?(.*[\/])[^\/]-$]]
		return script_path
	end 

function prequire(...)
    local status, lib = pcall(require, ...)
    if(status) then return lib end
    --Library failed to load, so perhaps return `nil` or something?
    reaper.ShowMessageBox("Missing Assets. Please Uninstall and Reinstall via Reapack","ERROR",0)
    return nil
end

local function loadFromFolder(file)
	local scriptPath = get_script_path()
	package.path = package.path .. ";" .. scriptPath .. "?.lua"
	return prequire(file)
end

local cs = loadFromFolder("CS_Library")

---------------------------------------------------------------
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

local function main()
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
		reaper.Main_OnCommand(40290,0) -- set time selection to item and move edit cursor to beginning

		local take = reaper.GetActiveTake(selectedItems[i])

		local takeVolEnv = reaper.GetTakeEnvelopeByName(take, "Volume")

		if takeVolEnv then

			local brTakeEnv = reaper.BR_EnvAlloc(takeVolEnv,true)
			local takeVolEnvIsActive = reaper.BR_EnvGetProperties(brTakeEnv)

			if takeVolEnvIsActive then
				takeVolEnv = reaper.GetTakeEnvelopeByName(take, "Volume")

				local track = reaper.GetMediaItem_Track(selectedItems[i])
				reaper.Main_OnCommand(41866,0) -- show and select Track VOlume envelope
				local trackVolEnv =  reaper.GetTrackEnvelopeByName(track, "Volume")

					local brTrackEnv = reaper.BR_EnvAlloc(trackVolEnv, false)
					local trackVolEnvIsActive,_, armed, inLane, laneHeight, defaultShape, faderScaling = reaper.BR_EnvGetProperties(brTrackEnv)


					reaper.BR_EnvSetProperties(brTrackEnv,true,true,armed,inLane,laneHeight,defaultShape,faderScaling)

					reaper.SetCursorContext(2, takeVolEnv)
					reaper.Main_OnCommand(reaper.NamedCommandLookup("_BR_INSERT_2_ENV_POINT_TIME_SEL"),0) -- add 2 points
					reaper.Main_OnCommand(40324,0) -- Copy points within time selection
					reaper.Main_OnCommand(40330,0) -- select points in time selection
					reaper.Main_OnCommand(40333,0) -- delete selected points
					reaper.Main_OnCommand(reaper.NamedCommandLookup("_S&M_TAKEENV4"),0) -- hide take volume envelope

					reaper.Main_OnCommand(41866,0) -- show and select Track VOlume envelope
					reaper.Main_OnCommand(40726,0) -- insert 4 points at edges of time selection
					reaper.Main_OnCommand(40058,0) -- Paste points

					reaper.BR_EnvFree(brTrackEnv,false)
			end
		end	
	end

	restoreOriginalSelection()
end

---------------------------------------------------------------
local reaper = reaper

reaper.PreventUIRefresh(1)
reaper.Undo_BeginBlock2(0)

-- if not cs.notRunningOnWindows() then
	main()
-- end

reaper.Undo_EndBlock2(0,"Copy Take Volume Envelope to Track Volume Envelope",0)
reaper.PreventUIRefresh(-1)
reaper.UpdateArrange()


