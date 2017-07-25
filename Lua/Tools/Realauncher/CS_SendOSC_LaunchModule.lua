function sendOSCMessage(arguments)
	if arguments then
		reaper.OscLocalMessageToHost(arguments)
	end	
end

rl.registeredCommands.sendOSC_Constant = {main = sendOSCMessage, waitForEnter = false}
rl.registeredCommands.sendOSC = {main = sendOSCMessage, waitForEnter = true}