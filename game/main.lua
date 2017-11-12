
--- TODO list
--  + [ ] Basic physics
--    + [x] Fixed-frame update
--    + [x] Delegate movement to map
--    + [ ] Tile collision
--    + [ ] Inter-agent repulsion
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

local DB    = require 'db'
local Stage = require 'model.stage'

local _FRAME
local _lag

local _stage

function love.load()
  _lag = 0
  _stage = Stage('test')
  _FRAME = 1 / DB.load('defs')['fps']
end

function love.update(dt)
  _lag = _lag + dt
  while _lag >= _FRAME do
    _stage.tick(_FRAME)
    _lag = _lag - _FRAME
  end
end

function love.draw()
  local g = love.graphics
  local colors = DB.load('defs')['colors']
  local tilesize = DB.load('defs')['tile-size']
  local map = _stage.map()
  g.setBackgroundColor(colors['charleston-green'])
  local w,h = map.size()
  for i=1,h do
    for j=1,w do
      if map.tilespec(i,j) == DB.load('tiletypes')['ruins'] then
        g.push()
        g.translate(j*tilesize, i*tilesize)
        g.setColor(colors['pale-pink'])
        g.rectangle('fill', 4, 4, 24, 24)
        g.pop()
      end
    end
  end
  for _,agent in _stage.eachAgent() do
    g.push()
    g.translate(agent.pos():unpack())
    g.setColor(colors['tiffany-blue'])
    g.polygon('fill', 0, -8, 8, 8, -8, 8)
    g.pop()
  end
end

