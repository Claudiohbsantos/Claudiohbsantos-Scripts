--[[
@description CS_Reset Marker 0 to cursor position
@version 1.0
@author Claudiohbsantos
@link http://claudiohbsantos.com
@date 2017 04 08
@about
  # CS_Reset Marker 0 to cursor position
  Deletes all markers with id 0 and creates a new marker with id 0 at the current edit cursor posisition. When used with "Create Marker 0" actions, can be used to quickly create and remove temporary markers during edit
@changelog
  - Initial Release
--]]
reaper.Undo_BeginBlock()
reaper.PreventUIRefresh(1)
local pos = reaper.GetCursorPosition()
for i=1,100,1 do -- Lazy hack. if there are more than 100 temp markers, some will be ignored. But.... does anyone really need more than 100?
	reaper.DeleteProjectMarker(0, 0, 0)
end
local color = reaper.ColorToNative(200,150,150)|0x1000000
reaper.AddProjectMarker2(0,0,pos,0, "", 0, color)
reaper.PreventUIRefresh(-1)
reaper.Undo_EndBlock("Reset Marker 0 to cursor Position", -1)