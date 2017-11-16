
local TASK = {}

local yield = coroutine.yield

function TASK.run(agent, stage, children)
  local pi, pj = stage.map().point2pos(agent.pos())
  for i=1,100 do
    yield(pi, pj)
  end
  return true
end

return TASK

