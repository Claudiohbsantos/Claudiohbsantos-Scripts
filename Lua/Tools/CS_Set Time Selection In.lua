--[[
@description CS_Set Time Selection In
@version 1.4
@author Claudiohbsantos
@link http://claudiohbsantos.com
@date 2017 06 13
@about
  # CS_Set Time Selection In
  Set Time Selection In point via time input
@changelog
  - Fixed plus and minus mode when timeline doesnt start at 0
@provides
  ../Libraries/TimecodeInput_Module.lua > ../Libraries/Set Time Selection In/TimecodeInput_Module.lua  
--]]

function get_script_path()
  local info = debug.getinfo(1,'S');
  local script_path = info.source:match[[^@?(.*[\/])[^\/]-$]]
  return script_path
end

function setTimeSelectionIn(inputInSeconds)

    if timeSelOut == reaper.GetProjectTimeOffset(0, false) then 
      timeSelOut = inputInSeconds
    end

    if inputInSeconds > timeSelOut then
      inputInSeconds = timeSelOut
    end

      reaper.GetSet_LoopTimeRange2(0,true,true,inputInSeconds,timeSelOut,false)
end

function onSuccessfulInput(inputInSeconds)
  if inputInSeconds then
    setTimeSelectionIn(inputInSeconds)
  end
end

function prequire(...)
    local status, lib = pcall(require, ...)
    if(status) then return lib end
    --Library failed to load, so perhaps return `nil` or something?
    return nil
end

local script_path = get_script_path()
local libraryPath = string.match(script_path,"(.*\\).*\\$").."Libraries\\Set Time Selection In\\"
package.path = package.path .. ";" .. libraryPath .. "?.lua"

local requireStatus = prequire("TimecodeInput_Module")

if requireStatus then
  
  initGUI(130,"Set Time Sel In")

  timeSelIn,timeSelOut = reaper.GetSet_LoopTimeRange2(0,false,true,0,0,false)

  defaulTimeInSeconds = timeSelIn
  runTimecodeInputBox()
else
  reaper.ShowMessageBox("The script is missing the TimecodeInput_Module to function. Please reinstall this script from Reapack","Error: Library Missing",0)
end
  

