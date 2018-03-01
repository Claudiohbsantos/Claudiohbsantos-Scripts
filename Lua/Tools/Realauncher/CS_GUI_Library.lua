--[[
@noindex
]]--


printWhite = function(text) gfx.set(1,1,1,0.8,0) ; gfx.drawstr(text) end
printGrey = function(text) gfx.set(1,1,1,0.3,0) ; gfx.drawstr(text) end
printRed = function(text) gfx.set(1,0.6,0.6,0.8,0) ; gfx.drawstr(text) end
printGreen = function(text) gfx.set(0.6,1,0.6,0.8,0) ; gfx.drawstr(text) end
printBlue = function(text) gfx.set(0.6,0.6,1,0.8,0) ; gfx.drawstr(text) end
printOrange = function(text) gfx.set(1,0.8,0.6,0.8,0) ; gfx.drawstr(text) end

local function drawWindow(w,h,offset)
    gfx.set(  1,1,1,  0.2,  0) --rgb a mode
    gfx.rect(0,0,w,h,1)	
    gfx.set(  1,1,1,  0.1,  0) --rgb a mode
    gfx.rect(offset,offset,w-offset*2,gui_fontsize+offset/2 ,1)
end

local function mouseLeftMouseClick()
  if gfx.mouse_cap == 1 then prevMouseState = 1 end

  if gfx.mouse_cap == 0 and prevMouseState == 1 then
    prevMouseState = nil
    return true
  end
end

local function mouseIsHovering(area)
  if gfx.mouse_x > area.x and gfx.mouse_x < area.x + area.w and
     gfx.mouse_y > area.y and gfx.mouse_y < area.y + area.h then
     return true
  end
end

local function mouseClick(area)
  if mouseIsHovering(area) then
    if mouseLeftMouseClick() then
      return true
    end
  end
end

local function drawHelpButton(w,h,offset)
  local help
  if not rl.text.util then
    help = rl.helpFiles.default
  else
    help = rl.helpFiles[rl.text.util]
  end

  if help then
    local helpBoxSize = 20
    local marginSize = 4
    local helpBox = {
                      size = helpBoxSize,
                      margin = marginSize,
                      x = w-offset-helpBoxSize-marginSize,
                      y = offset+marginSize,
                      w = helpBoxSize,
                      h = helpBoxSize,
                      }
    
    if mouseIsHovering(helpBox) then
      gfx.set(1,1,1,0.2,0)
    else
      gfx.set(1,1,1,0.1,0)
    end

    gfx.rect(helpBox.x,helpBox.y,helpBox.w,helpBox.h)
    gfx.x = helpBox.x+(helpBoxSize-gfx.measurestr("?"))/2
    gfx.y = helpBox.y
    printGreen("?")

    if mouseClick(helpBox) then launchAltGUI(openMarkdownDisplay,help) end
  end
end

local function drawText(obj_offs)
    gfx.setfont(1, gui_fontname, gui_fontsize)
    gfx.x = obj_offs*2
    gfx.y = obj_offs+2

    if rl.text.util then 
      printRed(rl.text.util)
      local _,endOfUtil = rl.text.raw:find(rl.text.util)
      local toPrint = rl.text.raw:sub(endOfUtil+1)
      for word in toPrint:gmatch("%s*%g+") do
        if word:match("^%s+/.+") or word:match("^%s+%-%-.+") then
          printBlue(word)
        elseif word:match("^%s+$.+") then
          printOrange(word)
        else
          printGreen(word)
        end
      end
    else
      printWhite(rl.text.raw)
      if rl.currentAutocomplete then
        printGrey(rl.currentAutocomplete)
      end
    end
end

local function drawCursor(obj_offs)
	if rl.active_char ~= nil then
    	alpha  = math.abs((os.clock()%1) -0.4)
      gfx.set(  1,1,1, alpha,  0) --rgb a mode
      gfx.x = obj_offs*1.5+
              gfx.measurestr(rl.text.raw:sub(0,rl.active_char)) + 2
      gfx.y = obj_offs + gui_fontsize/2 - gfx.texth/2
      gfx.drawstr('|')
    end   
end

local function drawTip(text,obj_offs)
	gfx.setfont(1, gui_fontname, gui_fontsize)
    gfx.x = obj_offs*2
    gfx.y = obj_offs + 32
    gfx.set(1,1,1,0.3,0)
    gfx.drawstr(tostring(text))
end

function drawMainGUI()
  local obj_offs = 10
  drawWindow(rl.config.launcherWidth,rl.config.launcherHeight,obj_offs)
  drawText(obj_offs)
  drawCursor(obj_offs)
  drawHelpButton(rl.config.launcherWidth,rl.config.launcherHeight,obj_offs)

  if tcInput then drawModeSymbol(tcInput) end

  if rl.text.tipLine then drawTip(rl.text.tipLine,obj_offs) end
end

function initLauncherGUI(position)
  local function Lokasenna_WindowAtCenter(w, h,position)
    -- thanks to Lokasenna 
    -- http://forum.cockos.com/showpost.php?p=1689028&postcount=15    
    local l, t, r, b = 0, 0, w, h    
    local __, __, screen_w, screen_h = reaper.my_getViewport(l, t, r, b, l, t, r, b, 1)    
    
    if position == "bottom" then
      local x, y = (screen_w - w) / 2, (screen_h - h) - 70
      return w,h,x,y
    else -- center
      local x, y = (screen_w - w) / 2, (screen_h - h) / 2  
      return w,h,x,y  
    end

  end
  
  gfx.quit()
  gui_aa = 1
  gui_fontname = 'Consolas'
  gui_fontsize = 21      
  local gui_OS = reaper.GetOS()
  if gui_OS == "OSX32" or gui_OS == "OSX64" then gui_fontsize = gui_fontsize - 7 end

  w,h,x,y = Lokasenna_WindowAtCenter(rl.config.launcherWidth,rl.config.launcherHeight,position)
  gfx.init("ReaLauncher", w, h, 0, x, y)
end