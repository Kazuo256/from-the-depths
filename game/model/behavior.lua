
local TASKS = require 'lux.pack' 'model.tasks'
local DB    = require 'db'
local Behavior = require 'lux.class' :new{}

local setfenv   = setfenv
local ipairs    = ipairs
local assert    = assert
local table     = table
local coroutine = coroutine
local print     = print

function Behavior:instance(_obj, _specname, _agent, _stage)

  setfenv(1, _obj)

  _specname     = 'behaviors/' .. _specname
  local _spec   = DB.load(_specname)
  local _tasks  = {}

  for _,taskspec in ipairs(_spec['tasks']) do
    assert(not _tasks[taskspec['id']])
    local task = {}
    task.run = TASKS[taskspec['typename']].run
    task.children = {}
    local parent = taskspec['parent'] if parent then
      table.insert(_tasks[parent].children, task)
    end
    _tasks[taskspec.id] = task
  end

  local function _routine(status)
    while true do
      local task = _tasks[_spec['root']]
      task.run(_agent, _stage, task.children, status)
    end
  end

  local _run = coroutine.wrap(_routine)

  function nextTarget(status)
    return _run(status)
  end

end

return Behavior

