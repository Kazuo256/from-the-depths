
local DB  =  require 'db'
local TASK = {}

function TASK.run(agent, stage, children)
  return agent.treasure() >= DB.load('defs')['gameplay']['price']['rest']
end

return TASK

