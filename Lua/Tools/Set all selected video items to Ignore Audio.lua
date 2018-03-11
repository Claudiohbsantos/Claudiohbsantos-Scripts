--[[
@description Set all selected video items to Ignore Audio
@version 1.0
@author Claudiohbsantos
@link http://claudiohbsantos.com
@date 2018 03 09
@about
  # Set all selected video items to Ignore Audio
  
@changelog
  - initial release
--]]

function selectedItems(proj)
	local i = -1
	return function () i = i+1 ; return reaper.GetSelectedMediaItem(proj,i) end
end

------------------

for item in selectedItems(0) do
	local chunk = ""
	local retval,chunk = reaper.GetItemStateChunk(item,chunk,false)
	if retval then 
		local ignoreAudioSetting = "AUDIO 0\n"
		local chunk,nmatches = chunk:gsub("<SOURCE VIDEO\nFILE ","<SOURCE VIDEO\n"..ignoreAudioSetting.."FILE ")
		if nmatches > 0 then
			reaper.SetItemStateChunk(item,chunk,false)
		end
	end
end