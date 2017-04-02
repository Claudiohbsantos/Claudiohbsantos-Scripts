--[[
@description CS_SoloXOR_Across_Projects
@version 1.0
@author Claudiohbsantos
@link http://claudiohbsantos.com
@date 2017 04 02
@about
  # CS_SoloXOR_Across_Projects
  This script performs a simple Solo X Or on the selected track. If any other tracks are soloed, they will be unsoloed so the selected track(s) is the only one playing. If background projects are playing they will also be muted. If more than one track is selected and they have diferent solo states, all selected tracks will follow the First track change.
  [SoloXORExample](https://github.com/Claudiohbsantos/Claudiohbsantos-Scripts/blob/master/Licecaps/CS_SoloXOR_Across_Projects.gif)
@changelog
  - Initial Release
--]]

function msg(msg)
	reaper.ShowConsoleMsg(msg.."\n")
end

function msgBox(msg)
	reaper.ShowMessageBox(msg,"Title",0)
end

reaper.Undo_BeginBlock()
reaper.PreventUIRefresh(1)

local track = reaper.GetSelectedTrack2(0,0,false)

local runBackgroundProjs = reaper.GetToggleCommandStateEx(0,40871) -- run background projects
local retval,stateFlags = reaper.GetTrackState(track)

if retval ~= 0 then
	if stateFlags & 16 == 16 then -- if soloed
		reaper.Main_OnCommand(40340,0) -- unsolo all tracks
		local _,shouldReenableRunBGProjs = reaper.GetProjExtState(0,"CS_SoloXOR","Run_Background_Projs_was_Active")
		if shouldReenableRunBGProjs == "true" then 
			reaper.Main_OnCommand(40871,0) -- toggle run background command state
		end
		reaper.SetProjExtState(0,"CS_SoloXOR","Run_Background_Projs_was_Active","false")	
	else
		reaper.Main_OnCommand(40340,0) -- unsolo all tracks
		reaper.Main_OnCommand(40728,0) -- solo tracks
		if runBackgroundProjs == 1 then 
			reaper.Main_OnCommand(40871,0) -- toggle run background command state
			reaper.SetProjExtState(0,"CS_SoloXOR","Run_Background_Projs_was_Active","true") 
		end
	end
end

reaper.PreventUIRefresh(-1)
reaper.Undo_EndBlock("CS_SoloXOR_Across_Projects", 0)
reaper.CSurf_FlushUndo(true)