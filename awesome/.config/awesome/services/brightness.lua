-- DEPENDENCIES: xbacklight

-- Required libraries
local capi = Capi
local tonumber = tonumber
local gtimer = require("gears.timer")
local awful = require("awful")
local math = require("math")

-- Service definition for brightness control using xbacklight
local brightness_service = {
	config = {
		-- How often to check for brightness changes (in seconds)
		interval = 2,
		-- The application to call
		app = "xbacklight",
	},
	data = {
		brightness = 0,
	},
	timer = nil,
}

-- This table generates the command-line arguments for xbacklight
local commands = {}

--- Returns the arguments to get brightness.
---@return string
function commands.get_data()
	return "-get"
end

--- Returns the arguments to set the brightness to a specific percentage.
---@param brightness number The target brightness percentage.
---@return string
function commands.set_brightness(brightness)
	return "-set " .. string.format("%.0f", brightness)
end

--- Returns the arguments to increase or decrease the brightness by a step.
---@param step number The percentage to change the brightness by (can be negative).
---@return string
function commands.change_brightness(step)
	step = step or 10 -- A reasonable default step
	return (step > 0 and "-inc " or "-dec ") .. math.abs(step)
end

--- Parses the output of the "xbacklight -get" command to extract brightness.
---@param raw_data string The raw stdout from xbacklight.
---@return table|nil A table with {brightness} or nil if parsing fails.
local function parse_raw_data(raw_data)
	local brightness_str = raw_data:match("([%d%.]+)")
	if not brightness_str then
		return nil
	end

	return {
		brightness = tonumber(brightness_str),
	}
end

--- Fetches the current brightness status from xbacklight and emits a signal with the data.
---@param skip_osd boolean If true, signals that the OSD/notification should be suppressed.
local function fetch_and_update_state(skip_osd)
	local command = brightness_service.config.app .. " " .. commands.get_data()

	awful.spawn.easy_async(command, function(stdout, stderr, exitreason, exitcode)
		if exitreason ~= "exit" or exitcode ~= 0 or not stdout then
			-- Command failed, do nothing.
			return
		end

		local new_data = parse_raw_data(stdout)
		if new_data then
			-- Update the service's data and emit a signal for widgets to update
			brightness_service.data = new_data
			brightness_service.data.skip_osd = skip_osd
			capi.awesome.emit_signal("brightness::update", brightness_service.data)
		end
	end)
end

--- Asynchronously runs a command to change the brightness, then fetches the new state.
---@param command_generator function A function from the 'commands' table.
---@param value any The value to pass to the command_generator.
---@param skip_osd boolean If true, suppresses the OSD.
local function run_and_update(command_generator, value, skip_osd)
	local command = brightness_service.config.app .. " " .. command_generator(value)
	awful.spawn.easy_async(command, function(stdout, stderr, exitreason, exitcode)
		-- After the command runs, fetch the new state to get the canonical value.
		if exitreason == "exit" and exitcode == 0 then
			fetch_and_update_state(skip_osd)
		end
	end)
end

--- Sets the brightness to a specific level.
---@param brightness number The target brightness percentage (0-100).
---@param skip_osd boolean If true, suppresses the OSD.
function brightness_service.set_brightness(brightness, skip_osd)
	run_and_update(commands.set_brightness, brightness, skip_osd)
end

--- Changes the brightness by a given amount.
---@param step number The amount to change by (e.g., 10 for up, -10 for down).
---@param skip_osd boolean If true, suppresses the OSD.
function brightness_service.change_brightness(step, skip_osd)
	run_and_update(commands.change_brightness, step, skip_osd)
end

--- Starts a timer to periodically check the brightness.
function brightness_service.watch()
	brightness_service.timer = brightness_service.timer
		or gtimer({
			timeout = brightness_service.config.interval,
			call_now = true,
			autostart = true,
			callback = function()
				-- Polling should not trigger the OSD.
				fetch_and_update_state(true)
			end,
		})
end

return brightness_service
