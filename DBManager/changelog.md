# DBManager v0.4beta

## FEATURES

    - Check reaper version and quit if unsupported
    - Warn to download JS API
    - Warn to download Lokasenna GUI library
    - Add version number to Help menu

## BUGS

    - Error when having spaces on DBAssistant path
    - Glitches when opening and closing multiple subwindows
    - User settings wiped when quiting with user picker dialog open
    - Error when trying to rename without any selected DBs 
    - Esc was triggering Ctrl+[
    - Double click to rename disabled due to bug that prevents typing when double clicking twice

## IMPROVEMENTS

    - Separated Developement of DBManager and DBAssistant for ease of maintenance
    - Lokasenna GUI is now added as a dependency instead of bundled (access to bugfixes)

## DEVELOPED WITH

    - Reaper 5.978
    - JS Reascript API 0.987
    - Lokasenna GUI Library 2.16.6

## ROADMAP

    - Feature:Mac Compatibility
    - Feature:help files
    - Feature:reapack installation
    - Improvements:Better shortcut handling. Possible ambiguities now (low priority)
    - Bug:GUI Dialog breaks after resizing. (low priority)
    - Bug:Add SFX Preview breaks when full subdirectory chosen
    - Bug:Double click to rename
