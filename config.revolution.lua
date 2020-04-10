local wibox = require("wibox")
local revolution = require("revolution")

return function(config) 
    config.middle_widgets = {
        layout = wibox.layout.fixed.horizontal,    
        {
            enabled = "${if_existing /sys/class/power_supply/BAT0/present 1}1${endif}",
            value = "${battery_short} "..config.hwmon("BAT0", 1, "in 0").."V "..config.hwmon("BAT0", 1, "curr 1 0.001 0").."A",
            label = "BAT",
            widget = revolution.widget.conky
        },
        {
            value = "${cpu}% "..config.hwmon("coretemp", 1, "temp 1").."°",
            label = "CPU",
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
            enabled = "${if_up enp0s20f0u2u3}1${endif}",
            value = "↑${upspeed enp0s20f0u2u3} ↓${downspeed enp0s20f0u2u3}",
            label = "LAN",
            widget = revolution.widget.conky
        },
        {
            enabled = "${if_up wlp2s0}1${endif}",
            value = "↑${upspeed wlp2s0} ↓${downspeed wlp2s0}",
            label = "WLAN",
            widget = revolution.widget.conky
        }
    }
end


