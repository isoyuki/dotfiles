-- DEPENDENCIES: amixer

-- Required libraries
local capi = Capi
local tonumber = tonumber
local string = string
local gtimer = require("gears.timer")
local awful = require("awful")
local math = require("math")

-- Service definition for volume control using amixer
local volume_service = {
	config = {
		-- How often to check for volume changes (in seconds)
		interval = 2,
		-- The amixer control to use. 'Master' is common, but you can also use
		-- 'PCM', 'Headphone', or 'Speaker' depending on your system.
		-- Use `amixer scontrols` to list available controls.
		control = "Master",
		-- The application to call
		app = "amixer",
	},
	data = {
		volume = 0,
		muted = false,
	},
	timer = nil,
}

-- This table generates the command-line arguments for amixer
local commands = {}

--- Returns the arguments to get volume and mute status.
---@return string
function commands.get_data()
	return "sget " .. volume_service.config.control
end

--- Returns the arguments to set the volume to a specific percentage.
---@param volume number The target volume percentage.
---@return string
function commands.set_volume(volume)
	return "sset " .. volume_service.config.control .. " " .. string.format("%.0f", volume) .. "%"
end

--- Returns the arguments to increase or decrease the volume by a step.
---@param step number The percentage to change the volume by (can be negative).
---@return string
function commands.change_volume(step)
	step = step or 5 -- A reasonable default step
	return "sset " .. volume_service.config.control .. " " .. math.abs(step) .. "%" .. (step > 0 and "+" or "-")
end

--- Returns the arguments to toggle the mute state.
---@return string
function commands.toggle_mute()
	return "sset " .. volume_service.config.control .. " toggle"
end

--- Parses the output of the "amixer sget" command to extract volume and mute status.
---@param raw_data string The raw stdout from amixer.
---@return table|nil A table with {volume, muted} or nil if parsing fails.
local function parse_raw_data(raw_data)
	-- Find a line containing volume and mute information. We prioritize 'Front Left'
	-- for stereo setups, but fallback to 'Mono' for single-channel controls.
	-- Example line: "  Front Left: Playback 6553 [100%] [0.00dB] [on]"
	local line = raw_data:match("([^\n]*Front Left:[^\n]*)")
	if not line then
		line = raw_data:match("([^\n]*Mono:[^\n]*Playback[^\n]*)")
	end

	-- If no relevant line is found, we can't determine the state.
	if not line then
		return nil
	end

	local volume_str = line:match("%[(%d+)%%%]")
	local mute_str = line:match("%[([onf]+)%]") -- Matches '[on]' or '[off]'

	if not volume_str or not mute_str then
		return nil
	end

	return {
		volume = tonumber(volume_str),
		muted = (mute_str == "off"),
	}
end

--- Fetches the current volume status from amixer and emits a signal with the data.
---@param skip_osd boolean If true, signals that the OSD/notification should be suppressed.
local function fetch_and_update_state(skip_osd)
	local command = volume_service.config.app .. " " .. commands.get_data()

	awful.spawn.easy_async(command, function(stdout, stderr, exitreason, exitcode)
		if exitreason ~= "exit" or exitcode ~= 0 or not stdout then
			-- Command failed, do nothing.
			return
		end

		local new_data = parse_raw_data(stdout)
		if new_data then
			-- Update the service's data and emit a signal for widgets to update
			volume_service.data = new_data
			volume_service.data.skip_osd = skip_osd
			capi.awesome.emit_signal("volume::update", volume_service.data)
		end
	end)
end

--- Asynchronously runs a command to change the volume, then fetches the new state.
---@param command_generator function A function from the 'commands' table.
---@param value any The value to pass to the command_generator.
---@param skip_osd boolean If true, suppresses the OSD.
local function run_and_update(command_generator, value, skip_osd)
	local command = volume_service.config.app .. " " .. command_generator(value)
	awful.spawn.easy_async(command, function(stdout, stderr, exitreason, exitcode)
		-- After the command runs, fetch the new state to get the canonical value.
		-- This is necessary because "5%+" might result in 100%, not 105%.
		if exitreason == "exit" and exitcode == 0 then
			fetch_and_update_state(skip_osd)
		end
	end)
end

--- Sets the volume to a specific level.
---@param volume number The target volume percentage (0-100+).
---@param skip_osd boolean If true, suppresses the OSD.
function volume_service.set_volume(volume, skip_osd)
	run_and_update(commands.set_volume, volume, skip_osd)
end

--- Changes the volume by a given amount.
---@param step number The amount to change by (e.g., 5 for up, -5 for down).
---@param skip_osd boolean If true, suppresses the OSD.
function volume_service.change_volume(step, skip_osd)
	run_and_update(commands.change_volume, step, skip_osd)
end

--- Toggles between muted and unmuted.
---@param skip_osd boolean If true, suppresses the OSD.
function volume_service.toggle_mute(skip_osd)
	run_and_update(commands.toggle_mute, nil, skip_osd)
end

--- Starts a timer to periodically check the volume.
-- This is useful for keeping the volume widget synced if the volume is
-- changed by an external application or media keys.
function volume_service.watch()
	volume_service.timer = volume_service.timer
		or gtimer({
			timeout = volume_service.config.interval,
			call_now = true,
			autostart = true,
			callback = function()
				-- Polling should not trigger the OSD.
				fetch_and_update_state(true)
			end,
		})
end

return volume_service
