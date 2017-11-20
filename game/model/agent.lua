
local DB        = require 'db'
local Behavior  = require 'model.behavior'
local Agent     = require 'lux.class' :new{}

local vec2    = require 'cpml' .vec2
local setfenv = setfenv
local unpack  = unpack
local ipairs  = ipairs
local pairs   = pairs
local print   = print
local math    = math

function Agent:instance(_obj, _specname, _stage)

  setfenv(1, _obj)

  local _NEIGHBORS    = DB.load('defs')['gameplay']['neighbors']
  local _TOLERANCE    = DB.load('defs')['gameplay']['tolerance']
  local _MAX_FATIGUE  = 100
  local _RETIRE       = Behavior('retire', _obj, _stage)
  local _DEFEND       = Behavior('defend', _obj, _stage)
  local _ASSAULT      = Behavior('assault', _obj, _stage)

  local _spec     = DB.load('agents/' .. _specname)
  local _behavior = Behavior(_spec['behavior'], _obj, _stage)

  function specname()
    return _specname
  end

  local _pos      = vec2(0, 0)

  local _fatigue  = 0
  local _log = {}
  local _blacklist = {}
  local _whitelist = {}
  local _retired  = false

  function fatigue()
    return _fatigue
  end

  function tire(amount)
    _fatigue = math.min(2*_MAX_FATIGUE, _fatigue + amount)
  end

  function restore(amount)
    _fatigue = math.max(0, _fatigue - amount)
  end

  function retire()
    _retired = true
  end

  function retired()
    return _retired
  end

  local _supply   = false
  local _treasure = DB.load('defs')['gameplay']['price']['training']/2/5

  function treasure()
    return _treasure
  end

  function gain(amount)
    _treasure = _treasure + amount
  end

  function spend(amount)
    if amount <= _treasure then
      _treasure = _treasure - amount
      return true
    end
  end

  function speed()
    local thresh = 0.75 * _MAX_FATIGUE
    local effective_fatigue = math.max(math.min(_fatigue, _MAX_FATIGUE), thresh)
                            - thresh
    return (1 - 0.5*effective_fatigue/(_MAX_FATIGUE - thresh))
         * _spec['speed']
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

  local _objective = nil
  local _target = nil
  local _status = nil

  local function log(settlement, score)
    local total = (_log[settlement] or 0) + score
    _log[settlement] = total
  end

  function done(settlement)
    _status = 'done'
    log(settlement, 1)
  end

  function fail(fatigue, settlement)
    _status = 'failed'
    log(settlement, -1)
    tire(fatigue)
  end

  function whitelisted(settlement)
    return (_log[settlement] or 0) >= _TOLERANCE
  end

  function blacklisted(settlement)
    return (_log[settlement] or 0) <= -_TOLERANCE
  end

  function objective()
    return _objective
  end

  function setObjective(objective)
    _objective = objective
  end

  function target()
    if _target then
      return unpack(_target)
    end
  end

  function setTarget(i, j)
    _target = {i,j}
  end

  function getIntention()
    local map             = _stage.map()
    local pathfinder      = _stage.pathfinder()
    _behavior.nextTarget(_status)
    local action = _objective
    local ti, tj = unpack(_target)
    if not action or not ti or not tj then return 'nothing', vec2(0,0) end
    _status = 'inprogress'
    local si, sj = map.point2pos(_pos)
    local pi, pj = pathfinder.findPath(si, sj, ti, tj)
    if pi and pj then
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

  function tick(dt)
    tire((_supply and 2 or 1)*dt/2)
    if _behavior ~= _RETIRE and _specname == 'worker' and _fatigue >= 150 then
      _behavior = _RETIRE
    elseif _behavior == _ASSAULT and _fatigue >= 100 then
      calmDown()
    end
  end

  function alert()
    if _specname == 'worker' then
      _behavior = _DEFEND
    end
  end

  function rampage()
    if _specname == 'monster' then
      _behavior = _ASSAULT
    end
  end

  function calmDown()
    _behavior = Behavior(_spec['behavior'], _obj, _stage)
  end

end

return Agent

