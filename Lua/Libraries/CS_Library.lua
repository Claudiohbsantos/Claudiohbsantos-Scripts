--[[
@description CS_Library
@version 1.0
@author Claudiohbsantos
@link http://claudiohbsantos.com
@date 2017 06 13
@about
  # General Library
  Resource Library for my script development
@changelog
  - Removed From Listing
@noindex
--]]

cs = {}

function cs.doOnce(foo,...)
	local function newExecutedFunctionsTable(foo)
		local done = {}
		return function (foo) 
			for i,f in pairs(done) do
				if f == foo then return true end
			end
			table.insert(done,foo) 
			return false 
		end
	end 

	alreadyDone = alreadyDone or newExecutedFunctionsTable(foo)

	if not alreadyDone(foo) then
		return foo(table.unpack({...}))
	end
end


function cs.msg(...)
	local indent = 0

	local function printTable(table,tableName)
		if tableName then reaper.ShowConsoleMsg(string.rep("    ",indent)..tostring(tableName)..": \n") end
		indent = indent + 1
		for key,tableValue in pairs(table) do
			if type(tableValue) == "table" then
				printTable(tableValue,key)
			else
				reaper.ShowConsoleMsg(string.rep("    ",indent)..tostring(key).." = "..tostring(tableValue).."\n")
			end
		end
		indent = indent - 1
	end

	printTable({...})
end

function cs.get_script_path()
	local info = debug.getinfo(1,'S');
	local script_path = info.source:match[[^@?(.*[\/])[^\/]-$]]
	return script_path
end 

function cs.prequire(...)
    local status, lib = pcall(require, ...)
    if(status) then return lib end
    --Library failed to load, so perhaps return `nil` or something?
    return nil
end

function cs.readProjFileToTable(projFile)
	local f = assert(io.open(projFile,"r"))
	local projectChunks = {}
	local BUFSIZE = 2^13     -- 8K
	while true do
		local projectChunk, rest = f:read(BUFSIZE, "*line")
		if not projectChunk then break end
		if rest then projectChunk = projectChunk .. rest .. '\n' end  
		table.insert(projectChunks,projectChunk)
	end
	f:close()
	return projectChunks
end

function cs.getParameterFromProjectChunks(param,projectChunks)
	local projectChunks = cs.readProjFileToTable(projFile)

	for i,chunk in ipairs(projectChunks) do
		for line in string.gmatch(chunk,"([^\r\n]*)[\r\n]") do
			local value = string.match(line,param.." (.*)")
			if value then return value end
		end
	end
end

function cs.dbToItemVolume(volume)
	return 10^(volume/20)
end

function cs.itemVolumeToDB(itemVolume)
	return 20*math.log(itemVolume,10)
end

function cs.rgbToColor(r,g,b)
	return reaper.ColorToNative(r,g,b)|0x1000000
end

function removePositionsFromNumberedTable(origTable,tableOfIndexesToRemove)
	-- receives an ordered list which will have elements removed from and an ordered list containing the indexes to be removed from the table.
	for i,indexToRemove in ipairs(tableOfIndexesToRemove) do
		table.remove(origTable,indexToRemove-(i-1))
	end
	return origTable
end
--------------------------------

function cs.saveOriginalState()
	local originalState = {}
	originalState.arrangeStart,originalState.arrangeEnd = reaper.BR_GetArrangeView(0)
	originalState.editCur = reaper.GetCursorPositionEx(0)
	originalState.timeSelStart,originalState.timeSelEnd = reaper.GetSet_LoopTimeRange2(0,false,true,0,0,false)

	originalState.selTracks = {}
	for i=1,reaper.CountSelectedTracks2(0,true),1 do
		originalState.selTracks[#originalState.selTracks+1] = reaper.GetSelectedTrack2(0,i-1,true)
	end

	originalState.selItems = {}
	for i=1, reaper.CountSelectedMediaItems(0),1 do
		originalState.selItems[i] = reaper.GetSelectedMediaItem(0,i-1)
	end

	originalState.lockWasEnabled = reaper.GetToggleCommandStateEx(0,1135) -- toggle lock
	reaper.Main_OnCommand(40570,0) -- disable locking

	originalState.autoFadeWasEnabled = reaper.GetToggleCommandStateEx(0,40041) -- if auto-crossfade is enabled
	reaper.Main_OnCommand(reaper.NamedCommandLookup("_SWS_XFDOFF"),0) -- turn off auto-crssfade

	return originalState
end

function cs.restoreOriginalState(originalState)
	reaper.SetEditCurPos2(0,originalState.editCur,false,false)

	reaper.GetSet_LoopTimeRange2(0,true,true,originalState.timeSelStart,originalState.timeSelEnd,false)

	reaper.Main_OnCommand(40297,0) -- unselect all tracks
	for i=1, #originalState.selTracks,1 do
		reaper.SetTrackSelected(originalState.selTracks[i],true)
	end

	reaper.SelectAllMediaItems(0,false)
	for i=1,#originalState.selItems,1 do
		reaper.SetMediaItemSelected(originalState.selItems[i],true)
	end

	if originalState.lockWasEnabled == 1 then reaper.Main_OnCommand(40569,0) end -- set locking
	if originalState.autoFadeWasEnabled == 1 then reaper.Main_OnCommand(reaper.NamedCommandLookup("_SWS_XFDON"),0) end-- toggle auto-crossfade
	reaper.BR_SetArrangeView(0,originalState.arrangeStart,originalState.arrangeEnd)
end


-------------------------------- ITERATORS

function cs.allTracks(proj)
	local i = -1
	return function () i = i+1 ;return reaper.GetTrack(proj,i) end
end

function cs.allItemsInTrack(track)
	local i = -1
	return function () i=i+1; return reaper.GetTrackMediaItem(track,i) end
end
function cs.allTakesInItem(item)
	local i= -1
	return function () i=i+1 ; return reaper.GetTake(item,i) end
end
function cs.allEnvelopes(track,take,proj)
end
function cs.selectedTracks()
end
function cs.selectedItems(proj)
	local i = -1
	return function () i = i+1 ; return reaper.GetSelectedMediaItem(proj,i) end
end


-------------------------------- GETTERS

function cs.getTimeSelInfo()
end
function cs.getEditCurInfo(proj)
	local editCurInfo = {}
	editCurInfo.projOffset = reaper.GetProjectTimeOffset(proj,false)
	editCurInfo.relPosition = reaper.GetCursorPositionEx(proj)
	editCurInfo.absPosition = editCurInfo.relPosition + editCurInfo.projOffset 
	editCurInfo.posString = reaper.format_timestr_pos(editCurInfo.relPosition,"",-1)
	return editCurInfo
end
function cs.getProjectInfo()
end

function cs.getMouseInfo()
end

----------------------- State
function cs.snappingEnabled()
	if reaper.GetToggleCommandStateEx(0,1157) == 0 then
		return false
	else 
		return true
	end
end

----------------------- Mouse 
function cs.initMouseCaseTables()
	local mouse = {}
	mouse.ruler = {}
	mouse.tcp = {}
	mouse.mcp = {}
	mouse.arrange = {}
	mouse.arrange.track = {}
	mouse.arrange.envelope = {}
	mouse.midi_editor = {}
	mouse.midi_editor.cc_lane = {}
	return mouse
end

function cs.executeMouseContextFunction(mouse)
	local mouseWindow,mouseContext,mouseDetails = reaper.BR_GetMouseCursorContext()  
	if mouseWindow ~= "" then
		if mouseContext ~= "" then
			if mouseDetails ~= "" then
				if mouse[mouseWindow][mouseContext][mouseDetails] then mouse[mouseWindow][mouseContext][mouseDetails][1](table.unpack(mouse[mouseWindow][mouseContext][mouseDetails],2)) return end
			else
				if mouse[mouseWindow][mouseContext] then mouse[mouseWindow][mouseContext][1](table.unpack(mouse[mouseWindow][mouseContext],2)) return end				
			end
		else
			if mouse[mouseWindow] then mouse[mouseWindow][1](table.unpack(mouse[mouseWindow],2)) return end
		end
	end
	if mouse.default then mouse.default[1](table.unpack(mouse.default,2)) end
end

function cs.calculateProximityRelativeToZoom(mousePos,refPos)
	local arrangeStart,arrangeEnd = reaper.GetSet_ArrangeView2(0,false,0,0)
	local distanceToRef = math.abs(mousePos - refPos)

	return distanceToRef/(arrangeEnd - arrangeStart)
end

local function mouseIsNearCursor(mousePos,proximity)
	local cursor = reaper.GetCursorPositionEx(0)
	
	if cs.calculateProximityRelativeToZoom(mousePos,cursor) <= proximity then
		return true
	end
end

function cs.getClosestMarker(pos)
	local totalMarkers = reaper.CountProjectMarkers(0)
	if totalMarkers > 0 then
		
		local closestMarker = {}
	
		closestMarker.retval, closestMarker.isrgn, closestMarker.pos, closestMarker.rgnend, closestMarker.name, closestMarker.markrgnindexnumber, closestMarker.color = reaper.EnumProjectMarkers3(0, 0)		

		for i=1,totalMarkers-1 do
			local marker = {}
			marker.retval, marker.isrgn, marker.pos, marker.rgnend, marker.name, marker.markrgnindexnumber, marker.color = reaper.EnumProjectMarkers3(0, i)
			if math.abs(marker.pos - pos) < math.abs(closestMarker.pos - pos) then
				closestMarker = marker
			end
		end
		return closestMarker
	end
end

local function getClosestMarkerOrRegionPos(pos)
	local totalMarkers = reaper.CountProjectMarkers(0)

	if totalMarkers > 0 then
		local markerPositions = {}

		for i=0,totalMarkers-1 do
			local marker = {}
			marker.retval, marker.isrgn, marker.pos, marker.rgnend, marker.name, marker.markrgnindexnumber, marker.color = reaper.EnumProjectMarkers3(0, i)	
			table.insert(markerPositions,marker.pos)
			if marker.isrgn then table.insert(markerPositions,marker.rgnend) end
		end

		local closestMarkerPos = markerPositions[1]
		for i=2,#markerPositions do
			if math.abs(markerPositions[i] - pos) < math.abs(closestMarkerPos - pos) then
				closestMarkerPos = markerPositions[i]
			end

		end
		return closestMarkerPos
	end
end

local function mouseIsNearMarker(mousePos,proximity)
	local marker= getClosestMarkerOrRegionPos(mousePos)

	if marker then
		if cs.calculateProximityRelativeToZoom(mousePos,marker) <= proximity then
			return marker
		end
	end
end

function cs.checkMouseSnappingPositions(proximity,mouse)
	local snapPosition = {}

	if mouseIsNearCursor(mouse.pos,proximity) then
		table.insert(snapPosition,reaper.GetCursorPositionEx(0))
	end

	local closeMarkerPos = mouseIsNearMarker(mouse.pos,proximity) 
	if closeMarkerPos then
		table.insert(snapPosition,closeMarkerPos)
	end

	if cs.snappingEnabled() and followSnapping then
		local nearestGrid = reaper.SnapToGrid(0, mouse.pos)
		table.insert(snapPosition,nearestGrid)
	end

	local closestSnap = snapPosition[1]
	for i=2,#snapPosition do
		if math.abs(snapPosition[i]-mouse.pos) < math.abs(closestSnap-mouse.pos) then
			closestSnap = snapPosition[i]
		end
	end

	return closestSnap
end