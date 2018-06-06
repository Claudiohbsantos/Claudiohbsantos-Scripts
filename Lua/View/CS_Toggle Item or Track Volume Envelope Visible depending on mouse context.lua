--[[
@description Toggle Item or Track Volume Envelope Visible depending on mouse context
@version 1.0
@author Claudiohbsantos
@link http://claudiohbsantos.com
@date 2018 06 06
@about
  # Toggle Item or Track Volume Envelope Visible depending on mouse context
@changelog
  - Initial Release
@provides
	. > CS_Toggle Item or Track Volume Envelope Visible depending on mouse context/CS_Toggle Item or Track Volume Envelope Visible depending on mouse context.lua
	../Libraries/CS_Library.lua > CS_Toggle Item or Track Volume Envelope Visible depending on mouse context/CS_Library.lua  
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
	local mouse = {}
	mouse.window,mouse.segment,mouse.detail = reaper.BR_GetMouseCursorContext()

	local item = reaper.BR_GetMouseCursorContext_Item()
	if item then	
		if not reaper.IsMediaItemSelected(item) then
			reaper.SelectAllMediaItems(0,0)
			reaper.SetMediaItemSelected(item,true)
		end
		reaper.Main_OnCommand(40693,0) -- take volume toggle
		return
	end

	local track = reaper.BR_GetMouseCursorContext_Track()
	if track then
		if not reaper.IsTrackSelected(track) then
			reaper.SetOnlyTrackSelected(track)
		end
		reaper.Main_OnCommand(40406,0) -- toggle track volume envelope visible
	end


end

---------------------------------------------------------------
local reaper = reaper

reaper.PreventUIRefresh(1)
reaper.Undo_BeginBlock2(0)

-- if not cs.notRunningOnWindows() then
	local originalState = cs.saveOriginalState()
	main()
	cs.restoreOriginalState(originalState)
-- end

reaper.Undo_EndBlock2(0,"Toggle Item or Track Volume Envelope Visible depending on mouse context",0)
reaper.PreventUIRefresh(-1)
reaper.UpdateArrange()