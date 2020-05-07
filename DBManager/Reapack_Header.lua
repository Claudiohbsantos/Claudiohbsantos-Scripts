--[[
@metapackage true
@description DBManager
@version 1.1
@author Claudiohbsantos
@link http://claudiohbsantos.com
@date 2020 05 07
@about
    DBManager is a tool designed to help organize and maintain Reaper Media Explorer Databases. It can help you import and export databases, add sounds to multiple databases at once and perform basic maintenance tasks such as removing duplicates and redirecting paths to a new location in the event of a library move.
    Uses DBAssistant to make changes - https://github.com/Claudiohbsantos/DBAssistant . The executable will be automatically downloaded upon installation. 
    Depends on JS Reascript API and Lokasenna GUI Library v2.
@changelog
    - Bug: crash when attempting to paste/import shortcuts without a selected db on list
@provides
    [main] DBManager.lua > DBManager.lua
    [nomain] lua_modules/json.lua > lua_modules/json.lua
    [nomain] reascript_modules/DBM_popups.lua > reascript_modules/DBM_popups.lua
    [nomain] reascript_modules/DBM_helper.lua > reascript_modules/DBM_helper.lua
    [nomain] reascript_modules/DBM_GUI.lua > reascript_modules/DBM_GUI.lua
    [nomain] reascript_modules/DBM_actions.lua > reascript_modules/DBM_actions.lua
    Documentation/Help.html > Documentation/Help.html
    Documentation/configTemplate.json > Documentation/configTemplate.json
    changelog.md > changelog.md
    [windows] dbassistant.exe https://github.com/Claudiohbsantos/DBAssistant/releases/download/v0.3.6/dbassistant.exe
    [darwin] dbassistant https://github.com/Claudiohbsantos/DBAssistant/releases/download/v0.3.6/dbassistant
    dbassistant_changelog.md https://github.com/Claudiohbsantos/DBAssistant/releases/download/v0.3.6/changelog.md
    [darwin] osx_launchers/osx_add.sh > osx_launchers/osx_add.sh 
    [darwin] osx_launchers/osx_deduplicate.sh > osx_launchers/osx_deduplicate.sh 
    [darwin] osx_launchers/osx_export.sh > osx_launchers/osx_export.sh 
    [darwin] osx_launchers/osx_version.sh > osx_launchers/osx_version.sh 
--]]