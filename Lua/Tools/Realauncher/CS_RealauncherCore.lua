--[[
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

local function declareMathFunctions()
	local declarations = [[
	local abs = math.abs
	local acos = math.acos
	local asin = math.asin
	local atan = math.atan
	local ceil = math.ceil
	local cos = math.cos
	local deg = math.deg
	local exp = math.exp
	local floor = math.floor
	local fmod = math.fmod
	local huge = math.huge
	local log = math.log
	local max = math.max
	local maxinteger = math.maxinteger
	local min = math.min
	local mininteger = math.mininteger
	local modf = math.modf
	local pi = math.pi
	local rad = math.rad
	local random = math.random
	local randomseed = math.randomseed
	local sin = math.sin
	local sqrt = math.sqrt
	local tan = math.tan
	local tointeger = math.tointeger
	local type = math.type
	local ult = math.ult
	]]

	return declarations
end

function evaluateMathExp(exp)
	local expFunction = load(declareMathFunctions().." return "..exp)
	local success,result = pcall(expFunction)
	return result
end

local function substituteMathInParentheses(str)
	local newString = str
	newString = newString:gsub("%[(.-)%]",evaluateMathExp)
	return newString
end

local function checkUniversalSwitches(universalSwitches)
	if universalSwitches.execnow then executeNowFlag = true end
	if universalSwitches.help and rl.helpFiles[rl.currentCommand.util] then viewMarkdown(rl.helpFiles[rl.currentCommand.util],true) ; forceExit = true end
end

local function matchSwitches(t)
	local switches = {}
	local switchesDefaultVals = rl.registeredUtils[t.util].switches or {}
	for switch,val in pairs(switchesDefaultVals) do switches[switch] = val end
	local nextIsSwitchVal = nil
	local toRemoveFromArgsTable = {}
	for i,arg in ipairs(t.arguments) do
		if nextIsSwitchVal then
			switches[nextIsSwitchVal] = arg
			table.insert(toRemoveFromArgsTable,i)
			nextIsSwitchVal = false
		end

		for switch,defaultValue in pairs(switchesDefaultVals) do
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
	t.arguments = removePositionsFromNumberedTable(t.arguments,toRemoveFromArgsTable)
	return switches,t.arguments
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
			rl.text.raw = rl.text.raw:sub(1,-(alias:len()+1))..substitution
			sendCursorToEndOfText()
			rl.forceReparse = true
			return substitution
		end
	end
end

local function matchRegisteredUtils(possibleUtil,args)
	rl.currentAutocomplete = nil
	if possibleUtil then 
		for util in pairs(rl.registeredUtils) do
			if util == possibleUtil then
				local matchedUtil = possibleUtil
				possibleUtil = nil
				return matchedUtil
			end
		end
		if not matchedUtil and args == "" then
			suggestUtil(possibleUtil)
		end
	end
end

local function  getPossibleUtil(rawToProcess)
	local possibleUtil = rawToProcess:match("^%s*(%g+)") or ""
	local startOfPossibleUtil,endOfPossibleUtil = rawToProcess:find(possibleUtil)
	rawToProcess = rawToProcess:sub(endOfPossibleUtil+1)
	return rawToProcess,possibleUtil
end

function parseInput(t)
	local commandsTable = {}

	local currChar = t:sub(1,1)
	local openString = false
	local currCommand = 1
	for i=1,t:len() do
		if not commandsTable[currCommand] then commandsTable[currCommand] = {raw = ""} end

		if currChar == [["]] then 
			if not openString then 
				openString = true
			else
				openString = false
			end
			commandsTable[currCommand].raw = commandsTable[currCommand].raw..currChar
			goto NEXT
		end

		if currChar == ";" then
			if openString then 
				commandsTable[currCommand].raw = commandsTable[currCommand].raw..currChar
			else
				currCommand = currCommand+1
				commandsTable[currCommand] = {raw = ""}
			end
			goto NEXT
		end		

		commandsTable[currCommand].raw = commandsTable[currCommand].raw..currChar

		::NEXT::
		t = t:sub(2)
		currChar = t:sub(1,1)
	end
	return commandsTable
end

function parseCommand(t)
	
	t.possibleUtil = nil
	t.fullArgument = nil

	local rawToProcess = t.raw
	rawToProcess, possibleUtil = getPossibleUtil(rawToProcess)
	if possibleUtil then 
		matchAliases(possibleUtil)
		t.util = matchRegisteredUtils(possibleUtil,rawToProcess)
	end

	if t.util then 
		if rl.config.subvariables then rawToProcess = substituteVariables(rawToProcess) end
		if rl.config.subvariables then rawToProcess = substituteMathInParentheses(rawToProcess) end
		t.fullArgument = rawToProcess:match("^%s*(%g+.*)")
		t.arguments = fillArgumentsTable(rawToProcess)
		matchUniversalSwitches(t.arguments)
		t.switches = matchSwitches(t)
	end
	return t
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
	if rl.currentCommand.util ~= "!!" then
	
		utilToSave = utilToSave:gsub("/execnow","")

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

	for util in pairs(rl.registeredUtils) do
		if reaper.file_exists(rl.helpFilesPath.."\\"..util..".md") then
			helpFiles[util] = rl.helpFilesPath.."\\"..util..".md"
		end
	end
	return helpFiles
end

function saveTableToFile(tableToSave,filePath)
	local tableFile = io.open(filePath,"w")
	for alias,sub in pairs(tableToSave) do
		if sub ~= "" then
			tableFile:write(alias.."="..sub.."\n")
		end
	end
	tableFile:close()
end

function scanModules()
	local scannedLibraries = ""
	local scannedModules = ""
	for file in io.popen([[dir "]]..rl.scriptPath..[[" /b]]):lines() do 
		
		if string.match(file,"_Library.lua$") then 
			local LaunchModule = string.match(file,"(.*)%.lua")
			scannedLibraries = scannedLibraries..LaunchModule..";"
		end
	end

	for file in io.popen([[dir "]]..rl.scriptPath..[[" /b]]):lines() do 
		if string.match(file,"_LaunchModule.lua$") then 
			local LaunchModule = string.match(file,"(.*)%.lua")
			scannedModules = scannedModules..LaunchModule..";"
		end
	end

	rl.config.libraries = scannedLibraries
	rl.config.modules = scannedModules
	saveTableToFile(rl.config,rl.userSettingsPath.."\\config.txt")
end

local function loadModules()
	-- TODO catch error message in case of error on module
	rl.scriptPath = get_script_path()
	
	package.path = package.path .. ";" .. rl.scriptPath .. "?.lua"
	
	require("CS_FunctionLibrary")
	local alreadyattempted = false
	::RESTART_MODULE_LOADING::

	for library in rl.config.libraries:gmatch("([^;]+)") do
		local success,err = pcall(require,library)
		if not success then
			scanModules()
			rl.config = loadUserSettingsFromFile("config.txt")
			if not alreadyattempted then
				alreadyattempted = true	
				goto RESTART_MODULE_LOADING
			else
				error(err)
			end
		end
	end

	for mod in rl.config.modules:gmatch("([^;]+)") do
		local success,err = pcall(require,mod)	
		if not success then
			scanModules()
			rl.config = loadUserSettingsFromFile("config.txt")
			if not alreadyattempted then
				alreadyattempted = true	
				goto RESTART_MODULE_LOADING
			else
				error(err)
			end
		end
	end

end

local function loadSettings()
	rl.scriptPath = get_script_path()

	rl.userSettingsPath = rl.scriptPath.."User"
	rl.helpFilesPath = rl.scriptPath.."Help"
	rl.thirdPartyPath = rl.scriptPath.."3rdparty"

	rl.config = rl.config or loadUserSettingsFromFile("config.txt")

	if not rl.compiled then loadModules() end

	rl.history = rl.history or loadhistory()
	rl.aliases = rl.aliases or loadUserSettingsFromFile("aliases.txt")
	rl.helpFiles = rl.helpFiles or loadHelpFiles()
	rl.variables.user = rl.variables.user or loadUserSettingsFromFile("variables.txt")
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


function sendCursorToEndOfText()
	rl.active_char = rl.text.raw:len()
end

function performAutocomplete(suggestion)
	if suggestion then
		rl.text.raw = rl.text.raw..suggestion.." "
		sendCursorToEndOfText()
		parseInput(rl.text.raw)
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

function suggestUtil(util,args)
	local utilsAndAliases = appendTables(rl.registeredUtils,rl.aliases)
	utilsAndAliases.default = nil
	local utilMatches = cs.searchUnorderedListForExactMatchesAndReturnMatchesTable(utilsAndAliases,{util})
	if #utilMatches > 0 and util:len() > 0 and rl.currentCommand.raw:match("%g+$") then --
		utilMatches = cs.mergeSortMatrixDescending(utilMatches,"percentageOfProximityToArguments")

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

function setCurrentEnvironment(currUtil)
	local environment = currUtil or "default"
	charFunction = appendTables(rl.registeredUtils.default.charFunction,rl.registeredUtils[environment].charFunction,true)
	passiveFunction = rl.registeredUtils[environment].passiveFunction or dummyFunction
	onEnterFunction = rl.registeredUtils[environment].onEnter or dummyFunction
	entranceFunction = rl.registeredUtils[environment].entranceFunction or dummyFunction
	executeOnExit =  rl.registeredUtils[environment].exitFunction or dummyFunction
	-- TODO clean help
	extendedHelp = rl.registeredUtils[environment].help
	drawGUI = rl.registeredUtils[environment].gui or drawMainGUI
	rl.text.tipLine = rl.registeredUtils[environment].description or ""
	return environment
end

function changeEnvironment(newEnv) 
	if rl.text.currentCommand == rl.text.commands[#rl.text.commands] then 
		executeOnExit()
	else
		rl.currentCommand = rl.text.commands[rl.text.currentCommandIndex - 1]
		executeOnExit()
		rl.currentCommand = rl.text.commands[rl.text.currentCommandIndex]
	end
	
	setCurrentEnvironment(newEnv)
	parseCommand(rl.currentCommand)
	entranceFunction()		
end

function launchAltGUI(altgui,...)
	rl.altGUI = true
	gfx.quit() 
	pcall(altgui,...)
end

function returnToMainLoop(returnValue,execnow)
	gfx.quit()
    rl.altGUIReturn = returnValue
    rl.altGUI = false 
    if  execnow then 
    	executeNowFlag = true
    else
    	initLauncherGUI("center")
    end

    realauncherMainLoop()
end

local function retrieveAltGUIReturnValue(retval)
	if retval then
		rl.text.raw = rl.text.raw..retval
		retval = nil
		sendCursorToEndOfText()	
		rl.forceReparse = true
	end
end

function realauncherMainLoop()
	if not rl.altGUI then	
		rl.text.currChar  = gfx.getchar()
	
		rl.altGUIReturn = retrieveAltGUIReturnValue(rl.altGUIReturn)
	
		if rl.text.currChar ~= 0 or preloadedText or rl.forceReparse then
			universalSwitches = {execnow = false,help = false} 
			preloadedText = nil
			rl.forceReparse = nil
			typeOrExecuteChar(rl.text.currChar)
			rl.text.commands = parseInput(rl.text.raw)
			for i in ipairs(rl.text.commands) do
				rl.text.currentCommandIndex = i
				rl.currentCommand = rl.text.commands[i]
				rl.currentCommand = parseCommand(rl.currentCommand)
				checkUniversalSwitches(universalSwitches)
			end
		end
			
		if rl.currentCommand.util and rl.currentCommand.util ~= prevUtil then
			changeEnvironment(rl.currentCommand.util)
			prevUtil = rl.currentCommand.util
		end
	
		passiveFunction()
		if rl.text.currChar == kbInput.enter or executeNowFlag then 
			for i in ipairs (rl.text.commands) do
				rl.currentCommand = rl.text.commands[i]
				setCurrentEnvironment(rl.currentCommand.util)
				onEnterFunction(rl.currentCommand) 
			end
		end
		
		if not executeNowFlag then drawGUI() end -- from GUI_Library

		gfx.update()
		if rl.text.currChar ~= -1 and rl.text.currChar ~= kbInput.escape and rl.text.currChar ~= kbInput.enter and not executeNowFlag and not forceExit then reaper.defer(realauncherMainLoop) else gfx.quit() end
	end
end 

function runRealauncher(preloadedText)
	rl = rl or {}
	rl.text = {}
	rl.text.raw = preloadedText or ''
	rl.currentCommand = rl.text
	rl.text.commands = {}
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

