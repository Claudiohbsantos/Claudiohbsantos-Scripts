--[[
@noindex
]]--


local markdownString

local print = {}
print.h1 = function(text) gfx.set(1,0.6,0.6,0.8,0) ; gfx.drawstr(text) end
print.h2 = function(text) gfx.set(0.6,0.6,1,0.8,0) ; gfx.drawstr(text) end
print.h3 = function(text) gfx.set(1,0.8,0.6,0.8,0) ; gfx.drawstr(text) end
print.italics = function(text) end
print.bold = function(text) end
print.list = function(text) gfx.set(0.6,0.6,1,0.8,0) ; gfx.drawstr(text) end
print.inlineCode = function(text) end

local markdownPatterns = {
-- https://github.com/adam-p/markdown-here/wiki/Markdown-Cheatsheet
	h1 = "^# ([^\n]*)",
	h2 = "^## ([^\n]*)",
	h3 = "^### ([^\n]*)",
	italics = "%*([^\n]+)%*", -- missing underscore option
	bold = "%*%*([^\n]+)%*%*", -- missing underscore option
	list = "^%-([^\n]+)",
	inlineCode = "`([^\n]+)`",
}

local function parseAndPrintMarkdown(t)
-- https://github.com/mpeterv/markdown	
	for line in t:gmatch("[^\n]*\n") do
	
		for format,pattern in pairs(markdownPatterns) do
			local capture = line:match(pattern)
			if capture then
				print[format](capture)
			end
		end
		gfx.x = 0	
		local _,charH = gfx.measurechar("1")	
		gfx.y = gfx.y + charH
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
	gui_fontname = 'Calibri'
	gui_fontsize = 23      
	local gui_OS = reaper.GetOS()
	if gui_OS == "OSX32" or gui_OS == "OSX64" then gui_fontsize = gui_fontsize - 7 end
	mouse = {}
	textbox_t = {}  

	Lokasenna_WindowAtCenter (obj_mainW,obj_mainH,windowName)
end
--------------------------------------------------------------------------------------

function  openMarkdownDisplay(markdownToDisplay)
	initGUI(1000,750,"Markdown Test")
	markdownString = markdownToDisplay
	displayMarkdown(markdownString)
end
