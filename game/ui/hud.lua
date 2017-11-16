
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

  local _WIDTH = DB.load('defs')['interface']['hud-width']
  local _COLORS = DB.load('defs')['colors']

  function draw()
    local g = love.graphics
    g.setColor(_COLORS['pale-pink'])
    g.rectangle('fill', 1280 - _WIDTH, 0, _WIDTH, 720)
  end
 
end

return HUD

