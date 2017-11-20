
local TASK = {}

function TASK.run(agent, stage, children)
  local child = children[1]
  return not child.run(agent, stage)
end

return TASK

