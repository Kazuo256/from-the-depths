
local DB    = require 'db'
local Map   = require 'model.map'
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

  --[[ Base Camps ]]--

  local _camps  = {}

  local function _addCamp(spec)
    table.insert(_camps, { pos = spec['pos'], delay = spec['delay'] })
  end

  for _,campspec in ipairs(_spec['camps']) do
    _addCamp(campspec)
  end

  --[[ Overall Logic ]]--

  function update()
  end

end

return Stage

