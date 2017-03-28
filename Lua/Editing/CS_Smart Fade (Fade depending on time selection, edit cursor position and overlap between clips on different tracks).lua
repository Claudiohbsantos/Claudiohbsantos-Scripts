-- @description CS_Smart Fade (Fade depending on time selection, edit cursor position and overlap between clips on different tracks)
-- @version 2.1
-- @author Claudiohbsantos
-- @link http://claudiohbsantos.com
-- @date 2017 03 28
-- @about
--   # CS_Smart Fade (Fade depending on time selection, edit cursor position and overlap between clips)
--   - If a single item is selected:
--     - If edit cursor is closer to start of item : **Fade In**
--     - If edit cursor is closer to end of item : **Fade Out**
--     - If there is a time selection over item : **Fade In/Out in Time selection**
--   - If Two items on same track are selected:
--     - If they overlap and there is no time selection: **Create crossfade on overlap**
--     - If they overlap and there is a time selection that includes the overlap: **Expand items and crossfade on time selection**
--     - If they don't overlap and there is a time selection enveloping their gap/split point: **Expand items and crossfade on time selection**
--   - If two or three items are selected on different tracks and they overlap in time : **Create fades on time overlap**
-- @changelog
--   - added support for non-overlapping conditions on 2 items on different tracks

function saveTimeSelection()
	timeSelStart,timeSelEnd = reaper.GetSet_LoopTimeRange2(0,false,false,0,0,false)
end

function restoreTimeSelection()
	reaper.GetSet_LoopTimeRange2(0,true,true,timeSelStart,timeSelEnd,false)
end

reaper.Undo_BeginBlock()

reaper.PreventUIRefresh(1)

local nSelectedItems = reaper.CountSelectedMediaItems(0)

if nSelectedItems == 2 then
	saveTimeSelection()

	local item1 = reaper.GetSelectedMediaItem(0,0)
	local item2 = reaper.GetSelectedMediaItem(0,1)

	local item1Track = reaper.GetMediaItem_Track(item1)
	local item2Track = reaper.GetMediaItem_Track(item2)

	local item1Start = reaper.GetMediaItemInfo_Value(item1,"D_POSITION")
	local item2Start = reaper.GetMediaItemInfo_Value(item2,"D_POSITION")

	local item1End = reaper.GetMediaItemInfo_Value(item1,"D_LENGTH") + item1Start
	local item2End = reaper.GetMediaItemInfo_Value(item2,"D_LENGTH") + item2Start

	if item1Track ~= item2Track then 
		if timeSelStart ~= timeSelEnd then
			if item1Start < timeSelStart and item1End > timeSelStart and item1End < timeSelEnd
				and  item2Start > timeSelStart and item2Start < timeSelEnd and item2End > timeSelEnd then

				local item2newOffset = item2Start - timeSelStart
					reaper.SetMediaItemPosition(item2,timeSelStart,false)
					reaper.SetMediaItemLength(item2,item2End-item2Start+item2newOffset,false)
					for i=0,reaper.CountTakes(item2)-1,1 do
						local take = reaper.GetTake(item2,i)
						local currentOffset = reaper.GetMediaItemTakeInfo_Value(take,"D_STARTOFFS")
						reaper.SetMediaItemTakeInfo_Value(take,"D_STARTOFFS",currentOffset-item2newOffset)
					end

				reaper.SetMediaItemLength(item1,timeSelEnd-item1Start,false)
				reaper.Main_OnCommand(reaper.NamedCommandLookup("_SWS_AWFADESEL"),0) -- sws smart fade
			end

			if item2Start < timeSelStart and item2End > timeSelStart and item2End < timeSelEnd 
				and item1Start > timeSelStart and item1Start < timeSelEnd and item1End > timeSelEnd then

				local item1newOffset = item1Start - timeSelStart
					reaper.SetMediaItemPosition(item1,timeSelStart,false)
					reaper.SetMediaItemLength(item1,item1End-item1Start+item1newOffset,false)
					for i=0,reaper.CountTakes(item1)-1,1 do
						local take = reaper.GetTake(item1,i)
						local currentOffset = reaper.GetMediaItemTakeInfo_Value(take,"D_STARTOFFS")
						reaper.SetMediaItemTakeInfo_Value(take,"D_STARTOFFS",currentOffset-item1newOffset)
					end

				reaper.SetMediaItemLength(item2,timeSelEnd-item2Start,false)
				reaper.Main_OnCommand(reaper.NamedCommandLookup("_SWS_AWFADESEL"),0) -- sws smart fade
			end
		else
			if item1Start < item2Start and item1End < item2End then
				reaper.GetSet_LoopTimeRange2(0,true,false,item2Start,item1End,false)
				reaper.Main_OnCommand(reaper.NamedCommandLookup("_SWS_AWFADESEL"),0) -- sws smart fade
			end

			if item1Start < item2Start and item1End > item2End then
				reaper.GetSet_LoopTimeRange2(0,true,false,item2Start,item2End,false)
				reaper.Main_OnCommand(reaper.NamedCommandLookup("_SWS_AWFADESEL"),0) -- sws smart fade
			end

			if item2Start < item1Start and item2End < item1End then
				reaper.GetSet_LoopTimeRange2(0,true,false,item1Start,item2End,false)
				reaper.Main_OnCommand(reaper.NamedCommandLookup("_SWS_AWFADESEL"),0) -- sws smart fade
			end

			if item2Start < item1Start and item2End > item1End then
				reaper.GetSet_LoopTimeRange2(0,true,false,item1Start,item1End,false)
				reaper.Main_OnCommand(reaper.NamedCommandLookup("_SWS_AWFADESEL"),0) -- sws smart fade
			end
		end
	else
		if timeSelStart ~= timeSelEnd then
			if item1End > item2Start then-- if both items overlap
				if timeSelStart < item1End and timeSelEnd > item2Start then
					reaper.Main_OnCommand(40916,0) -- crossfade items within time selection
				else	
					reaper.Main_OnCommand(41059,0) -- crossfade any overlapping items
				end
			else
				if timeSelStart > item1Start and timeSelStart < item1End and timeSelEnd > item2Start and timeSelEnd < item2End then
					local item2newOffset = item2Start - timeSelStart
					reaper.SetMediaItemPosition(item2,timeSelStart,false)
					reaper.SetMediaItemLength(item2,item2End-item2Start+item2newOffset,false)
					for i=0,reaper.CountTakes(item2)-1,1 do
						local take = reaper.GetTake(item2,i)
						local currentOffset = reaper.GetMediaItemTakeInfo_Value(take,"D_STARTOFFS")
						reaper.SetMediaItemTakeInfo_Value(take,"D_STARTOFFS",currentOffset-item2newOffset)
					end

					reaper.SetMediaItemLength(item1,timeSelEnd-item1Start,false)
					reaper.Main_OnCommand(41059,0) -- crossfade any overlapping items
				end
			end	
		else
			reaper.Main_OnCommand(41059,0) -- crossfade any overlapping items
		end
	end

	restoreTimeSelection()
else
	if nSelectedItems == 3 then
		saveTimeSelection()

		local item1 = reaper.GetSelectedMediaItem(0,0)
		local item2 = reaper.GetSelectedMediaItem(0,1)
		local item3 = reaper.GetSelectedMediaItem(0,2)

		local item1Track = reaper.GetMediaItem_Track(item1)
		local item2Track = reaper.GetMediaItem_Track(item2)
		local item3Track = reaper.GetMediaItem_Track(item3)

		if (item1Track ~= item2Track and item1Track ~= item3Track) or
			(item3Track ~= item1Track and item3Track ~= item2Track) then  
			
			local item1Start = reaper.GetMediaItemInfo_Value(item1,"D_POSITION")
			local item2Start = reaper.GetMediaItemInfo_Value(item2,"D_POSITION")
			local item3Start = reaper.GetMediaItemInfo_Value(item3,"D_POSITION")

			local item1End = reaper.GetMediaItemInfo_Value(item1,"D_LENGTH") + item1Start
			local item2End = reaper.GetMediaItemInfo_Value(item2,"D_LENGTH") + item2Start
			local item3End = reaper.GetMediaItemInfo_Value(item3,"D_LENGTH") + item3Start


			if item1Start > item2Start and item2End < item1End and item3Start > item1Start and item3End > item1End and item2End < item3Start then
				reaper.SelectAllMediaItems(0,false)
				reaper.SetMediaItemSelected(item1,true)
				reaper.SetMediaItemSelected(item2,true)
				reaper.GetSet_LoopTimeRange2(0,true,false,item1Start,item2End,false)
				reaper.Main_OnCommand(reaper.NamedCommandLookup("_SWS_AWFADESEL"),0) -- sws smart fade

				reaper.SelectAllMediaItems(0,false)
				reaper.SetMediaItemSelected(item1,true)
				reaper.SetMediaItemSelected(item3,true)
				reaper.GetSet_LoopTimeRange2(0,true,false,item3Start,item1End,false)
				reaper.Main_OnCommand(reaper.NamedCommandLookup("_SWS_AWFADESEL"),0) -- sws smart fade
			end

			if item1Start < item3Start and item1End > item3Start and item2Start > item1End and item2Start < item3End and item2End > item3End then
				reaper.SelectAllMediaItems(0,false)
				reaper.SetMediaItemSelected(item1,true)
				reaper.SetMediaItemSelected(item3,true)
				reaper.GetSet_LoopTimeRange2(0,true,false,item3Start,item1End,false)
				reaper.Main_OnCommand(reaper.NamedCommandLookup("_SWS_AWFADESEL"),0) -- sws smart fade

				reaper.SelectAllMediaItems(0,false)
				reaper.SetMediaItemSelected(item2,true)
				reaper.SetMediaItemSelected(item3,true)
				reaper.GetSet_LoopTimeRange2(0,true,false,item2Start,item3End,false)
				reaper.Main_OnCommand(reaper.NamedCommandLookup("_SWS_AWFADESEL"),0) -- sws smart fade
			end			

		end

		restoreTimeSelection()
	else
		reaper.Main_OnCommand(reaper.NamedCommandLookup("_SWS_AWFADESEL"),0) -- sws smart fade
	end
end

reaper.PreventUIRefresh(-1)
reaper.Undo_EndBlock("Smart Fade", 0)

