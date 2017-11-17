
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
local select  = select


function HUD:instance(_obj, _stage)

  setfenv(1, _obj)

  local _DEFS   = DB.load('defs')['interface']['sidebar']
  local _MARGIN = _DEFS['margin']
  local _WIDTH  = _DEFS['width']

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
  local _activated

  local function _buttonBounds()
    return _MARGIN*2, 0, _WIDTH - 6*_MARGIN, 60
  end

  function activateSelected(selected)
    _selected = selected
    local mpos = MOUSE.pos()
    return MOUSE.clicked(1)
       and MOUSE.within(_buttonBounds())
  end

  local function _text(g, str, weight, off)
    local font = _FONTS[weight]
    local align = _ALIGN[weight]
    g.push()
    g.translate(0, off)
    g.setColor(_COLORS['pale-pink'])
    g.setFont(font)
    g.printf(str, 16, 8, _WIDTH - 2*_MARGIN - 32, align)
    g.pop()
    return off + 8 + font:getHeight()
  end

  function flush()
    _activated = false
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
    off = _text(g, _stage.treasure(), 'TEXT', off)
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
      off = _text(g, _selected.role() .. " camp", 'TEXT', off)
      local action = _selected.roleAction()
      if action then
        off = off + 64
        local x, y, w, h = _buttonBounds()
        g.setColor(_COLORS['charleston-green'])
        g.rectangle('fill', x, off + y, w, h, 10, 10)
        off = _text(g, action, 'HEAD', off)
      end
    end
    g.pop()
  end
 
end

return HUD

