--[[
@noindex
--]]

function get_script_path()
        local info = debug.getinfo(1,'S');
        local script_path = info.source:match[[^@?(.*[\/])[^\/]-$]]
        return script_path
end

local function getPlatform()
    local osp = {}
    local currOS = reaper.GetOS()
	if currOS == "OSX32" or currOS == "OSX64"  then
        osp.os = "osx"
        osp.sep = "/"
        return osp
    elseif currOS == "Win32" or currOS == "Win64" then
        osp.os = "win"
        osp.sep = "\\"
        return osp
    end
    -- Linux
    return false
end

local function setEnv(env)
    package.path = package.path .. ";" .. get_script_path() .. "lua_modules"..env.sep.."?.lua"
    package.path = package.path .. ";" .. get_script_path() .. "reascript_modules"..env.sep.."?.lua"
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

    local GUI_path = reaper.GetExtState("Lokasenna_GUI", "lib_path_v2")
    if not GUI_path or GUI_path == "" or not reaper.file_exists(GUI_path .. "Core.lua") then
        reaper.MB("This script depends on the Lokasenna GUI Library, which seems to be missing or misconfigured. Please install it using Reapack and run the \"Set Lokasenna_GUI v2 library path.lua\" script","Error",0)
        if reaper.APIExists("ReaPack_BrowsePackages") then
            reaper.ReaPack_BrowsePackages("Lokasenna GUI library v2 for Lua")
        end
        return true
    end
    
    local GUI_ReaPackage = reaper.ReaPack_GetOwner(GUI_path .. "Core.lua")
    _,_,_,_,_,_,GUI_ver = reaper.ReaPack_GetEntryInfo(GUI_ReaPackage)
    local GUI_major,GUI_minor,GUI_patch = GUI_ver:match("(%d+)%.(%d+)%.(%d+)")
    if tonumber(GUI_major) ~= 2 or tonumber(GUI_minor) < 16 or tonumber(GUI_patch) < 6 then
        reaper.MB("This script was tested with Lokasenna GUI Library version 2.16.6, and you seem to be running an older version of the library. It is recommended that you update to the latest version","Error",0)
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
    local resourcesDir = string.match(iniPath,"(.+)"..osp.sep.."REAPER.ini$") or string.match(iniPath,"(.+)"..osp.sep.."reaper.ini$")
    local localDBPath = resourcesDir..osp.sep.."MediaDB"
    return localDBPath
end

function getAbsPath(ref)
	if string.find(ref,"[\\/]") then return ref end -- is absolute already
	return getLocalDBPath()..osp.sep..ref
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


function importConfigFile()
    local configFile = selectFiles(false, "config\0*.json\0\0",get_script_path())
    if not configFile then return end

    local retval,config = pcall(readJsonFile,configFile)
    if not retval then 
        reaper.MB("Failed to read selected config file","ERROR",0) 
        return 
    end
    
    writeJsonFile(json.stringify(config),dbm.configPath)
    if not reaper.file_exists(dbm.configPath) then 
        reaper.MB("Failed to write imported config file","ERROR",0)
        return
    end

    dbm.config = config

    if dbm.ui then dbm.ui.menubar[3].options[2][1] = "Library: ".. dbm.config.library end
    if dbm.ui then dbm.ui.menubar[3].options[3][1] = "Databases: ".. dbm.config.databases end
    if dbm.ui then dbm.ui.menubar[3].options[4][1] = "MasterDB: ".. dbm.config.masterDB end

    return config
end

local function getConfig()
    dbm.configPath = get_script_path().."config.json"
    local retval,config = pcall(readJsonFile,dbm.configPath)

    if not retval then
        local wantsToImport = reaper.MB("config.json couldn't be found in the script path.\nWould you like to import a config file?","DBManager",4)
        if wantsToImport == 6 then 
            config = importConfigFile() 
        else
            dbm.config = {}
            reaper.MB("Let's create a new config file","Setup",0)
            reaper.MB("Please pick a Sound Library Path","Setup",0)
            dbm.act.chooseNewLibraryPath()
            reaper.MB("Please pick a Database Folder Path","Setup",0) 
            dbm.act.chooseNewDatabasesPath()
            reaper.MB("Please pick a Master Database. This will receive all sfx added to any other db","Setup",0)
            dbm.act.chooseNewMasterDBPath()
            dbm.act.defineUsers()
            config = readJsonFile(dbm.configPath)
        end
    end

    return config
end

----------------
local reaper = reaper

osp = getPlatform()
if osp then 
    setEnv(osp)
    loadLuaModule("DBM_helper")

    local shouldAbort = checkDependencies()

    if not shouldAbort then 
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
else
    reaper.MB("DBManager doesn't work on Linux, sorry.","ERROR",0)
end