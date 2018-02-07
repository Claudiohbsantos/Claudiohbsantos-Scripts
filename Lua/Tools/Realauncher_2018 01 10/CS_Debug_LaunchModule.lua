function drawDEBUG(text)
	gfx.setfont(1, gui_fontname, gui_fontsize)
    gfx.x = obj_offs*2
    gfx.y = obj_offs + 32
    gfx.set(1,1,1,0.8,0)
    gfx.drawstr(tostring(text))
end

function msg(s) reaper.ShowConsoleMsg(tostring(s)..'\n') end

function printArgUnitsTypes()
	for i=1,#rl.textToPrint,1 do
		msg(rl.textToPrint[i].typeOfUnit)
	end
end

function testInputs()
	if rl.registeredCommands.testInputs.help then
		reaper.ShowMessageBox("Im here to help","MR Help",0)
	else
		msg("text = "..rl.text)
		msg("command = "..rl.command)
		if rl.arguments then msg("arguments = "..rl.arguments) end 
		if rl.argumentElement then 
			msg("arguments elements = ")
			for i,element in ipairs(rl.argumentElement) do
				msg("    - "..i.." = "..element)
			end
		end

		if rl.registeredCommands[rl.command].switches then
			msg("switches = ")
			for switch,value in pairs(rl.registeredCommands[rl.command].switches) do
				msg("    DEFAULT: "..switch.." = "..type(value))
				msg("    USER: "..switch.." = "..tostring(rl.registeredCommands[rl.command][switch]))
			end
		end
	end

end

function getPositionInput()
	local cursorPosition = reaper.GetCursorPositionEx(0)
	rl.timeInput(cursorPosition)
end


rl.registeredCommands.testInputs = {main = testInputs, waitForEnter = true, switches = {flip = true, light = true, name = "New Track Name", channels = "channels to process", help = true, time = getPositionInput}}
