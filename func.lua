--[[
||------------------------------------------||
||-- ####### tOS FUNCTION LIBRARY ####### --||
||-- ######## WRITTEN BY MAESWOON ####### --||
||------------------------------------------||
]]--
tgui = _G.tgui

-- ### Create Function Object ### --
function tgui.obj(func, tab = {}) 
  return setmetatable(tab, {__call = func})
end

-- ### Check if Position is Within Parameters ### --
function tgui.within(a, b)
  local a1, a2 = table.unpack(a)
  local b1, b2, w, h = table.unpack(b)
  if (a1 >= b1) and (a1 <= ((b1 + w) - 1)) then
    if (a2 >= b2) and (a2 <= ((b2 + h) - 1)) then
      return true
    else return false end
  else return false end
end
