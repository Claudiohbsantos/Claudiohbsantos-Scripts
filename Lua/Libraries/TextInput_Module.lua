-- @version 1.0
-- @author mpl
-- @changelog
--   + init release
-- @description Search tracks
-- @website http://forum.cockos.com/member.php?u=70694

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
          (char >= 65 -- a
          and char <= 90) --z
          or (char >= 97 -- a
          and char <= 122) --z
          or ( char >= 212 -- A
          and char <= 223) --Z
          or ( char >= 48 -- 0
          and char <= 57) --Z
          or char == 95 -- _
          or char == 44 -- ,
          or char == 32 -- (space)
          or char == 45 -- (-)
          or char == 92 -- \
          or char == 47 -- / 
          or char == 46 --.
          or char == 58 -- :
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

--------------------------------------------------------------------------------------- 

function runTextInputBox()
  char  = gfx.getchar()
  textbox_t.drawCursor = true
  
  TextBox(char) -- perform typing

  --  draw back
    gfx.set(  1,1,1,  0.2,  0) --rgb a mode
    gfx.rect(0,0,obj_mainW,obj_mainH,1) 
  --  draw frame
    gfx.set(  1,1,1,  0.1,  0) --rgb a mode
    gfx.rect(obj_offs,obj_offs,obj_mainW-obj_offs*2,gui_fontsize+obj_offs/2 ,1)
    
  -- draw text
    gfx.setfont(1, gui_fontname, gui_fontsize)
    gfx.x = obj_offs*2
    gfx.y = obj_offs
    if textbox_t.command then
      gfx.set(  1,0.6,0.6,  0.8,  0) --rgb a mode
      gfx.drawstr(textbox_t.command)
      if textbox_t.arguments and not textbox_t.hiddenArguments then
        gfx.set(  0.6,1,0.6,  0.8,  0) --rgb a mode
        gfx.drawstr(" "..textbox_t.arguments)
      end
    else
      gfx.set(  1,1,1,  0.8,  0) --rgb a mode
      gfx.drawstr(textbox_t.text) 
  end        
  -- active char

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
    reaper.defer(runTextInputBox) 
  else 
    gfx.quit()
    local userInput = textbox_t.text
    reaper.atexit(onSuccessfulInput(userInput)) 
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