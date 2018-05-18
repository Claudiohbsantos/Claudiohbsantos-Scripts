--[[
@noindex			
@description Make Editable Recording
@version 1.0	
@author Claudiohbsantos
@link http://claudiohbsantos.com
@date 2018 05 16
@about
  # Make Editable Recording
  Windows only
@changelog
  - Initial Release
@provides
	. > CS_Make Editable Recording/CS_Make Editable Recording.lua
	../Libraries/CS_Library.lua > CS_Make Editable Recording/CS_Library.lua  
--]]

local delayer = 0


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

local function main()
	-- local recPos = reaper.GetCursorPositionEx(0)

	if reaper.GetPlayStateEx(0) == 5 then -- if recording
		delayer = delayer + 1
		mediaPath = mediaPath or reaper.GetProjectPathEx(0,"") 
		mostRecentFile = mostRecentFile or cs.getMostRecentFileInFolder(mediaPath) 
		media = media or mediaPath..[[\]]..mostRecentFile 
		if reaper.file_exists(media) and delayer > 50 then 
			if not mediaInserted then
				-- mediaInserted = reaper.InsertMedia(media,1)
				guid = reaper.BR_GetMediaItemGUID( reaper.GetSelectedMediaItem(0,0))
			else
				if reaper.GetToggleCommandState(40579) == 0 or reaper.GetToggleCommandState(1135) == 0 then
					reaper.SetToggleCommandState(0,40579,1) 
					reaper.SetToggleCommandState(0,1135,1)
				end 

				if reaper.GetSelectedMediaItem(0,0) ~= reaper.BR_GetMediaItemByGUID(0,guid) then 
					reaper.SelectAllMediaItems(0,false)
					reaper.SetMediaItemSelected(reaper.BR_GetMediaItemByGUID(0,guid),true) 
				end
				reaper.Main_OnCommand(40612,0) -- extend time selection
			end	
		end
		reaper.defer(main)
	end
end

---------------------------------------------------------------
local reaper = reaper

reaper.PreventUIRefresh(1)
-- reaper.Undo_BeginBlock2(0)

if not cs.notRunningOnWindows() then
	-- if not recording
	reaper.Main_OnCommand(1013,0) -- record
	main()
end

-- reaper.Undo_EndBlock2(0,"Make Editable Recording",0)
reaper.PreventUIRefresh(-1)
reaper.UpdateArrange()