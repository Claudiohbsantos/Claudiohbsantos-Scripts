--[[
@description TimecodeInput_Module
@version 1.0
@author Claudiohbsantos
@link http://claudiohbsantos.com
@date 2017 06 13
@about
  # TimecodeInput_Module
  Timecode Input Module for other scripts
@changelog
  - initial release
@metapackage  
--]]
---------------------------------------------------------------------------------------

local leftArrow = 1818584692
local upArrow = 30064
local rightArrow = 1919379572
local downArrow = 1685026670
local deleteKey = 6579564
local backspace = 8
local minus = 45
local plus = 43
local spacebar = 32

local minusMode = false
local plusMode = false
local resetAutoCompletedTimecode = false

local persistentDefaultTimeInSeconds = nil
---------------------------------------------------------------------------------------

function msg(s) reaper.ShowConsoleMsg(tostring(s)..'\n') end

---------------------------------------------------------------------------------------
function TextBox(char)
if not textbox_t.active_char then textbox_t.active_char = 0 end
if not textbox_t.text        then textbox_t.text = '' end

if  -- regular input
    (
      ( char >= 48 -- 0
      and char <= 57) -- 9
    )
    then        
      textbox_t.text = textbox_t.text:sub(0,textbox_t.active_char)..
        string.char(char)..
        textbox_t.text:sub(textbox_t.active_char+1)
      textbox_t.active_char = textbox_t.active_char + 1
  end
  
  if char == backspace then
    textbox_t.text = textbox_t.text:sub(0,textbox_t.active_char-1)..
      textbox_t.text:sub(textbox_t.active_char+1)
    textbox_t.active_char = textbox_t.active_char - 1
  end

  if char == deleteKey then
    textbox_t.text = textbox_t.text:sub(0,textbox_t.active_char)..
      textbox_t.text:sub(textbox_t.active_char+2)
    textbox_t.active_char = textbox_t.active_char
  end
        
  if char == leftArrow then
    textbox_t.active_char = textbox_t.active_char - 1
  end
  
  if char == rightArrow then
    textbox_t.active_char = textbox_t.active_char + 1
  end

  if char == minus then
    minusMode = not minusMode
    resetAutoCompletedTimecode = not resetAutoCompletedTimecode
    if plusMode then 
      plusMode = false
      resetAutoCompletedTimecode = not resetAutoCompletedTimecode
    end
  end

  if char == plus then
    plusMode = not plusMode
    resetAutoCompletedTimecode = not resetAutoCompletedTimecode
    if minusMode then 
      minusMode = false
      resetAutoCompletedTimecode = not resetAutoCompletedTimecode 
    end
  end

  if char == spacebar and not minusMode and not plusMode then
    resetAutoCompletedTimecode = not resetAutoCompletedTimecode
  end

if textbox_t.active_char < 0 then textbox_t.active_char = 0 end
if textbox_t.active_char > textbox_t.text:len()  then textbox_t.active_char = textbox_t.text:len() end
end

function drawModeSymbol(minusMode,plusMode)

  gfx.setfont(1, gui_fontname, gui_fontsize)
  gfx.x = obj_offs*1.5
  gfx.y = obj_offs + gui_fontsize/2 - gfx.texth/2  

  if minusMode then
    gfx.set(   1.0 ,0.6,0.6,  0.8,  0) -- red
    gfx.drawstr("-")
  end

  if plusMode then
    gfx.set(   0.6,0.6,1.0,  0.8,  0) -- blue
    gfx.drawstr("+")
  end
end

function drawTimeInputPreview(preview)
	gfx.setfont(1, gui_fontname, gui_fontsize)
	if textbox_t.timeArgPreview then

    gfx.x = obj_offs*1.5 + 10
    gfx.y = obj_offs + gui_fontsize/2 - gfx.texth/2

    gfx.set(  0.5,0.5,0.5,  0.5,  0) -- grey
  	gfx.drawstr(preview)

    if not minusMode and not plusMode then
  	 gfx.set(   0.6,1,0.6,  0.8,  0) -- green
    else 
      if minusMode then
        gfx.set(   1.0 ,0.6,0.6,  0.8,  0) -- red  
      else
        gfx.set(   0.6,0.6,1.0,  0.8,  0) -- blue
      end
    end

  	gfx.drawstr(textbox_t.hiddenArguments)

  	textbox_t.timeArgPreview = nil
  	textbox_t.drawCursor = false	
	end

end

--------------------------------------------------------------------------------------- 

function getInput(arguments,defaultTimeInSeconds)
	if arguments and defaulTimeInSeconds then		
		local defaultTimeString = ""
		defaultTimeString = reaper.format_timestr_pos(defaultTimeInSeconds,defaultTimeString,-1)

    local timePunctuation = {}
    for i=1,defaultTimeString:len(),1 do
      if string.match(defaultTimeString:sub(i,i),"%d") then 
        timePunctuation[i] = 0
      else
        timePunctuation[i] = defaultTimeString:sub(i,i)
      end 
    end

    local zeroTCString = ""
    for i=1,#timePunctuation,1 do
      zeroTCString = zeroTCString..timePunctuation[i]
    end
    local tempArgs = arguments
    textbox_t.hiddenArguments = ""

    local i = #timePunctuation
    while tempArgs:len() > 0 do
        if timePunctuation[i] and timePunctuation[i] ~= 0 then
          textbox_t.hiddenArguments = textbox_t.hiddenArguments..timePunctuation[i]
        else
          textbox_t.hiddenArguments = textbox_t.hiddenArguments..tempArgs:sub(tempArgs:len())
          tempArgs = tempArgs:sub(1,tempArgs:len()-1)
        end
      i = i-1
    end

    textbox_t.hiddenArguments = textbox_t.hiddenArguments:reverse()

		if defaultTimeString:len()-textbox_t.hiddenArguments:len() > 0 then
      if not resetAutoCompletedTimecode then
			 defaultTimeStringUnchangedDigits = defaultTimeString:sub(1,defaultTimeString:len()-textbox_t.hiddenArguments:len())
      else
       defaultTimeStringUnchangedDigits = zeroTCString:sub(1,defaultTimeString:len()-textbox_t.hiddenArguments:len()) 
      end 
		else
			defaultTimeStringUnchangedDigits = ""
		end

    local lenOfdefaultString
    if string.len(textbox_t.hiddenArguments) > 10 then 
      lenOfdefaultString = string.len(textbox_t.hiddenArguments) 
    else 
      lenOfdefaultString = 10 
    end

		defaultTimeString = string.sub(defaultTimeStringUnchangedDigits..textbox_t.hiddenArguments,1,lenOfdefaultString)

		textbox_t.timeArgPreview = defaultTimeStringUnchangedDigits

		local inputInSeconds = reaper.parse_timestr_pos(defaultTimeString,-1)
		if char == 13 then
      local resultingTimecodeInSeconds
      if minusMode then 
        resultingTimecodeInSeconds = defaultTimeInSeconds - inputInSeconds
      else 
        if plusMode then
          resultingTimecodeInSeconds = defaultTimeInSeconds + inputInSeconds
        else
          resultingTimecodeInSeconds = inputInSeconds
        end
      end

      return resultingTimecodeInSeconds
		end

	end	
end	

function runTimecodeInputBox()
  char  = gfx.getchar()
  textbox_t.drawCursor = true
  
  TextBox(char) -- perform typing

  inputInSeconds = getInput(textbox_t.text,defaulTimeInSeconds)

  --  draw back
    gfx.set(  1,1,1,  0.2,  0) --rgb a mode
    gfx.rect(0,0,obj_mainW,obj_mainH,1)
  --  draw frame
    gfx.set(  1,1,1,  0.1,  0) --rgb a mode
    gfx.rect(obj_offs,obj_offs,obj_mainW-obj_offs*2,gui_fontsize+obj_offs/2 ,1)

  drawModeSymbol(minusMode,plusMode)
	drawTimeInputPreview(textbox_t.timeArgPreview)

    if textbox_t.active_char ~= nil then
    	alpha  = math.abs((os.clock()%1) -0.5)
      gfx.set(  1,1,1, alpha,  0) --rgb a mode
      gfx.x = obj_offs*1.5+
              gfx.measurestr(textbox_t.text:sub(0,textbox_t.active_char)) + 2
      gfx.y = obj_offs + gui_fontsize/2 - gfx.texth/2
      if textbox_t.drawCursor then gfx.drawstr('|') end
    end     

  gfx.update()
  last_char = char
  if char ~= -1 and char ~= 27 and char ~= 13  then 
    reaper.defer(runTimecodeInputBox) 
  else 
    gfx.quit()
    reaper.atexit(onSuccessfulInput(inputInSeconds)) 
  end
  
end 

---------------------------------------------------------------------------------------

function Lokasenna_WindowAtCenter (w, h,windowName)
  -- thanks to Lokasenna 
  -- http://forum.cockos.com/showpost.php?p=1689028&postcount=15    
  local l, t, r, b = 0, 0, w, h    
  local __, __, screen_w, screen_h = reaper.my_getViewport(l, t, r, b, l, t, r, b, 1)    
  local x, y = (screen_w - w) / 2, (screen_h - h) / 2    
  gfx.init(windowName, w, h, 0, x, y)  
end


function initGUI(boxWidth,windowName)
  obj_mainW = boxWidth
  obj_mainH = 50
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