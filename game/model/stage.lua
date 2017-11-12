
local DB    = require 'db'
local Map   = require 'model.map'
local Stage = require 'lux.class' :new{}

local setfenv = setfenv
local print   = print

function Stage:instance(_obj, _specname)

  setfenv(1, _obj)

  _specname     = 'stages/' .. _specname
  local _spec   = DB.load(_specname)
  local _map    = Map(_spec['map'])

  function map()
    return _map
  end

  function update()
  end

end

return Stage

