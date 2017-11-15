
local vec2  = require 'cpml' .vec2
local MOUSE = {}

local _down = { false, false }
local _clicked = { false, false }
local _motion = vec2(0,0)

function MOUSE.move(motion)
  _motion = _motion + motion
end

function MOUSE.update(dt)
  for i=1,3 do
    local last = _down[i]
    _down[i] = love.mouse.isDown(i)
    _clicked[i] = _down[i] and not last
  end
end

function MOUSE.clear(dt)
  _motion = vec2(0,0)
end

function MOUSE.down(i)
  return _down[i]
end

function MOUSE.pos()
  return vec2(love.mouse.getPosition())
end

function MOUSE.motion()
  return _motion
end

function MOUSE.clicked(i)
  return _clicked[i]
end

return MOUSE

