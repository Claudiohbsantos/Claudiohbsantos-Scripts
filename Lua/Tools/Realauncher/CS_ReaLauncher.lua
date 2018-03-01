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

local function matchVariables(str,tableOfVariables)
	::RESTART::
	for var,value in pairs(tableOfVariables) do
		local matches
		if type(value) == "string" and value:match("^return .+") then
			str,matches = str:gsub("%$"..var,function () return load(value)() end)
		else	
			str,matches = str:gsub("%$"..var,tostring(value))
		end
		if matches > 0 then goto RESTART end
	end
	return str
end

local function substituteVariables(str) 
	local newString = str
	newString = matchVariables(newString,rl.variables.user)
	newString = matchVariables(newString,rl.variables.native)
	return newString
end

local function checkUniversalSwitches(universalSwitches)
	if universalSwitches.execnow then executeNowFlag = true end
	if universalSwitches.help and rl.helpFiles[rl.text.util] then launchAltGUI(openMarkdownDisplay,rl.helpFiles[rl.text.util]) end
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

local function matchUniversalSwitches(args)
	local toRemoveFromArgsTable = {}
	for i,arg in ipairs(args) do
		for switch,defaultValue in pairs(universalSwitches) do
			if arg:match("^/"..switch) or arg:match("^%-%-"..switch) then
				if type(defaultValue) == "boolean" then
					universalSwitches[switch] = not universalSwitches[switch]
					table.insert(toRemoveFromArgsTable,i)
				end
			end
		end
	end
	args = removePositionsFromNumberedTable(args,toRemoveFromArgsTable)
	return args
end

local function fillArgumentsTable(rawToProcess)
	local argsTable = {}
	local currChar = rawToProcess:sub(1,1)
	local openString = false
	local currArg = 1

	for i=1,rawToProcess:len() do
		if not argsTable[currArg] then argsTable[currArg] = "" end

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
				argsTable[currArg] = argsTable[currArg]..currChar
			else
				if argsTable[currArg] ~= "" then currArg = currArg+1 end
			end
			goto NEXT
		end		

		argsTable[currArg] = argsTable[currArg]..currChar

		::NEXT::
		rawToProcess = rawToProcess:sub(2)
		currChar = rawToProcess:sub(1,1)
	end
	return argsTable
end

local function matchAliases(possibleUtil)
	for alias,substitution in pairs(rl.aliases) do
		if alias == possibleUtil then
			rl.text.raw = substitution
			sendCursorToEndOfText()
			return substitution
		end
	end
end

local function matchRegisteredUtils(possibleUtil)
	rl.currentAutocomplete = nil
	if possibleUtil then 
		for util in pairs(rl.registeredUtils) do
			if util == possibleUtil then
				local matchedUtil = possibleUtil
				possibleUtil = nil
				return matchedUtil
			end
		end
		if not matchedUtil and possibleUtil:match("^%g+$") then
			suggestUtil(possibleUtil)
		end
	end
end

local function  getPossibleUtil(rawToProcess)
	local possibleUtil = rawToProcess:match("^%s*(%g+)") or ""
	rawToProcess = rawToProcess:sub(possibleUtil:len()+1)
	return rawToProcess,possibleUtil
reaper.Undo_EndBlock(string descchange,integer extraflags)

local function parseCommands(t)
	local commandsTable = {}
	for command in t:gmatch("([^;]+)") do
		table.insert(commandsTable,command)
	end
	return commandsTable
end

function parseInput(t)
	::RESTARTPARSE::

	t.possibleUtil = nil
	t.fullArgument = nil
	local rawToProcess = t.raw

	rawToProcess, possibleUtil = getPossibleUtil(rawToProcess)
	if possibleUtil then 
		if matchAliases(possibleUtil) then goto RESTARTPARSE end
		t.commands = parseCommands(t.raw)
		t.util = matchRegisteredUtils(possibleUtil)
	end

	if t.util then 
		if rl.config.subvariables then rawToProcess = substituteVariables(rawToProcess) end
		t.fullArgument = rawToProcess:match("^%s*(%g+.*)")
		t.arguments = fillArgumentsTable(rawToProcess)
		matchUniversalSwitches(t.arguments)
		matchSwitches(t.arguments)
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
	for util in historyFile:lines() do 
		if util ~= "\n" then table.insert(history,util) end
	end
	return history
end

local function saveHistory(historyTable,utilToSave)
	if rl.text.util then
		if rl.text.util ~= "!!" then
			-- os.execute([[mkdir "]]..rl.userSettingsPath..[["]])
			
			table.insert(historyTable,utilToSave)
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

local function loadUserSettingsFromFile(filename)
	local settingsFile = io.open(rl.userSettingsPath.."\\"..filename,"r")
	settingsTable = {}
	for param in settingsFile:lines() do 
		local paramName,value = string.match(param,"^(%g+)=([^\n]+)")
		if paramName and value then settingsTable[paramName] = value end
	end
	return settingsTable
end

local function loadHelpFiles()
	local helpFiles = {}
	local helpDirectory = rl.scriptPath.."\\Help"

	for util in pairs(rl.registeredUtils) do
		local f = io.open(helpDirectory.."\\"..util..".md", "r")
		if f then
			local content = f:read("a")
			helpFiles[util] = content
			f:close()
		end
	end
	return helpFiles
end

local function loadModules()
	rl.scriptPath = get_script_path()
	
	package.path = package.path .. ";" .. rl.scriptPath .. "?.lua"
	
	require("CS_FunctionLibrary")


	for library in rl.config.libraries:gmatch("([^;]+)") do
		require(library)
	end

	for module in rl.config.modules:gmatch("([^;]+)") do
		require(module)
	end

end

local function loadSettings()
	rl.scriptPath = get_script_path()

	rl.userSettingsPath = rl.scriptPath.."\\User"
	rl.config = loadUserSettingsFromFile("config.txt")

	loadModules()

	rl.history = loadhistory()
	rl.aliases = loadUserSettingsFromFile("aliases.txt")
	rl.helpFiles = loadHelpFiles()
	rl.variables.user = loadUserSettingsFromFile("variables.txt")
	-- loadShortcuts()
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
		sendCursorToEndOfText()
		parseInput(rl.text)
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

function suggestUtil(util)
	local utilsAndAliases = appendTables(rl.registeredUtils,rl.aliases)

	local utilMatches = searchUnorderedListForExactMatchesAndReturnMatchesTable(utilsAndAliases,{util})
	if #utilMatches > 0 and util:len() > 0 and  rl.text.raw:match("^%g+$") then 
		utilMatches = mergeSortMatrixDescending(utilMatches,"percentageOfProximityToArguments")

		local suggestion = string.sub(utilMatches[1].match,string.len(util)+1)
		rl.currentAutocomplete = suggestion
	else 
		rl.currentAutocomplete = nil
	end
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

local function typeOrExecuteChar(char)
	if type(charFunction[char]) == "function" then
		charFunction[char]()
	else
		launcherTextBox(char)	
	end

end

local function dummyFunction()
end

local function setCurrentEnvironment(currUtil)
	local environment = currUtil or "default"
	charFunction = appendTables(rl.registeredUtils.default.charFunction,rl.registeredUtils[environment].charFunction,true)
	passiveFunction = rl.registeredUtils[environment].passiveFunction or dummyFunction
	onEnterFunction = rl.registeredUtils[environment].onEnter or dummyFunction
	entranceFunction = rl.registeredUtils[environment].entranceFunction or dummyFunction
	executeOnExit =  rl.registeredUtils[environment].exitFunction or dummyFunction
	switches = rl.registeredUtils[environment].switches or {}
	extendedHelp = rl.registeredUtils[environment].help
	drawGUI = rl.registeredUtils[environment].gui or drawMainGUI

	switchesDefaultVals = {}
	for switch,defaultValue in pairs(switches) do switchesDefaultVals[switch] = defaultValue end

	rl.text.tipLine = rl.registeredUtils[environment].description or ""
	return environment
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
	
		if rl.text.currChar ~= 0 or preloadedText then 
			preloadedText = nil
			typeOrExecuteChar(rl.text.currChar)
			parseInput(rl.text)
			checkUniversalSwitches(universalSwitches)
		end
			
		if rl.text.util ~= prevUtil then
			changeEnvironment(rl.text.util)
			prevUtil = rl.text.util
		end
	
		passiveFunction()
		if rl.text.currChar == kbInput.enter or executeNowFlag then onEnterFunction() end
		
		if not executeNowFlag then drawGUI() end -- from GUI_Library
	
		gfx.update()
		if rl.text.currChar ~= -1 and rl.text.currChar ~= kbInput.escape and rl.text.currChar ~= kbInput.enter and not executeNowFlag then reaper.defer(realauncherMainLoop) else gfx.quit() end
	end
end 

function runRealauncher(preloadedText)
	rl = {}
	rl.text = {}
	rl.text.raw = preloadedText or ''
	sendCursorToEndOfText()

	local prevUtil

	rl.registeredUtils = {}
	
	loadSettings()
	recallHistory = recallHistoryMaker()
	
	setCurrentEnvironment()
	
	if not executeNowFlag then initLauncherGUI("center") end
	realauncherMainLoop()
	
	reaper.atexit(exitRoutine)
end

-- SHOW TIME! --

runRealauncher(preloadedText)