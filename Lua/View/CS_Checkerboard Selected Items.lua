--[[
@description Checkerboard Selected Items
@version 1.0
@author Claudiohbsantos
@link http://claudiohbsantos.com
@date 2018 05 12
@about
  # Checkerboard Selected Items
@changelog
  - Initial Release
@provides
	. > CS_Checkerboard Selected Items/CS_Checkerboard Selected Items.lua
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
	local nSelItems = reaper.CountSelectedMediaItems(0)

	local evenItems = {}
	for i = 1, nSelItems - 1, 2 do

		evenItems[#evenItems+1] = reaper.GetSelectedMediaItem(0,i)

	end

	reaper.SelectAllMediaItems(0,false)

	for i=1, #evenItems, 1 do

		reaper.SetMediaItemSelected(evenItems[i],true)
		
	end

	reaper.Main_OnCommand(40118,0)
end

---------------------------------------------------------------
local reaper = reaper

reaper.PreventUIRefresh(1)
reaper.Undo_BeginBlock2(0)

-- if not cs.notRunningOnWindows() then
	main()
-- end

reaper.Undo_EndBlock2(0,"Checkerboard Selected Items",-1)
reaper.PreventUIRefresh(-1)
reaper.UpdateArrange()