
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
  local _pending  = Queue(128)
  local _count    = 0
  local _next     = false

  local _supplies = 0
  local _demand = 0

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

  local _SUPPLY_PRICE = DB.load('defs')['gameplay']['supply-price']

  function accept(agent, action, stage)
    if _role == 'harvest' and action == 'collect' then
      agent.giveSupply()
    elseif _role == 'rest' and action == 'sell' and _demand > 0
                           and agent.hasSupply()
                           and stage.spend(_SUPPLY_PRICE) then
      agent.takeSupply()
      agent.addTreasure(_SUPPLY_PRICE)
      _supplies = _supplies + 1
      _demand = _demand - 1
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

