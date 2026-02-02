-- Map brightness keys
local awful = require("awful")

require("develop")
require("globals")

require("core")

require("theme")
require("rice")
local services = require("services")
if services.wallpaper then
  services.wallpaper.restore()
end

require("ui")
require("autostart")

---@diagnostic disable: param-type-mismatch
collectgarbage("setpause", 110)
collectgarbage("setstepmul", 1000)
---@diagnostic enable: param-type-mismatch
