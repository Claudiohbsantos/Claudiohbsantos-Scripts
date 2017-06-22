function setTimeSelIn(arguments)
	timeSelIn,timeSelOut = reaper.GetSet_LoopTimeRange2(0,false,true,0,0,false)

	local userInput = getInput(arguments,timeSelIn)

	if userInput then
    if timeSelOut == reaper.GetProjectTimeOffset(0, false) then 
      timeSelOut = userInput
    end

    if userInput > timeSelOut then
      userInput = timeSelOut
    end

      reaper.GetSet_LoopTimeRange2(0,true,true,userInput,timeSelOut,false)
	end
end	

function setTimeSelLen(arguments)
  timeSelIn,timeSelOut = reaper.GetSet_LoopTimeRange2(0,false,true,0,0,false)

  timeSelLen = timeSelOut - timeSelIn

  local userInput = getInput(arguments,timeSelLen)

  if userInput then
    if timeSelIn == reaper.GetProjectTimeOffset(0, false) then
          timeSelIn = reaper.GetCursorPositionEx(0)
      end

      timeSelOut = timeSelIn + userInput

      reaper.GetSet_LoopTimeRange2(0,true,true,timeSelIn,timeSelOut,false)
  end
end 

function setTimeSelOut(arguments)
  timeSelIn,timeSelOut = reaper.GetSet_LoopTimeRange2(0,false,true,0,0,false)

  local userInput = getInput(arguments,timeSelOut)

  if userInput then
      if timeSelIn > userInput then
        timeSelIn = userInput
      end

        reaper.GetSet_LoopTimeRange2(0,true,true,timeSelIn,userInput,false)
  end
end 

registeredCommands.tslen = {setTimeSelLen,runImediatelly}
registeredCommands.tsin = {setTimeSelIn,runImediatelly}
registeredCommands.tsout = {setTimeSelOut,runImediatelly}