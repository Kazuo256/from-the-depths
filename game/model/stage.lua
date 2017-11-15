
local vec2        = require 'cpml' .vec2
local DB          = require 'db'
local Map         = require 'model.map'
local Agent       = require 'model.agent'
local Settlement  = require 'model.settlement'
local Stage       = require 'lux.class' :new{}

local setfenv = setfenv
local print   = print
local ipairs  = ipairs
local pairs   = pairs
local unpack  = unpack
local table   = table
local math    = math

function Stage:instance(_obj, _specname)

  setfenv(1, _obj)

  _specname       = 'stages/' .. _specname
  local _spec     = DB.load(_specname)
  local _PHYSDEFS = DB.load('defs')['physics']

  --[[ Tile Map ]]--

  local _map    = Map(_spec['map'])

  function map()
    return _map
  end

  --[[ Agents ]]--

  local _agents = {}

  local function _addAgent(spawn, pos)
    local specname, target = unpack(spawn)
    local ti, tj = unpack(target)
    local agent = Agent(specname)
    agent.setPos(pos)
    agent.setTarget(_map.pos2point(ti, tj))
    table.insert(_agents, agent)
  end

  function eachAgent()
    return ipairs(_agents)
  end

  --[[ Settlements ]]--

  local _settlements  = {}

  local function _addSettlement(spec)
    local settlement = Settlement()
    local pos = spec['pos']
    local i, j = unpack(pos)
    _settlements[settlement] = pos
    _map.setTileData(i, j, 'settlement', settlement)
  end

  for _,settlementspec in ipairs(_spec['settlements']) do
    _addSettlement(settlementspec)
  end

  function eachSettlement()
    return pairs(_settlements)
  end

  --[[ Overall Logic ]]--
  
  function tick(dt)
    for settlement,pos in pairs(_settlements) do
      local i, j = unpack(pos)
      settlement.tick(dt)
      local spawn = settlement.nextSpawn()
      if spawn then
        _addAgent(spawn, _map.pos2point(i,j))
      end
    end
    local repulsion = {}
    local colradius = _PHYSDEFS['collision-radius']
    local repfactor = _PHYSDEFS['repulsion-factor']
    for _,agent in ipairs(_agents) do
      local rep = vec2(0,0)
      for _,other in ipairs(_agents) do
        local dist = other.pos() - agent.pos()
        local len2 = math.max(dist:len2(), 0.01)
        if agent ~= other and len2 < colradius*colradius then
          rep = rep - dist:normalize() * repfactor/len2
        end
      end
      repulsion[agent] = rep
    end

    local removed = {}
    for k,agent in ipairs(_agents) do
      local dir = (agent.getIntention() + repulsion[agent]):normalize()
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
      local pi, pj = _map.point2pos(agent.pos())
      local ti, tj = _map.point2pos(agent.target())
      if pi == ti and pj == tj and _map.getTileData(pi, pj, 'settlement') then
        table.insert(removed, k)
      end
    end
    for n,k in ipairs(removed) do
      table.remove(_agents, k - n + 1)
    end
  end

end

return Stage

