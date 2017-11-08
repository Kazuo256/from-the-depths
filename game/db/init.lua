
local TOML  = require 'toml'
local FS    = love.filesystem
local DB    = {}

local _PATH_FMT = "db/%s.toml"

local _CACHE = {}

function DB.load(path)
  local spec = _CACHE[path]
  if not spec then
    local fullpath = _PATH_FMT:format(path)
    print(fullpath)
    local file = FS.newFile(fullpath, 'r')
    local data = file:read()
    file:close()
    spec = TOML.parse(data)
    _CACHE[path] = spec
  end
  return spec
end

return DB

