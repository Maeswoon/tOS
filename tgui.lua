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
  for k, v in pairs(listeners[name]) do
    if v == func then listener[name][k] = nil break end
  end
end

-- ### Refresh Window Buffers ### --
function tgui.refreshBuffer(win) 
  if windows[win] then
    for k, v in pairs(focusList) do if v == win then focusList[k] = nil end end
  end
  focusList[#tgui.focusList + 1] = win.name
  for k, v in ipairs(focusList) do windows[v].buffer() end 
end

-- ### Handle Click ### --
local function handleClick(_, _, x, y, _, _)
  local focus = ""
  for k, v in ipairs(tgui.focusList) do
    if within(table.pack(x, y), table.pack(windows[v].x, windows[v].y, windows[v].w, windows[v].h)) then focus = v end
  end
    if focus ~= "" then
      if focusList[#tgui.focusList] ~= focus then tgui.refreshBuffer(v) end
      windows[focus]:handle(x - windows[focus].x + 1, y - windows[focus].y + 1)
    end
end

-- ### Add Window ### --
function tgui.addWindow(name, x, y, w, h, color, textColor, borders, barColor)
  if windows[name] then windows[name]:close() end
  focusList[#tgui.focusList + 1] = name
  windows[name] = Window(name, x, y, w, h, color, textColor, borders, barColor)
end

function tgui.loadASCII(path)
  return dofile(path)
end
  
--------------------------
-- ### Finalization ### --
--------------------------

viewport = tgui.addWindow("viewport", 1, 1, screenWidth, screenHeight, 0x54B8F7, 0xFFFFFF, nil, nil)
for _, v in pairs(signals) do listeners[v] = {} end
tgui.addListener("touch", handleClick)
tgui.HALT = false

function tgui.init()
  while true do
    if tgui.HALT then
      break
    end
    for k, v in pairs(tgui.threads) do v() end
    dispatchSignal(table.pack(computer.pullSignal()))
  end
end

function tgui.halt()
  tgui.HALT = true
end
