--[[
@description Smart Delete
@version 1.5
@author Claudiohbsantos
@link http://claudiohbsantos.com
@date 2017 06 12
@about
  # 
  Deletes based on mouse context
@changelog
  - Updated Dependency loading
@provides
	. > CS_Smart Delete/CS_Smart Delete.lua
	../Libraries/CS_Library.lua > CS_Smart Delete/CS_Library.lua  
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

function deleteItemUnderMouse()
	local mouseItem = reaper.BR_GetMouseCursorContext_Item()

	for i=1,#originalState.selItems,1 do
		if mouseItem == originalState.selItems[i] then
			reaper.Main_OnCommand(40006,0) -- remove items
			originalState.selItems = {}
			return
		end
	end	
	reaper.SelectAllMediaItems(0,false)
	reaper.SetMediaItemSelected(mouseItem,true)
	reaper.Main_OnCommand(40006,0) -- Remove Items
	return
end

function deleteTracks()
	local mouseTrack = reaper.BR_GetMouseCursorContext_Track()

	for i=1,#originalState.selTracks,1 do
		if mouseTrack == originalState.selTracks[i] then
			reaper.Main_OnCommand(40005,0) -- remove tracks
			originalState.selTracks = {}
			return
		end
	end
	reaper.Main_OnCommand(40297,0) -- Unselect all tracks
	reaper.SetTrackSelected(mouseTrack,true)
	reaper.Main_OnCommand(40005,0) -- remove tracks
	return
end

function removeItemTracksEnvelopes()
	reaper.Main_OnCommand(40697,0) -- Remove items/tracks/envelops depending on focus
end

function deleteRegion()
	local pos = reaper.BR_GetMouseCursorContext_Position()
	reaper.SetEditCurPos2(0,pos,false,false)
	reaper.Main_OnCommand(40615,0) -- deleteRegionNearEditCursor
end

function deleteMarkerNearMouse(proximity)

	local pos = reaper.BR_GetMouseCursorContext_Position()
	local marker = cs.getClosestMarker(pos)
	if cs.calculateProximityRelativeToZoom(marker.pos,pos) < proximity then
		reaper.Undo_BeginBlock()
		reaper.DeleteProjectMarker(0,marker.markrgnindexnumber,false)
		reaper.Undo_EndBlock("CS_Smart Delete", 0)
	end
end

function deleteRegionOfItemUnderMouse()
	-- reaper.SelectAllMediaItems(0,false)
	local item = reaper.BR_GetMouseCursorContext_Item()
	if reaper.CountSelectedMediaItems(0) == 0 then
		reaper.SetMediaItemSelected(item,true)
	end
	reaper.Main_OnCommand(40312,0) -- REMOVE SELECTED AREA OF ITEMS
end

function default()
	reaper.Main_OnCommand(40697,0) -- general Delete
end

local function main()
	
	originalState = saveOriginalState()

	local proximity = 0.05
	mouse = cs.initMouseCaseTables()

	mouse.default = {default}
	mouse.tcp.track = {deleteTracks}
	mouse.ruler.region_lane = {deleteRegion}
	mouse.ruler.marker_lane = {deleteMarkerNearMouse,proximity}
	mouse.ruler.tempo_lane = {deleteMarkerNearMouse,proximity}

	mouse.arrange.track.item = {deleteItemUnderMouse}
	mouse.arrange.track.item_stretch_marker = {deleteItemUnderMouse}

	local timeSelStart,timeSelEnd = reaper.GetSet_LoopTimeRange2(0,false,false,0,0,false)
	if timeSelStart ~= timeSelEnd then
		reaper.BR_GetMouseCursorContext()
		local mousePos = reaper.BR_GetMouseCursorContext_Position()
		if mousePos >= timeSelStart and mousePos <= timeSelEnd then
			mouse.arrange.track.item = {deleteRegionOfItemUnderMouse}
			mouse.arrange.track.item_stretch_marker = {deleteRegionOfItemUnderMouse}
		end
	end



	cs.executeMouseContextFunction(mouse)

	reaper.SetEditCurPos2(0,originalState.editCur,false,false)
end

---------------------------------------------------------------
local reaper = reaper

reaper.PreventUIRefresh(1)
reaper.Undo_BeginBlock2(0)

-- if not cs.notRunningOnWindows() then
	main()
-- end

reaper.Undo_EndBlock2(0,"Smart Delete",0)
reaper.PreventUIRefresh(-1)
reaper.UpdateArrange()

------




