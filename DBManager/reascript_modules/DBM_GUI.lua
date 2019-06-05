--[[
@noindex
--]]

-- Script generated by Lokasenna's GUI Builder

local lib_path = reaper.GetExtState("Lokasenna_GUI", "lib_path_v2")
if not lib_path or lib_path == "" then
    reaper.MB("Couldn't load the Lokasenna_GUI library. Please run 'Set Lokasenna_GUI v2 library path.lua' in the Lokasenna_GUI folder.", "Whoops!", 0)
    return
end
loadfile(lib_path .. "Core.lua")()

GUI.req("Classes/Class - Button.lua")()
GUI.req("Classes/Class - Textbox.lua")()
GUI.req("Classes/Class - Listbox.lua")()
GUI.req("Classes/Class - Window.lua")()
GUI.req("Classes/Class - Label.lua")()
GUI.req("Classes/Class - Menubar.lua")()
GUI.req("Classes/Class - Options.lua")()
GUI.req("Classes/Class - Frame.lua")()

-- Overwriting draw function from listbox to read text from property. 
function GUI.Listbox:drawtext()

    GUI.color(self.color)
    GUI.font(self.font_b)

    local tmp = {}
    for i = self.wnd_y, math.min(self:wnd_bottom() - 1, #self.list) do

        local str = tostring(self.list[i].name)  or ""
        tmp[#tmp + 1] = str

    end

    gfx.x, gfx.y = self.x + self.pad, self.y + self.pad
    local r = gfx.x + self.w - 2*self.pad
    local b = gfx.y + self.h - 2*self.pad
    gfx.drawstr( table.concat(tmp, "\n"), 0, r, b)

end

-- If any of the requested libraries weren't found, abort the script.
if missing_lib then return 0 end

GUI.name = "DBManager"
GUI.x, GUI.y, GUI.w, GUI.h = 0, 0, 416, 670
GUI.anchor, GUI.corner = "mouse", "C"

loadLuaModule("DBM_popups")

dbm.ui = {}
dbm.ui.menubar = {
            {title = "File", options = {
                {"Save Changes to Profile", dbm.act.save},
                {"Import Database Files",dbm.act.importDB},
                {"Export Selected Shortcuts", dbm.act.exportShortcuts},
                {"Import Shortcuts (Replace All)", function() dbm.act.importShortcuts(true) end},
                {"Import Shortcuts (Insert)", function() dbm.act.importShortcuts(false) end},
            }},
            {title = "DB", options = {
                {"Add SFX to Selected DBs",dbm.act.importSFX},
                {"Clean Duplicate Entries in Selected DBs",dbm.act.cleanDuplicates},
                -- TODO implement export DBs
                {"Export DBs for portable use",dbm.act.exportDBs},
            }},
            {title = "Options", options = {
                {"User: "..(dbm.user or ""), dbm.act.setUser}, -- refereced in act.setUser
                {"Library: "..dbm.config.library,dbm.act.chooseNewLibraryPath},
                {"Databases: "..dbm.config.databases,dbm.act.chooseNewDatabasesPath},
                {"MasterDB: "..dbm.config.masterDB,dbm.act.chooseNewMasterDBPath},
            }},
            {title = "Help", options = {
                {"#DBManager Version: 0.5beta", foo}
            }}
        }

GUI.New("menubar","Menubar", {
        z = 5,
        x = 0,
        y = 0,
        w = GUI.w,
        h = 24,
        menus = dbm.ui.menubar
    })

GUI.New("userlist", "Listbox", {
    z = 11,
    x = 16,
    y = 36,
    w = 384,
    h = 568,
    list = dbm.userDbs,
    multi = true,
    caption = "",
    font_a = 3,
    font_b = 4,
    color = "txt",
    col_fill = "elm_fill",
    bg = "elm_bg",
    cap_bg = "wnd_bg",
    shadow = true,
    pad = 4
})

GUI.New("BG","Frame",{
    z = 12,
    x = 0,
    y = 0,
    w = 416,
    h = 670,
    shadow = false,
    fill = false,
    color = "elm_bg",
    round = 0,
})

GUI.New("searchbox","Textbox", {
    z = GUI.elms.userlist.z,
    x = GUI.elms.userlist.x,
    y = GUI.elms.userlist.y + GUI.elms.userlist.h + 8,
    w = 300,
    h = 30,
    })

GUI.New("searchbtn","Button", {
    z = GUI.elms.userlist.z,
    x = GUI.elms.userlist.x + GUI.elms.searchbox.w + 8,
    y = GUI.elms.userlist.y + GUI.elms.userlist.h + 8,
    w = 76,
    h = 29,
    font = 2,
    caption = "Search",
    func = dbm.act.search
    })

    function GUI.elms.searchbox:ontype()
        GUI.Textbox.ontype(self)
        if GUI.char == 13 then -- enter
            GUI.elms.searchbtn:exec()
        end
    end

function loop()
    for func in pairs(dbm.loopFunctions) do
        dbm.loopFunctions[func]()
    end
end

GUI.escape_bypass = true
GUI.fonts[5] = {'Arial', 8, 'b'}
GUI.func = loop
GUI.freq = 0


local function getEntryIUnderMouse()
    if GUI.IsInside(GUI.elms.userlist) then
        local list = GUI.elms.userlist
        local i = math.floor((GUI.mouse.y - list.y - list.pad) / 16) + list.wnd_y
        if i <= #dbm.userDbs then return i end
    end
end

function GUI.elms.userlist:onmouser_down()
    GUI.Listbox.onmouser_down(self)
    local i = getEntryIUnderMouse()
    if not i then showGeneralMenu() return end
    if not GUI.Val('userlist')[i] then
        GUI.Val('userlist',{[i] = true})
    end
    showEntryMenu(i)
end

-- Disabled double clikc until I figure out focus bug
-- function GUI.elms.userlist:ondoubleclick()
--     GUI.Listbox.ondoubleclick(self)
--     local i = getEntryIUnderMouse()
--     if not i then return end
--     dbm.act.rename()
-- end

function GUI.elms.userlist:ontype()
    GUI.Listbox.ontype(self)
    local this = GUI.elms.userlist

    if GUI.char == 30064 then -- up
        if GUI.mouse.cap & 4 == 4 then  -- Ctrl + up
            dbm.act.moveUp()
        elseif GUI.mouse.cap & 8 == 8 then -- Shift + up
            dbm.act.expandSelectionUp()
        else -- up
            local isTop = true
            for i = 1, #this.list do
                if this.retval[i] and i > 1 then
                    this.retval[i-1] = true 
                    this.retval[i] = nil 
                    if isTop then scrollToShowEntry(i-1) ; isTop = false end
                end
            end
            this:redraw()
        end
    end

    if GUI.char == 1685026670 then -- down
        if GUI.mouse.cap & 4 == 4 then --Ctrl + down
            dbm.act.moveDown()
        elseif GUI.mouse.cap & 8 == 8 then -- Shift + down
            dbm.act.expandSelectionDown()
        else -- down
            local isBottom = true
            for i = #this.list,1, -1  do
                if this.retval[i] and i < #this.list then 
                    this.retval[i+1] = true 
                    this.retval[i] = nil
                    if isBottom then scrollToShowEntry(i+1) ; isBottom = false end
                end
            end
            this:redraw()
        end
    end

    if GUI.char == 6579564 or GUI.char == 8 then -- del or backspace
        dbm.act.del()
        this:redraw()
    end    

    if GUI.char == 9 then -- tab
        if GUI.mouse.cap & 8 == 8 then -- shift + tab
            dbm.act.removeIndentation()
        else
            if GUI.mouse.cap & 4 == 4 then -- ctrl+i
                dbm.act.importSFX()
            else
                dbm.act.addIndentation()
            end
        end
        this:redraw()
    end

    if GUI.char == 26162 then -- F2
        dbm.act.rename()
    end

    if GUI.char == 14 then -- Ctrl + N
        dbm.act.createDB()
    end

    if GUI.char == 26 then -- Z
        if GUI.mouse.cap & 4 == 4 then -- Ctrl + Z\
            if GUI.mouse.cap & 8 == 8 then -- shift + Ctrl + Z
                dbm.act.redo()
            else
                dbm.act.undo()
            end
            this:redraw()
        end    
    end


    if GUI.char == 32 then -- Space
        dbm.act.sep()
        this:redraw()
    end

    if GUI.char == 24 then -- Ctrl + X
        dbm.act.cut()
        this:redraw()
    end


    if GUI.char == 22 then -- Ctrl + V
        dbm.act.paste()
        this:redraw()
    end

    if GUI.char == 27 then -- Esc
        local firstSel = getFirstSelectedIndex()
        if firstSel then 
            GUI.Val("userlist",{[firstSel] = true})
            this:redraw()
        end
    end

    if GUI.char == 1 then -- Ctrl + A
        local newSel = {}
        for i=1,#dbm.userDbs do newSel[i] = true end
        GUI.Val("userlist",newSel)
    end

    if GUI.char == 0x0000005b then -- [
        dbm.act.selectParent()
    end

    if GUI.char == 0x0000001b and GUI.mouse.cap & 4 == 4 then -- Ctrl + [
        dbm.act.selectAllParents()
    end

    if GUI.char == 92 then -- \
        dbm.act.selectSameIndentation()
    end

    if GUI.char == 93 then -- ]
        dbm.act.selectChildren()
    end

    if GUI.char == 6 then -- Ctrl F
        GUI.elms.userlist.focus = false
        GUI.elms.searchbox.focus = true
    end

    if GUI.char == 46 then
        dbm.act.selectAllParents()
    end


end

-------

GUI.Init()
GUI.Main()

if not dbm.user then dbm.act.setUser() end