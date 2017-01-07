-- Grab environment we need
local setmetatable = setmetatable

local capi =
{
    awesome = awesome
}
local debug = require("gears.debug")
local spawn = require("awful.spawn")
local naughty = require("naughty")
local lgi = require("lgi")
local Gio = lgi.Gio

-- revolution.conky
local conkyupdater = { mt = {} }

local formats = {}
local callbacks = {}

function conkyupdater.register(format, callback)
    table.insert(formats, '"' .. format .. '"')
    table.insert(callbacks, callback)
end

function conkyupdater.start()

    local config = [=[
        conky.config = {
            out_to_console = true,
            out_to_x = false,
            background = false,
            update_interval = 1.0,
            update_interval_on_battery = 1.0,
            total_run_times = 0,
            times_in_seconds = true,
            short_units = true,
        };
        conky.text = [[return {]=] .. table.concat(formats, ",") .. [=[}]]
    ]=]

--    naughty.notify({ text = debug.dump_return(config), timeout = 100 })

    local pid, _, stdin, stdout, _ = capi.awesome.spawn("conky -c -", false, true, true, false, nil)
    assert(type(pid) == "number", "Failed to start conky: " .. pid)

    capi.awesome.connect_signal("exit", function()
        capi.awesome.kill(pid, capi.awesome.unix_signal.SIGINT)
    end)

    local cfg_stream = Gio.UnixOutputStream.new(stdin, true)
    cfg_stream:write(config)

    local callback = function(line)
--        naughty.notify({ text = line })
        for i,v in ipairs(loadstring(line)()) do
            callbacks[i](v)
        end
    end

    spawn.read_lines(Gio.UnixInputStream.new(stdout, true), callback, nil, true)
end

function conkyupdater.mt:__call(...)
    return conkyupdater.new(...)
end

return setmetatable(conkyupdater, conkyupdater.mt)
