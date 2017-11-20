
local yield = coroutine.yield

return function(agent, stage, settlement, action, maxdist)
  local ti, tj = stage.settlementPos(settlement)
  maxdist = maxdist or 20
  agent.setObjective(action)
  agent.setTarget(ti, tj)
  repeat
    local status = yield()
    if status == 'failed' then
      return false
    end
    local pi, pj = stage.map().point2pos(agent.pos())
    local dist = stage.pathfinder().dist(pi, pj, ti, tj) or 999
    if dist > maxdist then
      return false
    end
  until status == 'done'
  return true
end
