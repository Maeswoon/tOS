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
_G.tgui = {}
tgui = _G.tgui
tgui.windows, tgui.listeners, tgui.threads, tgui.focusList = {}, {}, {}, {}
windows = tgui.windows
listeners = tgui.listeners
threads = tgui.threads
focusList = tgui.focusList
signals = {"component_available", "component_unavailable", "component_added", "component_removed", "term_available", "term_unavailable", "screen_resized", "touch", "drag", "drop", "scroll", "walk", "key_down", "key_up", "clipboard", "redstone_changed", "motion", "modem_message", "inventory_changed", "bus_message", "carriage_moved"}
dofile("window.lua")

-- ### Dispatch Signal ### --
local function dispatchSignal(signal)
  if signal then
    local name = signal[1]
    if _G.tgui.listeners[name] and #_G.tgui.listeners[name] > 0 then
      for k, v in pairs(_G.tgui.listeners[name]) do v(table.unpack(signal)) end
    end
  end
end

-- ### Add Listener ### --
function _G.tgui.addListener(name, func)
  _G.tgui.listeners[name][#_G.tgui.listeners[name] + 1] = func
end

-- ### Remove Listener ### --
function _G.tgui.removeListener(name, func)
  for k,v in pairs(_G.tgui.listeners[name]) do
    if v == func then listener[name][k] = nil break end
  end
end

-- ### Refresh Window Buffers ### --
function _G.tgui.refreshBuffer(win) 
  if _G.tgui.windows[win] then
    for k, v in pairs(_G.tgui.focusList) do if v == win then _G.tgui.focusList[k] = nil end end
  end
  _G.tgui.focusList[#_G.tgui.focusList + 1] = name
  for k, v in ipairs(_G.tgui.focusList) do _G.tgui.windows[v].buffer() end 
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
  for k,v in ipairs(_G.tgui.focusList) do
    if within(table.pack(x,y),table.pack(_G.tgui.windows[v].x,_G.tgui.windows[v].y,_G.tgui.windows[v].w,_G.tgui.windows[v].h)) then focus = v end
  end
    if focus ~= "" then
      if _G.tgui.focusList[#_G.tgui.focusList] ~= focus then _G.tgui.refreshBuffer(v) end
      _G.tgui.windows[focus]:handle(x - _G.tgui.windows[focus].x + 1, y - _G.tgui.windows[focus].y + 1)
    end
end


-- ### Add Window ### --
function _G.tgui.addWindow(name, x, y, w, h, color, textColor, borders, barColor)
  if _G.tgui.windows[name] then _G.tgui.windows[name]:close() end
  _G.tgui.focusList[#_G.tgui.focusList + 1] = name
  _G.tgui.windows[name] = Window(name, x, y, w, h, color, textColor, borders, barColor)
end
  
--------------------------
-- ### Finalization ### --
--------------------------

viewport = _G.tgui.addWindow("viewport", 1, 1, screenWidth, screenHeight, 0x54B8F7, 0xFFFFFF, _, _)
for _, v in pairs(signals) do _G.tgui.listeners[v] = {} end
_G.tgui.addListener("touch", handleClick)
  
_G.tgui.proc = coroutine.create(function()
  while true do
    local args = table.pack(computer.pullSignal(0.5))
    dispatchSignal(args)
    for k, v in pairs(_G.tgui.threads) do v() end
    os.sleep(0.1)
  end
end)

function _G.tgui.init()
  coroutine.resume(_G.tgui.proc)
end

function _G.tgui.halt()
  coroutine.yield()
end
