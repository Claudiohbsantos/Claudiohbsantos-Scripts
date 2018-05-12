--[[
@description DONTDOWNLOAD_REAPACKTEST
@version 0.1beta
@author Claudiohbsantos
@link http://claudiohbsantos.com
@date 2018 05 12
@about
  # DONTDOWNLOAD_REAPACKTEST
@changelog
  - Initial Release
@provides
	. > DONTDOWNLOAD_REAPACKTEST/
	../Libraries/CS_Library.lua > DONTDOWNLOAD_REAPACKTEST/
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

cs.msg("I work")

reaper.Undo_EndBlock2(0,"DONTDOWNLOAD_REAPACKTEST",0)