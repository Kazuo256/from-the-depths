
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
  local dist = stage.pathfinder().dist(pi, pj, ti, tj) or 999
  if dist > 20 then
    return false
  end
  repeat
    pi, pj = stage.map().point2pos(agent.pos())
    yield('something', ti, tj)
  until pi == ti and pj == tj
  return true
end

return TASK

