
local DB        = require 'db'
local MOUSE     = require 'ui.mouse'
local vec2      = require 'cpml' .vec2
local HUD       = require 'lux.class' :new{}

local setfenv = setfenv
local love    = love
local print   = print
local pairs   = pairs
local ipairs  = ipairs
local unpack  = unpack
local string  = string
local table   = table
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

  local _contents = {{ n = 0, off = 0 }, { n = 0, off = 0 }}

  local function _buttonBounds()
    return _MARGIN*2, 0, _WIDTH - 6*_MARGIN, 60
  end

  function text(panel, str, weight)
    local font = _FONTS[weight]
    local off = _contents[panel].off
    local n = _contents[panel].n+1
    _contents[panel][n] = {type='text', off, str, weight}
    _contents[panel].n = n
    _contents[panel].off =  off + 8 + font:getHeight()
  end

  function button(panel, str)
    local off = _contents[panel].off
    local n = _contents[panel].n+1
    _contents[panel][n] = {type='button', off}
    _contents[panel].n = n
    text(panel, str, 'HEAD')
    local x, y, w, h = _buttonBounds()
    y = y + off + (panel-1) * 720/2
    return MOUSE.clicked(1) and MOUSE.within(x, y, w, h)
  end

  function space(panel)
    _contents[panel].off = _contents[panel].off + 48
  end

  function flush()
    for i=1,2 do
      _contents[i].n = 0
      _contents[i].off = 0
    end
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
  end

  local function _button(g, off)
    local x, y, w, h = _buttonBounds()
    g.setColor(_COLORS['charleston-green'])
    g.rectangle('fill', x, off + y, w, h, 10, 10)
  end
    
  function draw()
    local g = love.graphics
    local m = _DEFS['margin']
    local w = _DEFS['width']
    for i=1,2 do
      g.push()
      g.translate(m, m + (i-1) * 720/2)
      g.setColor(_COLORS['smoky-black'])
      g.rectangle('fill', 0, 0, w - 2*m, 720/2 - 2*m, 20, 20)
      _off = 0
      for j=1,_contents[i].n do
        local item = _contents[i][j]
        if item.type == 'text' then
          local off, str, weight = unpack(item)
          _text(g, str, weight, off)
        elseif item.type == 'button' then
          local off = unpack(item)
          _button(g, off)
        end
      end
      g.pop()
    end
  end
 
end

return HUD

