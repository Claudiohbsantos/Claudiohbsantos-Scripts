--[[
@noindex
--]]

local settings = {
	projtimeoffs = {name = "Project Start Time", setter = function (newval) reaper.SNM_SetDoubleConfigVar("projtimeoffs",newval) end},
	projgridmin = {name = "Project minimum grid division pixels", setter = function (newval) reaper.SNM_SetDoubleConfigVar("projgridmin",newval) end},
}

local function getSetSettings(input)
	if cs.strHasValue(input.arguments[1]) and cs.strHasValue(input.arguments[2]) then
		settings[input.arguments[1]].setter(input.arguments[2])
	end
end

rl.registeredUtils.settings = {
	onEnter = getSetSettings,
	description = "Set Settings by name",
	switches = {T = false},
	entranceFunction = function () if rl.currentCommand.switches.T then launchAltGUI(tcInputStart,0) end end,
}