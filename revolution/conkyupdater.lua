-- Grab environment we need
local awesome = awesome
local debug = require("gears.debug")
local naughty = require("naughty")
local spawn = require("awful.spawn")
local lgi = require("lgi")
local Gio = lgi.Gio

local conkyupdater = { }

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
            update_interval = 1.0,
            update_interval_on_battery = 1.0,
            total_run_times = 0,
            short_units = true,
            if_up_strictness = address
        };
        conky.text = [[return {]=] .. table.concat(formats, ",") .. [=[}]]
    ]=]

--    naughty.notify({ text = debug.dump_return(config), timeout = 100 })

    local pid, _, stdin, stdout, _ = awesome.spawn("conky -c -", false, true, true, false, nil)
    assert(type(pid) == "number", "Failed to start conky: " .. pid)

    awesome.connect_signal("exit", function()
        awesome.kill(pid, awesome.unix_signal.SIGINT)
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

return conkyupdater
