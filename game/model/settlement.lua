
local DB          = require 'db'
local Settlement  = require 'lux.class' :new{}

local setfenv = setfenv

function Settlement:instance(_obj)

  setfenv(1, _obj)

  local _DELAY = DB.load('defs')['gameplay']['spawn-delay']
  local _count = 0
  local _next  = nil

  function tick(dt)
    _count = _count + dt
    if _count > _DELAY then
      _count = _count - _DELAY
      _next = 'test'
    end
  end

  function nextSpawn()
    local n = _next
    _next = nil
    return n
  end

end

return Settlement

