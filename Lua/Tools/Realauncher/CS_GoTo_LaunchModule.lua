function goTo(arguments)
	local timeToGo = reaper.parse_timestr_pos(rl.argumentElement[1],-1)
	reaper.SetEditCurPos2(0,timeToGo,true,false)
end	

function getPositionInput()
	local cursorPosition = reaper.GetCursorPositionEx(0)
	rl.timeInput(cursorPosition)
end

rl.registeredCommands.go = {main = goTo,waitForEnter = true,description = "Go to exact point in timeline"}
rl.registeredCommands.got = {main = goTo,customArg = getPositionInput,waitForEnter = true,description = "Go to exact point in timeline (time Input)"}

