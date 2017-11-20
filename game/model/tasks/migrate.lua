
local task = {}

local findsettlement  = require 'model.tasks.helpers.find_settlement'
local seek            = require 'model.tasks.helpers.seek'
local yield           = coroutine.yield

function task.run(agent, stage, children)
  agent.setTarget()
  agent.setObjective('nothing')
  local pi, pj = stage.map().point2pos(agent.pos())
  local current = stage.map().getTileData(pi, pj, 'settlement')
  local chosen = findsettlement(agent, stage, 'den', { [current or 1] = true })
  return seek(agent, stage, chosen, 'migrate')
end

return task

