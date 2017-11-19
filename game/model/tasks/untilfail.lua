
local TASK = {}

function TASK.run(agent, stage, children)
  local child = children[1]
  repeat until not child.run(agent, stage, child.children)
  return false
end

return TASK

