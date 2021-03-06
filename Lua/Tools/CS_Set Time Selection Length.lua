--[[
@description Set Time Selection Length
@version 1.72
@author Claudiohbsantos
@link http://claudiohbsantos.com
@date 2017 06 13
@about
  # Set Time Selection Length
  Set time Selection Length via time input
@changelog
  - Updated Libraries dependencies
@provides
  ../Libraries/TimecodeInput_Module.lua > ../Libraries/Set Time Selection Length/TimecodeInput_Module.lua
--]]

function get_script_path()
  local info = debug.getinfo(1,'S');
  local script_path = info.source:match[[^@?(.*[\/])[^\/]-$]]
  return script_path
end

function setTimeSelectionLen(inputInSeconds)

    if timeSelIn == reaper.GetProjectTimeOffset(0, false) then
      timeSelIn = reaper.GetCursorPositionEx(0)
    end

    timeSelOut = timeSelIn + inputInSeconds

    reaper.GetSet_LoopTimeRange2(0,true,true,timeSelIn,timeSelOut,false)
end

function onSuccessfulInput(inputInSeconds)
  if inputInSeconds then
  	setTimeSelectionLen(inputInSeconds)
  end
end

function prequire(...)
    local status, lib = pcall(require, ...)
    if(status) then return lib end
    --Library failed to load, so perhaps return `nil` or something?
    return nil
end

local script_path = get_script_path()
local libraryPath = string.match(script_path,"(.*\\).*\\$").."Libraries\\"
package.path = package.path .. ";" .. libraryPath .. "?.lua;".. libraryPath .."Go To Time\\?.lua"

requireStatus = prequire("TimecodeInput_Module")

if requireStatus then
  
  initGUI(130,"Set Time Sel Len")

  timeSelIn,timeSelOut = reaper.GetSet_LoopTimeRange2(0,false,true,0,0,false)

  defaulTimeInSeconds = timeSelOut - timeSelIn
  runTimecodeInputBox()
else
  reaper.ShowMessageBox("The script is missing the TimecodeInput_Module to function. Please reinstall this script from Reapack","Error: Library Missing",0)
end
  

