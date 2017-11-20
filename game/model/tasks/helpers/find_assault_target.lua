
return function (agent, stage)
  for _,other in stage.eachAgent() do
    if agent.specname() == 'worker' and other.specname() == 'monster'
                                    and other.objective() == 'assault' then
      local ti, tj = other.target()
      return stage.map().getTileData(ti, tj, 'settlement')
    elseif agent.specname() == 'monster' and
           other.specname() == 'worker' and
           other.objective() == 'scavenge' then
      local ti, tj = other.target()
      return stage.map().getTileData(ti, tj, 'settlement')
    end
  end
end

