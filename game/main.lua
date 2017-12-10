
require 'lib'

local DB          = require 'db'
local Stage       = require 'model.stage'
local Settlement  = require 'model.settlement'
local Agent       = require 'model.agent'
local MOUSE       = require 'ui.mouse'
local StageView   = require 'ui.stageview'
local HUD         = require 'ui.hud'

local vec2        = require 'cpml' .vec2

local _FRAME
local _lag

local _stage
local _view
local _hud

local _selected
local _next_monster

local _BGM

local _DEFS
local _MONSTER
local _PRICE

local function _resetMonster()
  _next_monster = _MONSTER['delay-base']
                + love.math.random() * _MONSTER['delay-range']
end

function love.load()
  _DEFS = DB.load('defs')
  _PRICE = _DEFS['gameplay']['price']
  _MONSTER = _DEFS['gameplay']['monster']
  _FRAME = 1 / _DEFS['fps']
  _BGM = love.audio.newSource('assets/bgm/Brain Damage.ogg')
  _BGM:setLooping(true)
  _BGM:play()
  _lag = 0
  _stage = Stage('test')
  _view = StageView(_stage)
  _hud = HUD(_stage)
  _selected = nil
  _resetMonster()
  love.graphics.setBackgroundColor(_DEFS['colors']['dark-coral'])
end

function love.mousemoved(x, y, dx, dy, istouch)
  MOUSE.move(vec2(dx, dy))
end

local function _updateUI()
  for settlement, pos in _stage.eachSettlement() do
    if _view.settlementSelected(settlement, unpack(pos)) then
      _selected = settlement
    end
  end
  for _,agent in _stage.eachAgent() do
    if _view.agentSelected(agent) then
      _selected = agent
    end
  end
  _hud.flush()
  _hud.text(1, "Resources", 'HEAD')
  _hud.text(1, "Treasure", 'TITLE')
  _hud.text(1, _stage.treasure(), 'TEXT')
  _hud.text(1, "Workers", 'TITLE')
  _hud.text(1, _stage.agentCount('worker'), 'TEXT')
  if _selected then
    if _selected.__class == Settlement then
      _hud.text(2, "Settlement", 'HEAD')
      _hud.text(2, _selected.role(), 'TITLE')
      if _selected.role() == 'rest' or _selected.role() == 'harvest' then
        _hud.text(2, _selected.supplies() .. " supplies", 'TEXT')
        if _selected.role() == 'rest' then
          _hud.text(2, _selected.demand() .. " requested", 'TEXT')
        end
      elseif _selected.role() == 'den' then
        _hud.text(2, "Next assault", 'TITLE')
        _hud.text(2, string.format("%.1f secs", _next_monster), 'TEXT')
      end
      local black, white = 0, 0
      for _,agent in _stage.eachAgent() do
        if agent.specname() == 'worker' then
          if agent.whitelisted(_selected) then
            white = white + 1
          elseif agent.blacklisted(_selected) then
            black = black + 1
          end
        end
      end
      _hud.text(2, white .. " whitelisted", 'TEXT')
      _hud.text(2, black .. " blacklisted", 'TEXT')
      local action = _selected.roleAction()
      if action then
        _hud.space(2)
        if _hud.button(2, action) then
          if _selected.role() == 'training' and
             _stage.spend(_PRICE['training']) then
            _selected.requestSpawn(5, 'worker')
          end
          if _selected.role() == 'rest' then
            _selected.increaseDemand(10)
          end
        end
      end
    elseif _selected.__class == Agent then
      _hud.text(2, "Agent", 'HEAD')
      _hud.text(2, _selected.specname(), 'TEXT')
      _hud.text(2, "Treasure", 'TITLE')
      _hud.text(2, _selected.treasure(), 'TEXT')
      _hud.text(2, "Fatigue", 'TITLE')
      _hud.text(2, string.format("%1d/100", _selected.fatigue()), 'TEXT')
      _hud.text(2, _selected.objective() or "lost", 'TEXT')
      if _selected.hasSupply() then
        _hud.text(2, "Carrying supply", 'TEXT')
      end
    end
  end
  MOUSE.clear()
end

local function _checkMonster(dt)
  _next_monster = _next_monster - dt
  if _next_monster <= 0 then
    local monster = _stage.pickAgent('monster')
    monster.rampage()
    _resetMonster()
    for _,agent in _stage.eachAgent() do
      if agent.specname() == 'worker' then
        agent.alert()
      end
    end
  end
end

function love.update(dt)
  _view.update(dt)
  _lag = _lag + dt
  while _lag >= _FRAME do
    _lag = _lag - _FRAME
    MOUSE.update(_FRAME)
    _checkMonster(_FRAME)
    _stage.tick(_FRAME)
    _updateUI()
  end
end

function love.draw()
  _view.draw()
  _hud.draw()
end

