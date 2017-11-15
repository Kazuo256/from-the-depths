
local DB    = require 'db'
local vec2  = require 'cpml' .vec2
local Map   = require 'lux.class' :new{}

local setfenv = setfenv
local print   = print
local math    = math

function Map:instance(_obj, _spec)

  setfenv(1, _obj)

  --[[ Tile Grid ]]--

  local _w, _h      = _spec['width'], _spec['height']
  local _tiletypes  = DB.load('tiletypes')
  local _tiles      = {}

  local function _index(i,j)
    return (i-1)*_w + j
  end

  local function _inside(i,j)
    return i >= 1 and i <= _h and j >= 1 and j <= _w
  end

  local function _point2pos(pos)
    local j = math.ceil(pos.x)
    local i = math.ceil(pos.y)
    return i, j
  end

  local function _point2index(pos)
    local i, j = _point2pos(pos)
    return _inside(i,j) and _index(i,j)
  end

  for i=1,_h do
    for j=1,_w do
      local index = _index(i,j)
      local tile_specname = _spec.pallete[_spec.tiles:sub(index,index)]
      local tile = {
        spec = _tiletypes[tile_specname]
      }
      _tiles[_index(i,j)] = tile
    end
  end

  function pos2index(i, j)
    return _index(i, j)
  end

  function point2pos(point)
    return _point2pos(point)
  end

  function pos2point(i, j)
    return vec2(j - 0.5, i - 0.5)
  end

  function size()
    return _w, _h
  end

  function tilespec(i, j)
    return _tiles[_index(i,j)].spec
  end

  function getTileData(i, j, key)
    local index = _inside(i,j) and _index(i,j)
    return index and _tiles[index][key]
  end

  function setTileData(i, j, key, value)
    local index = _inside(i,j) and _index(i,j)
    if index then
      _tiles[index][key] = value
    end
  end

  function passablePos(i, j)
    local index = _index(i, j)
    return index and _tiles[index].spec['passable']
  end

  function passable(point)
    return passablePos(_point2pos(point))
  end

end

return Map

