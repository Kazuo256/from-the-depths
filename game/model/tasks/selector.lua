
local TASK = {}

function TASK.run(agent, stage, children)
  for _,child in ipairs(children) do
    if child.run(agent, stage) then
      return true
    end
  end
  return false
end

return TASK

