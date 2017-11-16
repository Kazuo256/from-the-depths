
local TASK = {}

local yield = coroutine.yield

function TASK.run(agent, stage, children)
  local settlements = {}
  local n = 0
  for settlement in stage.eachSettlement() do
    table.insert(settlements, settlement)
    n = n + 1
  end
  local chosen = settlements[love.math.random(n)]
  local ti, tj = stage.settlementPos(chosen)
  repeat
    yield(ti, tj)
    local pi, pj = stage.map().point2pos(agent.pos())
  until pi == ti and pj == tj
  return true
end

return TASK

