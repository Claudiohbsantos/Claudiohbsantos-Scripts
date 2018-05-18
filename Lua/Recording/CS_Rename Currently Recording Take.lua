--[[
@description Rename Currently Recording Take
@version 1.0
@author Claudiohbsantos
@link http://claudiohbsantos.com
@date 2018 05 12
@about
  # Rename Currently Recording Take
  ! Only works on Windows
  - renames file that is currently being recorded after recording is finished. Only works with the first recording track for now. 
@changelog
  - Initial Release
@provides
	. > CS_Rename Currently Recording Take/CS_Rename Currently Recording Take.lua
	../Libraries/TextInput_Module.lua > CS_Rename Currently Recording Take/TextInput_Module.lua  
--]]

function prequire(...)
    local status, lib = pcall(require, ...)
    if(status) then return lib end
    --Library failed to load, so perhaps return `nil` or something?
    reaper.ShowMessageBox("Missing Assets. Please Uninstall and Reinstall via Reapack","ERROR",0)
    return nil
end

local function get_script_path()
		local info = debug.getinfo(1,'S');
		local script_path = info.source:match[[^@?(.*[\/])[^\/]-$]]
		return script_path
	end 

local function loadFromFolder(file)
	local scriptPath = get_script_path()
	package.path = package.path .. ";" .. scriptPath .. "?.lua"
	return prequire(file)
end

function get_script_path()
  local info = debug.getinfo(1,'S');
  local script_path = info.source:match[[^@?(.*[\/])[^\/]-$]]
  return script_path
end

function renameItemAndSource(newName)
	if newName then

		local selItem = reaper.GetSelectedMediaItem(0,0)
		if selItem then
			local activeTake = reaper.GetActiveTake(selItem)
			local source = reaper.GetMediaItemTake_Source(activeTake)

			local sourceFilename = ""
			sourceFilename = reaper.GetMediaSourceFileName(source,sourceFilename)

			local extension = string.sub(sourceFilename,-4)
			local newFileName = newName..extension

			reaper.Main_OnCommand(40440,0) -- set selected media offline

			reaper.GetSetMediaItemTakeInfo_String(activeTake,"P_NAME",newFileName,true)
			local cmd = [[ren "]]..sourceFilename..[[" "]]..newFileName..[["]]
			os.execute(cmd)

			local sourceDirectory = string.match(sourceFilename,"(.+\\)[^\\].+$")
			local newSourceFilename = sourceDirectory..newFileName
			reaper.BR_SetTakeSourceFromFile2(activeTake,newSourceFilename,false,true)

			reaper.Main_OnCommand(40441,0) -- rebuild peaks for selected items

		end
	end
end

function onSuccessfulInput(userInput)
  if userInput and userInput ~= "" then
  	retrievedUserInput = userInput
  end
end

function main()
	
	if reaper.GetPlayStateEx(0) & 4 == 4 then -- recording
		wasRecording = true
		reaper.defer(main)
		if not runYet then 
			initGUI(400,"Rename Take and Source")
			runTextInputBox()
			runYet = true
		end
	else
		if wasRecording then
			if retrievedUserInput then
				renameItemAndSource(retrievedUserInput)
			else
				reaper.defer(main)
			end
		end
	end

end

---------------------------------------------------------------
local reaper = reaper
local cs = loadFromFolder("CS_Library")
loadFromFolder("TextInput_Module")
reaper.PreventUIRefresh(1)
reaper.Undo_BeginBlock2(0)

-------------

if not cs.notRunningOnWindows() then
	main()
end

reaper.Undo_EndBlock2(0,"Rename Currently Recording Take",-1)
reaper.PreventUIRefresh(-1)