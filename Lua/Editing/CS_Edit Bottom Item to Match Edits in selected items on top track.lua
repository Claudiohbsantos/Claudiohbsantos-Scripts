-- @description CS_Edit Bottom Item to Match Edits in selected items on top track
-- @version 1.0		
-- @author Claudiohbsantos
-- @link http://claudiohbsantos.com
-- @date 2017 03 27
-- @about
--   # CS_Edit Bottom Item to Match Edits in selected items on top track
--   This script mirrors the cuts and fades on items on the top track onto a long item below them. Very useufl to crate quick layering of atmos and pads once you've edited one of the layers.
--   ## Instructions:
--   * Select items on 2 tracks (tracks don't need to be contiguous).
--   * Make sure there is only a single item selected on the bottom track
-- @changelog
--   --  Initial Release

function copyitemparams(item)
	pos = reaper.GetMediaItemInfo_Value(item, "D_POSITION" )
	len = reaper.GetMediaItemInfo_Value(item, "D_LENGTH" )
	filen = reaper.GetMediaItemInfo_Value(item, "D_FADEINLEN" )
	folen = reaper.GetMediaItemInfo_Value(item, "D_FADEOUTLEN" )
	fidir = reaper.GetMediaItemInfo_Value(item, "D_FADEINDIR" )
	fodir = reaper.GetMediaItemInfo_Value(item, "D_FADEOUTDIR" )
	fiauto = reaper.GetMediaItemInfo_Value(item, "D_FADEINLEN_AUTO" )
	foauto = reaper.GetMediaItemInfo_Value(item, "D_FADEOUTLEN_AUTO" )
	fishape = reaper.GetMediaItemInfo_Value(item, "D_FADEINSHAPE" )
	foshape = reaper.GetMediaItemInfo_Value(item, "D_FADEOUTSHAPE" )
end

function pasteitemparams(item,fadein,fadeout)
 
	if fadein == 1 then
		reaper.SetMediaItemInfo_Value(item, "D_FADEINSHAPE", fishape)
		reaper.SetMediaItemInfo_Value(item, "D_FADEINLEN_AUTO", fiauto)
		reaper.SetMediaItemInfo_Value(item, "D_FADEINDIR", fidir)
		reaper.SetMediaItemInfo_Value(item, "D_FADEINLEN", filen)
	end

	 if fadeout == 1 then
		reaper.SetMediaItemInfo_Value(item, "D_FADEOUTLEN", folen)	
		reaper.SetMediaItemInfo_Value(item, "D_FADEOUTDIR", fodir)	
		reaper.SetMediaItemInfo_Value(item, "D_FADEOUTLEN_AUTO", foauto)
		reaper.SetMediaItemInfo_Value(item, "D_FADEOUTSHAPE", foshape)
	end

end

reaper.Undo_BeginBlock()

reaper.PreventUIRefresh(1)

reaper.Main_OnCommand(40596,0) -- toggle edit locking

abort = 0
items = {}
edits = {}

tot_items = reaper.CountSelectedMediaItems(0)
firsttrack = reaper.GetMediaItemTrack(reaper.GetSelectedMediaItem(0,0))
lasttrack = reaper.GetMediaItemTrack(reaper.GetSelectedMediaItem(0,tot_items-1))

if firsttrack == lasttrack then
	reaper.ShowMessageBox("Select at least 2 items 2 different tracks", "Error", 0)
	abort = 1
else
	if reaper.GetMediaItemTrack(reaper.GetSelectedMediaItem(0,tot_items-2)) == lasttrack then
		reaper.ShowMessageBox("You should only select 1 item in the bottom track", "Error", 0)
		abort = 1
	end	
end	

if abort ~= 1 then

	for i=1,tot_items,1 do -- store selected items
		items[i] = reaper.GetSelectedMediaItem(0,i-1)
	end

	for i=1,#items-1,1 do -- get positions and params
		track = reaper.GetMediaItemTrack(items[i])

		if track == firsttrack then 
			fadein = 0
			fadeout = 0

			copyitemparams(items[i])

			reaper.SelectAllMediaItems(0, 0)
			reaper.SetMediaItemSelected(items[#items], 1)

			--abort if template item is after end of bottom item
			if pos >= reaper.GetMediaItemInfo_Value(items[#items], "D_POSITION" ) + reaper.GetMediaItemInfo_Value(items[#items], "D_LENGTH" ) then
				reaper.Main_OnCommand(40697,1) -- delete . (remove excess at bottom)
				break
			end

			if pos >= reaper.GetMediaItemInfo_Value(items[#items], "D_POSITION" ) then
				reaper.SetEditCurPos(pos, 0, 0) -- place cursor on start of item
				reaper.Main_OnCommand(41305,1) -- trim left edge
				fadein = 1
			end	

			if pos+len <= reaper.GetMediaItemInfo_Value(items[#items], "D_POSITION" ) + reaper.GetMediaItemInfo_Value(items[#items], "D_LENGTH" ) then
				reaper.SetEditCurPos(pos+len, 0, 0) -- place cursor on end of item
				if i == #items-1 then 
					reaper.Main_OnCommand(41311,1) -- trim right edge
				else
					reaper.Main_OnCommand(40759,1) -- split item
				end
				fadeout = 1
			end	

			pasteitemparams(items[#items],fadein,fadeout)

			items[#items] = reaper.GetSelectedMediaItem(0,0) -- change selection to remaining portion of bottom item

		end

	end
end
reaper.Main_OnCommand(40595,0) -- enable edit locking
reaper.PreventUIRefresh(-1)
reaper.Undo_EndBlock("Edit Bottom Item to Match cuts in selected items on top track", 0)