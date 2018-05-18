--[[
@description Only Show Tracks With Items Inside Time Selection
@version 1.0
@author Claudiohbsantos
@link http://claudiohbsantos.com
@date 2018 05 12
@about
  # Only Show Tracks With Items Inside Time Selection
@changelog
  - Initial Release
@provides
	. > CS_Only Show Tracks With Items Inside Time Selection/CS_Only Show Tracks With Items Inside Time Selection.lua
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


---------------------------------------------------------------

local function main()
	reaper.Main_OnCommand(40297,0) -- unselect all tracks

reaper.Main_OnCommand(40717,0) -- select all items in time selection (in all visible tracks)

local nItems = reaper.CountSelectedMediaItems(0)

for i=1,nItems, 1 do
	local item = reaper.GetSelectedMediaItem(0,i-1)
	local track = reaper.GetMediaItem_Track(item)
	reaper.SetTrackSelected(track,true)
end

reaper.Main_OnCommand(reaper.NamedCommandLookup("_SWSTL_SHOWTCPEX"),0) -- only show selected tracks
end

---------------------------------------------------------------
local reaper = reaper

reaper.PreventUIRefresh(1)
reaper.Undo_BeginBlock2(0)

-- if not cs.notRunningOnWindows() then
	main()
-- end

reaper.Undo_EndBlock2(0,"Only Show Tracks With Items Inside Time Selection",-1)
reaper.PreventUIRefresh(-1)
reaper.UpdateArrange()