local awful = require("awful")

local startup_apps = {
	"~/.config/awesome/autostart.sh",
}

for _, app_command in ipairs(startup_apps) do
	awful.spawn.with_shell(app_command)
end
