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
local line_buf = ""

function conkyupdater.register(format, callback)
    format = '"' .. format .. '"'
    for i,v in ipairs(formats) do
        if v == format then
            table.insert(callbacks[i], callback)
            return
        end
    end
    table.insert(formats, format)
    table.insert(callbacks, { callback })
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

    -- naughty.notify({ text = debug.dump_return(config), timeout = 100 })

    local pid, _, stdin, stdout, _ = awesome.spawn({"conky", "-c", "-"}, false, true, true, false)
    assert(type(pid) == "number", "Failed to start conky: " .. pid)

    awesome.connect_signal("exit", function()
        awesome.kill(pid, awesome.unix_signal.SIGINT)
    end)

    local cfg_stream = Gio.UnixOutputStream.new(stdin, true)
    cfg_stream:write_all(config)
    cfg_stream:close()

    local callback = function(line)
        line_buf = line_buf..line
        if (line_buf:sub(-1) == "}") then
            -- naughty.notify({ text = line_buf })
            for i,text in ipairs(load(line_buf)()) do
                for j,callback in ipairs(callbacks[i]) do
                    callback(text)
                end
            end
            line_buf = ""
        end
    end

    spawn.read_lines(Gio.UnixInputStream.new(stdout, true), callback, nil, true)
end

return conkyupdater
