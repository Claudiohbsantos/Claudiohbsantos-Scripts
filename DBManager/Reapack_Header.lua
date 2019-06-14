--[[
@metapackage true
@description DBManager
@version 0.7beta
@author Claudiohbsantos
@link http://claudiohbsantos.com
@date 2019 06 07
@about
    Database manager GUI for Reaper Media Explorer.
    Uses DBAssistant to make changes - https://github.com/Claudiohbsantos/DBAssistant . The executable will be automatically downloaded upon installation. 
    Depends on JS Reascript API and Lokasenna GUI Library v2.
@changelog
    - Includes DBAssistant 0.3.3
@provides
    [main] DBManager.lua > DBManager.lua
    [nomain] lua_modules/json.lua > lua_modules/json.lua
    [nomain] reascript_modules/DBM_popups.lua > reascript_modules/DBM_popups.lua
    [nomain] reascript_modules/DBM_helper.lua > reascript_modules/DBM_helper.lua
    [nomain] reascript_modules/DBM_GUI.lua > reascript_modules/DBM_GUI.lua
    [nomain] reascript_modules/DBM_actions.lua > reascript_modules/DBM_actions.lua
    Documentation/* > Documentation/
    changelog.md > changelog.md
    [windows] dbassistant.exe https://github.com/Claudiohbsantos/DBAssistant/releases/download/v0.3.3/dbassistant.exe
    dbassistant_changelog.md https://github.com/Claudiohbsantos/DBAssistant/releases/download/v0.3.3/changelog.md
--]]