--[[
||-------------------------------------||
||-- ###### tOS tGUI LIBRARY ####### --||
||-- ##### WRITTEN BY MAESWOON ##### --||
||-------------------------------------||
]]--

-- ### Library Retrieval and Initialization ### --
local component = require("component")
local computer = require("computer")
local unicode = require("unicode")
local event = require("event")
local gpu = component.proxy(component.list("gpu")())
local screenWidth, screenHeight = gpu.getResolution()
tgui, windows, listeners, updateVars, focusList = {}, {}, {}, {}, {}
signals = {"component_available", "component_unavailable", "component_added", "component_removed", "term_available", "term_unavailable", "screen_resized", "touch", "drag", "drop", "scroll", "walk", "key_down", "key_up", "clipboard", "redstone_changed", "motion", "modem_message", "inventory_changed", "bus_message", "carriage_moved"}
Window = {x = 0, y = 0, w = 0, h = 0, name = "", bg = 0x000000, fg = 0xFFFFFF, components = {}, handlers = {}, order = {}, buffer = {}}


------------------------------
-- ### SIGNAL FUNCTIONS ### --
------------------------------

-- ### Dispatch Signal ### --
local function dispatchSignal(signal)
  if signal then
    local name = signal[1]
    if listeners[name] and #listeners[name] > 0 then
      for k, v in pairs(listeners[name]) do v(table.unpack(signal)) end
    end
  end
end

-- ### Add Listener ### --
function tgui.addListener(name, func)
  listeners[name][#listeners[name] + 1] = func
end

-- ### Remove Listener ### --
function tgui.removeListener(name, func)
  for k,v in pairs(listeners[name]) do
    if v == func then listener[name][k] = nil break end
  end
end

---------------------------------------
-- ### BUFFER GRAPHICS FUNCTIONS ### --
---------------------------------------


function Window:set(name,x,y,wbg,wfg,val,vert)
  if not self.buffer[name] then self.order[#self.order + 1] = name end
  if vert then
    self.buffer[name] = setmetatable({
      bg = wbg,
      fg = wfg,
      x = x,
          y = y,
          hidden = false
      }, {
        __call = function()
          gpu.setBackground(wbg)
          gpu.setForeground(wfg)
          if (y - self.y + unicode.len(val) - 2) <= self.h and x <= (self.x + self.w - 1) and x >= self.x and not self.buffer[name].hidden then
            gpu.set(x,y,val,vert)
          end
        end })
  else
    self.buffer[name] = setmetatable({
        bg = wbg,
        fg = wfg,
        x = x,
        y = y,
        hidden = false
      }, {
        __call = function()
          gpu.setBackground(wbg)
          gpu.setForeground(wfg)
          if (x - self.x + unicode.len(val) - 2) <= self.w and y <= (self.y + self.h - 1) and y >= self.y and not self.buffer[name].hidden then
            gpu.set(x,y,val)
          end
      end })
  end
  self.buffer()
end

function Window:fill(name,x,y,w,h,wbg,wfg,val)
  if not self.buffer[name] then self.order[#self.order + 1] = name end
  self.buffer[name] = setmetatable({
      bg = wbg,
      fg = wfg,
      x = x,
      y = y,
      w = w,
      h = h,
      hidden = false
    }, {
    __call = function()
        if (self.buffer[name].x + self.x + w - 2) <= self.w and (self.buffer[name].y - self.y + h - 2) <= self.h and not self.buffer[name].hidden then 
          gpu.setBackground(wbg)
          gpu.setForeground(wfg)
          gpu.fill(self.buffer[name].x + self.x - 1, self.buffer[name].y + self.y - 1,self.buffer[name].w,self.buffer[name].h,val)
        end
    end })
  self.buffer()
end

function Window:toggle(name)
  if self.buffer[name] then self.buffer[name].hidden = not self.buffer[name].hidden end
  if self.buffer[name].children then
    for k,v in pairs(self.buffer[name].children) do self:toggle(v) end
  end    
  self.buffer()
end

function Window:show(name)
  if self.buffer[name] then self.buffer[name].hidden = false end
  if self.buffer[name].children then
    for k,v in pairs(self.buffer[name].children) do self:show(v) end
  end    
  self.buffer()
end

function Window:hide(name)
  if self.buffer[name] then self.buffer[name].hidden = true end
  if self.buffer[name].children then
    for k,v in pairs(self.buffer[name].children) do self:hide(v) end
  end    
  self.buffer()
end

function Window:getResolution() return self.w, self.h end

function Window:setResolution(width,height) 
  self.w = width
  self.h = height
  self.buffer()
end

-- ### Remove Buffer Element ### --
function Window:remove(name)
  for k,v in pairs(self.order) do if v == name then self.order[k] = nil break end end
  self.buffer[name] = nil
end

-- ### Refresh Window Buffers ### --
function tgui.refreshBuffer(win) 
  if windows[win] then
    for k, v in pairs(focusList) do if v == win then focusList[k] = nil end end
  end
  focusList[#focusList + 1] = name
  for k, v in ipairs(focusList) do windows[v].buffer() end 
end

--------------------------------
-- ### GRAPHICS FUNCTIONS ### --
--------------------------------

-- ### Invert Hex Color ### --
function tgui.invertColor(color)
  color = string.sub(color, 2)
  local inverted_color = '#'
  for i = 0, 2 do
    local component = string.sub(color, 1 + i * 2, 2 + i * 2)
    component = tonumber('0x' .. component)
    component = 0xff - component
    inverted_color = inverted_color .. string.format('%.2x', component)
  end
  return inverted_color
end

-- ### Draw Frame to Buffer ### --
function Window:drawFrame(x, y, width, height, color, borders, colBar)
  if borders then local left, right, top, bottom, frameColor = table.unpack(borders) end
  if not frameColor then frameColor = tgui.invertColor(color) end
  self:fill("window-body", x, y, width, height, color, color, " ")
  if borders then
    if left then
      self:fill("left-window-bar", x, y + 1, 1, height - 2, color, frameColor, unicode.char(0x2503))
    end
    if right then
      self:fill("right-window-bar", x + width - 1, y + 1, 1, height - 2, color, frameColor, unicode.char(0x2503))
    end
    if top and not colBar then
      self:fill("top-window-bar", x, y, width, 1, color, frameColor, unicode.char(0x2501))
    end
    if bottom then
      self:fill("bottom-window-bar", x, y + height - 1, width, 1, color, frameColor, unicode.char(0x2501))
    end
    if top and left and not colBar then
      self:set("tl-window-corner", x, y, color, frameColor, unicode.char(0x250F))
    end
    if top and right and not colBar then
      self:set("tr-window-corner", x + width - 1, y, color, frameColor, unicode.char(0x2513))
    end
    if bottom and left then
      self:set("bl-window-corner", x, y + height - 1, color, frameColor, unicode.char(0x2517))
    end
    if bottom and right then
      self:set("br-window-corner", x + width - 1, y + height - 1, color, frameColor, unicode.char(0x251B))
    end
    if colBar then
      self:fill("window-bar", x, y, width, 1, colBar, colBar, " ")
    end
  end  
  self.buffer()
end

-- ### Check if Position is Within Parameters ### --
local function within(a,b)
  local a1, a2 = table.unpack(a)
  local b1, b2, w, h = table.unpack(b)
  if (a1 >= b1) and (a1 <= ((b1 + w) - 1)) then
    if (a2 >= b2) and (a2 <= ((b2 + h) - 1)) then
      return true
    else return false end
  else return false end
end

-----------------------------------------
-- ### WINDOW AND BUTTON FUNCTIONS ### --
-----------------------------------------

-- ### Handle Click ### --
local function handleClick(_, _, x, y, _, _)
  local focus = ""
  for k,v in ipairs(focusList) do
    if within(table.pack(x,y),table.pack(windows[v].x,windows[v].y,windows[v].w,windows[v].h)) then focus = v end
  end
    if focus ~= "" then
        if focusList[#focusList] ~= focus then tgui.refreshBuffer(v) end
        windows[focus]:handle(x - windows[focus].x + 1, y - windows[focus].y + 1)
    end
end

-- ### Window Click Handling ### --
function Window:handle(x,y)
  for _, f in pairs(self.handlers) do
    f(x,y)
  end
end

-- ### Add Button ### --
function Window:addButton(name, x, y, w, h, bg, fg, text, onClick)
  self.components["button/"..name] = {}
  self.components["button/"..name].w = w
  self.components["button/"..name].h = h
  self.components["button/"..name].x = x
  self.components["button/"..name].y = y
  self.buffer["button/"..name].children = {"button-body/"..name, "button-label/"..name}
  self.handlers["button/"..name] = setmetatable({}, {
    __call = function(_,a,b)
      if within(table.pack(a,b), table.pack(self.components["button/"..name].x,self.components["button/"..name].y,self.components["button/"..name].w,self.components["button/"..name].h)) then onClick() end
    end })
  self:fill("button-body/"..name, x, y, w, h, bg, bg, " ")
  if text then
    self:set("button-label/"..name, math.ceil(w / 2) + x - math.ceil(unicode.len(text:sub(1, w - 2)) / 2), math.floor(h / 2) + y, bg, fg, text:sub(1, w - 2))
  end
end

-- ### Remove Button ### --
function Window:removeButton(name)
  self.components[name] = nil
  self.buffer["button-label/"..name] = nil
  self.buffer["button-body/"..name] = nil
  self.handlers["button/"..name] = nil
end

-- ### Add Switch ### --
function Window:addSwitch(name, x, y, bg, fg, f)
  self.components[name] = {
    toggle = f,
    stat = false,
    x = x,
    y = y,
    bg = bg,
    fg = fg
    } 

  self:addButton("switch/" .. name, x, y, 3, 1, bg, fg, _, setmetatable({}, {
    __call = function() 
      self.components[name].stat = not self.components[name].stat 
      self.components[name].toggle()
      if self.components[name].stat then
        self:set("switch-body/"..name, self.components[name].x, self.components[name].y, 0xD3D3D3, 0xD3D3D3, "  ")
        self:set("switch-box/"..name, self.components[name].x + 2, self.components[name].y, 0x00008B, 0x00008B," ")
      else
        self:set("switch-body/"..name, self.components[name].x + 1, self.components[name].y, 0xD3D3D3, 0xD3D3D3, "  ")
        self:set("switch-box/"..name, self.components[name].x, self.components[name].y, 0x8C8C8C, 0x8C8C8C, " ")
      end
    end }))
    self:set("switch-body/"..name, self.components[name].x + 1, self.components[name].y, 0xD3D3D3, 0xD3D3D3, "  ")
    self:set("switch-box/"..name, self.components[name].x, self.components[name].y, 0x8C8C8C, 0x8C8C8C, " ")
end

-- ### Add Window ### --
function tgui.addWindow(name, x, y, w, h, color, textColor, borders, barColor)
  if windows[name] then windows[name]:close() end
  self = Window
  self.x = x 
  self.y = y
  self.w = w
  self.h = h
  self.name = name
  self.bg = color
  self.fg = textColor
  self.components = {}
  self.handlers = {}
  self.order = {}
  self.buffer = setmetatable({}, { 
    __call = function() 
      for k, v in ipairs(self.order) do 
        if self.buffer[v] then 
          self.buffer[v]() 
        else
          self.order[k] = nil
        end
      end
      for k,v in pairs(focusList) do
        if v == self.name then
          for i=k+1,#focusList do
            windows[v].buffer()
          end
          break
        end
      end
    end })
  if barColor and borders then 
    self:drawFrame(x, y, w, h, color, borders, barColor) 
    if unicode.len(name) > w - 3 then
      name = name:sub(1, unicode.len(name) - (unicode.len(name) - (w - 6)))
      name = name .. "..."
    end
    self:addButton("close-window/" .. name, x + w - 4, y, 3, 1, 0xFF0000, 0xFFFFFF, "X", setmetatable({}, {__call = function() self:close() end}))
    self:set("window-title/"..name, x, y, barColor, 0xFFFFFF, name)
  elseif borders then 
    self:drawFrame(x, y, w, h, color, borders, _) 
  else
    self:drawFrame(x, y, w, h, color, _, _) 
  end
  focusList[#focusList + 1] = name
  self.buffer()
  windows[name] = self
  return self
end

-- ### Close Window ### --
function Window:close()
  for k, v in pairs(focusList) do
    if v == self.name then focusList[k] = nil break end
  end
  self = nil
  tgui.refreshBuffer()
end

-- ### Shift Window ### --
function Window:shift(x, y)
  self.x = x
  self.y = y
  self.buffer()
end
  
--------------------------
-- ### Finalization ### --
--------------------------

viewport = tgui.addWindow("viewport", 1, 1, screenWidth, screenHeight, 0x54B8F7, 0xFFFFFF, _, _)
for _, v in pairs(signals) do listeners[v] = {} end
tgui.addListener("touch", handleClick)
  
tgui.coroutine = coroutine.create(function()
  while true do
    local args = table.pack(computer.pullSignal(0.5))
    dispatchSignal(args)
    for k, v in pairs(updateVars) do v() end
    os.sleep(0.1)
  end
end)

function tgui.init()
  coroutine.resume(tgui.coroutine)
end

function tgui.halt()
  coroutine.yield()
end
  
return tgui