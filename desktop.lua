-------------------------------------
-- tOS Desktop and Process Setup
-------------------------------------

-- Library Retrieval
dofile("tgui.lua")
local gpu = require("component").proxy(require("component").list("gpu")())
local computer = require("computer")
local bg = gpu.getBackground()
local fg = gpu.getForeground()
local unicode = require("unicode")
local hBar = function(x) return string.rep(unicode.char(0x2501), x) end
local vBar = function(x) return string.rep(unicode.char(0x2503), x) end

-- Setup Menu
local menu = {}
menu.drawn = false
menu.items = {
  { name = "beep",
    label = "Beep",
    func = setmetatable({}, {__call = function() computer.beep(300) end}) },
  { name = "add_window",
    label = "Add Window",
    func = setmetatable({}, {__call = function() 
      windows.test_window = Window("test_window", 20, 20, 40, 20, 0x33F, 0x000)
      windows.test_window:init(0x33F, _, _)
    end}) },
}

--Setup Taskbar and Clock 
viewport:fill("taskbar", 1, 48, 160, 3, 0xAFAFAF, 0x000000, " ")
viewport:fill("menu_body", 1, 47- (2 * #menu.items), 18, 2 * #menu.items, 0xAFAFAF, 0x000000, " ")
viewport:hide("menu_body")
for k, v in pairs(menu.items) do
  viewport:addButton("menu_item-" .. v.name, 1, 48 - 2 * k, 18, 1, 0xAFAFAF, 0x000000, v.label, v.func)
  viewport:set("menu_div-"..(k+1), 1, 49 - (2 * k), 0xAFAFAF, 0x000000, hBar(18), false)
  viewport:hide("button/menu_item-" .. v.name)
  viewport:hide("menu_div-"..k+1)
end
viewport:set("menu_div-1", 1, 47 - (2 * #menu.items), 0xAFAFAF, 0x000000, hBar(18), false)
viewport:hide("menu_div-1")
viewport:addButton("menu", 1, 48, 8, 3, 0x009933, 0x000000, "Menu", setmetatable({},{__call = function() 
  viewport:toggle("menu_body")
  viewport:toggle("menu_div-1")
  for k, v in pairs(menu.items) do
    viewport:toggle("button/menu_item-" .. v.name)
    viewport:toggle("menu_div-"..k+1)
  end
  viewport.buffer()
end}))
viewport:set("clockbar_left", 149, 48, 0xAFAFAF, 0x000000, vBar(3), true)
viewport:set("clockbar_right", 160, 48, 0xAFAFAF, 0x000000, vBar(3), true)
--[[
updateVars["clock"] = setmetatable({}, { __call = function() 
  viewport:set("time", 151, 49, 0xAFAFAF, 0x000000, os.date("%I"..":".."%M".." ".."%p"), false) 
end })

-- Memory Counter
viewport:set("memoryBar", 129, 48, 0xAFAFAF, 0x000000, vBar(3), true)
threads.memoryCounter = setmetatable({}, {__call = function()
  local fmStr = ""
  local tmStr = ""
  if math.min(math.log(computer.totalMemory() - computer.freeMemory()) / math.log(2)) < 20 then 
    fmStr = math.max((computer.totalMemory() - computer.freeMemory()) / 2^10)
    fmStr = tostring(fmStr):sub(1, 3)
    fmStr = fmStr .. "KB" 
  else
    fmStr = math.max((computer.totalMemory() - computer.freeMemory()) / 2^20)
    fmStr = tostring(fmStr):sub(1, 3)
    fmStr = fmStr .. "MB" 
  end
  if math.min(math.log(computer.totalMemory()) / math.log(2)) < 20 then 
    tmStr = math.max((computer.totalMemory()) / 2^10)
    tmStr = tostring(tmStr):sub(1, 3)
    tmStr = tmStr .. "KB" 
  else 
    tmStr = math.max((computer.totalMemory()) / 2^20)
    tmStr = tostring(tmStr):sub(1, 3)
    tmStr = tmStr .. "MB" 
  end
  fmStr = string.rep(" ", math.abs(5 - #fmStr)) .. fmStr
  tmStr = tmStr .. string.rep(" ", math.abs(5 - #tmStr))
  viewport:set("memoryCounter", 131, 49, 0xAFAFAF, 0x000000, "MEM: " .. fmStr .. " / " .. tmStr, false)
end})
]]

logo = {
  "         _____                   _______                   _____            ", 
  "        /\\    \\                 /::\\    \\                 /\\    \\           ", 
  "       /::\\    \\               /::::\\    \\               /::\\    \\          ", 
  "       \\:::\\    \\             /::::::\\    \\             /::::\\    \\         ", 
  "        \\:::\\    \\           /::::::::\\    \\           /::::::\\    \\        ", 
  "         \\:::\\    \\         /:::/~~\\:::\\    \\         /:::/\\:::\\    \\       ", 
  "          \\:::\\    \\       /:::/    \\:::\\    \\       /:::/__\\:::\\    \\      ", 
  "          /::::\\    \\     /:::/    / \\:::\\    \\      \\:::\\   \\:::\\    \\     ", 
  "         /::::::\\    \\   /:::/____/   \\:::\\____\\   ___\\:::\\   \\:::\\    \\    ", 
  "        /:::/\\:::\\    \\ |:::|    |     |:::|    | /\\   \\:::\\   \\:::\\    \\   ", 
  "       /:::/  \\:::\\____\\|:::|____|     |:::|    |/::\\   \\:::\\   \\:::\\____\\  ", 
  "      /:::/    \\::/    / \\:::\\    \\   /:::/    / \\:::\\   \\:::\\   \\::/    /  ", 
  "     /:::/    / \\/____/   \\:::\\    \\ /:::/    /   \\:::\\   \\:::\\   \\/____/   ", 
  "    /:::/    /             \\:::\\    /:::/    /     \\:::\\   \\:::\\    \\       ", 
  "   /:::/    /               \\:::\\__/:::/    /       \\:::\\   \\:::\\____\\      ", 
  "   \\::/    /                 \\::::::::/    /         \\:::\\  /:::/    /      ", 
  "    \\/____/                   \\::::::/    /           \\:::\\/:::/    /       ", 
  "                               \\::::/    /             \\::::::/    /        ", 
  "                                \\::/____/               \\::::/    /         ", 
  "                                 ~~                      \\::/    /          ", 
  "                                                          \\/____/           ", 
  "                                                                          "
}

for k, v in ipairs(logo) do
  viewport:set("logo_row"..tostring(k), 40, 14 + k, 0x54B8F7, 0x000000, v, false)
end

viewport:addButton("halt", 151, 1, 10, 3, 0xFF0000, 0x000000, "Halt", setmetatable({}, {__call = function() tgui.halt() end})) 

-- Finalization
tgui.refreshBuffer("viewport")
tgui.init()