--[[
@noindex
]]--
function createMarker()
	local marker = {}

	marker.name = table.concat(rl.text.arguments," ") or ""
	
	marker.isRgn = switches.r
	if switches.r then 
		marker.pos,marker.rgnEnd = reaper.GetSet_LoopTimeRange2(0,false,false,0,0,false) 
	else 
		marker.pos = reaper.GetCursorPositionEx(0)
		marker.rgnEnd = 0
	end
	
	marker.index = switches.i
	marker.color = 0
	reaper.AddProjectMarker2(0,marker.isRgn,marker.pos,marker.rgnEnd,marker.name,marker.index,marker.color)
end

rl.registeredCommands.marker = {
	onEnter = createMarker,
	description = "Create Marker at Edit Cursor Position",
	switches = {
		i = -1,
		r = false,
		}							
	}