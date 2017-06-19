--[[
@description CS_ReaLauncher
@version 1.0
@author Claudiohbsantos
@link http://claudiohbsantos.com
@date 2017 06 19
@about
  # CS_ReaLauncher
  No Description Yet
@changelog
  - initial release
@noindex
--]]
---------------------------------------------------------------------------------------
realauncher = {}  
realauncher.textToPrint = {}

leftArrow = 1818584692
upArrow = 30064
rightArrow = 1919379572
downArrow = 1685026670
deleteKey = 6579564
backspace = 8
minus = 45
plus = 43
spacebar = 32
enter = 13
quotes = 34
parenthesesOpen = 40
parenthesesClose = 41
tab = 9

realauncher.white = function(text) gfx.set(1,1,1,0.8,0) ; gfx.drawstr(text) return end
realauncher.grey = function(text) gfx.set(1,1,1,0.3,0) ; gfx.drawstr(text) return end
realauncher.red = function(text) gfx.set(1,0.6,0.6,0.8,0) ; gfx.drawstr(text) return end
realauncher.green = function(text) gfx.set(0.6,1,0.6,0.8,0) ; gfx.drawstr(text) return end
realauncher.blue = function(text) gfx.set(0.6,0.6,1,0.8,0) ; gfx.drawstr(text) return end


minusMode = false
plusMode = false
resetAutoCompletedTimecode = false
zeroTCString = "0:00:00:00"
---------------------------------------------------------------------------------------

function msg(s) reaper.ShowConsoleMsg(tostring(s)..'\n') end

function get_script_path()
	local info = debug.getinfo(1,'S');
	local script_path = info.source:match[[^@?(.*[\/])[^\/]-$]]
	return script_path
end 

---------------------------------------------------------------------------------------

function printText(text,color)
	table.insert(realauncher.textToPrint,{text,color})
end

function unprintLastText(n)
	for i=1,n+1,1 do table.remove(realauncher.textToPrint) end
end

function printHint(text,color)
	realauncher.previewToPrint = {text,color}
end

function TextBox(char)
if not realauncher.active_char then realauncher.active_char = 0 end
if not realauncher.text        then realauncher.text = '' end

if not numericalInputOnly then
	if  -- regular input
	    (
	        (char >= 65 -- a
	        and char <= 90) --z
	        or (char >= 97 -- a
	        and char <= 122) --z
	        or ( char >= 212 -- A
	        and char <= 223) --Z
	        or ( char >= 48 -- 0
	        and char <= 57) --Z
	        or char == 95 -- _
	        or char == 44 -- ,
	        or char == 32 -- (space)
	        or char == 45 -- (-)
	        or char == 92 -- \
	        or char == 47 -- / 
	        or char == 46 --.
	        or char == 58 -- :
	        or char == 34 -- "
	        or char == 40 -- (
	        or char == 41 -- )
	    )
	    then        
	      realauncher.text = realauncher.text:sub(0,realauncher.active_char)..
	        string.char(char)..
	        realauncher.text:sub(realauncher.active_char+1)
	      realauncher.active_char = realauncher.active_char + 1
	end
else
		if  -- numerical input
	    (
	        ( char >= 48 -- 0
	        and char <= 57) --9
	    )
	    then        
	      realauncher.text = realauncher.text:sub(0,realauncher.active_char)..
	        string.char(char)..
	        realauncher.text:sub(realauncher.active_char+1)
	      realauncher.active_char = realauncher.active_char + 1
		end

		if char == minus then
    minusMode = not minusMode
    resetAutoCompletedTimecode = not resetAutoCompletedTimecode
    if plusMode then 
      plusMode = false
      resetAutoCompletedTimecode = not resetAutoCompletedTimecode
    end
  end

  if char == plus then
    plusMode = not plusMode
    resetAutoCompletedTimecode = not resetAutoCompletedTimecode
    if minusMode then 
      minusMode = false
      resetAutoCompletedTimecode = not resetAutoCompletedTimecode 
    end
  end

  if char == spacebar and not minusMode and not plusMode then
    resetAutoCompletedTimecode = not resetAutoCompletedTimecode
  end

end 
  
  if char == backspace then
    realauncher.text = realauncher.text:sub(0,realauncher.active_char-1)..
      realauncher.text:sub(realauncher.active_char+1)
    realauncher.active_char = realauncher.active_char - 1
  end

  if char == deleteKey then
    realauncher.text = realauncher.text:sub(0,realauncher.active_char)..
      realauncher.text:sub(realauncher.active_char+2)
    realauncher.active_char = realauncher.active_char
  end
        
  if char == leftArrow then
    realauncher.active_char = realauncher.active_char - 1
  end
  
  if char == rightArrow then
    realauncher.active_char = realauncher.active_char + 1
  end

if realauncher.active_char < 0 then realauncher.active_char = 0 end
if realauncher.active_char > realauncher.text:len()  then realauncher.active_char = realauncher.text:len() end
end

function drawArgumentsAutocomplete(suggestion)
	if realauncher.argSuggestion then
		gfx.x = obj_offs*2-4
		gfx.y = obj_offs+gui_fontsize+obj_offs/2

		for suggestionWord in string.gmatch(suggestion,"([^%s]+)") do
		local alreadyDrawn = false
			for k=1, #realauncher.argumentElement, 1 do
				if string.find(suggestionWord,realauncher.argumentElement[k]) then
					local matchStart = string.find(suggestionWord,realauncher.argumentElement[k])

					gfx.drawstr(" ")

					if matchStart ~= 1 then 
						realauncher.grey()
						gfx.drawstr(suggestionWord:sub(1,matchStart-1))
					end

					realauncher.blue()
					gfx.drawstr(realauncher.argumentElement[k])

					if suggestionWord:len() ~= realauncher.argumentElement[k]:len() then
						realauncher.grey()
						gfx.drawstr(suggestionWord:sub(matchStart + realauncher.argumentElement[k]:len()))
					end
					
					alreadyDrawn = true
	
				end
			end

			if not alreadyDrawn then 
				realauncher.grey()
				gfx.drawstr(" "..suggestionWord)
			end
		end
	end
	realauncher.argSuggestion = nil
end

function drawModeSymbol(minusMode,plusMode)

  gfx.setfont(1, gui_fontname, gui_fontsize)
  gfx.x = obj_offs*1.5+
            gfx.measurestr(realauncher.command) + 8
  gfx.y = obj_offs + gui_fontsize/2 - gfx.texth/2  

  if minusMode then
    realauncher.red()
    gfx.drawstr("-")
  end

  if plusMode then
    realauncher.blue()
    gfx.drawstr("+")
  end
end

function drawTimeInputPreview(preview)
	if realauncher.timeArgPreview then
    gfx.x = obj_offs*1.5+
            gfx.measurestr(realauncher.command) + 19
    gfx.y = obj_offs + gui_fontsize/2 - gfx.texth/2

    realauncher.grey()
	gfx.drawstr(preview)
	if not minusMode and not plusMode then
  	 realauncher.green()
    else 
      if minusMode then
        realauncher.red()  
      else
        realauncher.blue()
      end
    end
	gfx.drawstr(realauncher.hiddenArguments)

	realauncher.timeArgPreview = nil
	realauncher.drawCursor = false	
	end

end

-------------------------------

function mergeSortMatrixDescending(matrix,keyForSorting)
	local matrixLength = #matrix

	local subMatrix = {}
	for i = 1,matrixLength,1 do
		subMatrix[i] = {}
		subMatrix[i][1] = matrix[i]
	end

	while #subMatrix[1] < matrixLength do
		local i = 1
		while i <= #subMatrix do
			local a = i
			local b = i+1

			if subMatrix[b] then 

				local buffer = {}
				local nElementsToCompare = #subMatrix[a] + #subMatrix[b]
				while #buffer < nElementsToCompare do
					if subMatrix[a][1] and subMatrix[b][1] then
						if subMatrix[a][1][keyForSorting] > subMatrix[b][1][keyForSorting] then
							table.insert(buffer,subMatrix[a][1])
							table.remove(subMatrix[a],1)
						else
							table.insert(buffer,subMatrix[b][1])
							table.remove(subMatrix[b],1)
						end
					else
						if subMatrix[a][1] then 
							table.insert(buffer,subMatrix[a][1])
							table.remove(subMatrix[a],1)
						end

						if subMatrix[b][1] then 
							table.insert(buffer,subMatrix[b][1])
							table.remove(subMatrix[b],1)
						end
					end
				end

				subMatrix[a] = buffer
				table.remove(subMatrix,b)
			end

			i = i + 1
		end

	end

	local sortedMatrix = subMatrix[1]

	return sortedMatrix
end


function sortMatches(matches)
	local sortedMatches = mergeSortMatrixDescending(matches,"percentageOfProximityToArguments") 

	return sortedMatches
end

function removeExcludeWords(searchArgumentsTable)
	local nonExclude = {}
	for i=1, #searchArgumentsTable,1 do
		if not string.match(searchArgumentsTable[i],"^-.*") then 
			nonExclude[#nonExclude+1] = searchArgumentsTable[i]
		end
	end

	return nonExclude
end

function calculatePercentageOfProximityToArguments(databaseEntry,searchArgumentsTable)
	local validWords = removeExcludeWords(searchArgumentsTable)

	local argumentsLength = 0
	for i=1,#validWords,1 do

		local repetitions = 0
		for match in string.gmatch(databaseEntry,validWords[i]) do
			repetitions = repetitions + 1
		end

		argumentsLength = argumentsLength + ( string.len(validWords[i]) * repetitions ) 
	end

	local spaces = 0
	for space in string.gmatch(databaseEntry,"%s") do
		spaces = spaces + 1
	end
	entryLength = string.len(databaseEntry) - spaces

	local percentageOfProximity = argumentsLength / entryLength

	percentageOfProximity = string.format("%.2f",percentageOfProximity)

	return percentageOfProximity

end

function searchUnorderedListForExactMatchesAndReturnMatchesTable(databaseList,searchArgumentsTable)
	local matches = {}

	for key,value in pairs(databaseList) do
		local isMatch
		for k,searchArg in ipairs(searchArgumentsTable) do
			if string.match(searchArg,"^-.*") then
				local excludeWord = string.sub(searchArg,2)
				if string.match(key,"^"..excludeWord) then
					isMatch = false
					break
				end				
			else
				if  string.match(key,"^"..searchArg) then
					isMatch = true
				else
					isMatch = false
				end
			end
		end

		if isMatch then
			
			local percentageOfProximityToArguments = calculatePercentageOfProximityToArguments(key,searchArgumentsTable)

			table.insert(matches,{match = key,percentageOfProximityToArguments = percentageOfProximityToArguments})
			matches[#matches].percentageOfProximityToArguments = percentageOfProximityToArguments
		end
	end


	return matches
end

function searchMatrixAndReturnMatchesTable(databaseMatrix,searchArgumentsTable,keyToSearchIn)
	local matches = {}


	for i = 1, #databaseMatrix, 1 do
		local isMatch
		for k = 1, #searchArgumentsTable, 1 do
			if string.match(searchArgumentsTable[k],"^-.*") then
				local excludeWord = string.sub(searchArgumentsTable[k],2)
				if string.find(databaseMatrix[i][keyToSearchIn],excludeWord) then
					isMatch = false
					break
				end				
			else
				if  string.find(databaseMatrix[i][keyToSearchIn],searchArgumentsTable[k]) then
					isMatch = true
				else
					isMatch = false
					break
				end
			end
		end

		if isMatch then
			matches[#matches+1] = databaseMatrix[i]

			local percentageOfProximityToArguments = calculatePercentageOfProximityToArguments(databaseMatrix[i][keyToSearchIn],searchArgumentsTable)
			matches[#matches].percentageOfProximityToArguments = percentageOfProximityToArguments
		end
	end

	return matches
end

---------------------------------------------------------------------------------------  
function getInput(arguments,startingValue)
	
	if arguments and startingValue then	
		numericalInputOnly = true
		local defaultTimeString = ""
		defaultTimeString = reaper.format_timestr_pos(startingValue,defaultTimeString,-1)

	    local timePunctuation = {}
	    for i=1,defaultTimeString:len(),1 do
	      if string.match(defaultTimeString:sub(i,i),"%d") then 
	        timePunctuation[i] = 0
	      else
	        timePunctuation[i] = defaultTimeString:sub(i,i)
	      end 
	    end

	    local zeroTCString = ""
	    for i=1,#timePunctuation,1 do
	      zeroTCString = zeroTCString..timePunctuation[i]
	    end
	    local tempArgs = arguments
	    realauncher.hiddenArguments = ""

	    local i = #timePunctuation
	    while tempArgs:len() > 0 do
	        if timePunctuation[i] and timePunctuation[i] ~= 0 then
	          realauncher.hiddenArguments = realauncher.hiddenArguments..timePunctuation[i]
	        else
	          realauncher.hiddenArguments = realauncher.hiddenArguments..tempArgs:sub(tempArgs:len())
	          tempArgs = tempArgs:sub(1,tempArgs:len()-1)
	        end
	      i = i-1
	    end

	    realauncher.hiddenArguments = realauncher.hiddenArguments:reverse()	

		if defaultTimeString:len()-realauncher.hiddenArguments:len() > 0 then
    	  if not resetAutoCompletedTimecode then
			 defaultTimeStringUnchangedDigits = defaultTimeString:sub(1,defaultTimeString:len()-realauncher.hiddenArguments:len())
   		   else
   		    defaultTimeStringUnchangedDigits = zeroTCString:sub(1,defaultTimeString:len()-realauncher.hiddenArguments:len()) 
   		   end 
		else
			defaultTimeStringUnchangedDigits = ""
		end

		local lenOfdefaultString
	    if string.len(realauncher.hiddenArguments) > 10 then 
	      lenOfdefaultString = string.len(realauncher.hiddenArguments) 
	    else 
	      lenOfdefaultString = 10 
	    end

		defaultTimeString = string.sub(defaultTimeStringUnchangedDigits..realauncher.hiddenArguments,1,lenOfdefaultString)

		realauncher.timeArgPreview = defaultTimeStringUnchangedDigits

		local inputInSeconds = reaper.parse_timestr_pos(defaultTimeString,-1)
		if char == 13 then 
	      local resultingTimecodeInSeconds
	      if minusMode then 
				 -- reaper.SetEditCurPos2(0,currentPosRaw - positionToGo,true,false)
	       resultingTimecodeInSeconds = startingValue - inputInSeconds
	      else 
	        if plusMode then
	          -- reaper.SetEditCurPos2(0,currentPosRaw + positionToGo,true,false)
	          resultingTimecodeInSeconds = startingValue + inputInSeconds
	        else
	          -- reaper.SetEditCurPos2(0,positionToGo,true,false) -- default mode
	          resultingTimecodeInSeconds = inputInSeconds
	        end
	      end

	      return resultingTimecodeInSeconds
		end
	else
		numericalInputOnly = nil
		minusMode = false
		plusMode = false
	end	

end	
    
---------------------------------------------------------------------------------------    
function enumerateAvailableCommands()
	for command in pairs(registeredCommands) do
		msg(command)
		for key,value in pairs(registeredCommands[command]) do
			msg("    - "..key.." = "..tostring(value))
		end
	end
end
---------------------------------------------------------------------------------------    
function storeAndPrintArgumentUnit(argumentUnit,command)
	if realauncher.nextIsParam then
		unprintLastText(string.len(argumentUnit))
		printText(argumentUnit.." ","green") 
		if string.sub(argumentUnit,1,1) == "\"" then argumentUnit = string.sub(argumentUnit,2,-2) end
		registeredCommands[command][realauncher.nextIsParam] = argumentUnit
		realauncher.previewToPrint = nil
		realauncher.nextIsParam = nil
	else
		local isSwitch = false
		if registeredCommands[command].switches then
			for switch in pairs(registeredCommands[command].switches) do
				if argumentUnit  == ("/"..switch) or argumentUnit == ("--"..switch) then
					if type(registeredCommands[command].switches[switch]) == "boolean" then
						registeredCommands[command][switch] = true
					else
						realauncher.nextIsParam = switch
						printHint(" ("..registeredCommands[command].switches[switch]..")","grey")
					end
					isSwitch = true
					unprintLastText(string.len(argumentUnit))
					printText(argumentUnit.." ","blue")
				end
			end
		end
		if not isSwitch then 
			unprintLastText(string.len(argumentUnit))
			printText(argumentUnit.." ","green") 
			if string.sub(argumentUnit,1,1) == "\"" then argumentUnit = string.sub(argumentUnit,2,-2) end
			realauncher.argumentElement[#realauncher.argumentElement + 1] = argumentUnit
		end
	end	
end

function matchAndStore(command,arguments)
	realauncher.previewToPrint = nil
	if registeredCommands[command] then
		realauncher.textToPrint = {}
		realauncher.command = command
		printText(command,"red")

		if arguments and string.len(arguments) > 0 then
			printText(" ","white") 
			realauncher.arguments = arguments
			realauncher.argumentElement = {}	
			local argumentUnit = ""
			realauncher.quoteOpen = false
			realauncher.nextIsParam = nil
			for i=1,#realauncher.arguments,1 do
				currentChar = string.sub(realauncher.arguments,i,i)
				if string.find(currentChar," ") then
					if not realauncher.quoteOpen then 
						printText(currentChar,"white") 
						if not string.match(argumentUnit,"^ $") and string.len(argumentUnit) > 0 then storeAndPrintArgumentUnit(argumentUnit,command) end
						argumentUnit = ""
					else
						printText(currentChar,"white") 
						argumentUnit = argumentUnit..currentChar 
					end
				else
					printText(currentChar,"green")
					if string.find(currentChar,"\"") then realauncher.quoteOpen = not realauncher.quoteOpen end
					argumentUnit = argumentUnit..currentChar
					if string.match(argumentUnit,"^/.*") or string.match(argumentUnit,"^%-%-.*") then suggestSwitch(string.sub(argumentUnit,2),command) end
				end
			end		
		else
			realauncher.arguments = nil
		end	
	else -- command not found
		suggestCommand(command)
		realauncher.command = nil
		realauncher.arguments = nil
		realauncher.hiddenArguments = nil 
	end
end

function CommandDispatcher(text)
	if not text then return end

	local command = string.match(text,"^%s*([^%s]+)")
	local arguments = string.match(text,"^%s*[^%s]+ (.*)")

	matchAndStore(command,arguments)
end

function suggestSwitch(word,command)
	local switchMatches = searchUnorderedListForExactMatchesAndReturnMatchesTable(registeredCommands[command].switches,{word})
	if #switchMatches > 0 then 
		switchMatches = sortMatches(switchMatches) 

		local suggestion = string.sub(switchMatches[1].match,string.len(word)+1)
		printHint(suggestion,"grey")
		realauncher.currentAutocomplete = suggestion
	else
		realauncher.previewToPrint = nil
		realauncher.currentAutocomplete = nil 
	end
end

function suggestCommand(command)
	local commandMatches = searchUnorderedListForExactMatchesAndReturnMatchesTable(registeredCommands,{command})
	if #commandMatches > 0 then 
		commandMatches = sortMatches(commandMatches) 

		local suggestion = string.sub(commandMatches[1].match,string.len(command)+1)
		printHint(suggestion,"grey")
		realauncher.currentAutocomplete = suggestion
	end
end

function drawWindow()
  --  draw back
    gfx.set(  1,1,1,  0.2,  0) --rgb a mode
    gfx.rect(0,0,obj_mainW,obj_mainH,1)	
  --  draw frame
    gfx.set(  1,1,1,  0.1,  0) --rgb a mode
    gfx.rect(obj_offs,obj_offs,obj_mainW-obj_offs*2,gui_fontsize+obj_offs/2 ,1)
end

function drawText()
    gfx.setfont(1, gui_fontname, gui_fontsize)
    gfx.x = obj_offs*2
    gfx.y = obj_offs
    if realauncher.command then
		for i=1,#realauncher.textToPrint,1 do
			realauncher[realauncher.textToPrint[i][2]](realauncher.textToPrint[i][1])
		end
	else
		realauncher.white(realauncher.text)
    end
    if realauncher.previewToPrint then
    	realauncher[realauncher.previewToPrint[2]](realauncher.previewToPrint[1])
    end
end

function drawCursor()
	if realauncher.active_char ~= nil then
    	alpha  = math.abs((os.clock()%1) -0.4)
      gfx.set(  1,1,1, alpha,  0) --rgb a mode
      gfx.x = obj_offs*1.5+
              gfx.measurestr(realauncher.text:sub(0,realauncher.active_char)) + 2
      gfx.y = obj_offs + gui_fontsize/2 - gfx.texth/2
      if realauncher.drawCursor then gfx.drawstr('|') end
    end  
end

function drawDescription(text)
	gfx.setfont(1, gui_fontname, gui_fontsize)
    gfx.x = obj_offs*2
    gfx.y = obj_offs + 32
    gfx.set(1,1,1,0.3,0)
    gfx.drawstr(tostring(text))
end

---------------------------------------------------------------------------------------    

function Run()
  char  = gfx.getchar()
  realauncher.drawCursor = true
  

  TextBox(char) -- perform typing
  realauncher.text = string.match(realauncher.text,"^%s*([^%s]?.*)")

  

  if char > 0  
    and realauncher.text 
    and char ~=  rightArrow
    and char ~= leftArrow then 
    	CommandDispatcher(realauncher.text)
  end

  if realauncher.command then
  	if registeredCommands[realauncher.command].waitForEnter then 
  		if char == 13 then CommandDispatcher(realauncher.text.." ") ; registeredCommands[realauncher.command].main(realauncher.arguments) end
  	else
  		registeredCommands[realauncher.command].main(realauncher.arguments)
  	end
  end

	drawWindow()
	drawText()
  	drawModeSymbol(minusMode,plusMode)
	drawTimeInputPreview(realauncher.timeArgPreview)
	drawCursor()
	drawArgumentsAutocomplete(realauncher.argSuggestion)
	if realauncher.command and registeredCommands[realauncher.command].description then drawDescription(registeredCommands[realauncher.command].description) end

	if realauncher.currentAutocomplete and char == tab then 
		realauncher.text = realauncher.text..realauncher.currentAutocomplete 
		realauncher.active_char = realauncher.active_char + string.len(realauncher.currentAutocomplete )
		realauncher.previewToPrint = nil
		realauncher.currentAutocomplete = nil 
		CommandDispatcher(realauncher.text)
	end

  gfx.update()
  last_char = char
  if char ~= -1 and char ~= 27 and char ~= 13  then reaper.defer(Run) else reaper.atexit(gfx.quit) end
  
end 

---------------------------------------------------------------------------------------
function loadModules()
	local scriptPath = get_script_path()
	package.path = package.path .. ";" .. scriptPath .. "?.lua"

	for file in io.popen([[dir "]]..scriptPath..[[" /b]]):lines() do 
		if string.match(file,"_LaunchModule.lua$") then 
			local LaunchModule = string.match(file,"(.*)%.lua")
			require(LaunchModule)
		end
	end

end

function initCommands()

	registeredCommands = {
							quit = {main = function() reaper.Main_OnCommand(40004,0) end, waitForEnter = true},
							enumcmd = {main = enumerateAvailableCommands , waitForEnter = true}
						 }						 
end

function initGUI()
	obj_mainW = 800	
	obj_mainH = 70
	obj_offs = 10
	
	gui_aa = 1
	gui_fontname = 'Calibri'
	gui_fontsize = 23      
	local gui_OS = reaper.GetOS()
	if gui_OS == "OSX32" or gui_OS == "OSX64" then gui_fontsize = gui_fontsize - 7 end
end

function Lokasenna_WindowAtCenter (w, h)
	-- thanks to Lokasenna 
	-- http://forum.cockos.com/showpost.php?p=1689028&postcount=15    
	local l, t, r, b = 0, 0, w, h    
	local __, __, screen_w, screen_h = reaper.my_getViewport(l, t, r, b, l, t, r, b, 1)    
	local x, y = (screen_w - w) / 2, (screen_h - h) / 2    
	gfx.init("ReaLauncher", w, h, 0, x, y)  
end

---------------------------------------------------------------------------------------

initGUI()

initCommands()
loadModules()

Lokasenna_WindowAtCenter (obj_mainW,obj_mainH)
Run()