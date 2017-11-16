
local DB        = require 'db'
local MOUSE     = require 'ui.mouse'
local vec2      = require 'cpml' .vec2
local HUD       = require 'lux.class' :new{}

local setfenv = setfenv
local love    = love
local print   = print
local pairs   = pairs
local unpack  = unpack
local string  = string


function HUD:instance(_obj)

  setfenv(1, _obj)

  local _DEFS = DB.load('defs')['interface']['sidebar']
  local _COLORS = DB.load('defs')['colors']

  function draw()
    local g = love.graphics
    local m = _DEFS['margin']
    local w = _DEFS['width']
    g.push()
    g.setColor(_COLORS['smoky-black'])
    g.rectangle('fill', m, m, w - 2*m, 720 - 2*m, 20, 20)
    --g.setColor(_COLORS['pale-pink'])
    --g.print("All your base are belong to us", 0, 0)
    g.pop()
  end
 
end

return HUD

