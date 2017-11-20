
local TASK = {}

local yield = coroutine.yield

function TASK.run(agent, stage, children)
  local pi, pj = stage.map().point2pos(agent.pos())
  agent.setObjective('wait')
  for i=1,20 do
    yield()
  end
  return true
end

return TASK

