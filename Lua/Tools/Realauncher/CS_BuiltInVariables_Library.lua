--[[
@noindex
]]--

rl.variables = rl.variables or {}
rl.variables.native = {}
rl.variables.nativeDescriptions = {}
local var = rl.variables.native
local varDes = rl.variables.nativeDescriptions

--[[ Conventions
Time: All time values are absolute (exactly what they show on the timeline, regardless of proj offset)
--]]

-- Time
var.projStart = reaper.GetProjectTimeOffset(0,false)
varDes.projStart = "Beginning of Timeline"
var.projEnd = reaper.GetProjectLength(0) + var.projStart
varDes.projEnd = "End of Timeline"

local rawViewStart,rawViewEnd = reaper.GetSet_ArrangeView2(0,false,0,0)
var.viewStart = rawViewStart + var.projStart
varDes.viewStart = "Time At beginning of arrange view"
var.viewEnd = rawViewEnd + var.projStart
varDes.viewEnd = "Time At end of arrange view"
var.viewMid = (var.viewEnd - var.viewStart) /2 + var.viewStart
varDes.viewMid = "Time at middle of arrange view"

local rawTSStart,rawTSEnd = reaper.GetSet_LoopTimeRange2(0,false,false,0,0,false)
var.tsStart = rawTSStart + var.projStart
varDes.tsStart = "Time at start of time selection"
var.tsEnd = rawTSEnd + var.projStart
varDes.tsEnd = "Time at end of time selection"
var.tsMid = (var.tsEnd - var.tsStart) /2 + var.tsStart
varDes.tsMid = "Time at middle of time selection"

local rawlpStart,rawlpEnd = reaper.GetSet_LoopTimeRange2(0,false,true,0,0,false)
var.lpStart = rawlpStart + var.projStart
varDes.lpStart = "Time at start of loop points"
var.lpEnd = rawlpEnd + var.projStart
varDes.lpEnd = "Time at end of loop points"
var.lpMid = (var.lpEnd - var.lpStart) /2 + var.lpStart
varDes.lpMid = "Time at middle of time selection"

var.playpos = reaper.GetPlayPosition2()
varDes.playpos = "Play position in seconds when Realauncher opened"

var.curPos = reaper.GetCursorPositionEx(0) + var.projStart
varDes.curPos = "Cursor Position"