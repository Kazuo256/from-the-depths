
local task = {}

local findsettlement  = require 'model.tasks.helpers.find_assault_target'
local seek            = require 'model.tasks.helpers.seek'
local yield           = coroutine.yield

function task.run(agent, stage, children)
  agent.setTarget()
  agent.setObjective('nothing')
  local chosen = findsettlement(agent, stage)
  if chosen then
    return seek(agent, stage, chosen, 'defend')
  else
    return false
  end
end

return task

