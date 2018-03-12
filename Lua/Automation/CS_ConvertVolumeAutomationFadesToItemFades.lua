--[[
@description Convert Volume Automation Fades To Item Fades
@version 1.1
@author Claudiohbsantos
@link http://claudiohbsantos.com
@date 2018 03 10
@about
  # Convert Volume Automation Fades To Item Fades
@changelog
  - Renamed
--]]

local threshold = -50
local timethreshold = 1

function getEnvPoint(env,pIdx,opt_item)
	local p,retval = {}
	p.scale = reaper.GetEnvelopeScalingMode(env)
	p.idx = pIdx
	retval, p.relTime, p.rawVal, p.shape, p.tension, p.selected = reaper.GetEnvelopePoint(env,pIdx)

	if not retval then return nil end
	local dbStr = reaper.Envelope_FormatValue(env,p.rawVal)
	p.dbVal = tonumber(dbStr:match("[-]?[%d%.]+"))
	if not p.dbVal then p.dbVal = -math.huge end
	return p
end

local function getFirst2Points(env,item)
	local itemStart = reaper.GetMediaItemInfo_Value(item,"D_POSITION")
	local idx = reaper.GetEnvelopePointByTime(env,timethreshold)
	local firstPoint = getEnvPoint(env,idx)
	local secondPoint = getEnvPoint(env,idx+1)
	return firstPoint,secondPoint
end	

local function getLast2Points(env,t,item)
	local itemEnd = reaper.GetMediaItemInfo_Value(item,"D_LENGTH")
	local idx = reaper.GetEnvelopePointByTime(env,itemEnd + timethreshold)
	local secondToLastPoint = getEnvPoint(env,idx-1)
	local lastPoint = getEnvPoint(env,idx)
	return secondToLastPoint,lastPoint
end	

local function pointIsAtEdge(relTime,item,threshold)
	local iStart = reaper.GetMediaItemInfo_Value(item,"D_POSITION")
	local iEnd = iStart + reaper.GetMediaItemInfo_Value(item,"D_LENGTH")
	local time = relTime + iStart
	if math.abs(time - iStart) < threshold or math.abs(time - iEnd) < threshold then
		return true
	end
end

local function isFade(a,b,item)
-- checks if is an increasing fade from a to b
	if pointIsAtEdge(a.relTime,item,timethreshold) then
		if a.dbVal < threshold and b.dbVal > a.dbVal then
			return true
		end
	end
end

local function createFadeIn(endTime,item,shape)
	reaper.SetMediaItemInfo_Value(item,"D_FADEINLEN",endTime)
	reaper.SetMediaItemInfo_Value(item,"C_FADEINSHAPE",shape)
end

local function createFadeOut(startTime,item,shape)
	local itemLen = reaper.GetMediaItemInfo_Value(item,"D_LENGTH")
	local foLen = itemLen - startTime
	reaper.SetMediaItemInfo_Value(item,"D_FADEOUTLEN",foLen)
	reaper.SetMediaItemInfo_Value(item,"C_FADEOUTSHAPE",shape)
end

local function convertVolumeEnvelopeFadesToItemFades(take,item)
	local points = {}
	local env = reaper.GetTakeEnvelopeByName(take,"Volume")
	local totalPoints = reaper.CountEnvelopePoints(env)
	

	if totalPoints < 2 then return end

	points[1],points[2] = getFirst2Points(env,item)
	if points[1] and points[2] and isFade(points[1],points[2],item) then
		local shape = 0
		if points[1].scale == 1 then shape = 4 end -- change fade shape for fader scaling
		createFadeIn(points[2].relTime,item,shape)
		reaper.SetEnvelopePoint(env,points[1].idx,points[1].relTime,points[2].rawVal)
		reaper.UpdateArrange()
	end

	points[3],points[4] = getLast2Points(env,totalPoints,item)
	if points[3] and points[4] and isFade(points[4],points[3],item) then
		local shape = 0
		if points[1].scale == 1 then shape = 4 end -- change fade shape for fader scaling
		createFadeOut(points[3].relTime,item,shape)
		reaper.SetEnvelopePoint(env,points[4].idx,points[4].relTime,points[3].rawVal)
		reaper.UpdateArrange()
	end
end

local function allTakesInItem(item)
	local i= -1
	return function () i=i+1 ; return reaper.GetTake(item,i) end
end

local function selectedItems(proj)
	local i = -1
	return function () i = i+1 ; return reaper.GetSelectedMediaItem(proj,i) end
end


----------

for item in selectedItems(0) do
	for take in allTakesInItem(item) do
		convertVolumeEnvelopeFadesToItemFades(take,item)
	end
end