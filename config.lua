local gears = require("gears")
local naughty = require("naughty")

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

function compute_scale_factor()
	local dpi = read_stdout_synchronously("xdpyinfo | awk -F'[ x]+' '/resolution:/{print $3}'")
        if dpi and dpi ~= "" then
            if tonumber(dpi) >= 144 then
                return 2
            end
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

local scale = compute_scale_factor()
local sensors = determine_sensors()

local config = {
    modkey = "Mod4",

    terminal = "urxvt",
    editor = "vim",
    screenshot = "gnome-screenshot --interactive",
    lockscreen = "i3lock -fo",

    base_path = script_path(),
    resource_path = script_path() .. "resources",
    ui_scale = scale,

    scale = function(n) return math.floor(scale * n) end,
    
    host_name = determine_host_name(),
   
    hwmon = function(name, index, suffix) return "${hwmon " .. sensors[name][index] .. " " .. suffix .. "}" end
}

local status, machine_config = pcall(function() return dofile(script_path().."config."..config.host_name..".lua") end)
if (status) then
    machine_config(config)
end

return config;

