--[[
@description Select all items with same number of channels
@version 1.0
@author Claudiohbsantos
@link http://claudiohbsantos.com
@date 2018 05 30
@about
  # Select all items with same number of channels
@changelog
  - Initial Release
@provides
	. > CS_Select all items with same number of channels/CS_Select all items with same number of channels.lua
	../Libraries/CS_Library.lua > CS_Select all items with same number of channels/CS_Library.lua  
--]]


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

local function getEffectiveChanNumber(item)
	local take = reaper.GetActiveTake(item)
	if not take then return end

	local source = reaper.GetMediaItemTake_Source(take)
	if not source then return end

	local nChan = reaper.GetMediaSourceNumChannels(source)
	local chanMode = reaper.GetMediaItemTakeInfo_Value(take,"I_CHANMODE") 

	if chanMode == 2 or chanMode == 3 or chanMode == 4 then
		nChan = 1
	end

	-- TODO : stereo modes

	return nChan
end

local function main()
	local item = reaper.GetSelectedMediaItem(0,0)
	if not item then return end

	local nChan = getEffectiveChanNumber(item)
	if not nChan then return end	

	reaper.SelectAllMediaItems(0,false)
	for item in cs.allItems(0) do
		if getEffectiveChanNumber(item) == nChan then
			reaper.SetMediaItemSelected(item,true)
		end
	end
end

---------------------------------------------------------------
local reaper = reaper

reaper.PreventUIRefresh(1)
-- reaper.Undo_BeginBlock2(0)

-- if not cs.notRunningOnWindows() then
	main()
-- end

-- reaper.Undo_EndBlock2(0,"Select all items with same number of channels",0)
reaper.PreventUIRefresh(-1)
reaper.UpdateArrange()