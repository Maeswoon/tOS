--[[
||------------------------------------------||
||-- ####### tOS tGUI WINDOW CLASS ###### --||
||-- ######## WRITTEN BY MAESWOON ####### --||
||------------------------------------------||
]]--
Window = {
  x = 0, 
  y = 0, 
  w = 0, 
  h = 0, 
  name = "", 
  bg = 0x000000, 
  fg = 0xFFFFFF, 
  components = {}, 
  handlers = {}, 
  order = {}, 
  buffer = {}
}

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

function Window:remove(name)
  for k,v in pairs(self.order) do if v == name then self.order[k] = nil break end end
  self.buffer[name] = nil
end

function Window:drawFrame(x, y, width, height, color, borders, colBar)
  if borders then local left, right, top, bottom, frameColor = table.unpack(borders) end
  if not frameColor then frameColor = color end
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

-- ### Shift Window ### --
function Window:shift(x, y)
  self.x = x
  self.y = y
  self.buffer()
end

-- ### Close Window ### --
function Window:close() 
  _G.tgui.windows[self.name] = nil
  for k, v in pairs(_G.tgui.focusList)
    if v == self.name then _G.tgui.focusList[k] = nil end
  end
  self = nil
end

setmetatable(Window, __call = function(name, x, y, w, h, color, textColor, borders, barColor) {
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
      for k,v in pairs(_G.tgui.focusList) do
        if v == self.name then
          for i=k+1,#_G.tgui.focusList do
            _G.tgui.windows[v].buffer()
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
  self.buffer()
  return self
}}