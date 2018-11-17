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
dofile("window.lua")

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

-- ### Refresh Window Buffers ### --
function tgui.refreshBuffer(win) 
  if windows[win] then
    for k, v in pairs(focusList) do if v == win then focusList[k] = nil end end
  end
  focusList[#focusList + 1] = name
  for k, v in ipairs(focusList) do windows[v].buffer() end 
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

-- ### Close Window ### --
function Window:close()
  for k, v in pairs(focusList) do
    if v == self.name then focusList[k] = nil break end
  end
  self = nil
  tgui.refreshBuffer()
end

-- ### Add Window ### --
function tgui.addWindow(name, x, y, w, h, color, textColor, borders, barColor)
  if windows[name] then windows[name]:close() end
  focusList[#focusList + 1] = name
  windows[name] = Window(name, x, y, w, h, color, textColor, borders, barColor)
end
  
--------------------------
-- ### Finalization ### --
--------------------------

viewport = tgui.addWindow("viewport", 1, 1, screenWidth, screenHeight, 0x54B8F7, 0xFFFFFF, _, _)
for _, v in pairs(signals) do listeners[v] = {} end
tgui.addListener("touch", handleClick)
  
tgui.proc = coroutine.create(function()
  while true do
    local args = table.pack(computer.pullSignal(0.5))
    dispatchSignal(args)
    for k, v in pairs(updateVars) do v() end
    os.sleep(0.1)
  end
end)

function tgui.init()
  coroutine.resume(tgui.proc)
end

function tgui.halt()
  coroutine.yield()
end
  
return tgui