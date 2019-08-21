--[[
@metapackage true
@description DBManager
@version 0.9alpha
@author Claudiohbsantos
@link http://claudiohbsantos.com
@date 2019 08 21
@about
    Database manager GUI for Reaper Media Explorer.
    Uses DBAssistant to make changes - https://github.com/Claudiohbsantos/DBAssistant . The executable will be automatically downloaded upon installation. 
    Depends on JS Reascript API and Lokasenna GUI Library v2.
@changelog
    - Added mac compatibility
    - Includes DBAssistant 0.3.5
@provides
    [main] DBManager.lua > DBManager.lua
    [nomain] lua_modules/json.lua > lua_modules/json.lua
    [nomain] reascript_modules/DBM_popups.lua > reascript_modules/DBM_popups.lua
    [nomain] reascript_modules/DBM_helper.lua > reascript_modules/DBM_helper.lua
    [nomain] reascript_modules/DBM_GUI.lua > reascript_modules/DBM_GUI.lua
    [nomain] reascript_modules/DBM_actions.lua > reascript_modules/DBM_actions.lua
    Documentation/* > Documentation/
    changelog.md > changelog.md
    [windows] dbassistant.exe https://github.com/Claudiohbsantos/DBAssistant/releases/download/v0.3.5/dbassistant.exe
    [darwin] dbassistant https://github.com/Claudiohbsantos/DBAssistant/releases/download/v0.3.5/dbassistant
    dbassistant_changelog.md https://github.com/Claudiohbsantos/DBAssistant/releases/download/v0.3.5/changelog.md
    [darwin] osx_launchers/osx_add.sh > osx_launchers/osx_add.sh 
    [darwin] osx_launchers/osx_deduplicate.sh > osx_launchers/osx_deduplicate.sh 
    [darwin] osx_launchers/osx_export.sh > osx_launchers/osx_export.sh 
    [darwin] osx_launchers/osx_version.sh > osx_launchers/osx_version.sh 
--]]