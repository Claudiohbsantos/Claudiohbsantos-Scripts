  local timeSelIn,timeSelOut = reaper.GetSet_LoopTimeRange2(0,false,true,0,0,false)
  local timeSelLen = timeSelOut - timeSelIn

function lenitem()
  local item = reaper.GetSelectedMediaItem(0,0)
  local selItemLen = reaper.GetMediaItemInfo_Value(item,"D_LENGTH")
  if timeSelIn == reaper.GetProjectTimeOffset(0, false) then
    timeSelIn = reaper.GetCursorPositionEx(0)
  end
  timeSelLen = selItemLen
  timeSelOut = timeSelIn + timeSelLen
end

function movetocursor()
  local cursor = reaper.GetCursorPositionEx(0)
  timeSelIn = cursor
  timeSelOut = timeSelIn + timeSelLen
end

function setTimeSel()
  for i,arg in pairs(rl.argumentElement) do
    if arg == "len=item" then lenitem() end
    if arg == "move=cursor" then movetocursor() end
  end

  if rl.registeredCommands.ts.start then
    timeSelIn = rl.registeredCommands.ts.start
  end

  if rl.registeredCommands.ts.out then
    timeSelOut = rl.registeredCommands.ts.out
  end

  if timeSelIn == reaper.GetProjectTimeOffset(0, false) then
    timeSelIn = reaper.GetCursorPositionEx(0)
  end

  if timeSelOut == reaper.GetProjectTimeOffset(0, false) then 
    timeSelOut = timeSelIn
  end

  if timeSelIn > timeSelOut then
    timeSelIn = timeSelOut
  end

  if rl.registeredCommands.ts.len then 
    timeSelLen = rl.registeredCommands.ts.len
    timeSelOut = timeSelIn + timeSelLen
  end
    

  reaper.GetSet_LoopTimeRange2(0,true,true,timeSelIn,timeSelOut,false)

end

function getTimeSelectionIn()
  local timeSelIn = reaper.GetSet_LoopTimeRange2(0,false,true,0,0,false)
  rl.timeInput(timeSelIn)
end

function getTimeSelectionOut()
  local _,timeSelOut = reaper.GetSet_LoopTimeRange2(0,false,true,0,0,false)
  rl.timeInput(timeSelOut)
end

function getTimeSelectionLen()
  local timeSelIn,timeSelOut = reaper.GetSet_LoopTimeRange2(0,false,true,0,0,false)
  local timeSelLen = timeSelOut - timeSelIn
  rl.timeInput(timeSelLen)
end

rl.registeredCommands.ts = {main = setTimeSel, waitForEnter = true,switches = {start = getTimeSelectionIn, out = getTimeSelectionOut,len = getTimeSelectionLen} ,description = "Set Time Selection Values"}
