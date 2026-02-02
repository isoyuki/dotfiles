local capi = Capi
local awful = require("awful")
local wibox = require("wibox")
local gtimer = require("gears.timer")
local binding = require("core.binding")
local btn = binding.button
local beautiful = require("theme.theme")
local dpi = Dpi
local gshape = require("gears.shape")
local gtable = require("gears.table")
local pango = require("utils.pango")
local noice = require("core.style")


---@class BrightnessOsd.module
local M = {}


---@class BrightnessOsd.data
---@field is_set boolean
---@field brightness number
---@field skip_osd? boolean

---@class BrightnessOsd : awful.popup, stylable
---@field package _private BrightnessOsd.private
---Style properties:
---@field paddings thickness
M.object = {}
---@class BrightnessOsd.private
---@field timer gears.timer
---@field data BrightnessOsd.data

noice.define_style(M.object, {
    bg = { proxy = true },
    fg = { proxy = true },
    border_color = { proxy = true },
    border_width = { proxy = true },
    shape = { proxy = true },
    placement = { proxy = true },
    paddings = { id = "#paddings", property = "margins" },
})

do
    local styles = beautiful.brightness_osd and beautiful.brightness_osd.styles or beautiful.volume_osd.styles
    local text_format = "%2d" .. pango.thin_space .. "%%"
    local error_text = "--" .. pango.thin_space .. "%"

    function M.object:refresh()
        local data = self._private.data

        local style = (data.is_set and data.brightness > 100 and styles.boosted)
            or styles.normal
        self:apply_style(style)

        local text = data.is_set and string.format(text_format, data.brightness) or error_text
        local text_widget = self.widget:get_children_by_id("#text")[1] --[[@as wibox.widget.textbox]]
        text_widget:set_markup(text)
        
        local bar_widget = self.widget:get_children_by_id("#bar")[1]
        bar_widget:set_value(data.brightness)
        bar_widget:set_color(style.fg)
        bar_widget:set_background_color(beautiful.get_progressbar_bg(style.fg))
    end
end

---@param data? BrightnessOsd.data
function M.object:update(data)
    if data then
        self._private.data.is_set = not not data.brightness
        self._private.data.brightness = data.brightness or 0
    else
        self._private.data.is_set = false
        self._private.data.brightness = 0
    end

    self:refresh()
end

function M.object:hide()
    self.visible = false
    self.screen = nil

    self._private.timer:stop()
end

---@param data BrightnessOsd.data
function M.object:try_show(data)
    if data.skip_osd then
        return
    end

    local screen = awful.screen.focused()
    if not screen then
        return
    end

    self:update(data)

    self.screen = screen
    self.visible = true

    self._private.timer:again()
end


---@return BrightnessOsd
function M.new()
    local self = awful.popup {
        ontop = true,
        visible = false,
        widget = {
            layout = wibox.container.constraint,
            strategy = "exact",
            width = dpi(360),
            height = dpi(84),
            {
                id = "#paddings",
                widget = wibox.container.margin,
                {
                    layout = wibox.layout.fixed.horizontal,
                    spacing = dpi(16),
                    {
                        id = "#icon",
                        widget = wibox.widget.imagebox,
                        resize = true,
                        image = beautiful.icon("lightbulb-on.svg"),
                    },
                    {
                        id = "#text",
                        widget = wibox.widget.textbox,
                        font = beautiful.build_font { size_factor = 1.6 },
                    },
                    {
                        layout = wibox.container.place,
                        valign = "center",
                        {
                            id = "#bar",
                            widget = wibox.widget.progressbar,
                            shape = function(cr, width, height) gshape.rounded_rect(cr, width, height, dpi(6)) end,
                            bar_shape = function(cr, width, height) gshape.rounded_rect(cr, width, height, dpi(6)) end,
                            max_value = 100,
                            forced_height = dpi(24),
                        },
                    },
                },
            },
        },
    } --[[@as BrightnessOsd]]

    gtable.crush(self, M.object, true)

    self._private.data = {}

    self._private.timer = gtimer {
        timeout = 2,
        call_now = false,
        autostart = false,
        callback = function() self:hide() end,
    }

    self.buttons = binding.awful_buttons {
        binding.awful({}, { btn.left }, function() self:hide() end),
    }

    if beautiful.brightness_osd then
        self:initialize_style(beautiful.brightness_osd.default_style, self.widget)
    else
        self:initialize_style(beautiful.volume_osd.default_style, self.widget)
    end
    

    capi.awesome.connect_signal("brightness::update", function(data) self:try_show(data) end)

    self:update()

    return self
end

return M.new()
