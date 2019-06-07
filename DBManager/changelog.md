# DBManager v0.6beta

## FEATURES

- Import Config File option
- Show DBAssistant version in Help menu
- Upgraded bundled DBAssistant to 0.3.2

## BUGS

- Checks for existance of Lokasenna GUI Core.lua file
- Checks for Lokasenna GUI version compatibility
- error when exporting dbs for portable use

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
