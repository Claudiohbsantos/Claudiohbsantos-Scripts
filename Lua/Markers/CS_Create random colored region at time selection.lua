--[[
@description CS_Create random colored region at time selection
@version 1.0
@author Claudiohbsantos
@link http://claudiohbsantos.com
@date 2017 04 08
@about
  # CS_Create random colored region at time selection
  Creates a random colored regio at current time selection
@changelog
  - Initial Release
--]]

reaper.Undo_BeginBlock()
reaper.PreventUIRefresh(1)

local timeSelStart,timeSelEnd = reaper.GetSet_LoopTimeRange2(0,false,true,0,0,false)

if timeSelStart ~= timeSelEnd then

	local r = math.random(0,249)
	local g = math.random(0,249)
	local b = math.random(0,249)

	local color = reaper.ColorToNative(r,g,b)|0x1000000

	reaper.AddProjectMarker2(0,true,timeSelStart,timeSelEnd,"",-1,color)
end

reaper.PreventUIRefresh(-1)
reaper.Undo_EndBlock("Create random colored Region", -1)