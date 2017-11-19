
local task = {}

function task.run(agent, stage, children)
  if agent.hasSupply() then
    agent.takeSupply()
  end
  return true
end

return task
