--[[
@noindex
]]--

local function goToTime(time)
	local destination =  tonumber(time)
	local moveView = false
	if destination < (rl.variables.native.viewStart - 0.001) or destination > (rl.variables.native.viewEnd + 0.001) then
		moveView = true
	end
	reaper.SetEditCurPos2(0,destination - reaper.GetProjectTimeOffset(proj,false),moveView,false)
end

function goTo(input)
	local time = calcRelativeNumber(input.arguments[1],rl.variables.native.curPos)
	goToTime(time)
end

rl.registeredUtils.go = {
	switches = {t = rl.variables.native.curPos, T = false},
	entranceFunction = function () if rl.currentCommand.switches.T then launchAltGUI(tcInputStart,rl.variables.native.curPos) end end,
	charFunction = {[kbInput.ctrl.t] = function ()  launchAltGUI(tcInputStart,rl.variables.native.curPos) end,},
	onEnter = goTo,
	description = "Go To Position in Timeline",	
}