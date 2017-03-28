-- @description CS_Label REV if it has been reversed
-- @version 1.0
-- @author Claudiohbsantos
-- @link http://claudiohbsantos.com
-- @date 2017 03 28
-- @about
--   # CS_Label REV if it has been reversed
--   Labels a take name with the suffix **REV** if it has been reversed. Removes the label if it is unreversed.	
-- @changelog
--   - Initial Release

function nospace(string)
	return string.gsub(string,"%s*$","")
end

function rev(string)
	return string.reverse(string)
end

tselected = reaper.CountSelectedMediaItems(0)

for i=0, tselected-1, 1 do --iterate on all selected items
	item = reaper.GetSelectedMediaItem(0,i)
	take = reaper.GetActiveTake(item)


	name = nospace(reaper.GetTakeName(take))

	a,b,c,d,e,revstate = reaper.BR_GetMediaSourceProperties(take)

	if revstate == true then
		reaper.GetSetMediaItemTakeInfo_String(take,"P_NAME", name.." REV", 1)
	else
		if string.find(rev(name),rev("REV")) == 1 then   
					name = nospace(string.sub(name,1,string.len(name)-3))
		end

		reaper.GetSetMediaItemTakeInfo_String(take,"P_NAME", name, 1)
	end
end