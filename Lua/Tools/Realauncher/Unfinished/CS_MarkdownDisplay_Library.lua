--[[
@noindex
]]--

local margin = 10
local MDDisplayH = 750
local MDDisplayW = 1000

local markdownString


local function wrapTextToFitDisplay(line)
	if gfx.measurestr(line) >= gfx.w - 2*margin then
		local wrappedLine = ""	
		for word in line:gmatch("%g+%s*") do	
			if gfx.measurestr(wrappedLine..word) >= gfx.w - 2*margin then
				wrappedLine = wrappedLine.."\n"
			end
			wrappedLine = wrappedLine..word
		end
		return wrappedLine
	else
		return line
	end
end

local print = {}
print.h1 = function(text) gfx.setfont(1,gui_fontname, 35,98) ; text = wrapTextToFitDisplay(text) ; gfx.set(1,0.6,0.6,0.8,0) ; gfx.drawstr(text) end
print.h2 = function(text) gfx.setfont(1,gui_fontname, 30) ; text = wrapTextToFitDisplay(text) ; gfx.set(0.6,0.6,1,0.8,0) ; gfx.drawstr(text) end
print.h3 = function(text) gfx.setfont(1,gui_fontname, 25) ; text = wrapTextToFitDisplay(text) ; gfx.set(1,0.8,0.6,0.8,0) ; gfx.drawstr(text) end
-- print.italics = function(text) end
-- print.bold = function(text) gfx.setfont(1,gui_fontname, 20,98) ; gfx.set(0.6,0.6,0.6,0.8,0) ; gfx.drawstr(text) end
-- print.list = function(text) gfx.set(0.6,0.6,1,0.8,0) ; gfx.drawstr(text) end
-- print.inlineCode = function(text) end
print.default = function(text) gfx.setfont(1,gui_fontname, 20) ; text = wrapTextToFitDisplay(text) ; gfx.set(0.6,0.6,0.6,0.8,0) ; gfx.drawstr(text) end

local markdownPatterns = {
-- https://github.com/adam-p/markdown-here/wiki/Markdown-Cheatsheet
	h1 = "^# ([^\n]*)",
	h2 = "^## ([^\n]*)",
	h3 = "^### ([^\n]*)",
	italics = "%*([^\n]+)%*", -- missing underscore option
	bold = "(.*)%*%*([^\n]+)%*%*(.*)", -- missing underscore option
	list = "^%-([^\n]+)",
	inlineCode = "`([^\n]+)`",
}

local function drawVertScrollBar()
	-- draw bar bg	
	local barW = 20
	gfx.set(  0.15,0.15,0.15,  1,  0)
	gfx.rect(gfx.w - barW,0,barW,gfx.h,1)
	-- calculate viewable percetage
local totalHeight = 3000
	local scrollH = gfx.h/(totalHeight/gfx.h)

	-- draw scroll bar
local scrollPos = 0	
	gfx.set(  0.3,0.3,0.3,  1,  0)
	gfx.rect(gfx.w - barW,scrollPos,barW,scrollH,1)
end

local function parseAndPrintMarkdown(t)
-- https://github.com/mpeterv/markdown	

	gfx.setfont(1,"Courier New", 20)

	for line in t:gmatch("[^\r\n]*") do

		drawVertScrollBar()
		gfx.x = margin
		local _,charH = gfx.measurechar("1")	
		gfx.y = gfx.y + charH

		if gfx.y > gfx.h then break end

		if line:match(markdownPatterns.h1) then print.h1(line:match(markdownPatterns.h1)) ; goto NEXT end 
		if line:match(markdownPatterns.h2) then print.h2(line:match(markdownPatterns.h2)) ; goto NEXT end 
		if line:match(markdownPatterns.h3) then print.h3(line:match(markdownPatterns.h3)) ; goto NEXT end 
		print.default(line)

	::NEXT::
	end
end

local function setBackground()
	gfx.set(  1,1,1,  0.2,  0) --rgb a mode
	gfx.rect(0,0,gfx.w,gfx.h,1) 
end

local function displayMarkdown()
	local char  = gfx.getchar()

	setBackground()
	gfx.x = 0
	gfx.y = 0

	parseAndPrintMarkdown(markdownString)

	gfx.update()
	last_char = char
	if char ~= -1 and char ~= 27 and char ~= 13  then 
		reaper.defer(displayMarkdown) 
	else 
		returnToMainLoop("")
	end
end 

---------------------------------------------------------------------------------------

local function Lokasenna_WindowAtCenter (w, h,windowName)
	-- thanks to Lokasenna 
	-- http://forum.cockos.com/showpost.php?p=1689028&postcount=15    
	local l, t, r, b = 0, 0, w, h    
	local __, __, screen_w, screen_h = reaper.my_getViewport(l, t, r, b, l, t, r, b, 1)    
	local x, y = (screen_w - w) / 2, (screen_h - h) / 2    
	gfx.init(windowName, w, h, 0, x, y)  
end


local function initGUI(boxWidth,boxHeight,windowName)
	obj_mainW = boxWidth
	obj_mainH = boxHeight
	obj_offs = 10

	gui_aa = 1
	gui_fontname = 'Consolas'
	gui_fontsize = 21      
	local gui_OS = reaper.GetOS()
	if gui_OS == "OSX32" or gui_OS == "OSX64" then gui_fontsize = gui_fontsize - 7 end
	mouse = {}
	textbox_t = {}  

	Lokasenna_WindowAtCenter (obj_mainW,obj_mainH,windowName)
end
--------------------------------------------------------------------------------------

function  openMarkdownDisplay(markdownToDisplay)
	initGUI(MDDisplayW,MDDisplayH,"Markdown Test")
	markdownString = markdownToDisplay
	displayMarkdown(markdownString)
end
