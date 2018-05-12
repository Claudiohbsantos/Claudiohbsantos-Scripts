--[[
@description Item Disable LoopSource
@version 1.0
@author Claudiohbsantos
@link http://claudiohbsantos.com
@date 2018 05 10
@about
  # Item Disable LoopSource
@changelog
  - Initial Release
--]]

local function loadCSLibrary()
	local function get_script_path()
		local info = debug.getinfo(1,'S');
		local script_path = info.source:match[[^@?(.*[\/])[^\/]-$]]
		return script_path
	end 

	local scriptPath = get_script_path()
	package.path = package.path .. ";" .. scriptPath .. "?.lua"
	local library = "CS_Library"
	require(library)
end

---------------------------------------------------------------
local reaper = reaper
loadCSLibrary()


reaper.Undo_BeginBlock2(0)

for item in cs.selectedItems(0) do
	reaper.SetMediaItemInfo_Value(item,"B_LOOPSRC",0)
end
reaper.UpdateArrange()
reaper.Undo_EndBlock2(0,"Disable Items Loop Source",0)