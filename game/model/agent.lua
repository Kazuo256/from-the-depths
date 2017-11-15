
local DB    = require 'db'
local Agent = require 'lux.class' :new{}

local vec2    = require 'cpml' .vec2
local setfenv = setfenv
local unpack  = unpack

function Agent:instance(_obj, _specname)

  setfenv(1, _obj)

  local _NEIGHBORS = DB.load('defs')['gameplay']['neighbors']

  _specname     = 'agents/' .. _specname
  local _spec   = DB.load(_specname)
  local _pos    = vec2(0, 0)
  local _target = {1,1}

  function speed()
    return _spec['speed']
  end

  function pos()
    return _pos
  end

  function setPos(pos)
    _pos = pos
  end

  function target()
    return unpack(_target)
  end

  function setTarget(target)
    _target = target
  end

  function getIntention(map, pathfinder)
    local target = map.pos2point(unpack(_target))
    local dir = vec2(0, 0)
    local dist = target - _pos
    if dist:len2() > 0.001 then
      dir = dist:normalize()
    end
    return dir
  end

  function move(dir, dt)
    return _pos + dir * speed() * dt
  end

end

return Agent

