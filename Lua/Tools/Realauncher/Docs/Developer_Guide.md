# Realauncher Developer Guide

## Valid Syntax
command [arguments]

# command

Can't contain spaces. Can use any special characters and numbers

# switches

Switches are prefixed by */* or *--*

Note that all values on the switches tables will always exist since they always contain the default value. Therefore, if you need to check for the input of a switch instead of for it's value, you should check for inequality with the `switchesDefaultValues` table


# strings

Strings in the arguments must be enclosed by *"*

## Command Registration

```
rl.registeredCommands.**COMMANDNAME** = {
	passiveFunction = **FUNCTION TO BE EXECUTED ON EVERY LOOP**,
	onEnter = **FUNCTION TO BE EXECUTED ON ENTER PRESS**,
	entranceFunction = **FUNCTION TO BE EXECUTED WHEN COMMAND IS IDENTIFIED**,
	exitFunction = **FUNCTION TO BE EXECUTED ON EXIT**,
	charFunction = {[**NUMERICAL CODE FOR CHAR/SHORTCUT**] = **FUNCTION**},
	switches = {
				flip = true,
				light = true,
				name = "New Track Name",
				channels = "channels to process",
				help = true,
	},
	description = "**DESCRIPTION TO BE DISPLAY IN TIPLINE**",
}
```

### Entrance Function
	
The entrance Function is executed when entering the command mode (every time you enter the command mode in case of deletions for example). It is executed after parsing of switches so their value can be used in the function.

## Available parameters

- rl.text.currChar - Character typed/pressed on this loop (can be 0 for no typed character)
- rl.text.command - parsed command
- rl.text.arguments - table containing all parsed arguments
- rl.text.fullArgument - string with entire input minus command and preceding spaces
- rl.text.raw - raw typed string
- rl.text.tipLine = string that is printed every loop on the bottom of the window

- switchesDefaultValues - table containing the default values for the command's declared switches
- switches - table containing the parsed switch values including unmodified defaults

- rl.scriptPath - Absolute Path of Realaucher.lua
- rl.userSettingsPath - AboslutePath of Realauncher User folder. 
- rl.config - table containing the user configurations
- rl.history - table containing the history or commands


## Special Execution

A separate GUI can be launched, replacing the executing of the main loop until exited. The separate GUI can return a value to be added to the rl.text.raw string once returned. 

In order to do so, the following functions must be used:

### Entering Alt Gui:

`launchAltGUI(foo)` - in which *foo* is a function that starts the new gui. This function can be called from a shortcut or as an entrance function. Calling it from a passive or onEnter function will be inefective. 

### closing the Alt Gui:

`returnToMainLoop(returnValue)` - in which returnValue must be a number or a string.

## Help

Help files should be placed in the "Help" folder. The filename must be exactly the same as the command it refers to.

*References*

- http://pubs.opengroup.org/onlinepubs/9699919799/basedefs/V1_chap12.html