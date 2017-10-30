
require 'lib'

local vec2 = require 'cpml'.vec2

local _SPAWN_DELAY = 2

local _spawns = {}
local _agents = {}

local function _addSpawn(pos, team)
  table.insert(_spawns, { pos = pos, team = team, delay = _SPAWN_DELAY })
end

local function _addAgent(pos, team)
  table.insert(_agents, { pos = pos, team = team })
end

function love.load()
  _addSpawn(vec2(400,300), 1)
end

function love.update(dt)
  for _,spawn in ipairs(_spawns) do
    spawn.delay = spawn.delay - dt
    if spawn.delay < 0 then
      spawn.delay = spawn.delay + _SPAWN_DELAY
      _addAgent(spawn.pos, spawn.team)
    end
  end
  for _,agent in ipairs(_agents) do
    agent.pos = agent.pos + vec2(50, 0)*dt
  end
end

-- Pallete: https://coolors.co/17bebb-2e282a-cd5334-edb88b-fad8d6
function love.draw()
  local g = love.graphics
  g.setBackgroundColor(0x2E, 0x28, 0x2A)
  for _,agent in ipairs(_agents) do
    g.push()
    g.translate(agent.pos:unpack())
    g.setColor(0xCD, 0x53, 0x34, 0xff)
    g.polygon('fill', 0, -8, 8, 8, -8, 8)
    g.pop()
  end
end

