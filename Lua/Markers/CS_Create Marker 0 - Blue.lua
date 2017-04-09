--[[
@description Create Marker 0 - Blue
@version 1.0
@author Claudiohbsantos
@link http://claudiohbsantos.com
@date 2017 04 08
@about
  # Create Marker 0 - Blue
  Creates a blue marker 0 at edit cursor position. Can have many markers 0 created at different positions, and all are reset by action "Reset Marker 0 to Cursor Position", so it can be used to craeate temporary markers
@changelog
  - Initial Release
--]]

reaper.Undo_BeginBlock()
reaper.PreventUIRefresh(1)
local pos = reaper.GetCursorPosition()
local color = reaper.ColorToNative(150,150,200)|0x1000000
reaper.AddProjectMarker2(0,0,pos,0, "", 0, color)
reaper.PreventUIRefresh(-1)
reaper.Undo_EndBlock("Create extra Marker 0", -1)