--[[
@description CS_Library
@version 1.0
@author Claudiohbsantos
@link http://claudiohbsantos.com
@date 2017 06 13
@about
  # General Library
  Resource Lbrary for my script development
@changelog
  - Removed From Listing
@noindex
--]]

cs = {}

function cs.msg(s) reaper.ShowConsoleMsg(tostring(s)..'\n') end

function cs.get_script_path()
	local info = debug.getinfo(1,'S');
	local script_path = info.source:match[[^@?(.*[\/])[^\/]-$]]
	return script_path
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


-------------------------------- ITERATORS

function cs.allTracks(proj)
end
function cs.allItems(track,proj)
end
function cs.allTakes(item,track,proj)
end
function cs.allEnvelopes(track,take,proj)
end
function cs.selectedTracks()
end
function cs.selectedItems()
end


-------------------------------- GETTERS

function cs.getMouseInfo()
end
function cs.getTimeSelInfo()
end
function cs.getEditCurInfo()
end
