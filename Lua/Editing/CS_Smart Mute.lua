--[[
@description Smart Mute
@version 1.1
@author Claudiohbsantos
@link http://claudiohbsantos.com
@date 2017 06 12
@about
  # 
  Mutes based on mouse context
@changelog
  - Updated Dependencies
@provides
	. > CS_Smart Mute/CS_Smart Mute.lua
	../Libraries/CS_Library.lua > CS_Smart Mute/CS_Library.lua  
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

function muteItems()
	local mouseItem = reaper.BR_GetMouseCursorContext_Item()

	for i=1,#originalState.selItems,1 do
		if mouseItem == originalState.selItems[i] then
			reaper.Main_OnCommand(40175,0) -- mute items
			return
		end
	end	
	reaper.SelectAllMediaItems(0,false)
	reaper.SetMediaItemSelected(mouseItem,true)
	reaper.Main_OnCommand(40175,0) -- mute Items
	return
end

function muteTracks()
	local mouseTrack = reaper.BR_GetMouseCursorContext_Track()

	for i=1,#originalState.selTracks,1 do
		if mouseTrack == originalState.selTracks[i] then
			reaper.Main_OnCommand(6,0) -- mute tracks
			return
		end
	end
	reaper.Main_OnCommand(40297,0) -- Unselect all tracks
	reaper.SetTrackSelected(mouseTrack,true)
	reaper.Main_OnCommand(6,0) -- mute tracks
	return
end


local function main()
	
	originalState = saveOriginalState()


	mouse = cs.initMouseCaseTables()

	-- mouse.default = {default}
	mouse.arrange.track.item = {muteItems}
	mouse.arrange.track.item_stretch_marker = {muteItems}
	mouse.arrange.track.empty = {muteTracks}
	mouse.tcp.track = {muteTracks}

	cs.executeMouseContextFunction(mouse)

	restoreOriginalState(originalState)


end

---------------------------------------------------------------
local reaper = reaper

reaper.PreventUIRefresh(1)
reaper.Undo_BeginBlock2(0)

-- if not cs.notRunningOnWindows() then
	main()
-- end

reaper.Undo_EndBlock2(0,"Smart Mute",0)
reaper.PreventUIRefresh(-1)
reaper.UpdateArrange()
