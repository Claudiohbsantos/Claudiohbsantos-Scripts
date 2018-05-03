--[[
@noindex
]]--

rl.registeredUtils.default = {
	charFunction = {
					[kbInput.upArrow] = function() rl.text.raw = recallHistory(-1) ; sendCursorToEndOfText() end,
					[kbInput.downArrow] = function() rl.text.raw = recallHistory(1) ; sendCursorToEndOfText() end, 
					[kbInput.tab] = function () performAutocomplete(rl.currentAutocomplete) end,
					[kbInput.copy] = function () copyToClipboard(rl.text.raw) end,
					[kbInput.paste] = function () rl.text.raw = rl.text.raw..pasteFromClipboard(); sendCursorToEndOfText() end,
					[kbInput.ctrl.t] = function ()  launchAltGUI(tcInputStart,0) end,
					},				
	description = "Click the \"?\" button on the right for help.",
}

rl.registeredUtils.quit = {onEnter = function() reaper.Main_OnCommand(40004,0) end, description = "Quit Reaper"}

rl.registeredUtils.scanmodules = {onEnter = scanModules,description = "Scan Realauncher folder for new/deleted modules"}



local function enumerateAvailableUtils()
	local installedUtils = {}
	for util in pairs(rl.registeredUtils) do
		if util ~= "default" then
			installedUtils[util] = (rl.registeredUtils[util].description or "")
		end	
	end

	list("Installed Utilities",installedUtils)
end

rl.registeredUtils.enumcmd = {onEnter = enumerateAvailableUtils, description = "List all registered Utils and their descriptions"}

function redoUtil()
	rl.text.raw = rl.history[#rl.history]
	sendCursorToEndOfText()
	rl.text.commands = parseInput(rl.text.raw)
	for i in ipairs(rl.text.commands) do
		rl.text.currentCommandIndex = i
		rl.currentCommand = rl.text.commands[i]
		rl.currentCommand = parseCommand(rl.currentCommand)
		-- checkUniversalSwitches(universalSwitches)
	end
	for i in ipairs (rl.text.commands) do
		rl.currentCommand = rl.text.commands[i]
		setCurrentEnvironment(rl.currentCommand.util)
		passiveFunction()
		onEnterFunction(rl.currentCommand) 
	end
	
end

rl.registeredUtils["!!"] = {onEnter = redoUtil,description = "Redo last util", passiveFunction = function() rl.text.tipLine = [[Redo "]]..rl.history[#rl.history]..[["]] end}

local function registerAlias()
	if not rl.currentCommand.arguments then return end
	if rl.currentCommand.switches.l then list("Aliases",rl.aliases) return end

	if rl.currentCommand.arguments[1] ~= "" then newAlias = rl.currentCommand.arguments[1] end
	if rl.currentCommand.arguments[2] ~= "" then substitution = table.concat(rl.currentCommand.arguments," ",2) end

	if newAlias then
		rl.aliases[newAlias] = substitution
		saveTableToFile(rl.aliases,rl.userSettingsPath.."\\aliases.txt")
	end
end

rl.registeredUtils.alias = {
	onEnter = registerAlias,
	description = "Register, display and delete aliases",
	entranceFunction = function () 
		rl.text.tipLine = "(alias) [new substitution] ; if there is no substitution, alias will be erased" 
		rl.config.subvariables = false
	end,
	switches = {l = false,n = false},
	passiveFunction = function() executeNowFlag = false ; rl.config.subvariables = false ; if rl.currentCommand.switches and rl.currentCommand.switches.n then rl.config.subvariables = true end end, -- stops /execnow flag from triggering
	exitFunction = function () rl.config.subvariables = true end,
	}

local function registerVariable(input)
	if not input.arguments then return end
	
	if input.switches.l then 
		local tableToPrint = {["User Variables"] = rl.variables.user,["Native Variables"] = rl.variables.nativeDescriptions}
		list("Variables",tableToPrint)
		return 
	end

	if rl.currentCommand.arguments[1] ~= "" then newVar = input.arguments[1] end
	if rl.currentCommand.arguments[2] ~= "" then substitution = table.concat(input.arguments," ",2) end

	if newVar then
		rl.variables.user[newVar] = substitution
		saveTableToFile(rl.variables.user,rl.userSettingsPath.."\\variables.txt")
	end
end

rl.registeredUtils.var = {
	onEnter = registerVariable,
	description = "Register, display and delete variables",
	entranceFunction = function () rl.text.tipLine = "(variable) [value] ; if there is no value, variable will be erased" ; rl.config.subvariables = false end,
	switches = {l = false,n = false},
	passiveFunction = function() rl.config.subvariables = false ; if rl.currentCommand.switches and rl.currentCommand.switches.n then rl.config.subvariables = true end end, -- stops /execnow flag from triggering
	exitFunction = function () rl.config.subvariables = true end,
}


local function registerConfig(input)
	if not rl.currentCommand.arguments then return end

	if input.switches.l then
		list("Configurations",rl.config)
	end

	local configName,configVal
	if cs.strHasValue(rl.currentCommand.arguments[1]) and strHasValue(rl.currentCommand.arguments[2]) then
		configName = rl.currentCommand.arguments[1]
		configVal = rl.currentCommand.arguments[2]
		rl.config[configName] = configVal
		saveTableToFile(rl.config,rl.userSettingsPath.."\\config.txt")
	end
end

rl.registeredUtils.config = {
	onEnter = registerConfig,
	description = "Display and Modify config settings",
	entranceFunction = function () rl.text.tipLine = "/l to list current values" end,
	switches = {l = false},
}

-- local function compileDependencies()
-- 	local all = "-- Script compiled from Realauncher.\n--Be warned: It's a mess down here\n\n"
	
-- 	all = all .. "rl = {variables = {},history = {},aliases = {},helpFiles = {}}\nrl.compiled = true\n"
-- 	all = all .. cs.tableToString("rl.config",rl.config) .. "\n"
-- 	-- all = all .. cs.tableToString("rl.variables.user",rl.variables.user) .. "\n"

-- 	local filesToCompile = {"CS_RealauncherCore","CS_FunctionLibrary"}

-- 	for library in rl.config.libraries:gmatch("([^;]+)") do
-- 		table.insert(filesToCompile,library)
-- 	end

-- 	for mod in rl.config.modules:gmatch("([^;]+)") do
-- 		table.insert(filesToCompile,mod)
-- 	end

-- 	for i,file in ipairs(filesToCompile) do
-- 		local f = io.open(rl.scriptPath..file..".lua","r")
-- 		all = all.."do\n"..f:read("a").."\nend\n"
-- 		f:close()
-- 	end

-- 	return all
-- end

local function writeSubscriptFile(name,preloadedText,quiet,compile)
	local linker = [[
-- @noindex
local function get_script_path()
	local info = debug.getinfo(1,'S');
	local script_path = info.source:match("^@?(.*[\\/])[^\\/]-$")
	return script_path
end 

local function loadRealauncher()
	local scriptPath = get_script_path()
	local realauncherRoot = scriptPath:match("^@?(.*[\\/])Subscripts[\\/]$")

	package.path = package.path .. ";" .. realauncherRoot .. "?.lua"

	require("CS_ReaLauncher")
end
]]

	-- local dependencies = compileDependencies()

	local subscriptLauncher = [[
executeNowFlag = ]]..tostring((quiet or false))..[[

preloadedText = "]]..preloadedText.."\"\n"

	local subscriptContent,suffix
	-- if compile then 
	-- 	subscriptContent = subscriptLauncher..dependencies
	-- 	suffix = "StandaloneRealauncher" 
	-- else 
		subscriptContent = linker..subscriptLauncher.."\nloadRealauncher()"
		suffix = "RealauncherSubscript"
	-- end

	local filePath = rl.scriptPath..[[Subscripts\]]..name..[[_]]..suffix..[[.lua]]

	local subscriptFile = io.open(filePath,"w")

	subscriptFile:write(subscriptContent)

	subscriptFile:close()
end

local function createSubscript(input)
	if not rl.currentCommand.arguments then return end

	if rl.currentCommand.arguments[1] ~= "" then name = rl.currentCommand.arguments[1] end
	if rl.currentCommand.arguments[2] ~= "" then preloadedText = table.concat(rl.currentCommand.arguments," ",2) end
	preloadedText = preloadedText:gsub("\\;","\\\";\\\"")

	if name and preloadedText then
		writeSubscriptFile(name,preloadedText,input.switches.q)
	end
end

rl.registeredUtils.subscript = {
	onEnter = createSubscript,
	description = "Create ReaLauncher subscript",
	switches = {
		q = false,
		},
	passiveFunction = function() executeNowFlag = false end, -- stops /execnow flag from triggering
	entranceFunction = function() rl.config.subvariables = false end,
	exitFunction = function() rl.config.subvariables = true end,
}

local function cmdCalculate()
	if rl.currentCommand.fullArgument then
		local result = evaluateMathExp(rl.currentCommand.fullArgument)		
		if type(result) == "number" then rl.text.tipLine = result else rl.text.tipLine = "The Calculation is incorrect" end
	end
end

rl.registeredUtils.math = {passiveFunction = cmdCalculate,description = "Calculator"}

local function repCommand(inputTable)
	if inputTable.arguments[1] and type(tonumber(inputTable.arguments[1])) == "number" then
		for i=1,inputTable.arguments[1]-1 do
			table.insert(rl.text.commands,inputTable.cmdIndex+1,rl.text.commands[inputTable.cmdIndex+1])
		end
	else
		reaper.ShowMessageBox("The utility \"repeat\" accepts one number as an argument","Realauncher Error",0)
	end
end

rl.registeredUtils.rep = {onEnter = repCommand, description = "Repeat next command X times"}

rl.registeredUtils.help = {onEnter = function() viewMarkdown(rl.helpFiles["default"],true) end, description = "Open Realauncher help"}

rl.registeredUtils.testInputs = {onEnter = function() cs.msg(rl.currentCommand) end, description = "Prints parsed arguments to console"}

rl.registeredUtils.keyboardCodeViewer = {
	passiveFunction = 
		function() 
			if rl.text.currChar ~= 0 then 
				rl.text.tipLine = rl.text.currChar
			end 
		end,
	description = "Display typed character codes",	 
	}

rl.registeredUtils.changeCountDisplay = {
		passiveFunction = function() rl.text.tipLine = reaper.GetProjectStateChangeCount(0) end,
		description = "Display current Change Count",
}