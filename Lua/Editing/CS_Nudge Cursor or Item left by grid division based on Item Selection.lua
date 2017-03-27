-- @description CS_Nudge Cursor or Item left by grid division based on Item Selection
-- @version 1.0
-- @author Claudiohbsantos
-- @link http://claudiohbsantos.com
-- @date 2017 03 27
-- @about
--   # CS_Nudge Cursor or Item left by grid division based on Item Selection
--   If there is at least 1 item selected, the script nudges the items left by grid division. Otherwise it nudges the edit cursor left by same ammount
-- @changelog
--   - Initial Release

if reaper.CountSelectedMediaItems(0) ~= 0 then 
	reaper.Main_OnCommand(40793,0) -- move item left by grid division
else
	reaper.Main_OnCommand(40646,0) -- nudge cursor left by grid division
end
