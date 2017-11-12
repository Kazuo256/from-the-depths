
local DB          = require 'db'
local Settlement  = require 'lux.class' :new{}

local setfenv = setfenv
local print   = print

function Settlement:instance(_obj)

  setfenv(1, _obj)

  local _DELAY    = DB.load('defs')['gameplay']['spawn-delay']
  local _pending  = 0
  local _count    = 0
  local _next     = nil

  function tick(dt)
    if _pending > 0 then
      _count = _count + dt
      if _count >= _DELAY then
        _count = _count - _DELAY
        _next = 'test'
      end
    else
      _count = _DELAY
    end
  end

  function requestSpawn(n)
    _pending = _pending + n
  end

  function nextSpawn()
    if _next then
      local n = _next
      _next = nil
      _pending = _pending - 1
      return n
    end
  end

end

return Settlement

