--[[
@metapackage true
@description DBManager
@version 0.4beta
@author Claudiohbsantos
@link http://claudiohbsantos.com
@date 2019 06 03
@about
    Database manager GUI for Reaper Media Explorer.
    Uses DBAssistant to make changes - https://github.com/Claudiohbsantos/DBAssistant . The executable will be automatically downloaded upon installation. 
    Depends on JS Reascript API and Lokasenna GUI Library v2.
@changelog
    DBManager v0.4
    FEATURES
        - Check reaper version and quit if unsupported
        - Warn to download JS API
        - Warn to download Lokasenna GUI library
        - Add version number to Help menu
    BUGS
        - Error when having spaces on DBAssistant path
        - Glitches when opening and closing multiple subwindows
        - User settings wiped when quiting with user picker dialog open
        - Error when trying to rename without any selected DBs 
        - Esc was triggering Ctrl+[
        - Double click to rename disabled due to bug that prevents typing when double clicking twice
    IMPROVEMENTS
        - Separated Developement of DBManager and DBAssistant for ease of maintenance
        - Lokasenna GUI is now added as a dependency instead of bundled (access to bugfixes)
    DEVELOPED WITH
        - Reaper 5.978
        - JS Reascript API 0.987
        - Lokasenna GUI Library 2.16.6
    DBAssistant v0.3.1
    FEATURES
        - Extracts all fields of metadata from BEXT, iXML, ID3, exif and vorbis tags.
        - New metadata extractor without external dependencies
    IMPROVEMENTS
        - DBAssistant doesn't depend on config.json anymore
        - .ogg, .flac, .aif and .wv formats are now recognized
        - Avoid newlines on verbose logging
        - More steps are logged to file
@provides
    [main] DBManager.lua > DBManager.lua
    [nomain] lua_modules/json.lua > lua_modules/json.lua
    [nomain] reascript_modules/DBM_popups.lua > reascript_modules/DBM_popups.lua
    [nomain] reascript_modules/DBM_helper.lua > reascript_modules/DBM_helper.lua
    [nomain] reascript_modules/DBM_GUI.lua > reascript_modules/DBM_GUI.lua
    [nomain] reascript_modules/DBM_actions.lua > reascript_modules/DBM_actions.lua
    Documentation/* > Documentation/
    changelog.md > changelog.md
    [windows] dbassistant.exe https://github.com/Claudiohbsantos/DBAssistant/releases/download/v0.3.1/dbassistant.exe
    dbassistant_changelog.md https://github.com/Claudiohbsantos/DBAssistant/releases/download/v0.3.1/changelog.md
--]]