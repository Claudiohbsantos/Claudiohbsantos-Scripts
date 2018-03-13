--[[
@description Convert Volume Automation Fades To Item Fades
@version 1.23
@author Claudiohbsantos
@link http://claudiohbsantos.com
@date 2018 03 10
@about
  # Convert Volume Automation Fades To Item Fades
@changelog
  - Script now removes extra points in the threshold area to prevent script from chaning fade on retriggering.
--]]

local threshold = -50
local timethreshold = 1

local cs = {}
function cs.msg(...)
	local indent = 0

	local function printTable(table,tableName)
		if tableName then reaper.ShowConsoleMsg(string.rep("    ",indent)..tostring(tableName)..": \n") end
		indent = indent + 1
		for key,tableValue in pairs(table) do
			if type(tableValue) == "table" then
				printTable(tableValue,key)
			else
				reaper.ShowConsoleMsg(string.rep("    ",indent)..tostring(key).." = "..tostring(tableValue).."\n")
			end
		end
		indent = indent - 1
	end

	printTable({...})
end


function getEnvPoint(env,pIdx)
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

local function getPointsInTimeRange(env,timeIn,timeOut)
	local lastPointID = reaper.GetEnvelopePointByTime(env,timeOut)
	if lastPointID then
		local p = {}
		local currID = lastPointID
		while true do
			local point = getEnvPoint(env,currID)
			if point and point.relTime >= timeIn and point.relTime <= timeOut then 
				table.insert(p,1,point)
			else 
				break
			end
			currID = currID - 1	
		end
		return p
	end
end

local function removePointsAboveThreshold(points,max)
	for p in pairs(points) do
		if points[p].dbVal > max then
			points[p] = nil
		end
	end
	return points
end

local function getLargestFadeStartingAtPoints(env,points,max,highPointPosition)
	-- highPointPosition is +1 for next point or -1 for previous point
	local pointPairs = {}
	for p in pairs(points) do 
		local nextPoint = getEnvPoint(env,points[p].idx + highPointPosition)
		if nextPoint and nextPoint.dbVal >= max then
			delta = nextPoint.dbVal - points[p].dbVal
			table.insert(pointPairs,{delta = delta,low = points[p], high = nextPoint})
		end
	end
	if #pointPairs > 0 then
		table.sort(pointPairs,function(a,b) return a.delta > b.delta end)
		return pointPairs[1].low,pointPairs[1].high
	end
end

local function getFadeIn(env,item)
	local potentialLowPoints = getPointsInTimeRange(env,-timethreshold,timethreshold)
	if #potentialLowPoints > 0 then
		potentialLowPoints = removePointsAboveThreshold(potentialLowPoints,threshold)
		local lowPoint,highPoint = getLargestFadeStartingAtPoints(env,potentialLowPoints,threshold,1)
		if lowPoint and highPoint then
			return lowPoint,highPoint
		end
	end
end

local function getFadeOut(env,item)
	local itemLength = reaper.GetMediaItemInfo_Value(item,"D_LENGTH")
	local potentialLowPoints = getPointsInTimeRange(env,itemLength-timethreshold,itemLength+timethreshold)
	if #potentialLowPoints > 0 then
		potentialLowPoints = removePointsAboveThreshold(potentialLowPoints,threshold)
		local lowPoint,highPoint = getLargestFadeStartingAtPoints(env,potentialLowPoints,threshold,-1)
		if lowPoint and highPoint then
			return lowPoint,highPoint
		end
	end
end

local function convertVolumeEnvelopeFadesToItemFades(take,item)
	local points = {}
	local env = reaper.GetTakeEnvelopeByName(take,"Volume")
	if env then 
		local totalPoints = reaper.CountEnvelopePoints(env)

		if totalPoints < 2 then return end
		points[1],points[2] = getFadeIn(env,item)
		if points[1] and points[2] then
			local shape = 0
			if points[1].scale == 1 then shape = 4 end -- change fade shape for fader scaling
			createFadeIn(points[2].relTime,item,shape)
			reaper.DeleteEnvelopePointRange(env,-timethreshold,timethreshold)
			reaper.InsertEnvelopePoint(env,points[1].relTime,points[2].rawVal,points[1].shape,points[1].tension,points[1].selected)
			reaper.InsertEnvelopePoint(env,points[2].relTime,points[2].rawVal,points[2].shape,points[2].tension,points[2].selected)
			reaper.UpdateArrange()
		end

		points[4],points[3] = getFadeOut(env,item)
		if points[3] and points[4] then
			local shape = 0
			if points[3].scale == 1 then shape = 4 end --0 change fade shape for fader scaling
			createFadeOut(points[3].relTime,item,shape)
			local itemLength = reaper.GetMediaItemInfo_Value(item,"D_LENGTH")
			reaper.DeleteEnvelopePointRange(env,itemLength-timethreshold,itemLength+timethreshold)
			reaper.InsertEnvelopePoint(env,points[4].relTime,points[3].rawVal,points[4].shape,points[4].tension,points[4].selected)
			reaper.InsertEnvelopePoint(env,points[3].relTime,points[3].rawVal,points[3].shape,points[3].tension,points[3].selected)
			reaper.UpdateArrange()
		end
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