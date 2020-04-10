local wibox = require("wibox")
local textbox = require("wibox.widget.textbox")
local updater = require("revolution.conkyupdater")
local naughty = require("naughty")
local beautiful = require("beautiful")
local gtable = require("gears.table")

local conky = { mt = {} }

local function update_text(self, text) 
    self._private.value:set_markup('<span foreground="' .. self._private.value_color .. '">' .. text .. '</span>')
end

function conky:set_label(label)
    self._private.label:set_text(label)
end

function conky:set_value(value)
    updater.register(value, function(text) update_text(self, text) end)
end

function conky:set_spacing(spacing)
    self._private.container:set_spacing(spacing)
end

function conky:set_margin_left(margin)
    self._private.container_margin:set_left(margin)
end

function conky:set_margin_right(margin)
    self._private.container_margin:set_right(margin)
end

function conky:set_value_color(value_color)
    self._private.value_color = value_color
end

--- Create a conky widget.
-- @param format The string given to conky
-- @return the widget
local function new()
    local priv = {}
    
    priv.label = wibox.widget.textbox()
    priv.value = wibox.widget.textbox()
    priv.container = wibox.layout.fixed.horizontal(priv.label, priv.value)
    priv.container_margin = wibox.container.margin(priv.container) 

    local ret = wibox.widget.base.make_widget(priv.container_margin, nil, {enable_properties = true})

    gtable.crush(ret, conky, true)
    gtable.crush(ret._private, priv, true)
    
    ret:set_value_color(beautiful.conky_fg)
    ret:set_spacing(beautiful.conky_spacing)
    ret:set_spacing(beautiful.conky_spacing)
    ret:set_margin_left(beautiful.conky_margin_left)
    ret:set_margin_right(beautiful.conky_margin_right)
    
    return ret
end

function conky.mt:__call(...)
    return new(...)
end

return setmetatable(conky, conky.mt)
