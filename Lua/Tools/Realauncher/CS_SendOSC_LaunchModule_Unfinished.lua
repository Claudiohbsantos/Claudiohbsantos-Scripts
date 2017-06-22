function sendOSCMessage(arguments)
	reaper.OscLocalMessageToHost(arguments)
end

registeredCommands.sendOSC = {sendOSCMessage, waitForEnter}