local setmetatable = setmetatable
local textbox = require("wibox.widget.textbox")
local updater = require("revolution.conkyupdater")

-- revolution.widget.textclock
local conky = { mt = {} }

--- Create a conky widget.
-- @param format The string given to conky
-- @return the widget
function conky.new(format)
    local w = textbox()
    updater.register(format, function(text) w:set_markup(text) end)
    return w
end

function conky.mt:__call(...)
    return conky.new(...)
end

return setmetatable(conky, conky.mt)
