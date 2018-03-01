--[[
@noindex
]]--

rl.variables = {}
rl.variables.native = {}
rl.variables.nativeDescriptions = {}
local var = rl.variables.native
local varDes = rl.variables.nativeDescriptions

-- Playhead
var.playpos = reaper.GetPlayPosition2()
varDes.playpos = "Play position in seconds when Realauncher opened"

-- Math
math.randomseed(os.time())
var.rdm =  math.random()