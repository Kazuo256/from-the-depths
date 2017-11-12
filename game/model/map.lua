
local DB  = require 'db'
local Map = require 'lux.class' :new{}

local setfenv = setfenv
local print   = print
local math    = math

function Map:tilesize()
  return DB.load('defs')['tile-size']
end

function Map:instance(_obj, _specname)

  setfenv(1, _obj)

  _specname         = 'maps/' .. _specname
  local _spec       = DB.load(_specname)

  --[[ Tile Grid ]]--

  local _w, _h      = _spec['width'], _spec['height']
  local _tiletypes  = DB.load('tiletypes')
  local _tiles      = {}

  local function _index(i,j)
    return (i-1)*_w + j
  end

  local function _inside(i,j)
    return i >= 1 and i <= _h and j >= 1 and j <= _h
  end

  local function _point2index(pos)
    local j = math.floor(pos.x / self:tilesize()) + 1
    local i = math.floor(pos.y / self:tilesize()) + 1
    return _inside(i,j) and _index(i,j)
  end

  for i=1,_h do
    for j=1,_w do
      local tile_specname = _spec.pallete[_spec.tiles[_index(i,j)]]
      local tile = {
        spec = _tiletypes[tile_specname]
      }
      _tiles[_index(i,j)] = tile
    end
  end

  function size()
    return _w, _h
  end

  function tilespec(i, j)
    return _tiles[_index(i,j)].spec
  end

  function passable(pos)
    local index = _point2index(pos)
    return index and _tiles[index].spec['passable']
  end

end

return Map

