-- @description CS_Remove Selected area of Item and select right portion
-- @version 1.0
-- @author Claudiohbsantos
-- @link http://claudiohbsantos.com
-- @date 2017 03 28
-- @about
--   # CS_Remove Selected area of Item and select right portion
--   Removes area within time selection of selected item and selects right portion of remaining clip
--   Specially useful in custom actions, such as paired with Snap to Previous Clip to create an action that removes selected area and closes gap without moving the whole track.
-- @changelog
--   - Initial Release

reaper.Undo_BeginBlock()
reaper.PreventUIRefresh(1)

if reaper.CountSelectedMediaItems(0) == 1 then 
	reaper.Main_OnCommand(40312,0) -- remove selected area of item
	reaper.SetMediaItemSelected(reaper.GetSelectedMediaItem(0,0),0) -- deselect left portion
else
	reaper.Main_OnCommand(40312,0) -- remove selected area of item
end

reaper.PreventUIRefresh(-1)
reaper.Undo_EndBlock("CS_Remove area of item and select right portion", 0)