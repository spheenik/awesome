local wibox = require("wibox")
local revolution = require("revolution")

return function(config) 
    config.middle_widgets = {
        layout = wibox.layout.fixed.horizontal,    
        {
            value = "${cpu}% "..config.hwmon("k10temp", 1, "temp 1").."/"..config.hwmon("k10temp", 2, "temp 1").."°",
            label = "CPU",
            widget = revolution.widget.conky
        },
        {
            value = "${exec cat /sys/class/drm/card0/device/gpu_busy_percent}% "..config.hwmon("amdgpu", 1, "temp 1").."°",
            label = "GPU",
            widget = revolution.widget.conky
        },
        {
            value = "${mem}",
            label = "MEM",
            widget = revolution.widget.conky
        },
        {
            value = "↑${diskio_read /dev/nvme1n1p2} ↓${diskio_write /dev/nvme1n1p2} "..config.hwmon("nvme", 1, "temp 1").."°",
            label = "SSD",
            widget = revolution.widget.conky
        },
        {
            value = "↑${diskio_read /dev/sda} ↓${diskio_write /dev/sda}",
            label = "DUMP",
            widget = revolution.widget.conky
        },
        {
            value = "↑${upspeed br0} ↓${downspeed br0}",
            label = "LAN",
            widget = revolution.widget.conky
        },
    }
end


