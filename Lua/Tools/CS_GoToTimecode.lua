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

-- get "script path"
local script_path = get_script_path()
local libraryPath = string.sub(script_path,1,-(string.find(string.reverse(script_path),"\\")))
msg(libraryPath)
-- modify "package.path"
package.path = package.path .. ";" .. libraryPath .. "?.lua"

require "TimecodeInput_Module"
  
initGUI(130,"Go To Timecode")

defaulTimeInSeconds = reaper.GetCursorPositionEx(0)
runTimecodeInputBox()
