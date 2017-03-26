-- @description CS_Pro Tools Tab to Next Transient
-- @version 1.0
-- @author Claudiohbsantos
-- @link http://claudiohbsantos.com
-- @date 2017 03 25
-- @about
--   # Pro Tools Tab to Next Transient
--   Tab to Next Transient action mimicking the behaviour of the **Pro Tools DAW** action, which jumps to the next clip once the end of the current one is reached.
-- @changelog
--   + Initial release

reaper.Undo_BeginBlock()
reaper.PreventUIRefresh(1)

numberOfSelItems = reaper.CountSelectedMediaItems(0)
if numberOfSelItems ~= 0 then
	if numberOfSelItems == 1 then
		itemPosition = reaper.GetMediaItemInfo_Value(reaper.GetSelectedMediaItem(0,0), "D_POSITION")
		itemEnd = itemPosition + reaper.GetMediaItemInfo_Value(reaper.GetSelectedMediaItem(0,0), "D_LENGTH")

		if reaper.GetCursorPosition() == itemEnd then
			reaper.Main_OnCommand(40417,0) -- Select and move to next item in track
		else
			reaper.Main_OnCommand(40375,0) --Move to next transient in selected item 
		end
	else
	reaper.Main_OnCommand(40375,0) --Move to next transient in selected item 
	end
else  --No item Selected
	reaper.Main_OnCommand(40417,0) -- Select and move to next item in track
end

reaper.PreventUIRefresh(-1)
reaper.Undo_EndBlock("Pro Tools Tab to Next Transient", 0)
