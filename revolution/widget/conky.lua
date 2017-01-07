local setmetatable = setmetatable
local textbox = require("wibox.widget.textbox")
local updater = require("revolution.conkyupdater")

-- revolution.widget.textclock
local conky = { mt = {} }

--- Create a conky widget. It draws the time it is in a textbox.
-- @param text The time format. Default is " %a %b %d, %H:%M ".
-- @return A textbox widget.
function conky.new(format)
    local w = textbox()
    updater.register(format, function(text) w:set_markup(text) end)
    return w
end

function conky.mt:__call(...)
    return conky.new(...)
end

return setmetatable(conky, conky.mt)
