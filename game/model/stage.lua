
local vec2  = require 'cpml' .vec2
local DB    = require 'db'
local Map   = require 'model.map'
local Agent = require 'model.agent'
local Stage = require 'lux.class' :new{}

local setfenv = setfenv
local print   = print
local ipairs  = ipairs
local table   = table

function Stage:instance(_obj, _specname)

  setfenv(1, _obj)

  _specname     = 'stages/' .. _specname
  local _spec   = DB.load(_specname)

  --[[ Tile Map ]]--

  local _map    = Map(_spec['map'])

  function map()
    return _map
  end

  --[[ Agents ]]--

  local _agents = {}

  local function _addAgent(specname, pos)
    local agent = Agent(specname)
    agent.setPos(pos)
    agent.setTarget(vec2(640, 360))
    table.insert(_agents, agent)
  end

  function eachAgent()
    return ipairs(_agents)
  end

  --[[ Base Camps ]]--

  local _camps  = {}

  local function _addCamp(spec)
    table.insert(_camps, spec)
    spec.count = spec.delay
  end

  for _,campspec in ipairs(_spec['camps']) do
    _addCamp(campspec)
  end

  --[[ Overall Logic ]]--

  function tick(dt)
    for _,camp in ipairs(_camps) do
      camp.count = camp.count - dt
      if camp.count < 0 then
        camp.count = camp.count + camp.delay
        _addAgent(camp.spawns, vec2(camp.pos))
      end
    end
    for _,agent in ipairs(_agents) do
      local dir = agent.getIntention()
      local dir_h = vec2(dir.x,0)
      local dir_v = vec2(0,dir.y)
      local dirs = { dir, dir_h, dir_v }
      for _,d in ipairs(dirs) do
        local new_pos = agent.move(d, dt)
        if _map.passable(new_pos) then
          agent.setPos(new_pos)
          break
        end
      end
    end
  end

end

return Stage

