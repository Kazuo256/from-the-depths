
local function cmp(agent, dist1, settl1, dist2, settl2)
  local white1, black1 = agent.whitelisted(settl1), agent.blacklisted(settl1)
  local white2, black2 = agent.whitelisted(settl2), agent.blacklisted(settl2)
  if white1 == white2 and black1 == black2 then
    return dist1 < dist2
  else 
    return white1 and not white2
        or black2 and not black1
  end
end

return function (agent, stage, role, exclude)
  local chosen
  local min = 999
  local pi, pj = stage.map().point2pos(agent.pos())
  exclude = exclude or {}
  for settlement in stage.eachSettlement() do
    if settlement.role() == role and not exclude[settlement] then
      local ti, tj = stage.settlementPos(settlement)
      local dist   = stage.pathfinder().dist(pi, pj, ti, tj)
      if not chosen or cmp(agent, dist, settlement, min, chosen) then
        min = dist
        chosen = settlement
      end
    end
  end
  return chosen
end

