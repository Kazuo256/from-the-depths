
local DB          = require 'db'
local Queue       = require 'lux.common.Queue'
local Settlement  = require 'lux.class' :new{}

local setfenv = setfenv
local print   = print

Settlement.roles = {
  harvest = {
  },
  training = {
    action = "Train +5"
  },
  rest = {
    action = "Buy +10"
  }
}

function Settlement:instance(_obj, _role)

  setfenv(1, _obj)

  local _DELAY    = DB.load('defs')['gameplay']['spawn-delay']
  local _RATE     = DB.load('defs')['gameplay']['production-rate']
  local _PRICE    = DB.load('defs')['gameplay']['price']

  -- Agent spawning
  local _pending  = Queue(128)
  local _count    = 0
  local _next     = false

  -- Economy
  local _supplies = 0
  local _demand = 0
  local _production_count = 0

  function role()
    return _role
  end

  function roleAction()
    return self.roles[_role].action
  end

  function increaseDemand(amount)
    _demand = _demand + amount
  end

  function demand()
    return _demand
  end

  function supplies()
    return _supplies
  end

  function spendSupplies(n)
    if n <= _supplies then
      _supplies = _supplies - n
      return true
    end
  end

  function accept(agent, action, stage)
    if _role == 'harvest' and action == 'collect' and _supplies > 0 then
      agent.giveSupply()
      _supplies = _supplies - 1
    elseif _role == 'rest' and action == 'sell' and _demand > 0
                           and agent.hasSupply()
                           and stage.spend(_PRICE['supply']) then
      agent.takeSupply()
      agent.gain(_PRICE['supply'])
      _supplies = _supplies + 1
      _demand = _demand - 1
    elseif _role == 'rest' and action == 'rest' and _supplies > 0
                           and agent.spend(_PRICE['rest']) then
      agent.restore()
      _supplies = _supplies - 1
      stage.gain(_PRICE['rest'])
    end
  end

  function tick(dt)
    if not _pending.isEmpty() then
      _count = _count + dt
      if _count >= _DELAY then
        _count = _count - _DELAY
        _next = true
      end
    else
      _count = _DELAY
    end
    if _role == 'harvest' then
      local inv_rate = 60 * 1/_RATE
      _production_count = _production_count + dt
      if _production_count > inv_rate then
        _supplies = _supplies + 1
        _production_count = _production_count - inv_rate
      end
    end
  end

  function requestSpawn(n, typename)
    for i=1,n do
      _pending.push(typename)
    end
  end

  function nextSpawn()
    if _next then
      _next = false
      return _pending.pop()
    end
  end

end

return Settlement

