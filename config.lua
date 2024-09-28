local gears = require("gears")
local naughty = require("naughty")
local Gio = require("lgi").Gio

function script_path()
    local str = debug.getinfo(2, "S").source:sub(2)
    return str:match("(.*/)")
end

function read_stdout_synchronously(command)
	local f = assert(io.popen(command, "r"), "failed to open " .. command)
	local content = assert(f:read("*a"), "failed to read output from " .. command)
	f:close()
	return content
end

function determine_scale_factor()
    local status, scale = pcall(function()
        local settings = Gio.Settings.new('org.gnome.desktop.interface')
        local scale = settings:get_double('text-scaling-factor')
        return scale
    end)
    if (status) then
        return scale;
    end
    return 1
end

function determine_host_name()
    local name = string.gsub(read_stdout_synchronously("/bin/hostname"), "\n$", "")
    return name
end

function determine_sensors()
    local names = read_stdout_synchronously("cat /sys/class/hwmon/hwmon*/name")

    local index = 0
    local lookup = {}
    for name in names:gmatch("([^\n]*)\n?") do
      if (lookup[name] == nil) then
        lookup[name] = {}
      end
      table.insert(lookup[name], index)
      index = index + 1
    end
    return lookup
end

local scale = determine_scale_factor()
local sensors = determine_sensors()

local config = {
    modkey = "Mod4",

    terminal = "alacritty",
    editor = "vim",
    screenshot = "gnome-screenshot --interactive",
    lockscreen = "i3lock -fo",

    base_path = script_path(),
    resource_path = script_path() .. "resources",
    ui_scale = scale,

    scalef = function(n) return scale * n end,
    scale = function(n) return math.floor(scale * n) end,

    host_name = determine_host_name(),

    hwmon = function(name, index, suffix) return "${hwmon " .. sensors[name][index] .. " " .. suffix .. "}" end
}

local status, machine_config = pcall(function() return dofile(script_path().."config."..config.host_name..".lua") end)
if (status) then
    machine_config(config)
end

return config;

