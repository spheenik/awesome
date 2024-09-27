local wibox = require("wibox")
local revolution = require("revolution")

return function(config) 
    config.middle_widgets = {
        layout = wibox.layout.fixed.horizontal,    
        {
            enabled = "${if_existing /sys/class/power_supply/BAT0/present 1}1${endif}",
            value = "${battery_short} ${battery_time}",
            label = "BAT",
            widget = revolution.widget.conky
        },
        {
            value = "${cpu}% "..config.hwmon("k10temp", 1, "temp 1").."°",
            label = "CPU",
            widget = revolution.widget.conky
        },
        {
            value = "${head /sys/class/drm/card1/device/gpu_busy_percent 1 1}% "..config.hwmon("amdgpu", 1, "temp 1").."°",
            label = "GPU",
            widget = revolution.widget.conky
        },
        {
            value = "${mem}",
            label = "MEM",
            widget = revolution.widget.conky
        },
        {
            value = "↑${diskio_write /dev/nvme0n1} ↓${diskio_read /dev/nvme0n1} "..config.hwmon("nvme", 1, "temp 1").."°",
            label = "SSD",
            widget = revolution.widget.conky
        },
        {
            enabled = "${if_up enp99s0f3u1}1${endif}",
            value = "↑${upspeed enp99s0f3u1} ↓${downspeed enp99s0f3u1}",
            label = "LAN",
            widget = revolution.widget.conky
        },
        {
            enabled = "${if_up wlan0}1${endif}",
            value = "↑${upspeed wlan0} ↓${downspeed wlan0}",
            label = "WLAN",
            widget = revolution.widget.conky
        },
        {
            enabled = "${if_up nordlynx}1${endif}",
            value = "↑${upspeed nordlynx} ↓${downspeed nordlynx}",
            label = "VPN",
            widget = revolution.widget.conky
        }
     }
end


