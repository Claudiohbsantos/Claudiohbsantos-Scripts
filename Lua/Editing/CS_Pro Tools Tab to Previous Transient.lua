-- @noindex
-- @description CS_Pro Tools Tab to Previous Transient
-- @version 1.0
-- @author Claudiohbsantos
-- @link http://claudiohbsantos.com
-- @date dd1
-- @about
--   # CS_Pro Tools Tab to Previous Transient
--   Tab to transient that mimicks Pro Tools behaviour of jumping to previous clip once edge of clip is reached
-- @changelog
--   - Initial Release

reaper.Undo_BeginBlock()
reaper.PreventUIRefresh(1)

numberOfSelItems = reaper.CountSelectedMediaItems(0)
if numberOfSelItems ~= 0 then
	if numberOfSelItems == 1 then
		itemPosition = reaper.GetMediaItemInfo_Value(reaper.GetSelectedMediaItem(0,0), "D_POSITION")

		if reaper.GetCursorPosition() == itemPosition then
			reaper.Main_OnCommand(40416,0) -- Select and move to previous item in track
			reaper.Main_OnCommand(41174,0) --go to end of item
		else
			reaper.Main_OnCommand(40376,0) --Move to previous transient in selected item 
		end
	else
		reaper.Main_OnCommand(40376,0) --Move to previous transient in selected item 
	end	
else  --No item Selected
	reaper.Main_OnCommand(40416,0) -- Select and move to previous item in track
	reaper.Main_OnCommand(41174,0) --go to end of item
end


reaper.PreventUIRefresh(-1)
reaper.Undo_EndBlock("CS_Pro Tools Tab to Previous Transient", 0)
