--[[
@noindex
]]--

local function saveTableToFile(tableToSave,filePath)
	local tableFile = io.open(filePath,"w")
	for alias,sub in pairs(tableToSave) do
		if sub ~= "" then
			tableFile:write(alias.."="..sub.."\n")
		end
	end
	tableFile:close()
end

function ismacos()
	return reaper.GetOS():find('OSX') ~= nil
end

function iswindows()
	return reaper.GetOS():find('Win') ~= nil
end

function copyToClipboard(text)
	reaper.CF_SetClipboard(text)
end

function pasteFromClipboard()
	local fastString = reaper.SNM_CreateFastString("")
	local text = reaper.CF_GetClipboardBig(fastString)
	reaper.SNM_DeleteFastString(fastString)
	return text
end

universalSwitches = {execnow = false,help = false}

rl.registeredUtils.default = {
	charFunction = {
					[kbInput.upArrow] = function() rl.text.raw = recallHistory(-1) ; sendCursorToEndOfText() end,
					[kbInput.downArrow] = function() rl.text.raw = recallHistory(1) ; sendCursorToEndOfText() end, 
					[kbInput.tab] = function () performAutocomplete(rl.currentAutocomplete) end,
					[kbInput.copy] = function () copyToClipboard(rl.text.raw) end,
					[kbInput.paste] = function () rl.text.raw = rl.text.raw..pasteFromClipboard(); sendCursorToEndOfText() end,
					},				
	description = "Click the \"?\" button on the right for help. ReaLauncher by Claudio Santos.",
}

rl.registeredUtils.quit = {onEnter = function() reaper.Main_OnCommand(40004,0) end, description = "Quit Reaper"}

local function scanModules()
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

rl.registeredUtils.scanmodules = {onEnter = scanModules,description = "Scan Realauncher folder for new/deleted modules"}

local function enumerateAvailableUtils()
	for util in pairs(rl.registeredUtils) do
		if util ~= "default" then
			reaper.ShowConsoleMsg(util.." - "..(rl.registeredUtils[util].description or "").."\n")
		end	
	end
end

rl.registeredUtils.enumcmd = {onEnter = enumerateAvailableUtils, description = "List all registered Utils and their descriptions"}

function redoUtil()
	rl.text.raw = rl.history[#rl.history]
	sendCursorToEndOfText()
	parseInput(rl.text)
	changeEnvironment(rl.text.util)
	passiveFunction()
	onEnterFunction()
end

rl.registeredUtils["!!"] = {onEnter = redoUtil,description = "Redo last util", passiveFunction = function() rl.text.tipLine = [[Redo "]]..rl.history[#rl.history]..[["]] end}

local function list(table)
	for key,value in pairs(table) do
		reaper.ShowConsoleMsg(key.."  =  "..tostring(value).."\n")
	end
end

local function registerAlias()
	if not rl.text.fullArgument then return end
	if switches.l then list(rl.aliases) return end

	local newAlias,substitution = rl.text.fullArgument:match("([^=%s]+)=([^\r\n]*)")

	if newAlias then
		rl.aliases[newAlias] = substitution
		saveTableToFile(rl.aliases,rl.userSettingsPath.."\\aliases.txt")
	end
end

rl.registeredUtils.alias = {
	onEnter = registerAlias,
	description = "Register, display and delete aliases",
	entranceFunction = function () rl.text.tipLine = "(alias)=[new substitution] | if there is no substitution, alias will be erased" end,
	switches = {l = false},
	passiveFunction = function() executeNowFlag = false end, -- stops /execnow flag from triggering
	}

local function registerVariable()
	if not rl.text.fullArgument then return end
	if switches.l then cs.msg("USER VARIABLES:") ; list(rl.variables.user) ; cs.msg("NATIVE VARIABLES:") ; list(rl.variables.nativeDescriptions) return end

	local newVar,substitution = rl.text.fullArgument:match("([^=%s]+)=([^\r\n]*)")

	if newVar then
		rl.variables.user[newVar] = substitution
		saveTableToFile(rl.variables.user,rl.userSettingsPath.."\\variables.txt")
	end
end

rl.registeredUtils.var = {
	onEnter = registerVariable,
	description = "Register, display and delete variables",
	entranceFunction = function () rl.text.tipLine = "(variable)=[value] | if there is no value, variable will be erased" end,
	switches = {l = false},
	passiveFunction = function() executeNowFlag = false end, -- stops /execnow flag from triggering
}

local function writeSubscriptFile(name,preloadedText)
	local filePath = rl.scriptPath..[[Subscripts\]]..name..[[_RealauncherSubscript.lua]]

	local subscriptFile = io.open(filePath,"w")

	local subscriptContent = [[
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

executeNowFlag = ]]..tostring((switches.q or false))..[[

preloadedText = "]]..preloadedText..[["
loadRealauncher()
]]

	subscriptFile:write(subscriptContent)

	subscriptFile:close()
end

local function createSubscript()
	if not rl.text.fullArgument then return end

	local name,preloadedText = rl.text.fullArgument:match("([^=%s]+)=([^\r\n]*)")

	if name and preloadedText then
		writeSubscriptFile(name,preloadedText)
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

function cmdCalculate()
	if rl.text.fullArgument then

		local calculation = load(declareMathFunctions().." return "..rl.text.fullArgument)
		if calculation then
			local sucessful,result = pcall(calculation)
			if sucessful then rl.text.tipLine = result else rl.text.tipLine = "The Calculation is incorrect" end
		end
	end
end

rl.registeredUtils.math = {passiveFunction = cmdCalculate,description = "Util Line Calculator"}