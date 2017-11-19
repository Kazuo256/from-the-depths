
local task = {}

local findsettlement  = require 'model.tasks.helpers.find_settlement'
local seek            = require 'model.tasks.helpers.seek'
local yield           = coroutine.yield

function task.run(agent, stage, children)
  agent.setTarget()
  agent.setObjective('nothing')
  local chosen1 = findsettlement(agent, stage, 'harvest')
  local chosen2 = findsettlement(agent, stage, 'rest')
  local pi, pj  = stage.map().point2pos(agent.pos())
  local dist1   = stage.pathfinder().dist(pi, pj, stage.settlementPos(chosen1))
  local dist2   = stage.pathfinder().dist(pi, pj, stage.settlementPos(chosen2))
  local chosen  = dist1 < dist2 and chosen1 or chosen2
  return seek(agent, stage, chosen, 'assault')
end

return task

