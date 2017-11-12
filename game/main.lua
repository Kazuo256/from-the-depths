
--- TODO list
--  + [ ] Basic physics
--    + [ ] Fixed-frame update
--    + [ ] Delegate movement to map
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

local _stage

function love.load()
  _stage = Stage('test')
end

function love.update(dt)
  _stage.tick(dt)
end

function love.draw()
  local g = love.graphics
  local colors = DB.load('defs').colors
  local map = _stage.map()
  g.setBackgroundColor(colors['charleston-green'])
  local w,h = map.size()
  for i=1,h do
    for j=1,w do
      if map.tilespec(i,j) == DB.load('tiletypes')['ruins'] then
        g.push()
        g.translate(j*32, i*32)
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

