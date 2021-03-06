
local DB        = require 'db'
local MOUSE     = require 'ui.mouse'
local vec2      = require 'cpml' .vec2
local StageView = require 'lux.class' :new{}

local setfenv = setfenv
local love    = love
local print   = print
local pairs   = pairs
local unpack  = unpack
local string  = string

function StageView:instance(_obj, _stage)

  setfenv(1, _obj)

  local _TILESIZE = DB.load('defs')['tile-size']
  local _SIDEBAR = DB.load('defs')['interface']['sidebar']
  local _RUINS = love.graphics.newImage("assets/textures/ruins.png")
  local _SETTLEMENT = love.graphics.newImage("assets/textures/settlement.png")
  local _DEN = love.graphics.newImage("assets/textures/den.png")
  local _AGENTS = {
    worker = love.graphics.newImage("assets/textures/worker.png"),
    monster = love.graphics.newImage("assets/textures/monster.png")
  }

  local _debug = {}

  local _clicked = {}
  local _current_settlement = nil
  local _current_agent = nil

  --[[ Camera ]]--

  local _campos = vec2(0,0)
  local _camspd = vec2(0,0)

  local function _bounds()
    local width = _SIDEBAR['width']
    local margin = _SIDEBAR['margin']
    return width+margin, margin,
           1280 - width - 2*margin, 720 - 2*margin
  end

  local function _mouseWithin()
    return MOUSE.within(_bounds())
  end

  local function _tileClicked(i, j, mbutton)
    local mpos = (MOUSE.pos() - _campos) * (1/_TILESIZE)
    local mi, mj = _stage.map().point2pos(mpos)
    return _mouseWithin()
       and MOUSE.clicked(mbutton)
       and mi == i and mj == j
  end

  function settlementSelected(settlement, i, j)
    if _tileClicked(i, j, 1) then
      _clicked[settlement] = 0.2
      _current_settlement = settlement
      _current_agent = nil
      return true
    end
  end

  function targetSelected(settlement, i, j)
    if _tileClicked(i, j, 2) then
      _clicked[settlement] = 0.2
      return true
    end
  end

  function agentSelected(agent)
    local mpos = (MOUSE.pos() - _campos) * (1/_TILESIZE)
    local selected = _mouseWithin()
                 and MOUSE.clicked(1)
                 and (mpos - agent.pos()):len2() < 0.3*0.3
    if selected then
      _current_agent = agent
      _current_settlement = nil
    end
    return selected
  end

  function update(dt)
    for i=1,12 do
      local key = 'f'..i
      _debug[key] = love.keyboard.isDown(key)
    end
    for k,v in pairs(_clicked) do
      local clicked = _clicked[k] - dt
      _clicked[k] = clicked > 0 and clicked or nil
    end
    if _mouseWithin() and MOUSE.down(3) then
      _camspd = _camspd + MOUSE.motion() * 8
    end
    _campos = _campos + _camspd * dt
    _camspd = _camspd - _camspd * 0.1
  end

  local function _stencil()
    local x, y, w, h = _bounds()
    return love.graphics.rectangle('fill', x, y, w, h, 20, 20)
  end

  function draw()
    local g = love.graphics
    local colors = DB.load('defs')['colors']
    local map = _stage.map()
    local w,h = map.size()
    g.push()
    g.setColor(colors['charleston-green'])
    g.stencil(_stencil, 'replace', 1)
    g.setStencilTest('greater', 0)
    g.rectangle('fill', _bounds())
    g.translate(_campos:unpack())
    for i=1,h do
      for j=1,w do
        g.push()
        g.translate((j-1)*_TILESIZE, (i-1)*_TILESIZE)
        g.setColor(colors['pale-gold'])
        if map.tilespec(i,j) == DB.load('tiletypes')['ruins'] then
          g.draw(_RUINS, 0, 0)
        end
        local settlement = map.getTileData(i, j, 'settlement')
        if settlement then
          if settlement.role() ~= 'den' then
            g.setColor(colors['tiffany-blue'])
            g.draw(_SETTLEMENT, 0, 0)
          else
            g.setColor(colors['dark-coral'])
            g.draw(_DEN, 0, 0)
          end
          if _current_settlement == settlement then
            local clicked = _clicked[settlement] or 0
            g.push()
            g.setColor(colors['pale-pink'])
            g.translate(_TILESIZE/2, _TILESIZE/2)
            g.scale(1 + clicked, 1 + clicked)
            g.rectangle('line', -_TILESIZE/2, -_TILESIZE/2,
                                _TILESIZE, _TILESIZE)
            g.pop()
          end
        end
        if _debug.f1 then
          local bucket = map.getTileData(i, j, 'agents')
          if bucket then
            g.setColor(colors['pale-pink'])
            g.print(string.format("%d", bucket.n), 0, 0)
          end
        end
        if _current_settlement then
          local si, sj = _stage.settlementPos(_current_settlement)
          g.setColor(colors['pale-pink'])
          if _debug.f2 then
            local pi, pj = _stage.pathfinder().findPath(i, j, si, sj)
            if pi and pj then
              local di, dj = pi-i, pj-j
              g.print(string.format("%2d %2d", di, dj), 0, 0)
            end
          elseif _debug.f3 then
            local dist = _stage.pathfinder().dist(i, j, si, sj)
            if dist then
              g.print(string.format("%2d", dist), 0, 0)
            end
          end
        end
        g.pop()
      end
    end
    for _,agent in _stage.eachAgent() do
      g.push()
      g.translate((agent.pos() * _TILESIZE):unpack())
      if agent == _current_agent then
        g.setColor(colors['pale-pink'])
        g.circle('line', 0, 2, 16)
      end
      if agent.specname() == 'worker' then
        g.setColor(colors['tiffany-blue'])
        g.draw(_AGENTS.worker, 0, 0, 0, 1, 1, 8, 8)
      elseif agent.specname() == 'monster' then
        g.setColor(colors['dark-coral'])
        g.draw(_AGENTS.monster, 0, 0, 0, 1, 1, 12, 12)
      end
      if agent.hasSupply() then
        g.setColor(colors['tiffany-blue'])
        g.rectangle('fill', 12, -16, 6, 6)
      end
      g.pop()
    end
    g.setStencilTest()
    g.pop()
  end

end

return StageView

