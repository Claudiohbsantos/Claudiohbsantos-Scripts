# DBManager 1.0
- Feature: Unsaved Warning
- mac compatibility fixes
- handle fresh reaper installation 
- Feature: Convert slashes on export
- Feature: Export preview
- Include DBAssistant v0.3.6
- Menu options to open library and database folders on explorer/finder
- Feature: Help Files
- Feature: Option to ignore already existing files in directory

# DBManager 0.91alpha

- mac compatibility fixes

# DBManager 0.9alpha

- Added mac compatibility
- Includes DBAssistant 0.3.5

# DBManager v0.81beta

## BUGS

- error when searching without making selection
- false error dialogue when importing config file
- mismatched references  on list after save
- fixed preview copy destination on import sfx window

## IMPROVEMENTS

- Single popup for new DB creation

# DBManager v0.8beta

- Includes DBAssistant 0.3.4
- fixed parent detection

# DBManager v0.7beta

- Includes DBAssistant 0.3.3

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
