registeredCommands.n1 = {setNudgeValue1,runImediatelly}
registeredCommands.n2 = {setNudgeValue2,runImediatelly}

function setNudgeValue2(arguments)
	local _,currentNudge2Value = reaper.GetProjExtState(0,"CS_Top Display_GlobalVariables","nudge2Value")

	if not currentNudge2Value or currentNudge2Value:len() == 0 then 
		currentNudge2Value = 1
		reaper.SetProjExtState(0,"CS_Top Display_GlobalVariables","nudge2Value",currentNudge2Value)
	end

	local userInput = getInput(arguments,currentNudge2Value)

	if userInput then	
		reaper.SetProjExtState(0,"CS_Top Display_GlobalVariables","nudge2Value",userInput)
	end	
end

function setNudgeValue1(arguments)
	local _,currentNudge1Value = reaper.GetProjExtState(0,"CS_Top Display_GlobalVariables","nudge1Value")

	if not currentNudge1Value or currentNudge1Value:len() == 0 then 
		currentNudge1Value = 1/reaper.TimeMap_curFrameRate(0)
		reaper.SetProjExtState(0,"CS_Top Display_GlobalVariables","nudge1Value",currentNudge1Value)
	end

	local userInput = getInput(arguments,currentNudge1Value)

	if userInput then	
		reaper.SetProjExtState(0,"CS_Top Display_GlobalVariables","nudge1Value",userInput)
	end		
end
