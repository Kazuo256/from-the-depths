
local TASK = {}

function TASK.run(agent, stage, children)
  return agent.fatigue() < 50
end

return TASK

