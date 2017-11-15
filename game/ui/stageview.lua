
local DB        = require 'db'
local MOUSE     = require 'ui.mouse'
local StageView = require 'lux.class' :new{}

local setfenv = setfenv
local love    = love
local print   = print
local pairs   = pairs

function StageView:instance(_obj, _stage)

  setfenv(1, _obj)

  local _TILESIZE = DB.load('defs')['tile-size']
  local _clicked = {}

  local function _tileClicked(i, j, mbutton)
    local mpos = MOUSE.pos() * (1/_TILESIZE)
    local mi, mj = _stage.map().point2pos(mpos)
    return MOUSE.clicked(mbutton) and mi == i and mj == j
  end

  function settlementSelected(settlement, i, j)
    if _tileClicked(i, j, 1) then
      _clicked[settlement] = 0.2
      return true
    end
  end

  function targetSelected(settlement, i, j)
    if _tileClicked(i, j, 2) then
      _clicked[settlement] = 0.2
      return true
    end
  end

  function update(dt)
    for k,v in pairs(_clicked) do
      local clicked = _clicked[k] - dt
      _clicked[k] = clicked > 0 and clicked or nil
    end
  end

  function draw()
    local g = love.graphics
    local colors = DB.load('defs')['colors']
    local map = _stage.map()
    g.setBackgroundColor(colors['charleston-green'])
    local w,h = map.size()
    for i=1,h do
      for j=1,w do
        g.push()
        g.translate((j-1)*_TILESIZE, (i-1)*_TILESIZE)
        g.setColor(colors['pale-gold'])
        if map.tilespec(i,j) == DB.load('tiletypes')['ruins'] then
          g.rectangle('fill', 8, 8, _TILESIZE - 16, _TILESIZE - 16)
        end
        local settlement = map.getTileData(i, j, 'settlement')
        if settlement then
          local clicked = _clicked[settlement] or 0
          g.push()
          g.translate(_TILESIZE/2, _TILESIZE/2)
          g.scale(1 + clicked, 1 + clicked)
          g.rectangle('line', -_TILESIZE/2, -_TILESIZE/2, _TILESIZE, _TILESIZE)
          g.pop()
        end
        g.pop()
      end
    end
    for _,agent in _stage.eachAgent() do
      g.push()
      g.translate((agent.pos() * _TILESIZE):unpack())
      g.setColor(colors['tiffany-blue'])
      g.polygon('fill', 0, -8, 8, 8, -8, 8)
      g.pop()
    end
  end

end

return StageView

