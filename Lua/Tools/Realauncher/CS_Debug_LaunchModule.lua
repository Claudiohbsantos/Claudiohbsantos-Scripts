--[[
@noindex
]]--

rl.registeredCommands.testInputs = {onEnter = function() cs.msg(rl.text) end, description = "Prints parsed arguments to console"}

rl.registeredCommands.keyboardCodeViewer = {
	passiveFunction = 
		function() 
			if rl.text.currChar ~= 0 then 
				rl.text.tipLine = rl.text.currChar
			end 
		end,
	description = "Display typed character codes",	 
	}