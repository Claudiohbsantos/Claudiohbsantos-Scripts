--[[
@description Place Markers at clipping points
@version 1.0
@author Claudiohbsantos
@link http://claudiohbsantos.com
@date 2018 05 11
@about
  # Place Markers at clipping points
@changelog
  - Initial Release
--]]
----------------------
local settings = {}
settings.threshold = 1
settings.minIntervalBetweenMarkers = 5
----------------------
---------------------------------------------------------------
local cs = {}
function cs.rgbToColor(r,g,b)
	return reaper.ColorToNative(r,g,b)|0x1000000
end
function cs.getMarkerInfo(idx)
	local marker = {}
	retval, marker.isrgn, marker.pos, marker.rgnend, marker.name, marker.id, marker.color = reaper.EnumProjectMarkers3(0, idx)
	if retval then
		return marker
	end
end

function cs.getAllMarkersInTime(inT,outT)
	local totMarkers = reaper.CountProjectMarkers(0)
	local markers = {}
	for i = 0, totMarkers -1 do
		local m = cs.getMarkerInfo(i)
		if m.pos >= inT and m.pos <= outT then table.insert(markers,m) end
		if m.pos > outT then break end
	end
	return markers
end

function cs.placeWarningMarker(msg,pos,id,minDistance,color)
	local existingMarkers = cs.getAllMarkersInTime(pos - minDistance, pos + minDistance)
	for i,marker in pairs(existingMarkers) do
		if marker.id == id and marker.name == msg then
			return
		end
	end
	reaper.AddProjectMarker2(0,false,pos,0,msg,id,color)
end

local function main()
	local master = reaper.GetMasterTrack(0)
	local nChannels = reaper.GetMediaTrackInfo_Value(master,"I_NCHAN")
	for i=0, nChannels - 1 do
		local peak = reaper.Track_GetPeakInfo(master, i)
		if peak >= settings.threshold then
			-- local msg = string.format(peak,"%0.2f").." at ch "..i+1
			cs.placeWarningMarker("!:clip",reaper.GetPlayPosition(),999,settings.minIntervalBetweenMarkers,cs.rgbToColor(255,0,0))
		end
	end
	reaper.defer(main)
end

local reaper = reaper
reaper.Undo_BeginBlock2(0)
main()
reaper.Undo_EndBlock2(0,"Place Markers at clipping points",-1)