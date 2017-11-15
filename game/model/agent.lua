
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
    local pi, pj = map.point2pos(_pos)
    local ti, tj = target()
    local min
    local tgt
    for _,neigh in ipairs(_NEIGHBORS) do
      local i,j = pi + neigh[1], pj + neigh[2]
      local dist = pathfinder.dist(i, j, ti, tj)
      if dist and (not min or dist < min) then
        min = dist
        tgt = {i,j}
      end
    end
    if tgt then
      local target = map.pos2point(unpack(tgt))
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

