--[[
@description Go to highest numbered Marker
@version 1.0
@author Claudiohbsantos
@link http://claudiohbsantos.com
@date 2018 05 12
@about
  # Go to highest numbered Marker
@changelog
  - Initial Release
@provides
	. > CS_Go to highest numbered Marker/CS_Go to highest numbered Marker.lua
--]]
---------------------------------------------------------------
local reaper = reaper
reaper.PreventUIRefresh(1)
reaper.Undo_BeginBlock2(0)

local totalMarkers = reaper.CountProjectMarkers(0)
highestIdx = 0
for i = 1, totalMarkers, 1 do
	_,_,_,_,_,markerIdx = reaper.EnumProjectMarkers2(0,i)
	if markerIdx > highestIdx then highestIdx = markerIdx end
end
reaper.GoToMarker(0	, highestIdx, false)

reaper.Undo_EndBlock2(0,"Go to highest numbered Marker",0)
reaper.PreventUIRefresh(-1)