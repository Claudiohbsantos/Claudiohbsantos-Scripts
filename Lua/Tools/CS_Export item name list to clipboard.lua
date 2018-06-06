--[[
@description Export item name list to TXT
@version 1.0
@author Claudiohbsantos
@link http://claudiohbsantos.com
@date 2018 06 04
@about
  # Export item name list to TXT
@changelog
  - Initial Release
@provides
	. > CS_Export item name list to clipboard/CS_Export item name list to clipboard.lua
	../Libraries/CS_Library.lua > CS_Export item name list to clipboard/CS_Library.lua  
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
	local nameList = {}
	for item in cs.selectedItems(0) do
		local take = reaper.GetActiveTake(item)
		if not take then break end
		local _,takeName = reaper.GetSetMediaItemTakeInfo_String(take,"P_NAME","",false)
		if takeName and takeName ~= "" then
			table.insert(nameList,takeName)
		end
	end
	if #nameList > 0 then reaper.CF_SetClipboard(table.concat(nameList,"\n")) end
end

---------------------------------------------------------------
local reaper = reaper

reaper.PreventUIRefresh(1)
reaper.Undo_BeginBlock2(0)

-- if not cs.notRunningOnWindows() then
	main()
-- end

reaper.Undo_EndBlock2(0,"Export item name list to clipboard",0)
reaper.PreventUIRefresh(-1)
reaper.UpdateArrange()