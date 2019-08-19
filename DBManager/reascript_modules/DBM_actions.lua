--[[
@noindex
--]]

local act = {}
local clipboard = {}
local contentClipboard = {}

function createUndoPoint(floating)
    local maxUndo = 50

    if floating then
        if dbm.undoHistory.wasFloating then      
            return
        else 
            dbm.undoHistory.wasFloating = true
        end
    else
        if dbm.undoHistory.wasFloating then    
            dbm.undoHistory.wasFloating = false
        end
    end

    if dbm.undoHistory.current and dbm.undoHistory.current ~= 1 then
        for i=1, dbm.undoHistory.current -1 do
            table.remove(dbm.undoHistory,1)
        end
    end

    for i = maxUndo - 1, 1, -1 do
        if dbm.undoHistory[i] then
            dbm.undoHistory[i+1] = dbm.undoHistory[i] 
        end
    end
    dbm.undoHistory[1] = {}
    for i,entry in ipairs(dbm.userDbs) do
        dbm.undoHistory[1][i] = {name = entry.name, ref = entry.ref}
    end

    dbm.undoHistory.current = 1
    if #dbm.undoHistory > maxUndo then table.remove(dbm.undoHistory) end
end

function act.undo()
    createUndoPoint(true)
    if not dbm.undoHistory.current then dbm.undoHistory.current = 1 end
    local previous = dbm.undoHistory.current+1
    if previous > #dbm.undoHistory  then previous = #dbm.undoHistory  end

    if dbm.undoHistory[previous] then 
        table.clear(dbm.userDbs)
        for i,entry in ipairs(dbm.undoHistory[previous]) do
            dbm.userDbs[i] = {name = entry.name, ref = entry.ref}
        end
        dbm.undoHistory.current = previous
    end
end

function act.redo()
    createUndoPoint(true)
    if not dbm.undoHistory.current then dbm.undoHistory.current = 1 end
    local next = dbm.undoHistory.current-1
    if next < 1 then next = 1 end
    
    if dbm.undoHistory[next] then
        table.clear(dbm.userDbs)
        for i,entry in ipairs(dbm.undoHistory[next]) do
            dbm.userDbs[i] = {name = entry.name, ref = entry.ref}
        end
        dbm.undoHistory.current = next
    end
end

function scrollToShowEntry(i)
    local top = GUI.elms.userlist.wnd_y
    local bottom = GUI.elms.userlist.wnd_y + GUI.elms.userlist.wnd_h - 1

    if i < top then GUI.elms.userlist.wnd_y = i end
    if i > bottom then GUI.elms.userlist.wnd_y = i-GUI.elms.userlist.wnd_h+1 end
end

function dbaExec(command)
    local executable = [["]]..get_script_path()..[[dbassistant"]]

    local cmd = [[/C "]]..executable..[[ ]]..command..[[ & pause"]]
    local output = reaper.BR_Win32_ShellExecute("open","cmd.exe", cmd, get_script_path(), 1)
    return output
end

function act.showDBAVersion()
    dbaExec("-V")
end

function getFirstSelectedIndex()
    local sel = GUI.Val("userlist")
    local first
    for i in ipairs(dbm.userDbs) do
        if sel[i] then first = i ; break end
    end
    return first
end

local function getOrderedSelectionTable()
    local sel = GUI.Val("userlist")
    for i in ipairs(dbm.userDbs) do
        if not sel[i] then sel[i] = false end
    end
    return sel
end

local function countSelected()
    local sel = GUI.Val("userlist")
    local count = 0
    for i in ipairs(dbm.userDbs) do
        if sel[i] then count = count + 1 end
    end
    return count
end

local function createDBFile(path)
    local dbFile = io.open(path,"w")
    dbFile:write("")
    dbFile:close()
end

local function insertEntry(name,ref,i)
    table.insert(dbm.userDbs,i,{name = name, ref = ref})
end

local function measureIndentationLvl(i)
    local lvl = 0
    for tab in string.gmatch(dbm.userDbs[i].name,"%-%-%-%-%-%-") do
        lvl = lvl + 1
    end
    return lvl
end

local function getParents(i)
    local lvl = measureIndentationLvl(i)
    local parents = {}
    for n = i - 1, 1, -1 do
        if lvl < 0 then break end
        if dbm.userDbs[i].name == "=========================================" then break end
        if measureIndentationLvl(n) == lvl - 1 then table.insert(parents,n) ; lvl = lvl -1 end
    end
    return parents
end

-- TODO check for existing db
local function newDB(name,path,t)
    if name and name:match("[^%s]") then
        createDBFile(path)
        insertEntry(name,path,t)
        GUI.Val("userlist",{[t] = true})
    end
end

---

function act.moveUp()
    createUndoPoint()
    local sel = GUI.Val("userlist")
    local newSel = {}
    local isTop = true
    for i in ipairs(dbm.userDbs) do
        if sel[i] then
            if i-1 > 0 and i-1 <= #dbm.userDbs then
                local temp = dbm.userDbs[i-1]
                dbm.userDbs[i-1] = dbm.userDbs[i]
                dbm.userDbs[i] = temp

                newSel[i-1] = true

                if isTop then scrollToShowEntry(i-1) ; isTop = false end
            else
                newSel[i] = true
            end
        end
    end
    GUI.Val("userlist",newSel)
end

function act.moveDown()
    createUndoPoint()
    local sel = GUI.Val("userlist")
    local newSel = {}
    local isBottom = true
    for i=#dbm.userDbs,1,-1 do
        if sel[i] then
            if i+1 > 0 and i+1 <= #dbm.userDbs then

                local temp = dbm.userDbs[i+1]
                dbm.userDbs[i+1] = dbm.userDbs[i]
                dbm.userDbs[i] = temp

                newSel[i+1] = true
                if isBottom then scrollToShowEntry(i+1) ; isBottom = false end
            else
                newSel[i] = true
            end
        end
    end
    GUI.Val("userlist",newSel)
end

function act.del()
    createUndoPoint()
    local sel = getOrderedSelectionTable()

    local i = 1
    local last = #dbm.userDbs
    while i <= last do
        if sel[i] then
            table.remove(dbm.userDbs,i)
            table.remove(sel,i)
            last = last -1
            i = i-1
        end
        i = i+1
    end
    GUI.Val("userlist",{})
end

function act.createDB()
    local function createDBFile(fileName,dir) 
        if not fileName or not dir then return end

        -- FIXME make mac conditional
        local path = dir .. "\\" .. fileName
        if not string.find(path,"%.ReaperFileList$") then path = path..".ReaperFileList" end
        local name = string.match(path,"[\\/]([^\\/]+)%.ReaperFileList")

        local t = getFirstSelectedIndex() + 1
        if not t then t = #dbm.userDbs + 1 end

        newDB(name,path,t)
    end

    createUndoPoint()

    newDBWindow.open('','Create new DB',createDBFile)
end

function act.sep()
    createUndoPoint()
    local sel = getOrderedSelectionTable()
    local sep = "=========================================" 
    local sepref = "separator.ReaperFileList"

    local i = 1
    local last = #dbm.userDbs
    while i <= last do
        if sel[i] then
            insertEntry(sep,sepref,i+1)
            table.insert(sel,i+1,false)
            last = last + 1
            i = i+1
        end
        i = i+1
    end

    GUI.Val("userlist",sel)
end

function act.save()
    createDBFile(getLocalDBPath()..[[\separator.ReaperFileList]])
    local saveCopy = table.shift(dbm.userDbs,-1)
    for n,entry in pairs(saveCopy) do
        dbm.ini.reaper_explorer["ShortcutT"..n] = entry.name
        dbm.ini.reaper_explorer["Shortcut"..n] = getRelPath(entry.ref)
    end
    dbm.ini.reaper_explorer['NbShortcuts'] = #saveCopy + 1
    writeINIFileFromTable(dbm.ini)
    reaper.ShowMessageBox("Reaper.ini saved. Please restart reaper to see changes","Saved",0)
end

function act.cut()
    createUndoPoint()
    clipboard = {}
    local sel = getOrderedSelectionTable()
    local i = 1
    local last = #dbm.userDbs
    while i <= last do
        if sel[i] then
            table.insert(clipboard,table.remove(dbm.userDbs,i))
            table.remove(sel,i)
            last = last -1
            i = i-1
        end
        i = i+1
    end
    GUI.Val("userlist",{})
end

function act.paste()
    createUndoPoint()
    local t = getFirstSelectedIndex() + 1
    if not t then reaper.ShowMessageBox("Please select a position under which to paste","ERROR",0) ; return end

    local newSel = {}
    for i,entry in ipairs(clipboard) do
        table.insert(dbm.userDbs,t,entry)
        newSel[t] = true
        t = t+1
    end

    GUI.Val("userlist",newSel)
end

function act.addIndentation()
    createUndoPoint()
    local sel = GUI.Val('userlist')
    for i,entry in ipairs(dbm.userDbs) do
        if sel[i] then
            entry.name =  "------"..entry.name
        end
    end
end

function act.removeIndentation()
    createUndoPoint()
    local sel = GUI.Val('userlist')
    for i,entry in ipairs(dbm.userDbs) do
        if sel[i] then 
            entry.name = entry.name:match("^%-%-%-%-%-%-(.+)") or entry.name 
        end
    end
end

function act.rename()
    createUndoPoint()
    local function renameDB(newName,i)
        dbm.userDbs[i].name = newName
        GUI.Val("userlist",{[i] = true})
    end

    local t = getFirstSelectedIndex()
    if not t then return end
    inputWindow.open(dbm.userDbs[t].name,"Rename DB","New Name:",renameDB,t)
end

function act.expandSelectionUp()
    local sel = GUI.Val("userlist")
    local newSel = {}
    local topI = #dbm.userDbs
    for i in pairs(sel) do
        newSel[i] = true
        if i > 1 then 
            newSel[i-1] = true 
            if i-1 < topI then topI = i-1 end
        end
    end
    scrollToShowEntry(topI)
    GUI.Val("userlist",newSel)
end

function act.expandSelectionDown()
    local sel = GUI.Val("userlist")
    local newSel = {}
    local bottomI = 1
    for i in pairs(sel) do
        newSel[i] = true
        if i < #dbm.userDbs then 
            newSel[i+1] = true 
            if i+1 > bottomI then bottomI = i+1 end
        end
    end
    scrollToShowEntry(bottomI)
    GUI.Val("userlist",newSel)
end

function act.selectSameIndentation()
    local sel = getFirstSelectedIndex()
    local lvl = measureIndentationLvl(sel)

    local newSel = {[sel] = true}
    for i = sel-1, 1, -1 do
        if measureIndentationLvl(i) == lvl and dbm.userDbs[i].name:match("[^=]") then newSel[i] = true else break end
    end
    for i = sel+1, #dbm.userDbs do
       if measureIndentationLvl(i) == lvl and dbm.userDbs[i].name:match("[^=]") then newSel[i] = true else break end 
    end
    GUI.Val('userlist',newSel)
end 

function act.selectParent()
	local sel = GUI.Val("userlist")

    local newSel = {}
    for n in ipairs(dbm.userDbs) do
        if sel[n] then
            local lvl = measureIndentationLvl(n)
            for i = n-1, 1, -1 do
                if measureIndentationLvl(i) == lvl - 1 and dbm.userDbs[i].name:match("[^=]") then newSel[i] = true break end
            end
        end
    end
    GUI.Val("userlist",newSel)
end

function act.selectAllParents()
    local sel = GUI.Val('userlist')

    local newSel = {}
    for i in ipairs(dbm.userDbs) do
        if sel[i] then
            for i,p in ipairs(getParents(i)) do
                newSel[p] = true
            end
        end
    end
    GUI.Val('userlist',newSel)
end

function act.selectChildren()
    local sel = GUI.Val("userlist")

    local newSel = {}
    for n in ipairs(dbm.userDbs) do
        if sel[n] then
            local lvl = measureIndentationLvl(n)
            for i = n+1, #dbm.userDbs do
                if measureIndentationLvl(i) >= lvl + 1 and dbm.userDbs[i].name:match("[^=]") then newSel[i] = true else break end
            end
        end
    end
    GUI.Val("userlist",newSel)
end 

function act.search()
    local st = GUI.Val("searchbox")
    if not st or not st:match("[^%s]") then return end
    local matches = {names = {}, i = {}}
    for i=1,#dbm.userDbs do
        if dbm.userDbs[i].name:lower():match(st:lower()) then table.insert(matches.names,{name = dbm.userDbs[i].name}) ; table.insert(matches.i,i) end
    end

    local function goToSearchResult(i)
        if not i then return end 
        local t = matches.i[i]
        GUI.Val("userlist",{[t] = true})
        scrollToShowEntry(t)
    end

    listPicker.open("Search results: "..#matches,false,matches.names,goToSearchResult)
end

function act.chooseNewRef(i,pickFolder)
    createUndoPoint()
    local path
    if pickFolder then
        path = selectAFolder()
    else
        path = selectFiles(false,"Reaper DB files\0*.ReaperFileList\0\0",dbm.config.databases)
    end
    if path then dbm.userDbs[i].ref = path end
end

function act.exportShortcuts()
    local path = selectFiles(false, "DBManager Json\0*.dbmjson\0\0",dbm.config.databases)
    if not path then return end
    if not path:match("%.dbmjson$") then path = path..".dbmjson" end

    local export = {}
    local sel = GUI.Val("userlist")
    for i, entry in ipairs(dbm.userDbs) do
        if sel[i] then table.insert(export,entry) end
    end

    local tempFile = io.open(path,"w")
    tempFile:write(json.stringify(export))
    tempFile:close()    
end

function act.importShortcuts(replace)
    createUndoPoint()
    local path = selectFiles(false, "DBManager Json\0*.dbmjson\0\0",dbm.config.databases)
    if not path then return end

    local imported = readJsonFile(path)

    if not imported[1].name or not imported[1].ref then 
        reaper.MB("The imported json file seems to be formatted incorrectly","Error",0)
        return
    end

    if replace then 
        table.clear(dbm.userDbs)
        for i, entry in ipairs(imported) do
            dbm.userDbs[i] = entry
        end
    else
        clipboard = imported
        act.paste()
    end

    GUI.elms.userlist:redraw()
end

function act.setUser()
    local function callback(user)
        reaper.SetExtState("DBManager","user",user,true)
        dbm.user = user
        dbm.ui.menubar[3].options[1][1] = "Current User: ".. dbm.user
    end

    userPicker.open(callback)
end

function act.copyContents()
    local sel = GUI.Val("userlist")

    contentClipboard = {}
    for i, entry in ipairs(dbm.userDbs) do
        if sel[i] then 
            table.insert(contentClipboard,entry.ref)
        end
    end
end

function act.appendContents()
    if #contentClipboard < 1 then reaper.MB("There is no content in the clipboard","Error",0) ; return end
    if reaper.MB("Are you sure you want to append directly to the DBs? This action can't be undone","Warning",1) ~= 1 then return end

    local sel = GUI.Val("userlist")

    for i, entry in ipairs(dbm.userDbs) do
        if sel[i] then
            local t = assert(io.open(entry.ref,"a"))
            for i, source in ipairs(contentClipboard) do
                local s = assert(io.open(source,"r"))
                local size = 2^13      -- good buffer size (8K)
                while true do
                  local block = s:read(size)
                  if not block then break end
                  t:write(block)
                end
                s:close()
            end
            t:close()
        end
    end
    reaper.MB("Contents of Clipboard were appended to selected DBs","Sucess",0)
end

function act.chooseNewLibraryPath()
    local path = selectAFolder()
    if not path then return end

    dbm.config.library = path
    if dbm.ui then dbm.ui.menubar[3].options[2][1] = "Library: ".. dbm.config.library end

    writeJsonFile(json.stringify(dbm.config),dbm.configPath)
end

function act.chooseNewDatabasesPath()
    local path = selectAFolder()
    if not path then return end

    dbm.config.databases = path
    if dbm.ui then dbm.ui.menubar[3].options[3][1] = "Databases: ".. dbm.config.databases end

    writeJsonFile(json.stringify(dbm.config),dbm.configPath)
end

function act.chooseNewMasterDBPath()
    local path = selectFiles(false,"Reaper DB files\0*.ReaperFileList\0\0",dbm.config.databases)
    if not path then return end

    dbm.config.masterDB = path
    if dbm.ui then dbm.ui.menubar[3].options[4][1] = "MasterDB: ".. dbm.config.masterDB end

    writeJsonFile(json.stringify(dbm.config),dbm.configPath)
end

function act.defineUsers()
    reaper.MB("In the following dialog please provide the users to be available on the user picker as a csv string.Separate each name by a comma, with no spaces between names and commas.","Setup",0)
    local retval, csv = reaper.GetUserInputs("Users",1,"Users CSV","")
    if not retval then reaper.ReaScriptError("Error while generating config.\nError: User Cancelled dialog.\nPlease run again") end

    dbm.config.users = {}
    for name in string.gmatch(csv,"[^,]+") do
        table.insert(dbm.config.users,name)
    end
    
    writeJsonFile(json.stringify(dbm.config),dbm.configPath)
end

function act.importDB()
    createUndoPoint()
    local t = getFirstSelectedIndex()
    if not t then t = #dbm.userDbs end
    t = t + 1

    local dbPath = selectFiles(true,"Reaper DB files\0*.ReaperFileList\0\0",dbm.config.databases)
    if not dbPath then return end
    for i,path in ipairs(dbPath) do
        local name = string.match(path,"([^\\/]+)%.ReaperFileList$")
        table.insert(dbm.userDbs,t,{name = name, ref = path})
    end

    local newSel = {}
    for i=1,#dbPath do
        newSel[t+i-1] = true
    end
    GUI.Val("userlist",newSel)
end

function act.renameDBFile()
    local sel = GUI.Val("userlist")
    for i,entry in ipairs(dbm.userDbs) do
        if entry.name:match("[^=]") then
            if sel[i] then
                local entryDir = string.match(entry.ref,"(.+[\\/])[^\\/]+$")
                local name = entry.name:match("^%-*(.+)")
                for n,pindex in ipairs(getParents(i)) do
                    name = dbm.userDbs[pindex].name:match("^%-*(.+)") .. "_" .. name
                end    
                --TODO truncate long names
                local newRef = entryDir .. name .. ".ReaperFileList"
                if reaper.file_exists(newRef) then 
                    reaper.MB(newRef.." already exists","ERROR",0) 
                else
                    reaper.ExecProcess([[cmd.exe /C "move "]]..entry.ref..[[" "]]..newRef..[[""]],0)
                    entry.ref = newRef
                end
            end
        end
    end
end

local function selectedItems()
    local selItemsGUIDs = {}
    for i = 0, reaper.CountSelectedMediaItems(0) - 1 do
        table.insert(selItemsGUIDs, reaper.BR_GetMediaItemGUID(reaper.GetSelectedMediaItem(0,i)))
    end
    return function () 
            while #selItemsGUIDs > 0 do
                local item = reaper.BR_GetMediaItemByGUID(0, table.remove(selItemsGUIDs,1)) 
                if item then
                    return  item
                end
            end
        end
end

local function saveStringToTempFile(json) 
    local tempFilePath = get_script_path().."tempFile_DBAssistantFromReaper.json"

    local tempFile = io.open(tempFilePath,"w")
    tempFile:write(json)
    tempFile:close()

    return  tempFilePath
end

function act.importSFX()
    if countSelected() == 0 then reaper.MB('No DBs Selected','ERROR',0) ; return end

    local function addSFXwithDBAssistant(addOpts)
        if not addOpts then return end
        local addTable = {}
        addTable.library = dbm.config.library
        addTable.user = dbm.user
        addTable.list = {}
        addTable.shouldCopyToLib = addOpts.copyToLib or false

        local dbs = {}
        local sel = GUI.Val("userlist")
        for i,entry in ipairs(dbm.userDbs) do
            if sel[i] then 
                table.insert(dbs,entry.ref) 
                if addOpts.addToParents then
                    for i, parentI in pairs(getParents(i)) do
                        table.insert(dbs,dbm.userDbs[parentI].ref)     
                    end
                end
            end
        end

        if addOpts.addToMaster then table.insert(dbs,dbm.config.masterDB) end
        dbs = table.removeDups(dbs)

        if addOpts.isDir then  
            addTable.list[1] = {
                source = addOpts.dirPath,
                subdir = addOpts.subdir,
                dbs = dbs,
                rename = addOpts.rename,
                usertag = addOpts.customTag,
            } 
        end

        if addOpts.isSelItems then
            for item in selectedItems() do
                local take = reaper.GetActiveTake(item)
                local source = reaper.GetMediaItemTake_Source(take)
                local filePath = reaper.GetMediaSourceFileName(source,"")

                local subdir = addOpts.subdir
                local track = reaper.GetMediaItem_Track(item)
                local _,trackName = reaper.GetSetMediaTrackInfo_String(track,"P_NAME","",false)
                if addOpts.trackSubs and string.find(trackName,"%w") then 
                    if subdir ~= "" then 
                        subdir = subdir .. "\\" .. trackName 
                    else
                        subdir = trackName 
                    end
                end

                local addItem = {
                        source = filePath,
                        dbs = dbs,
                        subdir = subdir,
                        rename = addOpts.rename,
                        usertag = addOpts.customTag
                        }
                table.insert(addTable.list,addItem)
            end
        end

        local tempFile = saveStringToTempFile(json.stringify(addTable))
        local cmd = [[add "]]..tempFile..[["]]
        dbaExec(cmd)
    end

    addWindow.open(addSFXwithDBAssistant)
end

function act.cleanDuplicates()
    if countSelected() == 0 then reaper.MB('No DBs Selected','ERROR',0) ; return end
    local dbsList = {}
    local sel = GUI.Val("userlist")
    for i,entry in ipairs(dbm.userDbs) do
        if sel[i] then table.insert(dbsList,entry.ref) end
    end

    local tempFile = saveStringToTempFile(json.stringify(dbsList))
    local cmd = [[deduplicate "]]..tempFile..[["]]
    dbaExec(cmd)
end

function act.exportDBs()
    function export(newLib,dest)
        local export = {}

        export.newLib =  newLib
        export.currentLib =  dbm.config.library
        export.destination =  dest
    
        export.dbList = {}
        local sel = GUI.Val("userlist")
        for i,entry in ipairs(dbm.userDbs) do
            if sel[i] then table.insert(export.dbList,{name = entry.name , ref = entry.ref}) end
        end
        
        local tempFile = saveStringToTempFile(json.stringify(export))
        local cmd = [[export "]]..tempFile..[["]]
        dbaExec(cmd)
    end    

    if countSelected() == 0 then reaper.MB('No DBs Selected','ERROR',0) ; return end

    exportDBsWindow.open("",export)
end

return act