-- @description CS_Implode two monos into stereo
-- @version 1.4
-- @author Claudiohbsantos
-- @link http://claudiohbsantos.com
-- @date 2017 03 27
-- @about
--   # CS_Implode two monos into stereo
--   Implodes two clips on separate tracks to a single stereo clip on te top track.
--   * keeps handles on both clips
--   * prevents take envelope from being glue to file
--   * keeps fades intact
-- @changelog
--   -- Added Some error Catching to prevent errors when no items are selected.
--   -- This is script is being made obsolete. Check the new 

remove = {".wav" , ".aif", ".mp3", ".mid", ".mov", ".mp4", ".rex", ".bwf", "-glued", " glued", " render", "reversed"}

function msg(msg)
	reaper.ShowConsoleMsg(msg.."\n")
end

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
	local activeTake = reaper.GetActiveTake(item)
	local volEnv = reaper.GetTakeEnvelopeByName(activeTake,"Volume")
	if volEnv then
		volEnvChunk = ""
		_,volEnvChunk = reaper.GetEnvelopeStateChunk(volEnv,volEnvChunk,false)
	end

end

function pasteitemparams(item,fadein,fadeout)
 
	if fadein then
		reaper.SetMediaItemInfo_Value(item, "D_FADEINSHAPE", fishape)
		reaper.SetMediaItemInfo_Value(item, "D_FADEINLEN_AUTO", fiauto)
		reaper.SetMediaItemInfo_Value(item, "D_FADEINDIR", fidir)
		reaper.SetMediaItemInfo_Value(item, "D_FADEINLEN", filen)
	end

	 if fadeout then
		reaper.SetMediaItemInfo_Value(item, "D_FADEOUTLEN", folen)	
		reaper.SetMediaItemInfo_Value(item, "D_FADEOUTDIR", fodir)	
		reaper.SetMediaItemInfo_Value(item, "D_FADEOUTLEN_AUTO", foauto)
		reaper.SetMediaItemInfo_Value(item, "D_FADEOUTSHAPE", foshape)
	end
	
	if volEnvChunk then
		local activeTake = reaper.GetActiveTake(item)
		reaper.Main_OnCommand(reaper.NamedCommandLookup("_S&M_TAKEENV1"),0)
		local takeEnv = reaper.GetTakeEnvelopeByName(activeTake,"Volume")
		reaper.SetEnvelopeStateChunk(takeEnv,volEnvChunk,false)
	end

end

function rev(string)
	return string.reverse(string)
end

function nospace(string)
	return string.gsub(string,"%s*$","")
end

function extendItemToFullExtension(item)
	

	activeTake = reaper.GetActiveTake(item)
	shift = reaper.GetMediaItemTakeInfo_Value(activeTake,"D_STARTOFFS")
	rate = reaper.GetMediaItemTakeInfo_Value(activeTake, "D_PLAYRATE")
	position = reaper.GetMediaItemInfo_Value(item,"D_POSITION")
	for c=0,reaper.CountTakes(item)-1,1 do
		take = reaper.GetTake(item, c)
	-- FIx for items in beginning of timeline
		if position-shift/rate < 0 then
			reaper.SetMediaItemTakeInfo_Value(take,"D_STARTOFFS",math.abs(position-shift/rate))
		else
			reaper.SetMediaItemTakeInfo_Value(take,"D_STARTOFFS",0)		
		end	
	end
		if position-shift/rate < 0 then
			reaper.SetMediaItemPosition(item, 0,0)
		else
			reaper.SetMediaItemPosition(item, position-shift/rate,0)	
		end

		reaper.Main_OnCommand(40612,0) -- extend to full length
end



reaper.Undo_BeginBlock()
reaper.PreventUIRefresh(1)
top = {}
bottom = {}
tot_items = reaper.CountSelectedMediaItems(0)
if tot_items == 0 then return end
firsttrack = reaper.GetMediaItemTrack(reaper.GetSelectedMediaItem(0,0))
if not firsttrack then return end
lasttrack = reaper.GetMediaItemTrack(reaper.GetSelectedMediaItem(0,tot_items-1))

if firsttrack == lasttrack then
	reaper.ShowMessageBox("Select at least 2 items 2 different tracks", "Error", 0)
	abort = 1
end	


if abort ~= 1 then

	local reenableAutoCrossfade
	if reaper.GetToggleCommandStateEx(0,40041) == 1 then -- if auto-crossfade is enabled
		reaper.Main_OnCommand(40041,0) -- turn off auto-crssfade
		reenableAutoCrossfade = true
	end

	-- fill "top" and "bottom" arrays with media items
	for i=1,tot_items,1 do
		if reaper.GetMediaItemTrack(reaper.GetSelectedMediaItem(0,i-1)) == firsttrack then
			top[#top+1] = reaper.GetSelectedMediaItem(0,i-1)
		else
			bottom[#bottom+1] = reaper.GetSelectedMediaItem(0,i-1)
		end
	end

	reaper.SelectAllMediaItems(0,0) --deselect all items

	b = 1
	i = 1
	while i <= #top do 	 -- iterate all items on top track
		reaper.SetMediaItemSelected(top[i],1)
		reaper.Main_OnCommand(40290,0) -- Set Time Selection to items

		local topPos = reaper.GetMediaItemInfo_Value(top[i],"D_POSITION")

		-- Error checking to make sure nonaligned clips don't throw a whole lot of clips into chaos. Aborts Imploding from the point where there were unnaligned clips
		unnaligned = false
		if b > #bottom then break end
		if string.format("%.3f", topPos) ~= string.format("%.3f", reaper.GetMediaItemInfo_Value(bottom[b],"D_POSITION")) then
				unnaligned = true				
		end

		if not unnaligned then
			copyitemparams(top[i])
			reaper.Main_OnCommand(reaper.NamedCommandLookup("_S&M_TAKEENV4"),0) -- disable take volume envelope for both items 
			extendItemToFullExtension(top[i])

			reaper.Main_OnCommand(42009,0) -- Glue (auto increase channel count with take fx)
			top[i] = reaper.GetSelectedMediaItem(0,0)

		--
		
			reaper.SelectAllMediaItems(0,0) --deselect all items


			reaper.SetMediaItemSelected(bottom[b],1)

			reaper.Main_OnCommand(reaper.NamedCommandLookup("_S&M_TAKEENV4"),0) -- disable take volume envelope for both items
			extendItemToFullExtension(bottom[b])
			reaper.Main_OnCommand(42009,0) -- Glue (auto increase channel count with take fx)
			bottom[b] = reaper.GetSelectedMediaItem(0,0)

		-- Implosion starts here
			
			reaper.SetMediaItemSelected(top[i],1) -- reselect top item
			
			reaper.Main_OnCommand(reaper.NamedCommandLookup("_XENAKIOS_IMPLODEITEMSPANSYMMETRICALLY"),1) -- Implode monos into simmetrically panned takes

			reaper.Main_OnCommand(42009,0) -- Glue (auto increase channel count with take fx)
			reaper.Main_OnCommand(40508,0) -- Trim item to time selection

			---
			item = reaper.GetSelectedMediaItem(0,0)
			pasteitemparams(item,true,true)

			ttakes = reaper.CountTakes(item)

			for c=0,ttakes-1,1 do --iterate on all takes of item

				take = reaper.GetTake(item,c)
				name = nospace(reaper.GetTakeName(take))

				o = 1
				while o <= #remove do -- checks all items defined at top

					flag = 0
					while flag ==0 do
						if string.find(rev(name),rev(remove[o])) == 1 then   
							name = nospace(string.sub(name,1,string.len(name)-string.len(remove[o])))
							o = 1
						else
							if string.match(name,"%-%d%d$") ~= nil then 
								name = nospace(string.sub(name,1,string.len(name)-string.len(string.match(name,"%-%d%d$"))))
								o = 1
							else
								if string.match(name,"%s%d%d%d$") ~= nil then 
									name = nospace(string.sub(name,1,string.len(name)-string.len(string.match(name,"%d%d%d$"))))
									o = 1
								else
									flag = 1
								end
							end
						end
					end
				o = o+1
				end

			reaper.GetSetMediaItemTakeInfo_String(take,"P_NAME", name, 1)
			end

			---

			reaper.SelectAllMediaItems(0,0) --deselect all items
			b = b+1
			i = i+1
		else -- if unalligned
			reaper.SelectAllMediaItems(0,0) --deselect all items
			if string.format("%.3f", topPos) > string.format("%.3f", reaper.GetMediaItemInfo_Value(bottom[b],"D_POSITION")) then
				b = b+1		
			else
				i = i+1
			end
			
		end
	end

	reaper.Main_OnCommand(40635,0) -- Remove Time Selection
	if reenableAutoCrossfade then
		reaper.Main_OnCommand(40041,0) -- toggle auto-crossfade
	end
end

reaper.PreventUIRefresh(-1)
reaper.Undo_EndBlock("Implode Two Mono clips into one stereo", 0)