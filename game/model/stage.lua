
local vec2        = require 'cpml' .vec2
local DB          = require 'db'
local Map         = require 'model.map'
local Agent       = require 'model.agent'
local Settlement  = require 'model.settlement'
local PathFinder  = require 'model.pathfinder'
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

  --[[ Treasure ]]--
  
  local _treasure = _spec['treasure']

  function treasure()
    return _treasure
  end

  function gain(amount)
    _treasure = _treasure + amount
  end

  function spend(amount)
    if amount <= _treasure then
      _treasure = _treasure - amount
      return true
    end
  end

  --[[ Tile Map ]]--

  local _map        = Map(_spec['map'])
  local _pathfinder = PathFinder(_map)

  function map()
    return _map
  end

  function pathfinder()
    return _pathfinder
  end

  --[[ Agents ]]--

  local _agents = {}

  do -- Initialize agent count per tile
    local w, h = _map.size()
    for i=1,h do
      for j=1,w do
        _map.setTileData(i, j, 'agents', { n = 0 })
      end
    end
  end

  local function _bucket(i, j)
    return _map.getTileData(i, j, 'agents')
  end

  local function _bucketAgent(agent, i, j)
    local bucket = _bucket(i, j)
    bucket[agent] = true
    bucket.n = bucket.n + 1
  end

  local function _unbucketAgent(agent, i, j)
    local bucket = _bucket(i, j)
    bucket[agent] = nil
    bucket.n = bucket.n - 1
  end

  local function _addAgent(specname, i, j)
    local agent = Agent(specname, _obj)
    local point = _map.pos2point(i,j)
    agent.setPos(point)
    table.insert(_agents, agent)
    _bucketAgent(agent, i, j)
  end

  function eachAgent()
    return ipairs(_agents)
  end

  function agentCount()
    return #_agents
  end

  --[[ Settlements ]]--

  local _settlements  = {}

  local function _addSettlement(spec)
    local settlement = Settlement(spec['role'])
    local pos = spec['pos']
    local i, j = unpack(pos)
    _settlements[settlement] = pos
    _map.setTileData(i, j, 'settlement', settlement)
    _pathfinder.registerOrigin(settlement, {
      pos = pos,
      extra = function (i, j)
        local n = 0
        for agent in pairs(_map.getTileData(i, j, 'agents')) do
          if agent ~= 'n' then
            local oi, oj = agent.target()
            if oi ~= pos[1] or oj ~= pos[2] then
              n = n + 3
            else
              n = n + 0.1
            end
          end
        end
        return n
      end
    })
  end

  for _,settlementspec in ipairs(_spec['settlements']) do
    _addSettlement(settlementspec)
  end

  function eachSettlement()
    return pairs(_settlements)
  end

  function settlementPos(settlement)
    return unpack(_settlements[settlement])
  end

  --[[ Overall Logic ]]--
  
  function tick(dt)
    -- Spawn agents
    for settlement,pos in pairs(_settlements) do
      local i, j = unpack(pos)
      settlement.tick(dt)
      local spawn = settlement.nextSpawn()
      if spawn then
        _addAgent(spawn, i, j)
      end
    end

    for _,agent in ipairs(_agents) do
      agent.tick(dt)
    end

    -- Trace tactical paths
    _pathfinder.updatePaths(dt)

    -- Repel packed agents
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

    -- Move and remove agents
    local moved = {}
    for k,agent in ipairs(_agents) do
      local action, target = agent.getIntention(_map, _pathfinder)
      local oi, oj = _map.point2pos(agent.pos())
      local dir = (target + repulsion[agent])
                  :normalize()
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
      local ti, tj = agent.target()
      table.insert(moved, {agent, {oi, oj}, {pi, pj}})
      if ti == pi and tj == pj and action ~= 'nothing' then
        local settlement = _map.getTileData(ti, tj, 'settlement')
        settlement.accept(agent, action, _obj)
      end
    end
    for _,move in ipairs(moved) do
      local agent, from, to = unpack(move)
      local fi, fj = unpack(from)
      local ti, tj = unpack(to)
      if fi ~= ti or fj ~= tj then
        _unbucketAgent(agent, fi, fj)
        _bucketAgent(agent, ti, tj)
      end
    end
  end

end

return Stage

