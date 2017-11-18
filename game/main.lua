
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
  _BGM = love.audio.newSource('assets/bgm/Brain Damage.ogg')
  _BGM:setLooping(true)
  _BGM:play()
  _lag = 0
  _stage = Stage('test')
  _view = StageView(_stage)
  _hud = HUD(_stage)
  _selected = nil
  love.graphics.setBackgroundColor(
    DB.load('defs')['colors']['dark-coral']
  )
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
  _hud.flush()
  _hud.text(1, "Resources", 'HEAD')
  _hud.text(1, "Treasure", 'TITLE')
  _hud.text(1, _stage.treasure(), 'TEXT')
  _hud.text(1, "Workers", 'TITLE')
  _hud.text(1, _stage.agentCount(), 'TEXT')
  if _selected then
    _hud.text(2, "Settlement", 'HEAD')
    _hud.text(2, _selected.role(), 'TEXT')
    local action = _selected.roleAction()
    if action then
      _hud.space(2)
      if _hud.button(2, action) then
        if _selected.role() == 'training' and _stage.spend(200) then
          _selected.requestSpawn(5)
        end
      end
    end
  end
  MOUSE.clear()
end

function love.update(dt)
  _view.update(dt)
  _lag = _lag + dt
  while _lag >= _FRAME do
    _lag = _lag - _FRAME
    MOUSE.update(_FRAME)
    _stage.tick(_FRAME)
    _updateUI()
  end
end

function love.draw()
  _view.draw()
  _hud.draw()
end

