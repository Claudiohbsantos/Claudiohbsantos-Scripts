-- @description CS_Nudge Cursor or Item right by grid division based on Item Selection
-- @version 1.0
-- @author Claudiohbsantos
-- @link http://claudiohbsantos.com
-- @date 2017 03 27
-- @about
--   # CS_Nudge Cursor or Item right by grid division based on Item Selection
--   If there is at least 1 item selected, the script nudges the items right by grid division. Otherwise it nudges the edit cursor right by same ammount
-- @changelog
--   - Initial Release

if reaper.CountSelectedMediaItems(0) ~= 0 then 
	reaper.Main_OnCommand(40794,0) -- move item right by grid division
else
	reaper.Main_OnCommand(40647,0) -- nudge cursor right by grid division
end