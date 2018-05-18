--[[
@description Copy selected item before all markers within time selection
@version 1.0
@author Claudiohbsantos
@link http://claudiohbsantos.com
@date 2018 05 12
@about
  # Copy selected item before all markers within time selection
@changelog
  - Initial Release
@provides
	. > CS_Copy selected item before all markers within time selection/CS_Copy selected item before all markers within time selection.lua
--]]

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

local function get_script_path()
		local info = debug.getinfo(1,'S');
		local script_path = info.source:match[[^@?(.*[\/])[^\/]-$]]
		return script_path
	end 

local function loadFromFolder(file)
	local scriptPath = get_script_path()
	package.path = package.path .. ";" .. scriptPath .. "?.lua"
	require(file)
end

---------------------------------------------------------------
local reaper = reaper
reaper.PreventUIRefresh(1)
reaper.Undo_BeginBlock2(0)

saveOriginalSelection()

local totalSelectedItems = reaper.CountSelectedMediaItems(0)		
if totalSelectedItems > 0 then
	reaper.Main_OnCommand(40698,0) -- copy items
	
	reaper.Main_OnCommand(40042,0) -- go to start of timeline
	
	local timeSelStart, timeSelEnd = reaper.GetSet_LoopTimeRange2(0,false,true,0,0,false)

	if timeSelStart ~= timeSelEnd then
		local totalMarkers = reaper.CountProjectMarkers(0)
		for i=1,totalMarkers,1 do
		
			local _,isRegion,markerPos = reaper.EnumProjectMarkers3(0,i-1)
		
			if not isRegion then
		
					if markerPos >= timeSelStart and markerPos <= timeSelEnd then
						reaper.SetEditCurPos2(0,markerPos,false,false)
						reaper.Main_OnCommand(40058,0) -- paste
						reaper.Main_OnCommand(41307,0) -- move right edge of item to edit cursor
				end
			end	
		end
	else
		reaper.ShowMessageBox("You must create a time selection around the markers you wish to use as reference","Error",0)	
	end
else
	reaper.ShowMessageBox("You must select the item you wish to place before the markers","Error",0)
end
restoreOriginalSelection()

reaper.Undo_EndBlock2(0,"Copy selected item before all markers within time selection",0)
reaper.PreventUIRefresh(-1)