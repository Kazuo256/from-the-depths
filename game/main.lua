
--- TODO list
--  + Infra
--    + [ ] Behavior class
--  + Basic interaction??
--    + [ ] Agent pool
--    + [x] Deploy mechanics
--    + [ ] Basecamp interaction
--  + Economy
--    + [ ] Supply sources
--    + [ ] Supply transport
--    + [ ] Supply harvest
--    + [ ] Currency reward
--  + Monsters
--    + [ ] Nests
--    + [ ] Periodic spawn
--    + [ ] Assaults
--    + [ ] Gem cycle

require 'lib'

local DB        = require 'db'
local MOUSE     = require 'ui.mouse'
local Stage     = require 'model.stage'
local StageView = require 'ui.stageview'
local HUD       = require 'ui.hud'

local vec2      = require 'cpml' .vec2

local _FRAME
local _lag

local _stage
local _view
local _hud

local _selected
local _BGM

function love.load()
  _FRAME = 1 / DB.load('defs')['fps']
  _BGM = love.audio.newSource('assets/bgm/Socapex - Tokyo Chase.ogg')
  _BGM:setLooping(true)
  _BGM:play()
  _lag = 0
  _stage = Stage('test')
  _view = StageView(_stage)
  _hud = HUD()
  _selected = nil
end

function love.mousemoved(x, y, dx, dy, istouch)
  MOUSE.move(vec2(dx, dy))
end

function love.update(dt)
  _view.update(dt)
  _lag = _lag + dt
  while _lag >= _FRAME do
    _lag = _lag - _FRAME
    MOUSE.update(_FRAME)
    _stage.tick(_FRAME)
    for settlement, pos in _stage.eachSettlement() do
      if _view.settlementSelected(settlement, unpack(pos)) then
        _selected = settlement
      end
      if _selected and _view.targetSelected(settlement, unpack(pos)) then
        _selected.requestSpawn(1, pos)
      end
    end
    MOUSE.clear()
  end
end

function love.draw()
  _view.draw()
  _hud.draw()
end

