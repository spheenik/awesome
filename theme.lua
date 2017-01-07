local config = require("config")

local black         = "#000000"
local transparent   = "#00000000"

theme = {}

theme.wallpaper     = config.resource_path .. "/wall.jpg"
theme.volumewav     = config.resource_path .. "/volume.wav"
theme.awesome_icon  = config.resource_path .. "/awesome-icon.png"

-- FONTS
theme.font      = "Hack " .. (math.floor(10 * config.ui_scale))

-- COLORS
theme.fg_normal  = "#DCDCCC"
theme.fg_focus   = "#FF80AB"
theme.fg_urgent  = "#84FFFF"
theme.bg_normal  = black
theme.bg_focus   = theme.bg_normal
theme.bg_urgent  = theme.bg_normal
theme.bg_systray = theme.bg_normal
theme.bg_systray = transparent

-- BORDERS
theme.border_width  = math.floor(2 * config.ui_scale)
theme.border_normal = "#2A373E"
theme.border_focus  = "#495F6C"
theme.border_marked = "#CC9393"

--TAGLIST
theme.taglist_squares_sel   = config.resource_path .. "/taglist/squarefz.png"
theme.taglist_squares_unsel = config.resource_path .. "/taglist/squarez.png"

-- MENU
theme.menu_height = (math.floor(20 * config.ui_scale))
theme.menu_width  = (math.floor(200 * config.ui_scale))
theme.menu_bg_normal = theme.bg_normal
theme.menu_bg_focus = "#6699CC"
theme.menu_fg_focus = black
theme.menu_submenu_icon = "/usr/share/awesome/themes/default/submenu.png"

-- LAYOUT ICONS
theme.layout_tile       = config.resource_path .. "/layouts/tile.png"
theme.layout_tileleft   = config.resource_path .. "/layouts/tileleft.png"
theme.layout_tilebottom = config.resource_path .. "/layouts/tilebottom.png"
theme.layout_tiletop    = config.resource_path .. "/layouts/tiletop.png"
theme.layout_fairv      = config.resource_path .. "/layouts/fairv.png"
theme.layout_fairh      = config.resource_path .. "/layouts/fairh.png"
theme.layout_spiral     = config.resource_path .. "/layouts/spiral.png"
theme.layout_dwindle    = config.resource_path .. "/layouts/dwindle.png"
theme.layout_max        = config.resource_path .. "/layouts/max.png"
theme.layout_fullscreen = config.resource_path .. "/layouts/fullscreen.png"
theme.layout_magnifier  = config.resource_path .. "/layouts/magnifier.png"
theme.layout_floating   = config.resource_path .. "/layouts/floating.png"

-- TITLEBAR
theme.titlebar_close_button_focus  = config.resource_path .. "/titlebar/close_focus.png"
theme.titlebar_close_button_normal = config.resource_path .. "/titlebar/close_normal.png"

theme.titlebar_ontop_button_focus_active  = config.resource_path .. "/titlebar/ontop_focus_active.png"
theme.titlebar_ontop_button_normal_active = config.resource_path .. "/titlebar/ontop_normal_active.png"
theme.titlebar_ontop_button_focus_inactive  = config.resource_path .. "/titlebar/ontop_focus_inactive.png"
theme.titlebar_ontop_button_normal_inactive = config.resource_path .. "/titlebar/ontop_normal_inactive.png"

theme.titlebar_sticky_button_focus_active  = config.resource_path .. "/titlebar/sticky_focus_active.png"
theme.titlebar_sticky_button_normal_active = config.resource_path .. "/titlebar/sticky_normal_active.png"
theme.titlebar_sticky_button_focus_inactive  = config.resource_path .. "/titlebar/sticky_focus_inactive.png"
theme.titlebar_sticky_button_normal_inactive = config.resource_path .. "/titlebar/sticky_normal_inactive.png"

theme.titlebar_floating_button_focus_active  = config.resource_path .. "/titlebar/floating_focus_active.png"
theme.titlebar_floating_button_normal_active = config.resource_path .. "/titlebar/floating_normal_active.png"
theme.titlebar_floating_button_focus_inactive  = config.resource_path .. "/titlebar/floating_focus_inactive.png"
theme.titlebar_floating_button_normal_inactive = config.resource_path .. "/titlebar/floating_normal_inactive.png"

theme.titlebar_maximized_button_focus_active  = config.resource_path .. "/titlebar/maximized_focus_active.png"
theme.titlebar_maximized_button_normal_active = config.resource_path .. "/titlebar/maximized_normal_active.png"
theme.titlebar_maximized_button_focus_inactive  = config.resource_path .. "/titlebar/maximized_focus_inactive.png"
theme.titlebar_maximized_button_normal_inactive = config.resource_path .. "/titlebar/maximized_normal_inactive.png"

return theme
