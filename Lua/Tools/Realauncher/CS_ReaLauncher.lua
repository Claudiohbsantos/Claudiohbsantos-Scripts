--[[
@description CS_ReaLauncher
@version 2.1alpha
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
rl = {}
rl.text = {}
rl.registeredCommands = {}
rl.text.raw = ''
rl.history = {}

local prevCommand

local function parseText(t)
	t.possibleCommand = nil
	t.fullArgument = nil
	local rawToProcess = t.raw
	t.possibleCommand = rawToProcess:match("^%s*(%g+)") or ""

	rawToProcess = rawToProcess:sub(t.possibleCommand:len()+1)
	t.fullArgument = rawToProcess:match("^%s*(%g+.*)")
	t.arguments = {}
	local currChar = rawToProcess:sub(1,1)
	local openString = false
	local currArg = 1

	for i=1,rawToProcess:len() do
		if not t.arguments[currArg] then t.arguments[currArg] = "" end

		if currChar == [["]] then 
			if not openString then 
				openString = true
			else
				openString = false
			end
			goto NEXT
		end

		if currChar == " " then
			if openString then 
				t.arguments[currArg] = t.arguments[currArg]..currChar
			else
				if t.arguments[currArg] ~= "" then currArg = currArg+1 end
			end
			goto NEXT
		end		

		t.arguments[currArg] = t.arguments[currArg]..currChar

		::NEXT::
		rawToProcess = rawToProcess:sub(2)
		currChar = rawToProcess:sub(1,1)
	end
end

local function recallHistoryMaker() 
	local positionInHistoryList = #rl.history+1
	return function (direction) 
		positionInHistoryList = positionInHistoryList + direction
		if positionInHistoryList < 1 then positionInHistoryList = 1 end
		if positionInHistoryList > #rl.history then positionInHistoryList = #rl.history end
		return rl.history[positionInHistoryList]
	end
end

------------------------------------------------------
local function get_script_path()
	local info = debug.getinfo(1,'S');
	local script_path = info.source:match[[^@?(.*[\/])[^\/]-$]]
	return script_path
end 

local function loadhistory()
	local historyFile = io.open(rl.userSettingsPath.."\\history.txt","r")
	local history = {}
	for command in historyFile:lines() do 
		if command ~= "\n" then table.insert(history,command) end
	end
	return history
end

local function saveHistory(historyTable,commandToSave)
	if rl.text.command then
		if rl.text.command ~= "!!" then
			os.execute([[mkdir "]]..rl.userSettingsPath..[["]])
			
			table.insert(historyTable,commandToSave)
			local offset
			if #historyTable - rl.config.maxHistory + 1 < 1 then
				offset = 1
			else
				offset = #historyTable - rl.config.maxHistory + 1
			end
	
				local historyFile = io.open(rl.userSettingsPath.."\\history.txt","w")
				for i = offset, #historyTable, 1 do
					historyFile:write(historyTable[i].."\n")
				end
			historyFile:close()
		end
	end
end

local function loadConfig()
	local configFile = io.open(rl.userSettingsPath.."\\config.txt","r")
	local configTable = {}
	for param in configFile:lines() do 
		local paramName,value = string.match(param,"^(%a+)=([^\n]+)")
		if paramName and value then configTable[paramName] = value end
	end
	return configTable
end

local function loadAliases()
	local aliasesFile = io.open(rl.userSettingsPath.."\\aliases.txt","r")
	local aliasesTable = {}
	for param in aliasesFile:lines() do 
		local paramName,value = string.match(param,"^(%g+)=([^\n]+)")
		if paramName and value then aliasesTable[paramName] = value end
	end
	return aliasesTable
end

local function loadVariables()
	variables = {}
	local variablesFile = io.open(rl.userSettingsPath.."\\variables.txt","r")
	for param in variablesFile:lines() do 
		local paramName,value = string.match(param,"^(%g+)=([^\n]+)")
		if paramName and value then variables[paramName] = value end
	end
	return variables
end

local function loadHelpFiles()
	local helpFiles = {}
	local helpDirectory = rl.scriptPath.."\\Help"
	for file in io.popen([[dir "]]..helpDirectory..[[" /b]]):lines() do 
		local f = io.open(helpDirectory.."\\"..file, "r")
		local content = f:read("a")
		local command = string.match(file,"(%a+)%.%a+$")
		helpFiles[command] = content
	end

	return helpFiles
end

local function loadSettings()
	rl.userSettingsPath = rl.scriptPath.."\\User"

	rl.config = loadConfig()
	rl.history = loadhistory()
	rl.aliases = loadAliases()
	rl.helpFiles = loadHelpFiles()
	rl.variables.user = loadVariables()
	-- loadShortcuts()
end

local function loadModules()
	rl.scriptPath = get_script_path()
	
	package.path = package.path .. ";" .. rl.scriptPath .. "?.lua"
	
	require("CS_FunctionLibrary")

	for file in io.popen([[dir "]]..rl.scriptPath..[[" /b]]):lines() do 
		if string.match(file,"_Library.lua$") then 
			local LaunchModule = string.match(file,"(.*)%.lua")
			require(LaunchModule)
		end
	end

	for file in io.popen([[dir "]]..rl.scriptPath..[[" /b]]):lines() do 
		if string.match(file,"_LaunchModule.lua$") then 
			local LaunchModule = string.match(file,"(.*)%.lua")
			require(LaunchModule)
		end
	end
end

local function exitRoutine()
	saveHistory(rl.history,rl.text.raw)
	if executeOnExit then
		if type(executeOnExit) == "table" then
			executeOnExit[1](table.unpack(rl.executeOnExit,2))
		else
			executeOnExit()
		end
	end
end

local function removeExcludeWords(searchArgumentsTable)
	local nonExclude = {}
	for i=1, #searchArgumentsTable,1 do
		if not string.match(searchArgumentsTable[i],"^-.*") then 
			nonExclude[#nonExclude+1] = searchArgumentsTable[i]
		end
	end

	return nonExclude
end


local function calculatePercentageOfProximityToArguments(databaseEntry,searchArgumentsTable)
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

local function mergeSortMatrixDescending(matrix,keyForSorting)
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


local function searchUnorderedListForExactMatchesAndReturnMatchesTable(databaseList,searchArgumentsTable)
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

function sendCursorToEndOfText()
	rl.active_char = rl.text.raw:len()
end

function performAutocomplete(suggestion)
	if suggestion then
		rl.text.raw = rl.text.raw..suggestion
		parseText(rl.text)
		sendCursorToEndOfText()
	end
end

local function appendTables(table1,table2,table2Overwritestable1)
	local combinedTable = {}

	for key,value in pairs(table1) do
		combinedTable[key] = value
	end

	if table2 then
		for key,value in pairs(table2) do
			if not combinedTable[key] then
				combinedTable[key] = value
			else
				if table2Overwritestable1 then
					combinedTable[key] = value
				else
					if type(key) == "number" then
						combinedTable[#combinedTable+1] = value
					end
				end
			end
		end
	end

	return combinedTable
end

function suggestCommand(command)
	local commandsAndAliases = appendTables(rl.registeredCommands,rl.aliases)

	local commandMatches = searchUnorderedListForExactMatchesAndReturnMatchesTable(commandsAndAliases,{command})
	if #commandMatches > 0 and command:len() > 0 and  rl.text.raw:match("^%g+$") then 
		commandMatches = mergeSortMatrixDescending(commandMatches,"percentageOfProximityToArguments")

		local suggestion = string.sub(commandMatches[1].match,string.len(command)+1)
		rl.currentAutocomplete = suggestion
	else 
		rl.currentAutocomplete = nil
	end
end

function initLauncherGUI(position)
	local function Lokasenna_WindowAtCenter(w, h,position)
		-- thanks to Lokasenna 
		-- http://forum.cockos.com/showpost.php?p=1689028&postcount=15    
		local l, t, r, b = 0, 0, w, h    
		local __, __, screen_w, screen_h = reaper.my_getViewport(l, t, r, b, l, t, r, b, 1)    
		
		if position == "bottom" then
			local x, y = (screen_w - w) / 2, (screen_h - h) - 70
			return w,h,x,y
		else -- center
			local x, y = (screen_w - w) / 2, (screen_h - h) / 2  
			return w,h,x,y  
		end

	end
	
	gfx.quit()
	gui_aa = 1
	gui_fontname = 'Calibri'
	gui_fontsize = 23      
	local gui_OS = reaper.GetOS()
	if gui_OS == "OSX32" or gui_OS == "OSX64" then gui_fontsize = gui_fontsize - 7 end

	w,h,x,y = Lokasenna_WindowAtCenter(rl.config.launcherWidth,rl.config.launcherHeight,position)
	gfx.init("ReaLauncher", w, h, 0, x, y)

end

local function launcherTextBox(char)
	if not rl.active_char then rl.active_char = 0 end

	if  kbInput.isAnyPrintableSymbol(char) then        
	      rl.text.raw = rl.text.raw:sub(0,rl.active_char)..
	        string.char(char)..
	        rl.text.raw:sub(rl.active_char+1)
	      rl.active_char = rl.active_char + 1
	end

	 if char == kbInput.backspace then
	 	if rl.active_char > 0 then
	    	rl.text.raw = rl.text.raw:sub(0,rl.active_char-1)..
	      		rl.text.raw:sub(rl.active_char+1)
	    	rl.active_char = rl.active_char - 1
	    end	
	  end

	  if char == kbInput.deleteKey then
	    rl.text.raw = rl.text.raw:sub(0,rl.active_char)..
	      rl.text.raw:sub(rl.active_char+2)
	    rl.active_char = rl.active_char
	  end
	        
	  if char == kbInput.leftArrow then
	    rl.active_char = rl.active_char - 1
	  end
	  
	  if char == kbInput.rightArrow then
	    rl.active_char = rl.active_char + 1
	  end

	if rl.active_char < 0 then rl.active_char = 0 end
	if rl.active_char > rl.text.raw:len()  then rl.active_char = rl.text.raw:len() end
end

local function matchRegisteredCommands(t)
	rl.currentAutocomplete = nil
	if t.possibleCommand then 
		t.command = nil
		for command in pairs(rl.registeredCommands) do
			if command == t.possibleCommand then
				t.command = t.possibleCommand
				t.possibleCommand = nil
			end
		end
		if not t.command and t.raw:match("^%g+$") then
			suggestCommand(t.possibleCommand)
		end
	end
end

local function matchAliases(t)
	if t.raw then
		for alias,substitution in pairs(rl.aliases) do
			if alias == t.raw then
				t.raw = substitution
				parseText(t)
				rl.active_char = rl.text.raw:len()
				break
			end
		end
	end
end

local function matchSwitches(args)
	for switch in pairs (switches) do switches[switch] = switchesDefaultVals[switch] end -- reset switches from previous parses
	local nextIsSwitchVal = nil
	local toRemoveFromArgsTable = {}
	for i,arg in ipairs(args) do
		if nextIsSwitchVal then
			switches[nextIsSwitchVal] = arg
			table.insert(toRemoveFromArgsTable,i)
			nextIsSwitchVal = false
		end

		for switch,defaultValue in pairs(switches) do
			if arg:match("^/"..switch) or arg:match("^%-%-"..switch) then
				if type(defaultValue) == "number" or type(defaultValue) == "string" then
					nextIsSwitchVal = switch
					table.insert(toRemoveFromArgsTable,i)
				else 
					if type(defaultValue) == "boolean" then
						switches[switch] = not switchesDefaultVals[switch]
						table.insert(toRemoveFromArgsTable,i)
					end
				end
			end
		end
	end
	args = removePositionsFromNumberedTable(args,toRemoveFromArgsTable)
	return args
end 

local function typeOrExecuteChar(char)
	if type(charFunction[char]) == "function" then
		charFunction[char]()
	else
		launcherTextBox(char)	
	end

end

local function dummyFunction()
end

local function setCurrentEnvironment(currCommand)
	local environment = currCommand or "default"
	charFunction = appendTables(rl.registeredCommands.default.charFunction,rl.registeredCommands[environment].charFunction,true)
	passiveFunction = rl.registeredCommands[environment].passiveFunction or dummyFunction
	onEnterFunction = rl.registeredCommands[environment].onEnter or dummyFunction
	entranceFunction = rl.registeredCommands[environment].entranceFunction or dummyFunction
	executeOnExit =  rl.registeredCommands[environment].exitFunction or dummyFunction
	switches = rl.registeredCommands[environment].switches or {}
	extendedHelp = rl.registeredCommands[environment].help
	drawGUI = rl.registeredCommands[environment].gui or drawMainGUI

	switchesDefaultVals = {}
	for switch,defaultValue in pairs(switches) do switchesDefaultVals[switch] = defaultValue end

	rl.text.tipLine = rl.registeredCommands[environment].description or ""
	return environment
end

local function matchUserVariables(argIndex,argument,argsTable,userVariables)
	for var,value in pairs(userVariables) do
		if argument:match("^%$"..var) then 
			if type(value) == "string" and value:match("^return .+") then
				argsTable[argIndex] = tostring(load(value)())
			else
				argsTable[argIndex] = tostring(value)
			end
			return true
		end
	end
end

local function matchNativeVariables(argIndex,argument,argsTable,nativeVariables)
	for var,value in pairs(nativeVariables) do
		if argument:match("^%$"..var) then 
				argsTable[argIndex] = tostring(value)
			return true
		end
	end
end
local function substituteVariables(argsTable)
	if rl.variables then 
		for i,argument in ipairs(argsTable) do
			if argument:match("^%$") then
				if matchUserVariables(i,argument,argsTable,rl.variables.user) then return end
				-- if user var matched return early so user var takes priority over native one
				if matchNativeVariables(i,argument,argsTable,rl.variables.native) then return end
			end		
		end
	end
end

function parseInput(t)
	parseText(t)
	matchAliases(t)
	matchRegisteredCommands(t)
	substituteVariables(t.arguments)
	matchSwitches(t.arguments)
end

function changeEnvironment(newEnv) 
	executeOnExit()
	setCurrentEnvironment(newEnv)
	parseInput(rl.text)
	entranceFunction()		
end

function launchAltGUI(altgui,...)
	rl.altGUI = true
	gfx.quit() 
	pcall(altgui,...)
end

function returnToMainLoop(returnValue)
	gfx.quit()
    rl.altGUIReturn = returnValue 
    rl.altGUI = false 
    initLauncherGUI("center")
    realauncherMainLoop()
end

local function retrieveAltGUIReturnValue(retval)
	if retval then
		rl.text.raw = rl.text.raw..retval
		retval = nil
		sendCursorToEndOfText()	
	end
end

function realauncherMainLoop()
	if not rl.altGUI then	
		rl.text.currChar  = gfx.getchar()
	
		rl.altGUIReturn = retrieveAltGUIReturnValue(rl.altGUIReturn)
	
		if rl.text.currChar ~= 0 then 
			typeOrExecuteChar(rl.text.currChar)
			parseInput(rl.text)
		end
			
		if rl.text.command ~= prevCommand then
			changeEnvironment(rl.text.command)
			prevCommand = rl.text.command
		end
	
		passiveFunction()
		if rl.text.currChar == kbInput.enter then onEnterFunction() end
		
		drawGUI() -- from GUI_Library
	
		gfx.update()
		if rl.text.currChar ~= -1 and rl.text.currChar ~= kbInput.escape and rl.text.currChar ~= kbInput.enter then reaper.defer(realauncherMainLoop) else gfx.quit() end
	end
end 

-- SHOW TIME! --

loadModules()
loadSettings()
recallHistory = recallHistoryMaker()

setCurrentEnvironment()

initLauncherGUI("center")
realauncherMainLoop()

reaper.atexit(exitRoutine)