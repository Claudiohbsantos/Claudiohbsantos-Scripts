--[[
@description CS_Move Cursor to beginning of Time Selection
@version 1.0
@author Claudiohbsantos
@link http://claudiohbsantos.com
@date 2017 04 08
@about
  # CS_Move Cursor to beginning of Time Selection
  Moves edit cursor to beginning of time selection
@changelog
  - Initial release
--]]
timeSelStart = reaper.GetSet_LoopTimeRange2(0, false, false, 0, 0, false)
reaper.SetEditCurPos2(0,timeSelStart,false,false)	

