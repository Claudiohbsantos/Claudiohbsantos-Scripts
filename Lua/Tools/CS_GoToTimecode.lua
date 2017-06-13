--[[
@description Go To Time
@version 1.1
@author Claudiohbsantos
@link http://claudiohbsantos.com
@date 2017 06 13
@about
  # Go To Time
  Go to Time input
  Press + or - to change to subtration  or Addition Mode. Press Spacebar to reset default timecode to zero. 
@changelog
  - initial release
@provides
  [nomain] ../Libraries/TimecodeInput_Module.lua
--]]

function msg(s) reaper.ShowConsoleMsg(tostring(s)..'\n') end

function get_script_path()
  local info = debug.getinfo(1,'S');
  local script_path = info.source:match[[^@?(.*[\/])[^\/]-$]]
  return script_path
end

function goToTimecode(inputInSeconds)
  reaper.SetEditCurPos2(0,inputInSeconds,false,false)
end

function onSuccessfulInput(inputInSeconds) 
  if inputInSeconds then
  	goToTimecode(inputInSeconds)
  end
  
end

local script_path = get_script_path()
local libraryPath = string.match(script_path,"(.*\\).*\\$").."Libraries\\"
package.path = package.path .. ";" .. libraryPath .. "?.lua"

require "TimecodeInput_Module"
  
initGUI(130,"Go To Time")

defaulTimeInSeconds = reaper.GetCursorPositionEx(0)
runTimecodeInputBox()
