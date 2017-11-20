
return function (agent, stage)
  for _,agent in stage.eachAgent() do
    if agent.specname() == 'monster' and agent.objective() == 'assault' then
      local ti, tj = agent.target()
      return stage.map().getTileData(ti, tj, 'settlement')
    end
  end
end

