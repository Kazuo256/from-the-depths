
local DB    = require 'db'
local Agent = require 'lux.class' :new{}

local vec2    = require 'cpml' .vec2
local setfenv = setfenv

function Agent:instance(_obj, _specname)

  setfenv(1, _obj)

  _specname = 'agents/' .. _specname
  local _spec = DB.load(_specname)
  local _pos  = vec2(0, 0)

  function speed()
    return _spec['speed']
  end

  function pos()
    return _pos
  end

  function setPos(pos)
    _pos = pos
  end

  function move(dt)
    _pos = _pos + vec2(1,0) * speed() * dt
  end

end

return Agent

