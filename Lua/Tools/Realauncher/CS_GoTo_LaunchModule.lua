--[[
@noindex
]]--


function goTo()
	if switches.t ~= switchesDefaultVals.t or switches.T then
		if switches.T then switches.t = rl.text.arguments[1] end
		local destination =  switches.t - reaper.GetProjectTimeOffset(proj,false)
		reaper.SetEditCurPos2(0,destination,true,false)
	end
end

rl.registeredUtils.go = {
	charFunction = {
		[kbInput.ctrl.t] = function ()  launchAltGUI(tcInputStart,reaper.GetCursorPositionEx(0) + reaper.GetProjectTimeOffset(proj,false)) end,
		},
	switches = {t = reaper.GetCursorPositionEx(0) + reaper.GetProjectTimeOffset(proj,false), T = false},
	entranceFunction = function () if switches.T then launchAltGUI(tcInputStart,reaper.GetCursorPositionEx(0) + reaper.GetProjectTimeOffset(proj,false)) end end,
	onEnter = goTo,
	description = "Go To Position in Timeline",	
}