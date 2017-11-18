
local TASK = {}

local yield = coroutine.yield

function TASK.run(agent, stage, children)
  local settlements = {}
  local n = 0
  for settlement in stage.eachSettlement() do
    table.insert(settlements, settlement)
    n = n + 1
  end
  local pi, pj = stage.map().point2pos(agent.pos())
  local chosen = settlements[love.math.random(n)]
  local ti, tj = stage.settlementPos(chosen)
  local role = chosen.role()
  local action
  if role == 'harvest' then
    action = 'collect'
  elseif role == 'rest' then
    if agent.hasSupply() then
      action = 'sell'
    else
      action = 'rest'
    end
  else
    action = 'something'
  end
  repeat
    yield(action, ti, tj)
    pi, pj = stage.map().point2pos(agent.pos())
    local dist = stage.pathfinder().dist(pi, pj, ti, tj) or 999
    if dist > 20 then
      return false
    end
  until pi == ti and pj == tj
  return true
end

return TASK

