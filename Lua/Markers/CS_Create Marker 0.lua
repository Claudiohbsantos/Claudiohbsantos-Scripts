--[[
@description Create Marker 0 - Red
@version 1.0
@author Claudiohbsantos
@link http://claudiohbsantos.com
@date 2017 04 08
@about
  # Create Marker 0
  Creates a marker with ID 0 and color red at the edit cursor position. Many markers with the same id can be added and removed at once with the "Reset Marker 0 to cursor position" action, so it's great to use as a temporary marker
@changelog
  - Initial Release
--]]

reaper.Undo_BeginBlock()
reaper.PreventUIRefresh(1)

local pos = reaper.GetCursorPosition()
local color = reaper.ColorToNative(200,150,150)|0x1000000
reaper.AddProjectMarker2(0,0,pos,0, "", 0, color)

reaper.PreventUIRefresh(-1)
reaper.Undo_EndBlock("Create extra Marker 0", -1)