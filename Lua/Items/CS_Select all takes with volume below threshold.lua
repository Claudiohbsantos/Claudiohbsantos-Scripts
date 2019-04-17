--[[
@noindex
@description Select all active takes with take volume below threshold
@version 1.1
@author Claudiohbsantos
@link http://claudiohbsantos.com
@date 2019 04 17
@about
  # Select all active takes with take volume below threshold

--]]

function msg(...)
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
function allItems(proj)
	local itemGUIDS = {}
	for i = 0,  reaper.CountMediaItems(proj) - 1 do
		table.insert(itemGUIDS, reaper.BR_GetMediaItemGUID(reaper.GetMediaItem(proj,i)))
	end
	return function () 
			while #itemGUIDS > 0 do
				local item = reaper.BR_GetMediaItemByGUID(0, table.remove(itemGUIDS,1)) 
				if item then
					return  item
				end
			end
		end
end

---------------------------------------------------------------

local function getUserThreshold()
	local completed,retvalCSV = reaper.GetUserInputs("Set Threshold",1,"Level (db)","")

	if not completed then return nil end
	if not tonumber(retvalCSV) then
		reaper.MB("The threshold given doesn't seem to be a number","ERROR",0)
		return nil
	end

	return tonumber(retvalCSV)
end	

local function main()
	local threshold = getUserThreshold()
	if not threshold then return end

	reaper.SelectAllMediaItems(0,false)
	for item in allItems(0) do
		local take = reaper.GetActiveTake(item)
		local volumeRaw = reaper.GetMediaItemTakeInfo_Value(take,"D_VOL")
		local volume = 20*math.log(volumeRaw,10)

		if volume <= threshold then
			reaper.SetMediaItemSelected(item,true)
		end
	end
end

---------------------------------------------------------------
local reaper = reaper

reaper.PreventUIRefresh(1)

-- if not cs.notRunningOnWindows() then
	main()
-- end

reaper.PreventUIRefresh(-1)
reaper.UpdateArrange()