
local task = {}

local findsettlement  = require 'model.tasks.helpers.find_settlement'
local seek            = require 'model.tasks.helpers.seek'
local yield           = coroutine.yield

function task.run(agent, stage, children)
  local chosen = findsettlement(agent, stage, 'rest')
  return seek(agent, stage, chosen, 'sell')
end

return task

