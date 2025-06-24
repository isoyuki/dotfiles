require("develop")
require("globals")

require("core")

require("theme")
require("rice")
require("services")
require("ui")
require("autostart")

---@diagnostic disable: param-type-mismatch
collectgarbage("setpause", 110)
collectgarbage("setstepmul", 1000)
---@diagnostic enable: param-type-mismatch
