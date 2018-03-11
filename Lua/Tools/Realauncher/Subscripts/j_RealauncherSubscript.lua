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
executeNowFlag = true
preloadedText = "go -[$n1*$frame]"

loadRealauncher()