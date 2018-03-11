--[[
@description CS_Reset Volume Envelope from selected Tracks
@version 1.0
@author Claudiohbsantos
@link http://claudiohbsantos.com
@date 2018 03 10
@about
  # CS_Reset Volume Envelope from selected Tracks
  Removes all Volume envelope points from track. Keep in mind it doesn't remove automation items. 
@changelog
  - initial release
--]]

local function removeVolumeEnvelope(track)
	local volEnv = reaper.GetTrackEnvelopeByChunkName(track,"<VOLENV2")
	if not volEnv then return end
	local chunk = ""
	local retval,chunk = reaper.GetEnvelopeStateChunk(volEnv,chunk,false)
	if not retval then error("Envelope seems to exist but I couldn't get it's chunk. Sad, sad story...") end
	chunk = chunk:gsub("\nPT [^\n]*","") -- erase all points
	chunk = chunk:gsub("VOLTYPE (%d)\n>","VOLTYPE %1\nPT 0 1 0\n>") -- recreate point at 0
	retval = reaper.SetEnvelopeStateChunk(volEnv,chunk,false)
	if not retval then error("Couldn't write new envelope chunk") end
end

function selectedTracks(proj)
	local i = -1
	return function () i = i+1 ; return reaper.GetSelectedTrack2(proj,i,true) end
end

----------

for track in selectedTracks(0) do
	removeVolumeEnvelope(track)
end