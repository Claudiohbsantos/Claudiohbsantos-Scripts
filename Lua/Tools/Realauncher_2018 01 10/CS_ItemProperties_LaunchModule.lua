local calc = {}

calc["+"] = function  (val1,val2)
	return val1 + val2
end

calc["-"] = function  (val1,val2)
	return val1 - val2
end

calc["/"] = function  (val1,val2)
	return val1 / val2
end

calc["*"] = function  (val1,val2)
	return val1 * val2
end

calc["set"] = function (val1,val2)
	return val2 or 0
end

function parseArguments(arguments)
	local operator,value = string.match(arguments,"^([%+%-/%*]?)([%d%.]+)")
	if operator == "" then operator = "set"	end

	return operator, value 
end

function itemVolume(arguments)
	arguments = arguments or 0
	local operator,value = parseArguments(arguments)

	for item in cs.selectedItems(0) do
		local currentItemVolume = cs.itemVolumeToDB(reaper.GetMediaItemInfo_Value(item,"D_VOL"))
		local newValue = calc[operator](currentItemVolume,value)
		reaper.SetMediaItemInfo_Value(item,"D_VOL",cs.dbToItemVolume(newValue))
	end

	reaper.UpdateArrange()
end

function itemPitch(arguments)
	arguments = arguments or 0
	local operator,value = parseArguments(arguments)

	for item in cs.selectedItems(0) do
		for take in cs.allTakesInItem(item) do
			local currentItemPitch = reaper.GetMediaItemTakeInfo_Value(take,"D_PITCH")
			local newValue = calc[operator](currentItemPitch,value)
			reaper.SetMediaItemTakeInfo_Value(take,"D_PITCH",newValue)
		end
	end

	reaper.UpdateArrange()
end

function itemPlayRate(arguments)
	arguments = arguments or 1
	local operator,value = parseArguments(arguments)

	for item in cs.selectedItems(0) do
		for take in cs.allTakesInItem(item) do
			local currentItemPlayRate = reaper.GetMediaItemTakeInfo_Value(take,"D_PLAYRATE")
			local newValue = calc[operator](currentItemPlayRate,value)
			reaper.SetMediaItemTakeInfo_Value(take,"D_PLAYRATE",newValue)
		end
	end

	reaper.UpdateArrange()
end

function itemFadeInLength(arguments)
	arguments = arguments or 0
	local operator,value = parseArguments(arguments)

	for item in cs.selectedItems(0) do
		local currentItemPitch = reaper.GetMediaItemInfo_Value(item,"D_FADEINLEN")
		local newValue = calc[operator](currentItemPitch,value)
		reaper.SetMediaItemInfo_Value(item,"D_FADEINLEN",newValue)
	end

	reaper.UpdateArrange()
end

function itemFadeOutLength(arguments)
	arguments = arguments or 0
	local operator,value = parseArguments(arguments)

	for item in cs.selectedItems(0) do
		local currentItemPitch = reaper.GetMediaItemInfo_Value(item,"D_FADEOUTLEN")
		local newValue = calc[operator](currentItemPitch,value)
		reaper.SetMediaItemInfo_Value(item,"D_FADEOUTLEN",newValue)
	end

	reaper.UpdateArrange()
end

function itemLength(arguments)
	arguments = arguments or 0
	local operator,value = parseArguments(arguments)

	for item in cs.selectedItems(0) do
		local currentItemPitch = reaper.GetMediaItemInfo_Value(item,"D_LENGTH")
		local newValue = calc[operator](currentItemPitch,value)
		reaper.SetMediaItemInfo_Value(item,"D_LENGTH",newValue)
	end

	reaper.UpdateArrange()
end


rl.registeredCommands.iv = {main = itemVolume,waitForEnter = true,description = "Set Item Volume"}
rl.registeredCommands.ip = {main = itemPitch,waitForEnter = true,description = "Set Item Pitch"}
rl.registeredCommands.ir = {main = itemPlayRate,waitForEnter = true,description = "Set Item Playrate"}
rl.registeredCommands.ifi = {main = itemFadeInLength,waitForEnter = true,description = "Set Item FadeIn Length"}
rl.registeredCommands.ifo = {main = itemFadeOutLength,waitForEnter = true,description = "Set Item FadeOut Length"}
rl.registeredCommands.il = {main = itemLength,waitForEnter = true,description = "Set Item Length"}