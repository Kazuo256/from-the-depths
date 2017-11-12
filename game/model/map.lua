
local DB  = require 'db'
local Map = require 'lux.class' :new{}

local setfenv = setfenv
local print   = print
local ipairs  = ipairs
local table   = table

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

  function tilespec(i,j)
    return _tiles[_index(i,j)].spec
  end

  --[[ Base Camps ]]--

  local _camps  = {}

  local function _addCamp(spec)
    table.insert(_camps, { pos = spec['pos'], delay = spec['delay'] })
  end

  for _,campspec in ipairs(_spec['camps']) do
    _addCamp(campspec)
  end

end

return Map

