--[[
@description Item Disable Invert Phase
@version 1.1
@author Claudiohbsantos
@link http://claudiohbsantos.com
@date 2018 05 11
@about
  # Item Disable Invert Phase
@changelog
	- Updated Dependency loading
@provides
	. > CS_Item Disable Invert Phase/CS_Item Disable Invert Phase.lua
	../Libraries/CS_Library.lua > CS_Item Disable Invert Phase/CS_Library.lua  
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
	for item in cs.selectedItems(0) do
		local retval,chunk = reaper.GetItemStateChunk(item,"",false)
		if not retval then break end
		chunk = string.gsub(chunk,"(VOLPAN [%d.-]+ [%d.-]+ )(.)",function (head,val)  if val == "-" then return head else return end end)
		reaper.SetItemStateChunk(item,chunk,false)
	end
end

---------------------------------------------------------------
local reaper = reaper

reaper.PreventUIRefresh(1)
reaper.Undo_BeginBlock2(0)

-- if not cs.notRunningOnWindows() then
	main()
-- end

reaper.Undo_EndBlock2(0,"Item Disable Invert Phase",0)
reaper.PreventUIRefresh(-1)
reaper.UpdateArrange()