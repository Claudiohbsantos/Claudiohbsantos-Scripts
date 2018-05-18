--[[
@noindex
@description Turn Track Volume envelope into OSC controller
@version 1.0
@author Claudiohbsantos
@link http://claudiohbsantos.com
@date 2018 05 14
@about
  # Turn Track Volume envelope into OSC controller
@changelog
  - Initial Release
@provides
	. > CS_Turn Track Volume envelope into OSC controller/CS_Turn Track Volume envelope into OSC controller.lua
	../Libraries/CS_Library.lua > CS_Turn Track Volume envelope into OSC controller/CS_Library.lua  
--]]

local prevValue

local function get_script_path()
		local info = debug.getinfo(1,'S');
		local script_path = info.source:match[[^@?(.*[\/])[^\/]-$]]
		return script_path
	end 

function prequire(...)
    local status, lib = pcall(require, ...)
    if(status) then return lib end
    --Library failed to load, so perhaps return `nil` or something?
    reaper.ShowMessageBox("Missing Assets. Please Uninstall and Reinstall via Reapack","ERROR",0)
    return nil
end

local function loadFromFolder(file)
	local scriptPath = get_script_path()
	package.path = package.path .. ";" .. scriptPath .. "?.lua"
	return prequire(file)
end

local cs = loadFromFolder("CS_Library")

---------------------------------------------------------------

local function init()
	if reaper.CountSelectedTracks2(0,false) ~= 1 then reaper.ShowMessageBox("You must select exactly 1 track","Errr",0) ; return end
	local tr = {}
	tr.track = reaper.GetSelectedTrack2(0,0,false)
	-- tr.env = reaper.GetTrackEnvelopeByName(tr.track,"Volume")
	tr.env = reaper.GetTrackEnvelopeByName(tr.track,"Width")
	if not tr.env then 
		-- reaper.Main_OnCommand(40406,0) -- show track volume envelope
		reaper.Main_OnCommand(41870,0) -- show track width envelope
		-- tr.env = reaper.GetTrackEnvelopeByName(tr.track,"Volume")
		tr.env = reaper.GetTrackEnvelopeByName(tr.track,"Width")
	end 
	tr.brenv = reaper.BR_EnvAlloc(tr.env,true) 
	local _,chunk = reaper.GetEnvelopeStateChunk(tr.env,"",false)
	reaper.SetEnvelopeStateChunk(tr.env,string.gsub(chunk,"(VIS %d )1( %d)","%10%2"),false) 
	return tr
end

local function main()
	local retval
	local globalAutoMode = reaper.GetGlobalAutomationOverride()
	-- -1 is no, 0 is trim/read, 1 is read, 2 is touch, 4 is latch, 5 is latch preview, 3 is write, 6 is bypass
	tr.autoMode = reaper.GetTrackAutomationMode(tr.track)

	local appliedAutoMode
	if globalAutoMode == -1 then appliedAutoMode = tr.autoMode else appliedAutoMode = globalAutoMode end

	-- local volValue
	-- if appliedAutoMode ~= 0 then
	-- 	_, volValue = reaper.GetTrackUIVolPan(tr.track)
	-- else
	-- 	local _, fader = reaper.GetTrackUIVolPan(tr.track)
	-- 	local envVal = reaper.BR_EnvValueAtPos(tr.brenv, reaper.GetPlayPosition2())
	-- 	cs.msg(fader,envVal)
	-- 	volValue = 	envVal - (fader - 1)
	-- end

	local _,volValue = reaper.GetTrackUIVolPan(tr.track)

	volValue = reaper.BR_EnvValueAtPos(tr.brenv, reaper.GetPlayPosition2())
	volValue = (volValue+1)/2
	-- local scale = reaper.GetEnvelopeScalingMode(tr.env)

	-- volValue = reaper.ScaleFromEnvelopeMode(scale,volValue)
	-- volValue = reaper.ScaleToEnvelopeMode(0,volValue)
	-- volValue = cs.itemVolumeToDB(volValue) 
	-- volValue = reaper.Envelope_FormatValue(tr.env,volValue)
	-- volValue = reaper.SLIDER2DB(volValue) 
	-- volValue = reaper.DB2SLIDER(volValue)/1000

	if volValue ~= prevValue then
		
		cs.msg(volValue)
		-- volValue =  volValue^2*(-1/12) + volValue*7/12
		-- cs.msg(volValue)
		reaper.OscLocalMessageToHost("f/trackVolToOSC", volValue)
		prevValue = volValue
	end
	reaper.defer(main)
end

---------------------------------------------------------------
local reaper = reaper

reaper.PreventUIRefresh(1)
reaper.Undo_BeginBlock2(0)

-- if not cs.notRunningOnWindows() then
	tr = init()
	main()
-- end

reaper.Undo_EndBlock2(0,"Turn Track Volume envelope into OSC controller",0)
reaper.PreventUIRefresh(-1)
reaper.UpdateArrange()		