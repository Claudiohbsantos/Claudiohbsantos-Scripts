function TCTextBox(char)
if not tcInput.active_char then tcInput.active_char = 0 end
if not tcInput.text        then tcInput.text = '' end

if  -- regular input
    (
      ( char >= 48 -- 0
      and char <= 57) -- 9
    )
    then        
      tcInput.text = tcInput.text:sub(0,tcInput.active_char)..
        string.char(char)..
        tcInput.text:sub(tcInput.active_char+1)
      tcInput.active_char = tcInput.active_char + 1
  end
  
  if char == kbInput.backspace then
    tcInput.text = tcInput.text:sub(0,tcInput.active_char-1)..
      tcInput.text:sub(tcInput.active_char+1)
    tcInput.active_char = tcInput.active_char - 1
  end

  if char == kbInput.deleteKey then
    tcInput.text = tcInput.text:sub(0,tcInput.active_char)..
      tcInput.text:sub(tcInput.active_char+2)
    tcInput.active_char = tcInput.active_char
  end
        
  if char == kbInput.leftArrow then
    tcInput.active_char = tcInput.active_char - 1
  end
  
  if char == kbInput.rightArrow then
    tcInput.active_char = tcInput.active_char + 1
  end

  if char == kbInput.minus then
    tcInput.minusMode = not tcInput.minusMode
    tcInput.resetAutoCompletedTimecode = not tcInput.resetAutoCompletedTimecode
    if tcInput.plusMode then 
      tcInput.plusMode = false
      tcInput.resetAutoCompletedTimecode = not tcInput.resetAutoCompletedTimecode
    end
  end

  if char == kbInput.plus then
    tcInput.plusMode = not tcInput.plusMode
    tcInput.resetAutoCompletedTimecode = not tcInput.resetAutoCompletedTimecode
    if tcInput.minusMode then 
      tcInput.minusMode = false
      tcInput.resetAutoCompletedTimecode = not tcInput.resetAutoCompletedTimecode 
    end
  end

  if char == kbInput.spacebar and not tcInput.minusMode and not tcInput.plusMode then
    tcInput.resetAutoCompletedTimecode = not tcInput.resetAutoCompletedTimecode
  end

if tcInput.active_char < 0 then tcInput.active_char = 0 end
if tcInput.active_char > tcInput.text:len()  then tcInput.active_char = tcInput.text:len() end

end

function drawTimeInputPreview(preview,userInput)
  if tcInput.minusMode then printText("- ","red","TimeInput") end
  if tcInput.plusMode then printText("+ ","blue","TimeInput") end

	if preview then printText(preview,"grey","TimeInput") end

  local color = nil
  if tcInput.minusMode then color = "red" end
  if tcInput.plusMode then color = "blue" end
  if not color then color = "green" end

  printText(userInput,color,"TimeInput")

end

--------------------------------------------------------------------------------------- 

function getTimeInput(arguments,defaultTimeInSeconds)

		local TimeString = ""
		TimeString = reaper.format_timestr_pos(defaultTimeInSeconds,TimeString,-1)

    local timePunctuation = {}
    for i=1,TimeString:len(),1 do
      if string.match(TimeString:sub(i,i),"%d") then 
        timePunctuation[i] = 0
      else
        timePunctuation[i] = TimeString:sub(i,i)
      end 
    end

    for i=1,#timePunctuation,1 do
      tcInput.zeroTCString = tcInput.zeroTCString..timePunctuation[i]
    end
    local tempArgs = arguments
    tcInput.userInput = ""

    local i = #timePunctuation
    while tempArgs:len() > 0 do
        if timePunctuation[i] and timePunctuation[i] ~= 0 then
          tcInput.userInput = tcInput.userInput..timePunctuation[i]
        else
          tcInput.userInput = tcInput.userInput..tempArgs:sub(tempArgs:len())
          tempArgs = tempArgs:sub(1,tempArgs:len()-1)
        end
      i = i-1
    end

    tcInput.userInput = tcInput.userInput:reverse()

		if TimeString:len()-tcInput.userInput:len() > 0 then
      if not tcInput.resetAutoCompletedTimecode then
			 defaultTimeStringUnchangedDigits = TimeString:sub(1,TimeString:len()-tcInput.userInput:len())
      else
       defaultTimeStringUnchangedDigits = tcInput.zeroTCString:sub(1,TimeString:len()-tcInput.userInput:len()) 
      end 
		else
			defaultTimeStringUnchangedDigits = ""
		end

    local lenOfdefaultString
    if string.len(tcInput.userInput) > 10 then 
      lenOfdefaultString = string.len(tcInput.userInput) 
    else 
      lenOfdefaultString = 10 
    end

		TimeString = string.sub(defaultTimeStringUnchangedDigits..tcInput.userInput,1,lenOfdefaultString)

		tcInput.timeArgPreview = defaultTimeStringUnchangedDigits


    drawTimeInputPreview(tcInput.timeArgPreview,tcInput.userInput)

		local inputInSeconds = reaper.parse_timestr_pos(TimeString,-1)
		if char == kbInput.tab or char == kbInput.enter then
      local resultingTimecodeInSeconds
      if tcInput.minusMode then 
        resultingTimecodeInSeconds = defaultTimeInSeconds - inputInSeconds

      else 
        if tcInput.plusMode then
          resultingTimecodeInSeconds = defaultTimeInSeconds + inputInSeconds
        else
          resultingTimecodeInSeconds = inputInSeconds
        end
      end

      return resultingTimecodeInSeconds,TimeString
		end

end	

function initTimeInput()
  char = 0
  tcInput = {}
  tcInput.minusMode = false
  tcInput.plusMode = false
  tcInput.resetAutoCompletedTimecode = false
  tcInput.zeroTCString = "0:00:00:00"
  rl.tipLine = [[Spacebar to reset to 0  -  "+" for addition mode  -  "-" for subtraction mode]] 
end