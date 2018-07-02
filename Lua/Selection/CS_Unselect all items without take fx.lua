--[[
@description Unselect all items without take fx
@version 1.0
@author Claudiohbsantos
@link http://claudiohbsantos.com
@date 2018 07 02
@about
  # Unselect all items without take fx
@changelog
  - Initial Release
@provides
	. > CS_Unselect all items without take fx/CS_Unselect all items without take fx.lua
	../Libraries/CS_Library.lua > CS_Unselect all items without take fx/CS_Library.lua  
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

local function main()
		for item in cs.selectedItems() do
		local take = reaper.GetActiveTake(item)
		if reaper.TakeFX_GetCount(take) == 0 then
			reaper.SetMediaItemSelected(item,false)
		end
	end
end

---------------------------------------------------------------
local reaper = reaper

reaper.PreventUIRefresh(1)
reaper.Undo_BeginBlock2(0)

-- if not cs.notRunningOnWindows() then
	main()
-- end

reaper.Undo_EndBlock2(0,"Unselect all items without take fx",0)
reaper.PreventUIRefresh(-1)
reaper.UpdateArrange()