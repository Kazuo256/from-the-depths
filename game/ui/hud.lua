
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


function HUD:instance(_obj, _stage)

  setfenv(1, _obj)

  local _DEFS = DB.load('defs')['interface']['sidebar']
  local _COLORS = DB.load('defs')['colors']
  local _FONTS = {
    HEAD = love.graphics.newFont("assets/fonts/VollkornSC-Regular.ttf", 24),
    TITLE = love.graphics.newFont("assets/fonts/VollkornSC-Regular.ttf", 20),
    TEXT = love.graphics.newFont("assets/fonts/VollkornSC-Regular.ttf", 16),
  }
  local _ALIGN = {
    HEAD = 'center',
    TITLE = 'left',
    TEXT = 'right'
  }
  local _selected

  function activateSelected(selected)
    _selected = selected
    return false
  end

  local function _text(g, str, weight, off)
    local font = _FONTS[weight]
    local align = _ALIGN[weight]
    g.push()
    g.translate(0, off)
    g.setColor(_COLORS['pale-pink'])
    g.setFont(font)
    g.printf(str, 16, 8, _DEFS['width'] - 2*_DEFS['margin'] - 32, align)
    g.pop()
    return off + 8 + font:getHeight()
  end
    
  function draw()
    local g = love.graphics
    local m = _DEFS['margin']
    local w = _DEFS['width']
    g.push()
    g.translate(m, m)
    g.setColor(_COLORS['smoky-black'])
    g.rectangle('fill', 0, 0, w - 2*m, 720/2 - 2*m, 20, 20)
    local off = 0
    off = _text(g, "Resources", 'HEAD', off)
    off = _text(g, "Treasure", 'TITLE', off)
    off = _text(g, 1024, 'TEXT', off)
    off = _text(g, "Workers", 'TITLE', off)
    off = _text(g, _stage.agentCount(), 'TEXT', off)
    g.pop()
    g.push()
    g.translate(m, 720/2 + m)
    g.setColor(_COLORS['smoky-black'])
    g.rectangle('fill', 0, 0, w - 2*m, 720/2 - 2*m, 20, 20)
    local off = 0
    if _selected then
      off = _text(g, "Settlement", 'HEAD', off)
      off = _text(g, "Action", 'TITLE', off)
      off = _text(g, _selected.action(), 'TEXT', off)
    end
    g.pop()
  end
 
end

return HUD

