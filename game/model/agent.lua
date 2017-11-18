
local DB        = require 'db'
local Behavior  = require 'model.behavior'
local Agent     = require 'lux.class' :new{}

local vec2    = require 'cpml' .vec2
local setfenv = setfenv
local unpack  = unpack
local ipairs  = ipairs
local pairs   = pairs
local print   = print

function Agent:instance(_obj, _specname, _stage)

  setfenv(1, _obj)

  local _NEIGHBORS = DB.load('defs')['gameplay']['neighbors']

  _specname       = 'agents/' .. _specname
  local _spec     = DB.load(_specname)
  local _behavior = Behavior(_spec['behavior'], _obj, _stage)
  local _pos      = vec2(0, 0)
  local _target   = nil

  local _supply   = false

  function speed()
    return _spec['speed']
  end

  function pos()
    return _pos
  end

  function setPos(pos)
    _pos = pos
  end

  function hasSupply()
    return _supply
  end

  function giveSupply()
    _supply = true
  end

  function takeSupply()
    _supply = false
  end

  function target()
    if _target then
      return unpack(_target)
    end
  end

  function getIntention()
    local map             = _stage.map()
    local pathfinder      = _stage.pathfinder()
    local action, ti, tj  = _behavior.nextTarget()
    if not ti or not tj then return 'nothing', vec2(0,0) end
    local si, sj = map.point2pos(_pos)
    local pi, pj = pathfinder.findPath(si, sj, ti, tj)
    if pi and pj then
      _target = {ti, tj}
      local target = map.pos2point(pi, pj)
      local dir = vec2(0, 0)
      local dist = target - _pos
      if dist:len2() > 0.001 then
        dir = dist:normalize()
      end
      return action, dir
    else
      return action, vec2(0, 0)
    end
  end

  function move(dir, dt)
    return _pos + dir * speed() * dt
  end

end

return Agent

