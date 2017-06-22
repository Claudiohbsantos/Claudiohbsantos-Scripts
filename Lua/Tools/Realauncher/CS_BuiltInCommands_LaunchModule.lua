rl.registeredCommands.quit = {main = function() reaper.Main_OnCommand(40004,0) end, waitForEnter = true, description = "Quit Reaper"}

function enumerateAvailableCommands()
	for command in pairs(rl.registeredCommands) do
		msg(command)
		for key,value in pairs(rl.registeredCommands[command]) do
			msg("    - "..key.." = "..tostring(value))
		end
	end
end

rl.registeredCommands.enumcmd = {main = enumerateAvailableCommands , waitForEnter = true}

rl.registeredCommands["!!"] = {main = redoCommand,waitForEnter = true}