--[[
@noindex
--]]

inputWindow = {}
function inputWindow.open(placeholder,title,caption,okfunc, ...)
    local varParams = ...
    GUI.New("inputDial", "Window", {
        z = 20,
        x = (GUI.w - 400)/2,
        y = (GUI.h - 150)/2,
        w = 400,
        h = 150,
        z_set = {19,20},
        caption = title,
        })
    
    GUI.New("inputbox", "Textbox", {
        z = 19,
        x = (400 - 360)/2,
        y = 31,
        w = 360,
        h = 30,
        caption = caption,
        cap_pos = "top"
        })
    
    GUI.New("inputokbtn", "Button", {
        z = 19,
        x = (400 - 36)/2,
        y = 81,
        w = 36,
        h = 24,
        caption = "Ok",
        font = 3,
        col_txt = "txt",
        col_fill = "elm_frame",
        func = function() okfunc(inputWindow.ok(), varParams) end
    })

    function GUI.elms.inputbox:ontype()
        GUI.Textbox.ontype(self)
        if GUI.char == 13 then -- enter
            GUI.elms.inputokbtn:exec()
        end
    end

    GUI.elms.inputDial:adjustelm(GUI.elms.inputokbtn)
    GUI.elms.inputDial:adjustelm(GUI.elms.inputbox)
    
    function GUI.elms.inputDial:onopen()
        GUI.elms.inputbox.focus = true
        GUI.Val("inputbox",(placeholder or ""))
        GUI.elms.inputbox.caret = placeholder:len()
    end

    function GUI.elms.inputDial:onclose()
        GUI.elms.inputbox:delete()
        GUI.elms.userlist:redraw()
    end

    GUI.elms.inputDial:open()

end
function inputWindow.ok()
    local txt = GUI.Val("inputbox")
    GUI.elms.inputDial:close()
    GUI.elms.userlist:redraw()
    return txt
end

newDBWindow = {}
function newDBWindow.open(placeholder,title,okfunc)
    GUI.New("newDBDial", "Window", {
        z = 20,
        x = (GUI.w - 400)/2,
        y = (GUI.h - 150)/2,
        w = 400,
        h = 250,
        z_set = {19,20},
        caption = title,
        })
    
    GUI.New("dbName", "Textbox", {
        z = 19,
        x = (400 - 360)/2,
        y = 0,
        w = 360,
        h = 30,
        caption = 'DB File name',
        cap_pos = "top"
        })
    GUI.elms.newDBDial:adjustelm(GUI.elms.dbName)

    GUI.New("dbPath", "Textbox", {
        z = 19,
        x = (400 - 360)/2,
        y = 61,
        w = 360,
        h = 30,
        caption = 'DB Path',
        cap_pos = "top",
        })
    GUI.elms.newDBDial:adjustelm(GUI.elms.dbPath)
    GUI.Val("dbPath",dbm.config.databases)
        
    GUI.New("dbPathPick", "Button", {
        z = 19,
        x = (400 - 60) / 2,
        y = 101,
        w = 60,
        h = 20,
        caption = "Choose",
        font = 2,
        col_txt = "txt",
        col_fill = "elm_frame",
        func = function() GUI.Val("dbPath",selectAFolder()) end
    })
    GUI.elms.newDBDial:adjustelm(GUI.elms.dbPathPick)    

    GUI.New("inputokbtn", "Button", {
        z = 19,
        x = (400 - 36)/2,
        y = 141,
        w = 36,
        h = 24,
        caption = "Ok",
        font = 3,
        col_txt = "txt",
        col_fill = "elm_frame",
        func = function() okfunc(newDBWindow.ok()) end
    })
    GUI.elms.newDBDial:adjustelm(GUI.elms.inputokbtn)

    function GUI.elms.dbName:ontype()
        GUI.Textbox.ontype(self)
        if GUI.char == 13 then -- enter
            GUI.elms.inputokbtn:exec()
        end
    end
    
    function GUI.elms.newDBDial:onopen()
        GUI.elms.dbName.focus = true
        GUI.Val("dbName",(placeholder or ""))
        GUI.elms.dbName.caret = placeholder:len()
    end

    function GUI.elms.newDBDial:onclose()
        GUI.elms.dbName:delete()
        GUI.elms.userlist:redraw()
    end

    GUI.elms.newDBDial:open()

end
function newDBWindow.ok()
    local txt = GUI.Val("dbName")
    local dir = GUI.Val("dbPath")
    GUI.elms.newDBDial:close()
    GUI.elms.userlist:redraw()
    return txt, dir
end

exportDBsWindow = {}
function exportDBsWindow.open(placeholder,okfunc)

    GUI.New("exportDial", "Window", {
        z = 30,
        x = (GUI.w - 400)/2,
        y = (GUI.h - 250)/2,
        w = 400,
        h = 250,
        z_set = {29,30},
        caption = "Export DBs",
        })
        
    GUI.New("inputbox", "Textbox", {
        z = 29,
        x = (400 - 360)/2,
        y = 31,
        w = 360,
        h = 30,
        caption = "New Lib Path:",
        cap_pos = "top"
        })

    GUI.New("destbox", "Textbox", {
        z = 29,
        x = (400 - 360)/2,
        y = 86,
        w = 360,
        h = 30,
        caption = "Export to:",
        cap_pos = "top"
        })

    GUI.New("destpick", "Button", {
        z = 29,
        x = (400 - 60)/2,
        y = 123,
        w = 60,
        h = 20,
        caption = "Choose",
        font = 2,
        col_txt = "txt",
        col_fill = "elm_frame",
        func = function() GUI.Val("destbox",selectAFolder()) end
    })


    GUI.New("inputokbtn", "Button", {
        z = 29,
        x = (400 - 36)/2,
        y = 171,
        w = 36,
        h = 24,
        caption = "Ok",
        font = 3,
        col_txt = "txt",
        col_fill = "elm_frame",
        func = function() okfunc(exportDBsWindow.ok()) end
    })

    function GUI.elms.inputbox:ontype()
        GUI.Textbox.ontype(self)
        if GUI.char == 13 then -- enter
            GUI.elms.inputokbtn:exec()
        end
    end

    GUI.elms.exportDial:adjustelm(GUI.elms.inputokbtn)
    GUI.elms.exportDial:adjustelm(GUI.elms.inputbox)
    GUI.elms.exportDial:adjustelm(GUI.elms.destbox)
    GUI.elms.exportDial:adjustelm(GUI.elms.destpick)
    GUI.elms.inputbox.focus = true
    GUI.Val("inputbox",(placeholder or ""))
    GUI.elms.inputbox.caret = placeholder:len()

    GUI.elms.exportDial:open()
end
function exportDBsWindow.ok()
    local newLib = GUI.Val("inputbox")
    local dest = GUI.Val("destbox")
    GUI.elms.exportDial:close()
    GUI.elms.userlist:redraw()
    return newLib , dest
end

listPicker = {}
function listPicker.open(title,allowMulti,displayList,func)

    GUI.New("pickerDial", "Window", {
        z = 40,
        x = (GUI.w - 400)/2,
        y = (GUI.h - 300)/2,
        w = 400,
        h = 320,
        z_set = {39,40},
        caption = title,
    })
    GUI.New("pickerlist", "Listbox", {
        z = 39,
        x = 8, 
        y = -1,
        w = 400 - 8*2,
        h = 270 - 8*2,
        multi = allowMulti,
        list = displayList
        })

    GUI.New("gobtn", "Button", {
        z = 39,
        x = (400 - 40)/2,
        y = 258,
        w = 40,
        h = 20,
        caption = "Go",
        func = function() func(listPicker.go()) end
        })


    GUI.elms.pickerDial:adjustelm(GUI.elms.pickerlist)
    GUI.elms.pickerDial:adjustelm(GUI.elms.gobtn)

    GUI.elms.pickerDial:open()
end
function listPicker.go()
    local sel = GUI.Val("pickerlist")
    GUI.elms.pickerDial:close()
    GUI.elms.userlist:redraw()
    return sel
end

userPicker = {}
function userPicker.open(setFunc)
    GUI.New("usersDial", "Window", {
        z = 50,
        x = (GUI.w - 110)/2,
        y = (GUI.h - 260)/2,
        w = 110,
        h = 280,
        z_set = {49,50},
        caption = "User",
        noclose = true,         
        })

    GUI.New("users", "Radio", {
        z = 49,
        x = 8,
        y = -1,
        w = 96,
        h = 205,
        optarray = dbm.config.users,
        dir = "v",
        font_a = 2,
        font_b = 3,
        col_txt = "txt",
        col_fill = "elm_fill",
        bg = "wnd_bg",
        frame = false,
        shadow = true,
        swap = nil,
        opt_size = 20,
    })

        GUI.New("setbtn", "Button", {
        z = 49,
        x = (GUI.elms.usersDial.w - 40)/2,
        y = 211,
        w = 40,
        h = 20,
        caption = "Set",
        func = function() setFunc(userPicker.set()) end
        })

    GUI.elms.usersDial:adjustelm(GUI.elms.setbtn)
    GUI.elms.usersDial:adjustelm(GUI.elms.users)

    GUI.elms.usersDial:open()
end
function userPicker.set()
    local user = dbm.config.users[GUI.Val("users")]
    GUI.elms.usersDial:close()
    return user
end

addWindow = {}

function addWindow.open(addFunc)
    GUI.req("Classes/Class - Tabs.lua")()

    GUI.New("addDial", "Window", {
        z = 60,
        x = (GUI.w - 400)/2,
        y = (GUI.h - 430)/2,
        w = 400,
        h = 450,
        z_set = {54,55,56,57,58,59,60},
        caption = 'Add SFX',
    })

    GUI.New("sourceTabs","Tabs",{
        z = 58,
        x = 4,
        y = -5,
        tab_w = 90,
        tab_h = 30,
        opts = {"Selected Items","Directory"},
        fullwidth = false
    })
    GUI.New("tabsBG","Frame",{
        z = 59,
        x = 4,
        y = -5,
        w = 390,
        h = 30,
        shadow = false,
        fill = false,
        color = "elm_bg",
        bg = "elm_bg",
        round = 0,
    })
    GUI.elms.addDial:adjustelm(GUI.elms.sourceTabs)
    GUI.elms.addDial:adjustelm(GUI.elms.tabsBG)
    
    GUI.elms.sourceTabs:update_sets({{54,55},{56,57}})

    GUI.New("selItemStats", "Label",{
        z = 54,
        x = 150,
        y = 31,
        caption = "",
        color = "cyan",
        font = 3
    })
    GUI.elms.addDial:adjustelm(GUI.elms.selItemStats)

    function updateSelItems()
        local nSelItems = reaper.CountSelectedMediaItems(0)
        if nSelItems ~= GUI.Val("selItemStats") then
            GUI.Val("selItemStats",nSelItems.." items selected")
        end
    end
    dbm.loopFunctions.updateSelItems = updateSelItems
    
    GUI.New("rename","Textbox", {
        z = 54,
        x = 60,
        y = 56,
        w = 330,
        h = 20,
        font_a = 3,
        caption = "Rename:",
        cap_pos = "left",
        font_b = "monospace",
        color = "txt",
        bg = "wnd_bg",
        shadow = true,
        pad = 4,
        undo_limit = 20
    })  
    GUI.elms.addDial:adjustelm(GUI.elms.rename)

    GUI.New("tracksAsSubs", "Checklist", {
        z = 54,
        x = 100.0,
        y = 76,
        w = 250,
        h = 35,
        caption = "",
        optarray = {"Use Track Names as Subdirectories"},
        dir = "v",
        pad = 10,
        font_a = 2,
        font_b = 3,
        col_txt = "txt",
        col_fill = "elm_fill",
        bg = "wnd_bg",
        frame = false,
        shadow = false,
        swap = nil,
        opt_size = 20
    })
    GUI.elms.addDial:adjustelm(GUI.elms.tracksAsSubs)

    GUI.New("selItemsBG","Frame",{
        z = 55,
        x = 3,
        y = 25,
        w = 392,
        h = 96,
        shadow = false,
        fill = false,
        -- color = "elm_bg",
        -- bg = "elm_bg",
        round = 0,
    })
    GUI.elms.addDial:adjustelm(GUI.elms.selItemsBG)

    GUI.New("dirPath","Textbox", {
        z = 56,
        x = 10,
        y = 56,
        w = 380,
        h = 20,
        caption = "Source Directory",
        cap_pos = "top",
        font_a = 3,
        font_b = "monospace",
        color = "txt",
        bg = "wnd_bg",
        shadow = true,
        pad = 4,
        undo_limit = 20
    })
    GUI.elms.addDial:adjustelm(GUI.elms.dirPath)

    GUI.New("dirPick", "Button", {
        z = 56,
        x = (400 - 60) / 2,
        y = 85,
        w = 60,
        h = 20,
        caption = "Choose",
        font = 2,
        col_txt = "txt",
        col_fill = "elm_frame",
        func = function() GUI.Val("dirPath",selectAFolder()) end
    })
    GUI.elms.addDial:adjustelm(GUI.elms.dirPick)

    GUI.New("dirsBG","Frame",{
        z = 57,
        x = 3,
        y = 25,
        w = 392,
        h = 96,
        shadow = false,
        fill = false,
        -- color = "elm_bg",
        -- bg = "elm_bg",
        round = 0,
    })
    GUI.elms.addDial:adjustelm(GUI.elms.dirsBG)
    
    GUI.New("customTag","Textbox", {
        z = 58,
        x = 79  ,
        y = 136,
        w = 311,
        h = 20,
        font_a = 3,
        caption = "Custom Tag:",
        cap_pos = "left",
        font_b = "monospace",
        color = "txt",
        bg = "wnd_bg",
        shadow = true,
        pad = 4,
        undo_limit = 20
    })  
    GUI.elms.addDial:adjustelm(GUI.elms.customTag)

    GUI.New("subdirName","Textbox", {
        z = 58,
        x = 79,
        y = 171,
        w = 311,
        h = 20,
        caption = "Subdir:",
        cap_pos = "left",
        font_a = 3,
        font_b = "monospace",
        color = "txt",
        bg = "wnd_bg",
        shadow = true,
        pad = 4,
        undo_limit = 20
    })
    GUI.elms.addDial:adjustelm(GUI.elms.subdirName)

    GUI.New("subdirPick", "Button", {
        z = 58,
        x = (400 - 60) / 2,
        y = 201,
        w = 60,
        h = 20,
        caption = "Choose",
        font = 2,
        col_txt = "txt",
        col_fill = "elm_frame",
        func = function() GUI.Val("subdirName",selectAFolder()) end
    })
    GUI.elms.addDial:adjustelm(GUI.elms.subdirPick)

    GUI.New("addToParents", "Checklist", {
        z = 58,
        x = 20,
        y = 226,
        w = 145,
        h = 35,
        caption = "",
        optarray = {"Add to DB Parents"},
        dir = "v",
        pad = 10,
        font_a = 2,
        font_b = 3,
        col_txt = "txt",
        col_fill = "elm_fill",
        bg = "wnd_bg",
        frame = false,
        shadow = false,
        swap = nil,
        opt_size = 20
    })
    GUI.elms.addDial:adjustelm(GUI.elms.addToParents)

    GUI.New("addToMaster", "Checklist", {
        z = 58,
        x = 205,
        y = 226,
        w = 145,
        h = 35,
        caption = "",
        optarray = {"Add to Master DB"},
        dir = "v",
        pad = 10,
        font_a = 2,
        font_b = 3,
        col_txt = "txt",
        col_fill = "elm_fill",
        bg = "wnd_bg",
        frame = false,
        shadow = false,
        swap = nil,
        opt_size = 20
    })
    GUI.elms.addDial:adjustelm(GUI.elms.addToMaster)

    GUI.New("copyToLib", "Checklist", {
        z = 58,
        x = 20,
        y = 256,
        w = 145,
        h = 35,
        caption = "",
        optarray = {"Copy Files to Library"},
        dir = "v",
        pad = 10,
        font_a = 2,
        font_b = 3,
        col_txt = "txt",
        col_fill = "elm_fill",
        bg = "wnd_bg",
        frame = false,
        shadow = false,
        swap = nil,
        opt_size = 20
    })
    GUI.elms.addDial:adjustelm(GUI.elms.copyToLib)

    GUI.New("PreviewFrame","Frame", {
        z = 58,
        x = 4,
        y = 301,
        w = 390,
        h = 78,
        shadow = false,
        fill = false,
        color = "elm_bg",
        bg = "elm_bg",
        round = 0,
        text = "",
        txt_indent = 2,
        txt_pad = 0,
        pad = 8,
        font = 4,
        col_txt = "cyan",
    })
    GUI.elms.addDial:adjustelm(GUI.elms.PreviewFrame)

    GUI.New("AddButton", "Button", {
        z = 59,
        x = (400 - 80)/2,
        y = 383,
        w = 80,
        h = 24,
        caption = "ADD",
        font = 2,
        col_txt = "txt",
        col_fill = "elm_frame",
        func = function() addFunc(addWindow.addClick()) end
    })

    GUI.elms.addDial:adjustelm(GUI.elms.AddButton)

    GUI.elms.addDial:open()

    GUI.Val("addToParents",true)
    GUI.Val("addToMaster",true)
    GUI.Val("copyToLib",true)

    function updateAddPreview()
        -- TODO: Fix preview fo fullpath subdir
        if not GUI.Val("copyToLib") then GUI.Val("PreviewFrame","source files won't be copied") ; return end

        local intro = "source files will be copied to:\n"

        local lib = dbm.config.library
        local subdir = ""
        local user
        if GUI.Val("subdirName") ~= "" then 
            subdir = GUI.Val("subdirName")
            if subdir:match("^/") or subdir:match("^%a:") then 
                lib = "" 
            else
                subdir = "\\"..subdir 
            end
        else
            subdir = nil
            user = "\\".. (dbm.user or '')
        end

        local subTrack
        if GUI.Val("sourceTabs") == 1 and GUI.Val("tracksAsSubs") then subTrack = '\\[TrackName]' ; user = "" end 

        local dirname = ""
        if GUI.Val("sourceTabs") == 2 and GUI.Val("dirPath") ~= "" then
            dirname = GUI.Val("dirPath"):match("[^\\/]+$")
            if dirname then dirname = "\\"..dirname else dirname = "" end
            user = ""
        end   

        local destination = lib..(subdir or user)..(subTrack or '')..dirname

        GUI.Val("PreviewFrame",intro..destination)
    end
    
    dbm.loopFunctions.updateAddPreview = updateAddPreview
end
function addWindow.addClick()
    local add = {}
    if GUI.Val("sourceTabs") == 1 then add.isSelItems = true end
    if GUI.Val("sourceTabs") == 2 then add.isDir = true  end
    if string.find(GUI.Val("subdirName"),"%w") then add.subdir = GUI.Val("subdirName") else add.subdir = "" end
    if string.find(GUI.Val("customTag"),"%w") then add.customTag = GUI.Val("customTag") else add.customTag = "" end
    if string.find(GUI.Val("rename"),"%w") then add.rename = GUI.Val("rename") else add.rename = "" end
    if GUI.Val("dirPath") and string.find(GUI.Val("dirPath"),"%w") then add.dirPath = GUI.Val("dirPath") else add.dirPath = "" end
    if GUI.Val("tracksAsSubs") then add.trackSubs = true else add.trackSubs = false end
    if GUI.Val("addToParents") then add.addToParents = true end
    if GUI.Val("addToMaster") then add.addToMaster = true end
    if GUI.Val("copyToLib") then add.copyToLib = true end

    if add.isDir and add.dirPath == "" then reaper.MB("Please Select a Directory","ERROR",0) ; return nil end
    if add.isSelItems and reaper.CountSelectedMediaItems(0) == 0 then reaper.MB("Please Select Items in the session","ERROR",0) ; return nil end

    dbm.loopFunctions.updateSelItems = nil
    dbm.loopFunctions.updateAddPreview = nil

    GUI.elms.addDial:close()
    
    return add
end

function showGeneralMenu()
    gfx.x = GUI.mouse.x
    gfx.y = GUI.mouse.y

    local menu = {
        {"Create New DB (Ctrl+N)",dbm.act.createDB},
        {"Import Database File",dbm.act.importDB}
    }

    local menuOpts = ""
    for i,opt in ipairs(menu) do
        menuOpts = menuOpts .. opt[1] .. '|'
    end
    menu[0] = {nil,foo}
    menu[gfx.showmenu(menuOpts)][2]()
    GUI.elms.userlist:redraw()
end

function showEntryMenu(i)
    gfx.x = GUI.mouse.x
    gfx.y = GUI.mouse.y

    local menu = {
        {"#" .. dbm.userDbs[i].name,foo},
        {">Path: " .. dbm.userDbs[i].ref,foo},
        {"Choose new DB file",function() dbm.act.chooseNewRef(i,false) end},
        {"<Choose new path (Shortcut)",function() dbm.act.chooseNewRef(i,true) end},
        {"|Cut Shortcuts (Ctrl+X)",dbm.act.cut},
        {"Paste Shortcuts (Ctrl+V)",dbm.act.paste},
        {"Copy Contents of DBs",dbm.act.copyContents},
        {"Append Copied Contents to DBs",dbm.act.appendContents},
        {"|Add Separator (Spacebar)",dbm.act.sep},
        {"Indent Shortcut (Tab)",dbm.act.addIndentation},
        {"Remove Indentation from Shortcut (Shift+Tab)",dbm.act.removeIndentation},
        {"Select Adjacent Shortcuts of same Indentation (\\)",dbm.act.selectSameIndentation},
        {"Select Immediate Parent ([)",dbm.act.selectParent},
        {"Select All Parents (Ctrl+[)",dbm.act.selectAllParents},
        {"Select Children (])",dbm.act.selectChildren},
        {"|Rename Shortcut (F2)",dbm.act.rename},
        {"|Rename Database File",dbm.act.renameDBFile},
        {"Delete Shortcuts (Del)",dbm.act.del},
        {"Create New DB (Ctrl+N)",dbm.act.createDB},
        {"Import Database File",dbm.act.importDB},
        {"|Import SFX to selected DBs (Ctrl+I)",dbm.act.importSFX},
        {"Clean Duplicate entries in selected DBs",dbm.act.cleanDuplicates}
    }

    local menuOpts = ""
    for i,opt in ipairs(menu) do
        menuOpts = menuOpts .. opt[1] .. '|'
    end
    menu[0] = {nil,foo}
    menu[gfx.showmenu(menuOpts)+1][2]()
    GUI.elms.userlist:redraw()
end