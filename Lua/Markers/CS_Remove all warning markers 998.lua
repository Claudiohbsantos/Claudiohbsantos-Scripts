--[[
@description Remove all warning markers (998)
@version 1.0
@author Claudiohbsantos
@link http://claudiohbsantos.com
@date 2018 05 12
@about
  # Remove all warning markers (998)
@changelog
  - Initial Release
--]]

--------------------------------------------------------------
local reaper = reaper
reaper.Undo_BeginBlock2(0)

local totMarkers = reaper.CountProjectMarkers(0)
for i = 0, totMarkers-1 do
	reaper.DeleteProjectMarker(0,998,false)
end

reaper.Undo_EndBlock2(0,"Remove all warning markers (998)",0)