--[[
@description CS_Extend Track Selection to Track under Mouse
@version 1.0
@author Claudiohbsantos
@link http://claudiohbsantos.com
@date 2017 04 08
@about
  # CS_Extend Track Selection to Track under Mouse
  Extends curent track selection to track currently under mouse
@changelog
  - Initial Release
--]]

reaper.PreventUIRefresh(1)

local nSelTracks = reaper.CountSelectedTracks(0)

local firstSelTrack = reaper.GetSelectedTrack(0, 0)
local firstSelTrackId = reaper.GetMediaTrackInfo_Value(firstSelTrack,"IP_TRACKNUMBER")
local lastSelTrack = reaper.GetSelectedTrack(0, nSelTracks-1)
local lastSelTrackId = reaper.GetMediaTrackInfo_Value(lastSelTrack,"IP_TRACKNUMBER")

local track = reaper.BR_TrackAtMouseCursor()
if track then
	local trackId = reaper.GetMediaTrackInfo_Value(track,"IP_TRACKNUMBER")
	
	if trackId < firstSelTrackId then
		for i = trackId-1, firstSelTrackId-1, 1 do
			local affectedTrack = reaper.GetTrack(0, i)
			if reaper.GetMediaTrackInfo_Value(affectedTrack, "B_SHOWINTCP") == 1 then
				reaper.SetTrackSelected(affectedTrack, true)
			end
		end
	end
	
	if trackId > lastSelTrackId then 
		for i = lastSelTrackId-1, trackId-1, 1 do
			local affectedTrack = reaper.GetTrack(0, i)
			if reaper.GetMediaTrackInfo_Value(affectedTrack, "B_SHOWINTCP") == 1 then
				reaper.SetTrackSelected(affectedTrack, true)
			end
		end
	end	
end
reaper.PreventUIRefresh(-1)
