local wibox = require("wibox")
local revolution = require("revolution")

return function(config) 
    config.middle_widgets = {
        layout = wibox.layout.fixed.horizontal,    
        {
            value = "${cpu}% "..config.hwmon("k10temp", 1, "temp 2").."/"..config.hwmon("k10temp", 2, "temp 2").."°",
            label = "CPU",
            widget = revolution.widget.conky
        },
        {
            value = "${head /sys/class/drm/card0/device/gpu_busy_percent 1 1}% "..config.hwmon("amdgpu", 1, "temp 1").."°",
            label = "GPU",
            widget = revolution.widget.conky
        },
        {
            value = "${mem}",
            label = "MEM",
            widget = revolution.widget.conky
        },
        {
            value = "↑${diskio_write /dev/nvme1n1p2} ↓${diskio_read /dev/nvme1n1p2} "..config.hwmon("nvme", 1, "temp 1").."°",
            label = "SSD",
            widget = revolution.widget.conky
        },
        {
            value = "↑${diskio_write /dev/sda} ↓${diskio_read /dev/sda}",
            label = "DUMP",
            widget = revolution.widget.conky
        },
        {
            enabled = "${if_up br0}1${endif}",
            value = "↑${upspeed br0} ↓${downspeed br0}",
            label = "LAN",
            widget = revolution.widget.conky
        },
    }
end


