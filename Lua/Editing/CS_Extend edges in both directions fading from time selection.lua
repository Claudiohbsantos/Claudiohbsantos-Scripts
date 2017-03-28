-- @description CS_Extend edges in both directions fading from time selection
-- @version 1.0
-- @author Claudiohbsantos
-- @link http://claudiohbsantos.com
-- @date 2017 03 27
-- @about
--   # CS_Extend edges in both directions fading from time selection
--   Extends both clip edges, creating fades if there is a time selection within the clip
-- @changelog
--   - Initial Release
reaper.Undo_BeginBlock()
reaper.PreventUIRefresh(1)

reaper.Main_OnCommand(40596,0) -- clear item edges locking mode

reaper.Main_OnCommand(40225,0) -- grow left edge
reaper.Main_OnCommand(40225,0) -- grow left edge
reaper.Main_OnCommand(40225,0) -- grow left edge
reaper.Main_OnCommand(40225,0) -- grow left edge
reaper.Main_OnCommand(40225,0) -- grow left edge
reaper.Main_OnCommand(40225,0) -- grow left edge

reaper.Main_OnCommand(40228,0) -- grow right edge
reaper.Main_OnCommand(40228,0) -- grow right edge
reaper.Main_OnCommand(40228,0) -- grow right edge
reaper.Main_OnCommand(40228,0) -- grow right edge
reaper.Main_OnCommand(40228,0) -- grow right edge
reaper.Main_OnCommand(40228,0) -- grow right edge


local timeSelStart, timeSelEnd = reaper.GetSet_LoopTimeRange2(0, false,false, 0, 0, false)
if timeSelStart ~= timeSelEnd then	
	reaper.Main_OnCommand(reaper.NamedCommandLookup("_SWS_AWFADESEL"),0) -- sws fade
end

reaper.Main_OnCommand(40595,0) -- set item edges locking mode

reaper.PreventUIRefresh(-1)
reaper.Undo_EndBlock("CS_Extend edges in both directions fading from time selection", 0)