--[[
@noindex
]]--

rl.registeredUtils.testInputs = {onEnter = function() cs.msg(rl.currentCommand) end, description = "Prints parsed arguments to console"}

rl.registeredUtils.keyboardCodeViewer = {
	passiveFunction = 
		function() 
			if rl.currentCommand.currChar ~= 0 then 
				rl.currentCommand.tipLine = rl.currentCommand.currChar
			end 
		end,
	description = "Display typed character codes",	 
	}