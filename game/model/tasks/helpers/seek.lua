
local yield = coroutine.yield

return function(agent, stage, settlement, action)
  local ti, tj = stage.settlementPos(settlement)
  agent.setObjective(action)
  agent.setTarget(ti, tj)
  repeat
    local status = yield()
    if status == 'failed' then
      return false
    end
    local pi, pj = stage.map().point2pos(agent.pos())
    local dist = stage.pathfinder().dist(pi, pj, ti, tj) or 999
    if dist > 12 then
      return false
    end
  until status == 'done'
  return true
end
