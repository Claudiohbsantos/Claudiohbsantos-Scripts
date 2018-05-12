--[[
@description Item Disable Invert Phase
@version 1.0
@author Claudiohbsantos
@link http://claudiohbsantos.com
@date 2018 05 11
@about
  # Item Disable Invert Phase
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
	local retval,chunk = reaper.GetItemStateChunk(item,"",false)
	if not retval then break end
	chunk = string.gsub(chunk,"(VOLPAN [%d.-]+ [%d.-]+ )(.)",function (head,val)  if val == "-" then return head else return end end)
	reaper.SetItemStateChunk(item,chunk,false)
end

reaper.UpdateArrange()
reaper.Undo_EndBlock2(0,"Item Disable Invert Phase",0)