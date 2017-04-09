--[[
@description CS_Render as new take with handles removing labels and extensions and setting original FX offline
@version 1.0
@author Claudiohbsantos
@link http://claudiohbsantos.com
@date 2017 04 08
@about
  # CS_Render as new take with handles removing labels and extensions
  This scripts renders the item into a new take, keeping handles outside of the current item edges. After rendereing, it removes extensions such as .wav, render, -glued, and such. The fx in the original take are set to offline. 
@changelog
  - Initial Release
--]]
remove = {".wav" , ".aif", ".mp3", ".mid", ".mov", ".mp4", ".rex", ".bwf", "-glued", " glued", " render", "reversed"}


function msg(msg)
	reaper.ShowConsoleMsg(msg.."\n")
end

function rev(string)
	return string.reverse(string)
end

function nospace(string)
	return string.gsub(string,"%s*$","")
end


function copyitemparams(item)
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

items = {}

tot_items = reaper.CountSelectedMediaItems(0)

for i=1,tot_items,1 do
	items[i] = reaper.GetSelectedMediaItem(0,i-1)
end

reaper.SelectAllMediaItems(0,0) --deselect all items

for i=1,tot_items,1 do
	reaper.SetMediaItemSelected(items[i],1)
	reaper.Main_OnCommand(40290,0) -- Set Time Selection to items

	copyitemparams(items[i])
	extendItemToFullExtension(items[i])


	-- reaper.Main_OnCommand(42009,0) -- Glue (auto increase channel count with take fx)
	reaper.Main_OnCommand(41999,0) -- Render Items as new take

	reaper.Main_OnCommand(40126,0) -- switch to previous take
	reaper.Main_OnCommand(reaper.NamedCommandLookup("_S&M_TAKEFX_OFFLINE"),0) -- set all fx offline
	reaper.Main_OnCommand(40125,0) -- switch to next take

	reaper.Main_OnCommand(40508,0) -- Trim item to time selection

	pasteitemparams(reaper.GetSelectedMediaItem(0,0),1,1)
	take = reaper.GetActiveTake(reaper.GetSelectedMediaItem(0,0))

	-- Fix for items in beginning of timeline
	if position-shift/rate < 0 then 
		reaper.SetMediaItemTakeInfo_Value(take,"D_STARTOFFS",shift)
	end
	---
	item = reaper.GetSelectedMediaItem(0,0)
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
end

reaper.Main_OnCommand(40635,0) -- Remove Time Selection

reaper.PreventUIRefresh(-1)

reaper.Undo_EndBlock("Glue Items With Handles and without labels or extensions", 0)