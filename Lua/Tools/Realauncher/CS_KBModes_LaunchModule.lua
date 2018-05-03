--[[
@noindex
--]]

local function goToScreenMid()
		-- Time
	local projStart = reaper.GetProjectTimeOffset(0,false)
	local rawViewStart,rawViewEnd = reaper.GetSet_ArrangeView2(0,false,0,0)
	viewStart = rawViewStart + projStart
	viewEnd = rawViewEnd + projStart
	viewMid = (viewEnd - viewStart) /2 + viewStart
	
	reaper.SetEditCurPos2(0,viewMid,false,false)
end

rl.registeredUtils.navmode = {
	charFunction = {
					[kbInput.spacebar] = function () reaper.Main_OnCommand( reaper.NamedCommandLookup("_RS4367f57872a62cb071294962cce2e6366e1f04a0") ,0) end, -- play 

					[kbInput["e"]] = function () reaper.Main_OnCommand( 41622 ,0) end, -- zoom to selection
					[kbInput["r"]] = function () reaper.Main_OnCommand( 1011,0) end, -- zoom out horizontal
					[kbInput["t"]] = function () reaper.Main_OnCommand( 1012,0) end, -- zoom in horizontal

					[kbInput["s"]] = function () reaper.Main_OnCommand( reaper.NamedCommandLookup("_XENAKIOS_SELITEMSUNDEDCURSELTX") ,0) end, -- select item under cursor
					[kbInput["u"]] = function () goToScreenMid() end, -- move cursor to center of screen
					
					[kbInput["i"]] = function () reaper.Main_OnCommand( 40286,0) end, -- go to previous track
					[kbInput["k"]] = function () reaper.Main_OnCommand( 40285,0) end, -- go to next track
					
					
					[kbInput["j"]] = function () reaper.Main_OnCommand( 40646 ,0) end, -- move cursor left
					[kbInput["J"]] = function () reaper.Main_OnCommand( reaper.NamedCommandLookup("_a3a0192053d3634f8bb18d4bf8edebe7") ,0) end, -- move cursor left to nearest Edge
					
					[kbInput["l"]] = function () reaper.Main_OnCommand( 40647 ,0) end, -- move cursor right
					[kbInput["L"]] = function () reaper.Main_OnCommand( reaper.NamedCommandLookup("_9093dc92ec52bb46a890d39a03113a1b") ,0) end, -- move cursor right

					[kbInput["m"]] = function () reaper.Main_OnCommand( 40140 ,0) end, -- scroll left
					[kbInput[","]] = function () reaper.Main_OnCommand( reaper.NamedCommandLookup("_SWS_HSCROLL50") ,0) end, -- center cursor
					[kbInput["."]] = function () reaper.Main_OnCommand( 40141 ,0) end, -- scroll right
					
					
					},				
	description = "Navigation Mode",
}