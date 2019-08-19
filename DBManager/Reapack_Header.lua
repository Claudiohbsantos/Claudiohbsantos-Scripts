--[[
@metapackage true
@description DBManager
@version 0.81beta
@author Claudiohbsantos
@link http://claudiohbsantos.com
@date 2019 08 19
@about
    Database manager GUI for Reaper Media Explorer.
    Uses DBAssistant to make changes - https://github.com/Claudiohbsantos/DBAssistant . The executable will be automatically downloaded upon installation. 
    Depends on JS Reascript API and Lokasenna GUI Library v2.
@changelog
    # DBManager v0.81beta

    ## BUGS

    - error when searching without making selection
    - false error dialogue when importing config file
    - mismatched references  on list after save
    - fixed preview copy destination on import sfx window

    ## IMPROVEMENTS

    - Single popup for new DB creation
@provides
    [main] DBManager.lua > DBManager.lua
    [nomain] lua_modules/json.lua > lua_modules/json.lua
    [nomain] reascript_modules/DBM_popups.lua > reascript_modules/DBM_popups.lua
    [nomain] reascript_modules/DBM_helper.lua > reascript_modules/DBM_helper.lua
    [nomain] reascript_modules/DBM_GUI.lua > reascript_modules/DBM_GUI.lua
    [nomain] reascript_modules/DBM_actions.lua > reascript_modules/DBM_actions.lua
    Documentation/* > Documentation/
    changelog.md > changelog.md
    [windows] dbassistant.exe https://github.com/Claudiohbsantos/DBAssistant/releases/download/v0.3.4/dbassistant.exe
    dbassistant_changelog.md https://github.com/Claudiohbsantos/DBAssistant/releases/download/v0.3.4/changelog.md
--]]