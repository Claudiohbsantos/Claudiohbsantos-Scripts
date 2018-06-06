--[[
@description Select All item with same custom color as selected item
@version 1.0
@author Claudiohbsantos
@link http://claudiohbsantos.com
@date 2018 05 21
@about
  # Select All item with same custom color as selected item
@changelog
  - Initial Release
@provides
	. > CS_Select All item with same custom color as selected item/CS_Select All item with same custom color as selected item.lua
	../Libraries/CS_Library.lua > CS_Select All item with same custom color as selected item/CS_Library.lua  
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

local function main()
	if reaper.CountSelectedMediaItems(0) ~= 1 then reaper.ShowMessageBox("Please select a single item for reference","ERROR",0) ; return end
	local refItem = reaper.GetSelectedMediaItem(0,0)
	local refColor = reaper.GetMediaItemInfo_Value(refItem,"I_CUSTOMCOLOR")
	-- cs.msg(refColor)

	reaper.SelectAllMediaItems(0,false)
	for i=0,reaper.CountMediaItems(0) - 1 do
		local item = reaper.GetMediaItem(0,i)
		if reaper.GetMediaItemInfo_Value(item,"I_CUSTOMCOLOR") == refColor then
			reaper.SetMediaItemSelected(item,true)
		end	
	end

end

---------------------------------------------------------------
local reaper = reaper

reaper.PreventUIRefresh(1)
reaper.Undo_BeginBlock2(0)

-- if not cs.notRunningOnWindows() then
	main()
-- end

reaper.Undo_EndBlock2(0,"Select All item with same custom color as selected item",1)
reaper.PreventUIRefresh(-1)
reaper.UpdateArrange()