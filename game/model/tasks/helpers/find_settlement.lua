
return function (stage, role)
  local settlements = {}
  local n = 0
  for settlement in stage.eachSettlement() do
    if settlement.role() == role then
      table.insert(settlements, settlement)
      n = n + 1
    end
  end
  return settlements[love.math.random(n)]
end

