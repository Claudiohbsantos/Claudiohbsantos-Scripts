--[[
@description Create Markers at Selected Items Snap Offsets
@version 1.0
@author Claudiohbsantos
@link http://claudiohbsantos.com
@date 2018 04 11
@about
  # CS_Create Markers at Snap Offsets
  
@changelog
  - 
--]]

function msg(msg)
	reaper.ShowConsoleMsg(msg.."\n")
end

function msgBox(msg)
	reaper.ShowMessageBox(msg,"Title",0)
end

-------------------------
local cs = {}

function cs.selectedItems(proj)
	local i = -1
	return function () i = i+1 ; return reaper.GetSelectedMediaItem(proj,i) end
end

local function getSnapOffsetPos(item)
	if not item then return end
	local itemPos = reaper.GetMediaItemInfo_Value(item,"D_POSITION")
	local snapOffset = reaper.GetMediaItemInfo_Value(item,"D_SNAPOFFSET")

	if snapOffset ~= 0 then
		return itemPos + snapOffset
	end
end

local function createMarkerZero(pos)
	local color = reaper.ColorToNative(200,150,150)|0x1000000
	reaper.AddProjectMarker2(0,0,pos,0, "", 0, color)
end

--------------------------

reaper.Undo_BeginBlock()
reaper.PreventUIRefresh(1)

for item in cs.selectedItems(proj) do
	local snapOffset = getSnapOffsetPos(item)	
	if snapOffset then
		createMarkerZero(snapOffset)
	end
end

reaper.PreventUIRefresh(-1)
reaper.Undo_EndBlock("Create Markers at Snap Offsets", 0)
