
--- TODO list
--  + [x] Basic physics
--    + [x] Fixed-frame update
--    + [x] Delegate movement to map
--    + [x] Tile collision
--    + [x] Inter-agent repulsion
--  + [ ] Basic intelligent movement
--    + [ ] Heap
--    + [ ] A* algorithm
--    + [ ] pathfinding agents
--    + [ ] Behavior class
--  + [ ] Basic interaction??
--    + [ ] Agent pool
--    + [ ] Deploy mechanics
--    + [ ] Basecamp interaction

require 'lib'

local DB        = require 'db'
local MOUSE     = require 'ui.mouse'
local Stage     = require 'model.stage'
local StageView = require 'ui.stageview'

local vec2      = require 'cpml' .vec2

local _FRAME
local _lag

local _stage
local _view

function love.load()
  _lag = 0
  _stage = Stage('test')
  _view = StageView(_stage)
  _FRAME = 1 / DB.load('defs')['fps']
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
        settlement.requestSpawn(10, vec2(640, 360))
      end
    end
  end
end

function love.draw()
  _view.draw()
end

