
local task = {}

local yield = coroutine.yield

function task.run(agent, stage, children)
  agent.calmDown()
  yield()
  return true
end

return task
