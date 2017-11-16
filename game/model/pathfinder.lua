
local DB          = require 'db'
local Heap        = require 'lux.common.Heap'
local Queue       = require 'lux.common.Queue'
local PathFinder  = require 'lux.class' :new{}

local setfenv = setfenv
local unpack  = unpack
local ipairs  = ipairs
local pairs   = pairs
local print   = print

function PathFinder:instance(_obj, _map)

  setfenv(1, _obj)

  local _NEIGHBORS  = DB.load('defs')['gameplay']['neighbors']

  local _frontier = Heap()
  local _paths    = {}
  local _next     = Queue(128)

  local function _get(tiles, i, j)
    return tiles[_map.pos2index(i, j)]
  end

  local function _set(tiles, val, i, j)
    tiles[_map.pos2index(i, j)] = val
  end

  local function _newGrid()
    local grid = {}
    local w, h = _map.size()
    for i=1,h do
      for j=1,w do
        _set(grid, false, i, j)
      end
    end
    return grid
  end

  local function _dist(i1, j1, i2, j2)
    local di, dj = i1-i2, j1-j2
    return (di*di + dj*dj) ^ 0.5
  end

  function generatePaths(i, j, extra_cost)
    local cost = _newGrid()
    local from = _newGrid()
    _frontier.clear()
    _frontier.push({i,j}, 0)
    _set(cost, 0, i, j)
    while not _frontier.isEmpty() do
      local cur_i, cur_j = unpack((_frontier.pop()))
      for _,neighbor in ipairs(_NEIGHBORS) do
        local nex_i, nex_j = cur_i + neighbor[1], cur_j + neighbor[2]
        if _map.passablePos(nex_i, nex_j) then
          local new_cost = _get(cost, cur_i, cur_j)
                         + _dist(cur_i, cur_j, nex_i, nex_j)
                         + extra_cost(nex_i, nex_j)
          local previous_cost = _get(cost, nex_i, nex_j)
          if not previous_cost or new_cost < previous_cost then
            _set(cost, new_cost, nex_i, nex_j)
            _set(from, {cur_i, cur_j}, nex_i, nex_j)
            _frontier.push({nex_i, nex_j}, new_cost)
          end
        end
      end
    end
    _map.setTileData(i, j, 'paths', from)
    _map.setTileData(i, j, 'dists', cost)
  end

  function registerOrigin(tag, origin)
    _paths[tag] = origin
  end

  function updatePaths(dt)
    if _next.isEmpty() then
      for _,origin in pairs(_paths) do
        _next.push(origin)
      end
    else
      local origin = _next.pop()
      generatePaths(origin.pos[1], origin.pos[2], origin.extra)
    end
  end

  function findPath(si, sj, ti, tj)
    return unpack(_get(_map.getTileData(ti, tj, 'paths') or {}, si, sj) or {})
  end

  function dist(si, sj, ti, tj)
    return _get(_map.getTileData(ti, tj, 'dists') or {}, si, sj)
  end

end

return PathFinder

