
local task = {}

local findsettlement  = require 'model.tasks.helpers.find_assault_target'
local seek            = require 'model.tasks.helpers.seek'
local yield           = coroutine.yield

function task.run(agent, stage, children, params)
  agent.setTarget()
  agent.setObjective('nothing')
  local chosen = findsettlement(agent, stage)
  if chosen and (agent.specname() ~= 'worker' or
                 agent.lastFailed() ~= chosen) then
    return seek(agent, stage, chosen, 'defend', params['max-dist'])
  else
    return false
  end
end

return task

