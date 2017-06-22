function goTo(arguments)
	reaper.SetEditCurPos2(0,rl.registeredCommands.go.customArgInput,true,false)
end	

function getPositionInput()
	local cursorPosition = reaper.GetCursorPositionEx(0)
	rl.timeInput(cursorPosition)
end

rl.registeredCommands.go = {main = goTo,customArg = getPositionInput,waitForEnter = true,description = "Go to exact point in timeline"}

