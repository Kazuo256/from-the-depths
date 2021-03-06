
local task = {}

local findsettlement  = require 'model.tasks.helpers.find_settlement'
local seek            = require 'model.tasks.helpers.seek'
local yield           = coroutine.yield

function task.run(agent, stage, children)
  agent.setTarget()
  agent.setObjective('nothing')
  local chosen = findsettlement(agent, stage, 'training')
  return seek(agent, stage, chosen, 'retire')
end

return task

