
local DB          = require 'db'
local Heap        = require 'lux.common.Heap'
local PathFinder  = require 'lux.class' :new{}

local setfenv = setfenv
local unpack  = unpack
local ipairs  = ipairs
local print   = print

function PathFinder:instance(_obj, _map)

  setfenv(1, _obj)

  local _NEIGHBORS = DB.load('defs')['gameplay']['neighbors']

  local _frontier = Heap()

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

  local function _generateDists(i, j)
    _frontier.clear()
    _frontier.push({i,j}, 0)
    local cost = _newGrid()
    _set(cost, 0, i, j)
    while not _frontier.isEmpty() do
      local cur_i, cur_j = unpack((_frontier.pop()))
      for _,neighbor in ipairs(_NEIGHBORS) do
        local nex_i, nex_j = cur_i + neighbor[1], cur_j + neighbor[2]
        if _map.passablePos(nex_i, nex_j) then
          local new_cost = _get(cost, cur_i, cur_j)
                         + _dist(cur_i, cur_j, nex_i, nex_j)
          local previous_cost = _get(cost, nex_i, nex_j)
          if not previous_cost or new_cost < previous_cost then
            _set(cost, new_cost, nex_i, nex_j)
            _frontier.push({nex_i, nex_j}, new_cost)
          end
        end
      end
    end
    return cost
  end

  function dist(from_i, from_j, to_i, to_j)
      local dists = _map.getTileData(to_i, to_j, 'dists')
      if not dists then
        dists = _generateDists(to_i, to_j)
        _map.setTileData(to_i, to_j, 'dists', dists)
      end
      return _get(dists, from_i, from_j)
    end


  function findPath(si, sj, ti, tj, extra_cost, halt_cost)
    local cost = _newGrid()
    local from = _newGrid()
    extra_cost = extra_cost or function() return 0 end
    _frontier.clear()
    _frontier.push({si,sj}, 0)
    _set(cost, 0, si, sj)
    while not _frontier.isEmpty() do
      local cur_i, cur_j = unpack((_frontier.pop()))

      if cur_i == ti and cur_j == tj then
        break
      end

      for _,neighbor in ipairs(_NEIGHBORS) do
        local nex_i, nex_j = cur_i + neighbor[1], cur_j + neighbor[2]
        if _map.passablePos(nex_i, nex_j) then
          local previous_cost = _get(cost, nex_i, nex_j)
          if previous_cost and previous_cost > halt_cost then
            return false
          end
          local new_cost = _get(cost, cur_i, cur_j)
                         + _dist(cur_i, cur_j, nex_i, nex_j)
                         + extra_cost(nex_i, nex_j)
          if not previous_cost or new_cost < previous_cost then
            local priority = new_cost + _dist(nex_i, nex_j, ti, tj)
            _frontier.push({nex_i, nex_j}, priority)
            _set(cost, new_cost, nex_i, nex_j)
            _set(from, {cur_i, cur_j}, nex_i, nex_j)
          end
        end
      end
    end
    if not _get(from, ti, tj) then
      return false
    end
    local pi, pj = ti, tj
    while true do
      local fi, fj = unpack(_get(from, pi, pj))
      if fi == si and fj == sj then
        break
      else
        pi, pj = fi, fj
      end
    end
    return pi, pj
  end

end

return PathFinder

