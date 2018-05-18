--[[
@description Show FX Chain for item or Track depending on mouse context
@version 1.0
@author Claudiohbsantos
@link http://claudiohbsantos.com
@date 2018 05 12
@about
  # Show FX Chain for item or Track depending on mouse context
@changelog
  - Initial Release
@provides
	. > CS_Show FX Chain for item or Track depending on mouse context/CS_Show FX Chain for item or Track depending on mouse context.lua
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
	windowHovered = reaper.BR_GetMouseCursorContext()

	if windowHovered == "tcp" then
		reaper.Main_OnCommand(reaper.NamedCommandLookup("_S&M_TOGLFXCHAIN"),0) -- show fx window for selected track
	else
		reaper.Main_OnCommand(40638,0) -- show fx chain for item take
	end
end

---------------------------------------------------------------
local reaper = reaper

reaper.PreventUIRefresh(1)
reaper.Undo_BeginBlock2(0)

-- if not cs.notRunningOnWindows() then
	main()
-- end

reaper.Undo_EndBlock2(0,"Show FX Chain for item or Track depending on mouse context",-1)
reaper.PreventUIRefresh(-1)
reaper.UpdateArrange()	