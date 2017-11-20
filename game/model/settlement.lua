
local DB          = require 'db'
local Queue       = require 'lux.common.Queue'
local Settlement  = require 'lux.class' :new{}

local setfenv = setfenv
local print   = print
local math    = math
local love    = love

Settlement.roles = {
  harvest = {
  },
  training = {
    action = "Train +5"
  },
  rest = {
    action = "Buy +10"
  },
  den = {}
}

function Settlement:instance(_obj, _role)

  setfenv(1, _obj)

  local _DELAY    = DB.load('defs')['gameplay']['spawn-delay']
  local _RATE     = DB.load('defs')['gameplay']['production-rate']
  local _PRICE    = DB.load('defs')['gameplay']['price']
  local _MONSTER  = DB.load('defs')['gameplay']['monster']

  -- Agent spawning
  local _pending  = Queue(128)
  local _count    = 0
  local _next     = false

  if _role == 'den' then
    _pending.push('monster', 'monster', 'monster')
  end

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
    if _role == 'harvest' and action == 'collect' then
      if _supplies > 0 then
        agent.giveSupply()
        _supplies = _supplies - 1
        agent.done()
      else
        agent.fail(5, _obj)
      end
    elseif _role == 'rest' and action == 'sell' then
      if _demand > 0 and agent.hasSupply()
                     and stage.spend(_PRICE['supply']) then
        agent.takeSupply()
        agent.gain(_PRICE['supply'])
        _supplies = _supplies + 1
        _demand = _demand - 1
        agent.done()
      else
        agent.fail(10, _obj)
      end
    elseif _role == 'rest' and action == 'rest' then
      if _supplies >= 1 and agent.spend(_PRICE['rest']) then
        agent.restore(40)
        _supplies = _supplies - 1
        stage.gain(_PRICE['rest'])
        agent.done()
      else
        agent.fail(0, _obj)
      end
    elseif _role == 'den' and action == 'scavenge' then
      agent.gain(_MONSTER['treasure-base'] +
                 math.floor(_MONSTER['treasure-range'] * love.math.random()))
      agent.fail(50, _obj)
      agent.done()
    elseif _role == 'den' and action == 'migrate' then
      agent.restore(200)
      agent.fail(0, _obj)
      agent.done()
    elseif _role == 'training' and action == 'retire' then
      agent.retire()
    elseif action == 'assault' then
      _supplies = 0
      agent.calmDown()
      agent.done()
    elseif action == 'defend' then
      agent.done()
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

