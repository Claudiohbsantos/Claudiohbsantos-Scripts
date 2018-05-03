--[[
@noindex
]]--

local function getActionList()
	local actListFile
	if reaper.file_exists(rl.userSettingsPath.."\\ActionList.txt") then
		actListFile = rl.userSettingsPath.."\\ActionList.txt"
		local f = io.open(actListFile,"r")
		local actList = f:read("a")
		f:close()
		return actList
	else
		local fileNotFound =[[
Realauncher couldn't find an action list file. 
Please use the SWS action "SWS/S&M: Dump action list (custom actions only)" to generate a list and save it to your Realauncher user directory. 
For detailed instructions,open the act utility help.]]
		reaper.ShowMessageBox(fileNotFound,"Realauncher Error",0)
		error("Realauncher Couldn't find file. Stopping execution of command")
	end
end

local function parseActionList(list)
	local actTable = {}
	for id,name in list:gmatch("[^\t\n]+\t([^\t\n]+)\t([^\t\n]+)\n") do
		actTable[#actTable+1] = {id = id,name = name}
	end
	return actTable
end

local function execActionByID(id)
	if cs.strHasValue(id) then
		if type(id) == "string" then
			reaper.Main_OnCommandEx(reaper.NamedCommandLookup(id),0,0)
		else
			reaper.Main_OnCommandEx(id,0,0)
		end
	end
end

-- local function searchActionByName()
-- 	local dumpedList = getActionList()
-- 	local actionList = parseActionList(dumpedList)

-- 	if cs.strHasValue(input.arguments[1]) then
-- 		local actionMatches = cs.searchMatrixAndReturnMatchesTable(actionList,"name",input.arguments)
-- 		actionMatches = cs.mergeSortMatrixDescending(actionMatches,"percentageOfProximityToArguments")
-- 	end
-- end

local function execAction(input)
	if not cs.strHasValue(input.fullArgument) then return end

	if input.switches.i then
		execActionByID(input.arguments[1])		
		return
	end
end

rl.registeredUtils.act = {
	onEnter = execAction,
	description = "Launch Reaper Action",
	switches = {i = false},
}