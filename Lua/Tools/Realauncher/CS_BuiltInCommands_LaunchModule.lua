--[[
@noindex
]]--


function ismacos()
	return reaper.GetOS():find('OSX') ~= nil
end

function iswindows()
	return reaper.GetOS():find('Win') ~= nil
end

function copyToClipboard(text)
	local tool

	if ismacos() then
	tool = 'pbcopy'
	elseif iswindows() then
	tool = 'clip'
	end

	local proc = assert(io.popen(tool, 'w'))
	proc:write(text)
	proc:close()
end

function pasteFromClipboard()
	local tool

	if ismacos() then
	tool = 'pbpaste'
	elseif iswindows() then
	tool = 'powershell -windowstyle hidden -Command Get-Clipboard'
	end

	local proc = assert(io.popen(tool, 'r'))
	local text = proc:read("*all")
	proc:close()

	return text
end

rl.registeredCommands.default = {
	charFunction = {
					[kbInput.upArrow] = function() rl.text.raw = recallHistory(-1) ; sendCursorToEndOfText() end,
					[kbInput.downArrow] = function() rl.text.raw = recallHistory(1) ; sendCursorToEndOfText() end, 
					[kbInput.tab] = function () performAutocomplete(rl.currentAutocomplete) end,
					[kbInput.copy] = function () copyToClipboard(rl.text.raw) end,
					[kbInput.paste] = function () rl.text.raw = rl.text.raw..pasteFromClipboard(); sendCursorToEndOfText() end,
					},				
	description = "Click the \"?\" button on the right for help. ReaLauncher by Claudio Santos.",
}

rl.registeredCommands.quit = {onEnter = function() reaper.Main_OnCommand(40004,0) end, description = "Quit Reaper"}

local function enumerateAvailableCommands()
	for command in pairs(rl.registeredCommands) do
		if command ~= "default" then
			reaper.ShowConsoleMsg(command.." - "..(rl.registeredCommands[command].description or "").."\n")
		end	
	end
end

rl.registeredCommands.enumcmd = {onEnter = enumerateAvailableCommands, description = "List all registered Commands and their descriptions"}

function redoCommand()
	rl.text.raw = rl.history[#rl.history]
	sendCursorToEndOfText()
	parseInput(rl.text)
	changeEnvironment(rl.text.command)
	passiveFunction()
	onEnterFunction()
end

rl.registeredCommands["!!"] = {onEnter = redoCommand,description = "Redo last command", passiveFunction = function() rl.text.tipLine = [[Redo "]]..rl.history[#rl.history]..[["]] end}

local function list(table)
	for key,value in pairs(table) do
		reaper.ShowConsoleMsg(key.."  =  "..tostring(value).."\n")
	end
end

local function saveTableToFile(aliasesTable,aliasesFilePath)
	local aliasesFile = io.open(aliasesFilePath,"w")
	for alias,sub in pairs(aliasesTable) do
		if sub ~= "" then
			aliasesFile:write(alias.."="..sub.."\n")
		end
	end
	aliasesFile:close()
end

local function registerAlias()
	if not rl.text.fullArgument then return end
	if switches.l then list(rl.aliases) return end

	local newAlias,substitution = rl.text.fullArgument:match("(%w+)=*([^\r\n]*)")

	if newAlias then
		rl.aliases[newAlias] = substitution
		saveTableToFile(rl.aliases,rl.userSettingsPath.."\\aliases.txt")
	end
end

rl.registeredCommands.alias = {
	onEnter = registerAlias,
	description = "Register, display and delete aliases",
	entranceFunction = function () rl.text.tipLine = "(ALIAS)=[NEW SUBSTITUTION] | if there is no substitution, alias will be erased" end,
	switches = {l = false},
	}

local function registerVariable()
	if not rl.text.fullArgument then return end
	if switches.l then cs.msg("USER VARIABLES:") ; list(rl.variables.user) ; cs.msg("NATIVE VARIABLES:") ; list(rl.variables.nativeDescriptions) return end

	local newVar,substitution = rl.text.fullArgument:match("(%w+)=*([^\r\n]*)")

	if newVar then
		rl.variables.user[newVar] = substitution
		saveTableToFile(rl.variables.user,rl.userSettingsPath.."\\variables.txt")
	end
end

rl.registeredCommands.var = {
	onEnter = registerVariable,
	description = "Register, display and delete variables",
	switches = {l = false},
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

rl.registeredCommands.math = {passiveFunction = cmdCalculate,description = "Command Line Calculator"}