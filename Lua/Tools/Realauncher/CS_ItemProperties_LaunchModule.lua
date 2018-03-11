--[[
@noindex
]]--

local function itemVolume(iTable)
	local arguments = iTable.arguments[1]

	if arguments and arguments:match("%d")  then

	reaper.Undo_BeginBlock()
	reaper.PreventUIRefresh(1)
		
		for item in cs.selectedItems(0) do
			local currentItemVolume = cs.itemVolumeToDB(reaper.GetMediaItemInfo_Value(item,"D_VOL"))
			local newValue = calcRelativeNumber(arguments,currentItemVolume)
			reaper.SetMediaItemInfo_Value(item,"D_VOL",cs.dbToItemVolume(newValue))
		end
		
	reaper.PreventUIRefresh(-1)
	reaper.Undo_EndBlock("Modify item Volumes to "..arguments, 0)
	reaper.UpdateArrange()

	end
	
end

rl.registeredUtils.itemvolume = {onEnter = itemVolume,
	description = "Set Item Volume",
	switches = {i = false},
	passiveFunction = function()
			if rl.currentCommand.switches.i then
				rl.registeredUtils.itemvolume.charFunction = {
					[kbInput.g] =  function() itemVolume({arguments = {[1] = "-0.1"}}) end,
					[kbInput.f] =  function() itemVolume({arguments = {[1] = "-1"}}) end,
					[kbInput.d] =  function() itemVolume({arguments = {[1] = "-5"}}) end,
					[kbInput.s] =  function() itemVolume({arguments = {[1] = "-10"}}) end,
					[kbInput.h] =  function() itemVolume({arguments = {[1] = "+0.1"}}) end,
					[kbInput.j] =  function() itemVolume({arguments = {[1] = "+1"}}) end,
					[kbInput.k] =  function() itemVolume({arguments = {[1] = "+5"}}) end,
					[kbInput.l] =  function() itemVolume({arguments = {[1] = "+10"}}) end,
					[kbInput.n] =  function() reaper.Main_OnCommand(40936,0) end, -- normalize/unormalize
					[kbInput["0"]] =  function() itemVolume({arguments = {[1] = "0"}}) end,
				}
				setCurrentEnvironment("itemvolume")
			end
		end,
	}

local function itemPitch(input)
	reaper.Undo_BeginBlock()
	reaper.PreventUIRefresh(1)

	local arguments = input.arguments[1]
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

rl.registeredUtils.itempitch = {onEnter = itemPitch,description = "Set Item Pitch"}

function itemPlayRate(input)
	reaper.Undo_BeginBlock()
	reaper.PreventUIRefresh(1)

	local arguments = input.arguments[1]
	if arguments == "" or not arguments then arguments = 1 end

	for item in cs.selectedItems(0) do
		for take in cs.allTakesInItem(item) do
			local currentItemPlayRate = reaper.GetMediaItemTakeInfo_Value(take,"D_PLAYRATE")
			local newValue = calcRelativeNumber(arguments,currentItemPlayRate)

			reaper.SetMediaItemTakeInfo_Value(take,"D_PLAYRATE",newValue)
		end
	end

	reaper.PreventUIRefresh(-1)
	reaper.Undo_EndBlock("Modify Item Playrate to "..arguments, 0)
	reaper.UpdateArrange()
end

rl.registeredUtils.itemrate = {onEnter = itemPlayRate,description = "Set Item Playrate"}

local function itemFadeInLength(input)
	reaper.Undo_BeginBlock()
	reaper.PreventUIRefresh(1)

	local arguments = input.arguments[1]
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

rl.registeredUtils.itemfadein = {onEnter = itemFadeInLength,description = "Set Item FadeIn Length"}

local function itemFadeOutLength(input)
	reaper.Undo_BeginBlock()
	reaper.PreventUIRefresh(1)

	local arguments = input.arguments[1]
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

rl.registeredUtils.itemfadeout = {onEnter = itemFadeOutLength,description = "Set Item FadeOut Length"}

local function itemLength(input)
	reaper.Undo_BeginBlock()
	reaper.PreventUIRefresh(1)

	local arguments = input.arguments[1]
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

rl.registeredUtils.itemlength = {onEnter = itemLength,description = "Set Item Length"}





