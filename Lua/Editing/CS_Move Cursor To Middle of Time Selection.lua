--[[
@description CS_Move Cursor To Middle of Time Selection
@version 1.0
@author Claudiohbsantos
@link http://claudiohbsantos.com
@date 2017 04 08
@about
  # CS_Move Cursor To Middle of Time Selection
  Moves edit cursor to middle of current time selection
@changelog
  - Initial Release
--]]

reaper.Undo_BeginBlock()
reaper.PreventUIRefresh(1)

	local timeSelStart,timeSelEnd = reaper.GetSet_LoopTimeRange2(0,false,true,0,0,false)
	local cursorPos = (timeSelEnd - timeSelStart)/2 + timeSelStart
	reaper.SetEditCurPos2(0,cursorPos,false,false)

reaper.PreventUIRefresh(-1)
reaper.Undo_EndBlock("Move to middle of time Selection", 0)
