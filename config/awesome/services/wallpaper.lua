-- DEPENDENCIES (feature flag "wallpaper_menu"): nitrogen

local config = require("rice.config")
if not config.features.wallpaper_menu then
	return
end

local awful = require("awful")

local wallpaper_service = {}

function wallpaper_service.set_collection(collection)
	awful.spawn("nitrogen --set-zoom-fill " .. collection.path)
end

function wallpaper_service.restore()
	awful.spawn("nitrogen --restore")
end

return wallpaper_service
