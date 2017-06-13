--[[
@description CS_Set Time Selection Out
@version 1.1
@author Claudiohbsantos
@link http://claudiohbsantos.com
@date 2017 06 13
@about
  # CS_Set Time Selection Out
  Set time selection out via time input
@changelog
  - initial release
@provides
  ../Libraries/TimecodeInput_Module.lua > ../Libraries/TimecodeInput_Module.lua  
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

local script_path = get_script_path()
local libraryPath = string.match(script_path,"(.*\\).*\\$").."Libraries\\"
package.path = package.path .. ";" .. libraryPath .. "?.lua"

require "TimecodeInput_Module"
  
initGUI(130,"Set Time Sel Out")

timeSelIn,timeSelOut = reaper.GetSet_LoopTimeRange2(0,false,true,0,0,false)

defaulTimeInSeconds = timeSelOut
runTimecodeInputBox()
