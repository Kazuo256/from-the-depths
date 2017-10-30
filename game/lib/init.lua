local fs = love.filesystem
fs.setRequirePath("lib/?.lua;lib/?/init.lua;" .. fs.getRequirePath())
package.cpath = fs.getSourceBaseDirectory() .. "/?.so;" .. package.cpath
