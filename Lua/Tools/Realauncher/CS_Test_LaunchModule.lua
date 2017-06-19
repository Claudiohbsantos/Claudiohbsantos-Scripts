--[[
@description CS_Test_LaunchModule
@version 1.0
@author Claudiohbsantos
@link http://claudiohbsantos.com
@date 2017 06 19
@about
  # CS_Test_LaunchModule
  
@changelog
  - initial release
@noindex
--]]

function testMain()
	-- if registeredCommands.test.help then
	-- 	reaper.ShowMessageBox("Im here to help","MR Help",0)
	-- else
	-- 	msg("text = "..realauncher.text)
	-- 	msg("command = "..realauncher.command)
	-- 	if realauncher.arguments then msg("arguments = "..realauncher.arguments) end
	-- 	if realauncher.argumentElement then 
	-- 		msg("arguments elements = ")
	-- 		for i,element in ipairs(realauncher.argumentElement) do
	-- 			msg("    - "..i.." = "..element)
	-- 		end
	-- 	end

	-- 	if registeredCommands[realauncher.command].switches then
	-- 		msg("switches = ")
	-- 		for switch,value in pairs(registeredCommands[realauncher.command].switches) do
	-- 			msg("    DEFAULT: "..switch.." = "..type(value))
	-- 			msg("    USER: "..switch.." = "..tostring(registeredCommands[realauncher.command][switch]))
	-- 		end
	-- 	end
	-- end
	local cursorPos = reaper.GetCursorPositionEx(0)
	local userInput = getInput(cursorPos)

	if userInput then
		reaper.SetEditCurPos2(0,userInput,true,false)
	end
end

registeredCommands.test = {main = testMain, waitForEnter = false, switches = {flip = true, light = true, name = "New Track Name", channels = "channels to process", help = true }, description = "General Tester for functions of this module"}

function drawDEBUG(text)
	gfx.setfont(1, gui_fontname, gui_fontsize)
    gfx.x = obj_offs*2
    gfx.y = obj_offs + 32
    gfx.set(1,1,1,0.8,0)
    gfx.drawstr(tostring(text))
end

