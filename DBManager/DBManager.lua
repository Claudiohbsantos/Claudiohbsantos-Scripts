--[[
@noindex
--]]

function get_script_path()
        local info = debug.getinfo(1,'S');
        local script_path = info.source:match[[^@?(.*[\/])[^\/]-$]]
        return script_path
end 

local function setEnv()
    package.path = package.path .. ";" .. get_script_path() .. "lua_modules\\?.lua"
    package.path = package.path .. ";" .. get_script_path() .. "reascript_modules\\?.lua"
    package.path = package.path .. ";" .. get_script_path() .. "?.lua"
end

function loadLuaModule(...)
	return require(...)
    -- local status, lib = pcall(require, ...)
    -- if(status) then return lib end
    -- --Library failed to load, so perhaps return `nil` or something?
    -- reaper.ShowMessageBox("Missing ".. ...,"ERROR",0)
    -- return nil
end

local function checkDependencies()
    local reaperVersion = tonumber(reaper.GetAppVersion():match("[%d%.]+"))
    if reaperVersion < 5.978 then 
        reaper.MB("This scripts needs reaper of version 5.978 or newer. Please update reaper","Error",0)
        return true
    end

    if not reaper.APIExists("JS_ReaScriptAPI_Version") then 
        reaper.MB("This script depends on the JS Reascript API extension. Please install it using Reapack","Error",0)
        if reaper.APIExists("ReaPack_BrowsePackages") then
            reaper.ReaPack_BrowsePackages("js_ReaScriptAPI: API functions for ReaScripts")
        end
        return true
    end

    local jsApiVersion = tonumber(reaper.JS_ReaScriptAPI_Version())
    if jsApiVersion < 0.987 then 
        reaper.MB("This scripts needs the JS Reascript API extension of version 0.987 or newer. Please update it using reapack","Error",0)
        if reaper.APIExists("ReaPack_BrowsePackages") then
            reaper.ReaPack_BrowsePackages("js_ReaScriptAPI: API functions for ReaScripts")
        end
        return true
    end

    if not reaper.HasExtState("Lokasenna_GUI", "lib_path_v2") then
        reaper.MB("This script depends on the Lokasenna GUI Library, which seems to be missing or unconfigured. Please install it using Reapack and run the \"Set Lokasenna_GUI v2 library path.lua\" script","Error",0)
        if reaper.APIExists("ReaPack_BrowsePackages") then
            reaper.ReaPack_BrowsePackages("Lokasenna GUI library v2 for Lua")
        end
        return true
    end
end

----------
local function storeINIFileInTable()
    local reaperINIpath = reaper.get_ini_file()
    local ini = {}
    local currSection
    for line in io.lines(reaperINIpath) do 
        local section = line:match("^%[(.+)%]$")
        if section then 
            ini[section] = {} 
            currSection = ini[section]
        else
            local key,value = line:match("([^=]+)=(.+)")
            if key and value then currSection[key] = value end
        end

    end
    return ini
end

function writeINIFileFromTable(iniTable)
    local reaperINIpath = reaper.get_ini_file()

    file = io.open(reaperINIpath,"w")
    for section,keys in pairs(iniTable) do
        file:write("["..section.."]\n")
        for key,val in pairs(keys) do
            file:write(key.."="..val.."\n")        
        end
    end

    file:close()
end

function readJsonFile(path)
    local f = assert(io.open(path, "rb"))
    local content = f:read("*all")
    f:close()
    return json.parse(content)
end

function writeJsonFile(content,path)
    local f = assert(io.open(path, "w"))
    f:write(content)
    f:close()
end

local function getUser()
    local user
    if reaper.HasExtState("DBManager","user") then
        user = reaper.GetExtState("DBManager","user")
    end
    for i, allowedUser in ipairs(dbm.config.users) do
        if allowedUser == user then return user end
    end
end

local function extractDBsFromINI(inisection)
	-- removes extracted entries from ini table
    local ref,names = {},{}
    for key,value in pairs(inisection) do
        local isName,n = key:match("^Shortcut(T?)(%d+)")
        if n and isName ~= "" then names[n] = value ; inisection[key] = nil end
        if n and isName == "" then ref[n] = value ; inisection[key] = nil end
    end

    return ref,names
end

local function fillMissingNamesWithRefs(names,refs)
    for i,val in pairs(refs) do
        if not names[i] then names[i] = val end
    end
end

function selectAFolder(initialFolder)
    local initialFolder = initialFolder or ""
    local retval,path = reaper.JS_Dialog_BrowseForFolder("Pick a Folder", initialFolder)
    if retval == 1 then return path end
    if retval == -1 then reaper.ShowMessageBox("There was a problem with the Folder Picker. Are you using the latest version of Reaper?","Oops...",0) end
end

function selectFiles(multichoice, exts,initialFolder)
    local initialFolder = initialFolder or ""
    local retval,path = reaper.JS_Dialog_BrowseForOpenFiles("Select a File", initialFolder, "", exts, multichoice)

    if multichoice then
        paths = {}
        for sub in string.gmatch(path,"[^\0]+") do
            table.insert(paths,sub)
        end

        if #paths > 1 then 
            for i=2,#paths do
                paths[i] = paths[1]..paths[i]
            end
            table.remove(paths,1)
        end
        path = paths
    end

    if retval == 1 then return path end
    if retval == -1 then reaper.ShowMessageBox("There was a problem with the File Picker. Are you using the latest version of Reaper?","Oops...",0) end
end

function getLocalDBPath()
    local iniPath = reaper.get_ini_file()
    local resourcesDir = string.match(iniPath,"(.+)".."\\".."REAPER.ini$") or string.match(iniPath,"(.+)".."\\".."reaper.ini$")
    local localDBPath = resourcesDir.."\\".."MediaDB"
    return localDBPath
end

function getAbsPath(ref)
	if string.find(ref,"[\\/]") then return ref end -- is absolute already
	return getLocalDBPath().."\\"..ref
end

function getRelPath(ref)
	local relPath = string.match(ref,getLocalDBPath().."[/\\](.+)")
	if relPath then return relPath else return ref end
end

local function getUserDBListIndexedFrom1(inisection)
	local refs,names = extractDBsFromINI(inisection)
	fillMissingNamesWithRefs(names,refs)

	local dbs = {}
	for i,name in pairs(names) do
		dbs[i] = {name = names[i],ref = getAbsPath(refs[i])}
	end

	dbs = table.shift(dbs,1)

	return dbs
end

local function getConfig()
    dbm.configPath = get_script_path().."config.json"
    local retval,config = pcall(readJsonFile,dbm.configPath)

    if not retval then
        dbm.config = {}
        reaper.MB("config.json couldn't be found in the script path. Let's create a new config file","Setup",0)
        reaper.MB("Please pick a Sound Library Path","Setup",0)
        dbm.act.chooseNewLibraryPath()
        reaper.MB("Please pick a Database Folder Path","Setup",0) 
        dbm.act.chooseNewDatabasesPath()
        reaper.MB("Please pick a Master Database. This will receive all sfx added to any other db","Setup",0)
        dbm.act.chooseNewMasterDBPath()
        dbm.act.defineUsers()
        config = readJsonFile(dbm.configPath)
    end
    return config
end

----------------
local reaper = reaper

local shouldAbort = checkDependencies()

if not shouldAbort then 
    setEnv()
    loadLuaModule("DBM_helper")
    json = loadLuaModule("json")

    dbm = {}
    dbm.ini = storeINIFileInTable()
    dbm.userDbs = getUserDBListIndexedFrom1(dbm.ini.reaper_explorer)
    dbm.undoHistory = {}

    dbm.act = loadLuaModule("DBM_actions")
    dbm.config = getConfig()
    dbm.user = getUser()

    dbm.loopFunctions = {}
    loadLuaModule("DBM_GUI")
end
-- TODO: error loading config
-- TODO: refs and name linking