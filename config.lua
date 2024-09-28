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
    local base = '/sys/class/hwmon/hwmon';
    local names = read_stdout_synchronously('find '..base..'* -type l -printf "%p " -exec cat {}/name \\;')

    local lookup = {}
    for entry in names:gmatch("([^\n]*)\n?") do
        local parts = {}
        for part in entry:gmatch("([^ ]*) ?") do
            table.insert(parts, part)
        end

        local index = tonumber(parts[1]:sub(base:len() + 1))
        local driver = parts[2];
        print(("hwmon: index: %i, driver: %s"):format(index, driver))

        if (lookup[driver] == nil) then
            lookup[driver] = {}
        end
        table.insert(lookup[driver], index)
        index = index + 1
    end
    return lookup
end

local scale = determine_scale_factor()
local sensors = determine_sensors()

function fn_scalef(n)
    return scale * n
end

function fn_scale(n)
    return math.floor(fn_scalef(n))
end

local config = {
    modkey = "Mod4",

    terminal = "alacritty",
    editor = "vim",
    screenshot = "gnome-screenshot --interactive",
    lockscreen = "i3lock -fo",

    base_path = script_path(),
    resource_path = script_path() .. "resources",
    arc_resource_path = "/usr/share/themes/Arc/unity",
    ui_scale = scale,

    scalef = fn_scalef,
    scale = fn_scale,

    rofi = ("rofi -dpi %s "):format(fn_scale(96)),

    host_name = determine_host_name(),

    hwmon = function(name, index, suffix) return "${hwmon " .. sensors[name][index] .. " " .. suffix .. "}" end
}

local status, machine_config = pcall(function() return dofile(script_path().."config."..config.host_name..".lua") end)
if (status) then
    machine_config(config)
end

return config;

