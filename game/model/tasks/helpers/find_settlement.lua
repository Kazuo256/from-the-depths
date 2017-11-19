
return function (agent, stage, role)
  local chosen
  local min = 999
  local pi, pj = stage.map().point2pos(agent.pos())
  for settlement in stage.eachSettlement() do
    if settlement.role() == role then
      local ti, tj = stage.settlementPos(settlement)
      local dist   = stage.pathfinder().dist(pi, pj, ti, tj)
      if dist < min then
        min = dist
        chosen = settlement
      end
    end
  end
  return chosen
end

