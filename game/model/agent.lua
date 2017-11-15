
local DB    = require 'db'
local Agent = require 'lux.class' :new{}

local vec2    = require 'cpml' .vec2
local setfenv = setfenv
local unpack  = unpack
local ipairs  = ipairs

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
    local si, sj = map.point2pos(_pos)
    local ti, tj = target()
    local dist = pathfinder.dist(si, sj, ti, tj)
    local pi, pj = pathfinder.findPath(
      si, sj, ti, tj,
      function (i, j)
        return map.getTileData(i, j, 'agents')
      end,
      dist+10
    )
    if pi and pj then
      local target = map.pos2point(pi, pj)
      local dir = vec2(0, 0)
      local dist = target - _pos
      if dist:len2() > 0.001 then
        dir = dist:normalize()
      end
      return dir
    else
      return vec2(0, 0)
    end
  end

  function move(dir, dt)
    return _pos + dir * speed() * dt
  end

end

return Agent

