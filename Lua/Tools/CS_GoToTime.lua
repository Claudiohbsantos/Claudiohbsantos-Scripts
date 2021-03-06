--[[
@description CS_Go To Time
@version 2.1
@author Claudiohbsantos
@link http://claudiohbsantos.com
@date 2020 05 05
@about
  # CS_Go To Time
  Go to Time input
  Press + or - to change to subtration  or Addition Mode. Press Spacebar to reset default timecode to zero. 
@changelog
  - Corrected download path from git
@provides
  ../Libraries/TimecodeInput_Module.lua > ../Libraries/Go To Time/TimecodeInput_Module.lua  
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

function prequire(...)
    local status, lib = pcall(require, ...)

    if (status) then return lib end
    --Library failed to load, so perhaps return `nil` or something?
    return nil
end

local script_path = get_script_path()
local libraryPath = string.match(script_path,"(.*[\\/]).*[\\/]$").."Libraries/"
package.path = package.path .. ";" .. libraryPath .. "?.lua;".. libraryPath .."Go To Time/?.lua"

requireStatus = prequire("TimecodeInput_Module")

if requireStatus then
  initGUI(130,"Go To Time")

  defaulTimeInSeconds = reaper.GetCursorPositionEx(0)
  runTimecodeInputBox()
else
  reaper.ShowMessageBox("The script is missing the TimecodeInput_Module to function. Please reinstall this script from Reapack","Error: Library Missing",0)
end
  

