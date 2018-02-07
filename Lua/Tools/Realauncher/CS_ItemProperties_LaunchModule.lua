--[[
@noindex
]]--

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

local function parseArguments(arguments)
	local operator,value = string.match(arguments,"^([%+%-/%*]?)([%d%.]+)")
	if operator == "" then operator = "set"	end

	return operator, value 
end

local function itemVolume()
	reaper.Undo_BeginBlock()
	reaper.PreventUIRefresh(1)

	local arguments = rl.text.arguments[1]
	if arguments == "" or not arguments then arguments = 0 end
	local operator,value = parseArguments(arguments)
	for item in cs.selectedItems(0) do
		local currentItemVolume = cs.itemVolumeToDB(reaper.GetMediaItemInfo_Value(item,"D_VOL"))
		local newValue = calc[operator](currentItemVolume,value)
		reaper.SetMediaItemInfo_Value(item,"D_VOL",cs.dbToItemVolume(newValue))
	end
	reaper.PreventUIRefresh(-1)
	reaper.Undo_EndBlock("Modify item Volumes to "..arguments, 0)
	reaper.UpdateArrange()
end

rl.registeredCommands.itemvolume = {onEnter = itemVolume,
	description = "Set Item Volume",
	charFunction = {
		[kbInput.upArrow] = function() reaper.Main_OnCommand(41925,0) end, -- nudge items volumes up +1
		[kbInput.downArrow] = function() reaper.Main_OnCommand(41924,0) end, -- nudge items volumes down -1
		}
	}

local function itemPitch()
	reaper.Undo_BeginBlock()
	reaper.PreventUIRefresh(1)

	local arguments = rl.text.arguments[1]
	if arguments == "" or not arguments then arguments = 0 end
	local operator,value = parseArguments(arguments)

	for item in cs.selectedItems(0) do
		for take in cs.allTakesInItem(item) do
			local currentItemPitch = reaper.GetMediaItemTakeInfo_Value(take,"D_PITCH")
			local newValue = calc[operator](currentItemPitch,value)
			reaper.SetMediaItemTakeInfo_Value(take,"D_PITCH",newValue)
		end
	end

	reaper.PreventUIRefresh(-1)
	reaper.Undo_EndBlock("Modify Item Pitch to "..arguments, 0)
	reaper.UpdateArrange()
end

rl.registeredCommands.itempitch = {onEnter = itemPitch,description = "Set Item Pitch"}

function itemPlayRate()
	reaper.Undo_BeginBlock()
	reaper.PreventUIRefresh(1)

	local arguments = rl.text.arguments[1]
	if arguments == "" or not arguments then arguments = 1 end
	local operator,value = parseArguments(arguments)

	for item in cs.selectedItems(0) do
		for take in cs.allTakesInItem(item) do
			local currentItemPlayRate = reaper.GetMediaItemTakeInfo_Value(take,"D_PLAYRATE")
			local newValue = calc[operator](currentItemPlayRate,value)
			reaper.SetMediaItemTakeInfo_Value(take,"D_PLAYRATE",newValue)
		end
	end

	reaper.PreventUIRefresh(-1)
	reaper.Undo_EndBlock("Modify Item Playrate to "..arguments, 0)
	reaper.UpdateArrange()
end

rl.registeredCommands.itemrate = {onEnter = itemPlayRate,description = "Set Item Playrate"}

local function itemFadeInLength()
	reaper.Undo_BeginBlock()
	reaper.PreventUIRefresh(1)

	local arguments = rl.text.arguments[1]
	if arguments == "" or not arguments then arguments = 0 end
	local operator,value = parseArguments(arguments)

	for item in cs.selectedItems(0) do
		local currentItemPitch = reaper.GetMediaItemInfo_Value(item,"D_FADEINLEN")
		local newValue = calc[operator](currentItemPitch,value)
		reaper.SetMediaItemInfo_Value(item,"D_FADEINLEN",newValue)
	end

	reaper.PreventUIRefresh(-1)
	reaper.Undo_EndBlock("Modify item Fade-In Lenght to "..arguments, 0)
	reaper.UpdateArrange()
end

rl.registeredCommands.itemfadein = {onEnter = itemFadeInLength,description = "Set Item FadeIn Length"}

local function itemFadeOutLength()
	reaper.Undo_BeginBlock()
	reaper.PreventUIRefresh(1)

	local arguments = rl.text.arguments[1]
	if arguments == "" or not arguments then arguments = 0 end
	local operator,value = parseArguments(arguments)

	for item in cs.selectedItems(0) do
		local currentItemPitch = reaper.GetMediaItemInfo_Value(item,"D_FADEOUTLEN")
		local newValue = calc[operator](currentItemPitch,value)
		reaper.SetMediaItemInfo_Value(item,"D_FADEOUTLEN",newValue)
	end

	reaper.PreventUIRefresh(-1)
	reaper.Undo_EndBlock("Modify item Fade Out Leght to "..arguments, 0)
	reaper.UpdateArrange()
end

rl.registeredCommands.itemfadeout = {onEnter = itemFadeOutLength,description = "Set Item FadeOut Length"}

local function itemLength()
	reaper.Undo_BeginBlock()
	reaper.PreventUIRefresh(1)

	local arguments = rl.text.arguments[1]
	if arguments == "" or not arguments then arguments = 0 end
	local operator,value = parseArguments(arguments)

	for item in cs.selectedItems(0) do
		local currentItemPitch = reaper.GetMediaItemInfo_Value(item,"D_LENGTH")
		local newValue = calc[operator](currentItemPitch,value)
		reaper.SetMediaItemInfo_Value(item,"D_LENGTH",newValue)
	end

	reaper.PreventUIRefresh(-1)
	reaper.Undo_EndBlock("Modify item Lenght to "..arguments, 0)
	reaper.UpdateArrange()
end

rl.registeredCommands.itemlength = {onEnter = itemLength,description = "Set Item Length"}





