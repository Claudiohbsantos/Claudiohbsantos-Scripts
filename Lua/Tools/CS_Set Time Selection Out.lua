--[[
@description CS_Set Time Selection Out
@version 1.72
@author Claudiohbsantos
@link http://claudiohbsantos.com
@date 2017 06 13
@about
  # CS_Set Time Selection Out
  Set time selection out via time input
@changelog
  - Updated Library loading. Shouldn't affect operation in any way.
@provides
  ../Libraries/TimecodeInput_Module.lua > ../Libraries/Set Time Selection Out/TimecodeInput_Module.lua
  ../Libraries/CS_Library.lua > ../Libraries/Set Time Selection Out/CS_Library.lua
--]]

function get_script_path()
  local info = debug.getinfo(1,'S');
  local script_path = info.source:match[[^@?(.*[\/])[^\/]-$]]
  return script_path
end

function setTimeSelectionOut(inputInSeconds)

    if timeSelIn > inputInSeconds then
      timeSelIn = inputInSeconds
    end

      reaper.GetSet_LoopTimeRange2(0,true,true,timeSelIn,inputInSeconds,false)
end

function onSuccessfulInput(inputInSeconds)
  if inputInSeconds then
  	setTimeSelectionOut(inputInSeconds)
  end
end

function prequire(...)
    local status, lib = pcall(require, ...)
    if(status) then return lib end
    return nil
end

local script_path = get_script_path()
local libraryPath = string.match(script_path,"(.*\\).*\\$").."Libraries\\"
package.path = package.path .. ";" .. libraryPath .. "?.lua;".. libraryPath .."Go To Time\\?.lua"

requireStatus = prequire("TimecodeInput_Module")

if requireStatus then
  
  initGUI(130,"Set Time Sel Out")

  timeSelIn,timeSelOut = reaper.GetSet_LoopTimeRange2(0,false,true,0,0,false)

  defaulTimeInSeconds = timeSelOut
  runTimecodeInputBox()
else
  reaper.ShowMessageBox("The script is missing the TimecodeInput_Module to function. Please reinstall this script from Reapack","Error: Library Missing",0)
end
  

