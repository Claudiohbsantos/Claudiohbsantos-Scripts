-- @description CS_Extend Item to Full Length
-- @version 2.1
-- @author Claudiohbsantos
-- @link http://claudiohbsantos.com
-- @date 2017 03 27
-- @about
--   # CS_Extend Item to Full Length
--   Extends selected items to it's full length in place.
-- @changelog
--   - Script now keeps item selected after extending

reaper.Undo_BeginBlock()
reaper.PreventUIRefresh(1)

items = {}

tot_items = reaper.CountSelectedMediaItems(0)

for i=1,tot_items,1 do
	items[i] = reaper.GetSelectedMediaItem(0,i-1)
end

reaper.SelectAllMediaItems(0,0) 

for i=1,tot_items,1 do
	
	reaper.SetMediaItemSelected(items[i],1)

	activeTake = reaper.GetActiveTake(items[i])
	shift = reaper.GetMediaItemTakeInfo_Value(activeTake,"D_STARTOFFS")
	rate = reaper.GetMediaItemTakeInfo_Value(activeTake, "D_PLAYRATE")
	position = reaper.GetMediaItemInfo_Value(items[i],"D_POSITION")
	for c=0,reaper.CountTakes(items[i])-1,1 do
		take = reaper.GetTake(items[i], c)
	-- FIx for items in beginning of timeline
		if position-shift/rate < 0 then
			reaper.SetMediaItemTakeInfo_Value(take,"D_STARTOFFS",math.abs(position-shift/rate))
		else
			reaper.SetMediaItemTakeInfo_Value(take,"D_STARTOFFS",0)		
		end	
	end
		if position-shift/rate < 0 then
			reaper.SetMediaItemPosition(items[i], 0,0)
		else
			reaper.SetMediaItemPosition(items[i], position-shift/rate,0)	
		end

		reaper.Main_OnCommand(40612,0) -- extend to full length
		reaper.SelectAllMediaItems(0,0)
end

for i=1,#items,1 do
	reaper.SetMediaItemSelected(items[i],true)
end

reaper.PreventUIRefresh(-1)
reaper.Undo_EndBlock("Extend item to it's full length", 0)
