
local TASK = {}

function TASK.run(agent, stage, children)
  return agent.hasSupply()
end

return TASK

