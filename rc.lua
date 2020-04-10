local gears = require("gears")
local awful = require("awful")
require("awful.autofocus")
local wibox = require("wibox")
local beautiful = require("beautiful")
local naughty = require("naughty")
local menubar = require("menubar")
local hotkeys_popup = require("awful.hotkeys_popup").widget
local revolution = require("revolution")
local config = require("config")

-- Error handling
if awesome.startup_errors then
    naughty.notify({ preset = naughty.config.presets.critical,
        title = "Oops, there were errors during startup!",
        text = awesome.startup_errors })
end
do
    local in_error = false
    awesome.connect_signal("debug::error", function (err)
        -- Make sure we don't go into an endless error loop
        if in_error then return end
        in_error = true

        naughty.notify({ preset = naughty.config.presets.critical,
            title = "Oops, an error happened!",
            text = tostring(err) })
        in_error = false
    end)
end

-- Theme init
beautiful.init(config.base_path .. "/theme.lua")

-- Table of layouts to cover with awful.layout.inc, order matters.
awful.layout.layouts = {
    awful.layout.suit.tile,
    awful.layout.suit.tile.left,
    awful.layout.suit.tile.bottom,
    awful.layout.suit.tile.top,
    awful.layout.suit.floating,
    --    awful.layout.suit.fair,
    --    awful.layout.suit.fair.horizontal,
    --    awful.layout.suit.spiral,
    --    awful.layout.suit.spiral.dwindle,
    --    awful.layout.suit.max,
    --    awful.layout.suit.max.fullscreen,
    --    awful.layout.suit.magnifier
}

-- Create a laucher widget and a main menu
myawesomemenu = {
    { "manual",         config.terminal .. " -e man awesome" },
    { "edit config",    config.terminal .. " -e " .. config.editor .. " " .. awesome.conffile },
    { "restart",        awesome.restart },
    { "quit",           function() awesome.quit() end }
}
mymainmenu = awful.menu({
    items = {
        { "awesome",    myawesomemenu, beautiful.awesome_icon },
	    { "sleep",      "systemctl suspend" },
	    { "power off",  "systemctl poweroff" },
        { "reboot",     "systemctl reboot" }
    }
})
mylauncher = awful.widget.launcher({ image = beautiful.awesome_icon, menu = mymainmenu })

-- Configure buttons for taglist
local taglist_buttons = awful.util.table.join(
    awful.button({ }, 1, function(t) t:view_only() end),
    awful.button({ config.modkey }, 1, function(t)
        if client.focus then
            client.focus:move_to_tag(t)
        end
    end),
    awful.button({ }, 3, awful.tag.viewtoggle),
    awful.button({ config.modkey }, 3, function(t)
        if client.focus then
            client.focus:toggle_tag(t)
        end
    end),
    awful.button({ }, 4, function(t) awful.tag.viewnext(t.screen) end),
    awful.button({ }, 5, function(t) awful.tag.viewprev(t.screen) end)
)

mysystray = wibox.widget.systray()
-- mysystray.forced_width = config.scale(100)

myclock = revolution.widget.conky()
myclock:set_value("${time %H:%M}")
myclock:set_value_color(beautiful.fg_normal)
awful.tooltip({
    objects = { myclock },
    timer_function = function()
        return os.date("Today is %A %B %d %Y\nThe time is %T")
    end,
})

-- Create widgets for bottom wibars on each screen
awful.screen.connect_for_each_screen(function(s)

    -- Wallpaper
    gears.wallpaper.maximized(beautiful.wallpaper, s, true)

    -- Each screen has its own tag table.
    awful.tag({ "1", "2", "3", "4", "5", "6", "7", "8", "9" }, s, awful.layout.layouts[1])

    -- Create the wibox
    s.mywibox = awful.wibar({ position = "bottom", screen = s })

    -- Create a taglist widget
    s.mytaglist = awful.widget.taglist(s, awful.widget.taglist.filter.all, taglist_buttons)

    -- Create an imagebox widget which will contains an icon indicating which layout we're using.
    -- We need one layoutbox per screen.
    s.mylayoutbox = awful.widget.layoutbox(s)
    s.mylayoutbox:buttons(awful.util.table.join(
        awful.button({ }, 1, function () awful.layout.inc( 1) end),
        awful.button({ }, 3, function () awful.layout.inc(-1) end),
        awful.button({ }, 4, function () awful.layout.inc( 1) end),
        awful.button({ }, 5, function () awful.layout.inc(-1) end)))

    -- Add widgets to the wibox
    s.mywibox:setup {
        layout = wibox.layout.align.horizontal,
        -- Left widgets
        {
            layout = wibox.layout.fixed.horizontal,
            mylauncher,
            s.mytaglist
        },
        -- Middle widgets
        config.middle_widgets,
        -- Right widgets
        {
            layout = wibox.layout.fixed.horizontal,
            wibox.layout.margin(mysystray, config.scale(7), config.scale(7), config.scale(2), config.scale(2)),
            myclock,
            s.mylayoutbox
        }
    }
end)

-- Start conky
revolution.conkyupdater.start()

-- Mouse bindings
root.buttons(awful.util.table.join(
    awful.button({ }, 3, function () mymainmenu:toggle() end),
    awful.button({ }, 4, awful.tag.viewnext),
    awful.button({ }, 5, awful.tag.viewprev)
))

-- Global key bindings
globalkeys = awful.util.table.join(
    awful.key({ config.modkey,           }, "q",      hotkeys_popup.show_help,
        {description="show help", group="awesome"}),
    awful.key({ config.modkey,           }, "Left",   awful.tag.viewprev,
        {description = "view previous", group = "tag"}),
    awful.key({ config.modkey,           }, "Right",  awful.tag.viewnext,
        {description = "view next", group = "tag"}),
    awful.key({ config.modkey,           }, "Escape", awful.tag.history.restore,
        {description = "go back", group = "tag"}),

    awful.key({ config.modkey,           }, "j",
        function ()
            awful.client.focus.byidx( 1)
        end,
        {description = "focus next by index", group = "client"}
    ),
    awful.key({ config.modkey,           }, "k",
        function ()
            awful.client.focus.byidx(-1)
        end,
        {description = "focus previous by index", group = "client"}
    ),

    -- Screenshot
    awful.key({ config.modkey }, "s", function () awful.spawn(config.screenshot) end,
        {description = "make a screenshot", group = "screen"}),

    -- Lock Screen
    awful.key({ config.modkey }, "i", function () awful.spawn(config.lockscreen) end,
        {description = "lock the screen", group = "screen"}),

    -- Layout manipulation
    awful.key({ config.modkey, "Shift"   }, "j", function () awful.client.swap.byidx(  1)    end,
        {description = "swap with next client by index", group = "client"}),
    awful.key({ config.modkey, "Shift"   }, "k", function () awful.client.swap.byidx( -1)    end,
        {description = "swap with previous client by index", group = "client"}),
    awful.key({ config.modkey, "Control" }, "j", function () awful.screen.focus_relative( 1) end,
        {description = "focus the next screen", group = "screen"}),
    awful.key({ config.modkey, "Control" }, "k", function () awful.screen.focus_relative(-1) end,
        {description = "focus the previous screen", group = "screen"}),
    awful.key({ config.modkey,           }, "u", awful.client.urgent.jumpto,
        {description = "jump to urgent client", group = "client"}),
    awful.key({ config.modkey,           }, "Tab",
        function ()
            awful.client.focus.history.previous()
            if client.focus then
                client.focus:raise()
            end
        end,
        {description = "go back", group = "client"}),

    -- Standard program
    awful.key({ config.modkey,           }, "Return", function () awful.spawn(config.terminal) end,
        {description = "open a terminal", group = "launcher"}),
    awful.key({ config.modkey, "Control" }, "r", awesome.restart,
        {description = "reload awesome", group = "awesome"}),
    awful.key({ config.modkey, "Shift"   }, "q", awesome.quit,
        {description = "quit awesome", group = "awesome"}),

    awful.key({ config.modkey,           }, "l",     function () awful.tag.incmwfact( 0.05)          end,
        {description = "increase master width factor", group = "layout"}),
    awful.key({ config.modkey,           }, "h",     function () awful.tag.incmwfact(-0.05)          end,
        {description = "decrease master width factor", group = "layout"}),
    awful.key({ config.modkey, "Shift"   }, "h",     function () awful.tag.incnmaster( 1, nil, true) end,
        {description = "increase the number of master clients", group = "layout"}),
    awful.key({ config.modkey, "Shift"   }, "l",     function () awful.tag.incnmaster(-1, nil, true) end,
        {description = "decrease the number of master clients", group = "layout"}),
    awful.key({ config.modkey, "Control" }, "h",     function () awful.tag.incncol( 1, nil, true)    end,
        {description = "increase the number of columns", group = "layout"}),
    awful.key({ config.modkey, "Control" }, "l",     function () awful.tag.incncol(-1, nil, true)    end,
        {description = "decrease the number of columns", group = "layout"}),
    awful.key({ config.modkey,           }, "space", function () awful.layout.inc( 1)                end,
        {description = "select next", group = "layout"}),
    awful.key({ config.modkey, "Shift"   }, "space", function () awful.layout.inc(-1)                end,
        {description = "select previous", group = "layout"}),

    awful.key({ config.modkey, "Control" }, "n",
        function ()
            local c = awful.client.restore()
            -- Focus restored client
            if c then
                client.focus = c
                c:raise()
            end
        end,
        {description = "restore minimized", group = "client"}),

    -- Run
    awful.key({ config.modkey }, "r", function() awful.spawn("rofi -show run", false) end,
        {description = "show run dialog", group = "launcher"}),

    -- Show windows
    awful.key({ config.modkey }, "w", function() awful.spawn("rofi -show window", false) end,
        {description = "show open windows", group = "client"}),

    -- Volume Control
    awful.key({ }, "XF86AudioRaiseVolume", function ()
        awful.util.spawn("pactl -- set-sink-mute @DEFAULT_SINK@ 0", false)
        awful.util.spawn("pactl -- set-sink-volume @DEFAULT_SINK@ +4%", false)
        awful.util.spawn("pactl -- play-sample volumewav", false)
    end),
    awful.key({ }, "XF86AudioLowerVolume", function ()
        awful.util.spawn("pactl -- set-sink-mute @DEFAULT_SINK@ 0", false)
        awful.util.spawn("pactl -- set-sink-volume @DEFAULT_SINK@ -4%", false)
        awful.util.spawn("pactl -- play-sample volumewav", false)
    end),
    awful.key({ }, "XF86AudioMute", function()
        awful.util.spawn("pactl -- set-sink-mute @DEFAULT_SINK@ toggle", false)
        awful.util.spawn("pactl -- play-sample volumewav", false)
    end)
)

-- Client key bindings
clientkeys = awful.util.table.join(
    awful.key({ config.modkey,           }, "f",
        function (c)
            c.fullscreen = not c.fullscreen
            c:raise()
        end,
        {description = "toggle fullscreen", group = "client"}),
    awful.key({ config.modkey, "Shift"   }, "c",      function (c) c:kill()                         end,
        {description = "close", group = "client"}),
    awful.key({ config.modkey, "Control" }, "space",  awful.client.floating.toggle                     ,
        {description = "toggle floating", group = "client"}),
    awful.key({ config.modkey, "Control" }, "Return", function (c) c:swap(awful.client.getmaster()) end,
        {description = "move to master", group = "client"}),
    awful.key({ config.modkey,           }, "o",      function (c) c:move_to_screen()               end,
        {description = "move to screen", group = "client"}),
    awful.key({ config.modkey,           }, "t",      function (c) c.ontop = not c.ontop            end,
        {description = "toggle keep on top", group = "client"}),
    awful.key({ config.modkey, "Control" }, "t",
        function (c)
            c:emit_signal("request::titlebars")
            naughty.notify { title = "TOGGLE NOW" }
            awful.titlebar.toggle(c)
        end,
        {description = "toggle titlebar", group = "client"}),
    awful.key({ config.modkey,           }, "n",
        function (c)
            -- The client currently has the input focus, so it cannot be
            -- minimized, since minimized clients can't have the focus.
            c.minimized = true
        end ,
        {description = "minimize", group = "client"}),
    awful.key({ config.modkey,           }, "m",
        function (c)
            c.maximized = not c.maximized
            c:raise()
        end ,
        {description = "maximize", group = "client"})
)

-- Number key bindings
for i = 1, 9 do
    globalkeys = awful.util.table.join(globalkeys,
        -- View tag only.
        awful.key({ config.modkey }, "#" .. i + 9,
            function ()
                local screen = awful.screen.focused()
                local tag = screen.tags[i]
                if tag then
                    tag:view_only()
                end
            end,
            {description = "view tag #"..i, group = "tag"}),
        -- Toggle tag display.
        awful.key({ config.modkey, "Control" }, "#" .. i + 9,
            function ()
                local screen = awful.screen.focused()
                local tag = screen.tags[i]
                if tag then
                    awful.tag.viewtoggle(tag)
                end
            end,
            {description = "toggle tag #" .. i, group = "tag"}),
        -- Move client to tag.
        awful.key({ config.modkey, "Shift" }, "#" .. i + 9,
            function ()
                if client.focus then
                    local tag = client.focus.screen.tags[i]
                    if tag then
                        client.focus:move_to_tag(tag)
                    end
                end
            end,
            {description = "move focused client to tag #"..i, group = "tag"}),
        -- Toggle tag on focused client.
        awful.key({ config.modkey, "Control", "Shift" }, "#" .. i + 9,
            function ()
                if client.focus then
                    local tag = client.focus.screen.tags[i]
                    if tag then
                        client.focus:toggle_tag(tag)
                    end
                end
            end,
            {description = "toggle focused client on tag #" .. i, group = "tag"})
    )
end

clientbuttons = awful.util.table.join(
    awful.button({ }, 1, function (c) client.focus = c; c:raise() end),
    awful.button({ config.modkey }, 1, awful.mouse.client.move),
    awful.button({ config.modkey }, 3, awful.mouse.client.resize))

root.keys(globalkeys)

-- Rules to apply to new clients (through the "manage" signal).
awful.rules.rules = {
    -- All clients will match this rule.
    {
        rule = { },
        properties = {
            border_width = beautiful.border_width,
            border_color = beautiful.border_normal,
            focus = awful.client.focus.filter,
            raise = true,
            keys = clientkeys,
            buttons = clientbuttons,
            screen = awful.screen.preferred,
            placement = awful.placement.no_overlap + awful.placement.no_offscreen,
            maximized_vertical = false,
            maximized_horizontal = false,
            titlebars_enabled = false,
        },
        --callback = function(c) naughty.notify{ timeout=0, title="new window", text = "name: " .. c.name .. ", instance: " .. c.instance .. ", class: " .. c.class .. ", pid: " .. c.pid } end
    },
    -- Ignore terminal size hints
    {
        rule = { instance = "urxvt" }, properties = { size_hints_honor = false }
    },
    -- Floating clients.
    {
        rule_any = {
            instance = {
                "plugin-container",
                "ProjectGenesis",
            },
            class = {
                "MPlayer",
                "mpv",
                "pinentry",
                "feh",
            },
            name = {
                "Event Tester",     -- xev
		        "Steam -.*News.*",   -- Steam News Popup
                "Dota VConsole Client",
                "Transfer Agent",
                "Dota Record Parser",
                "GLFW.*",
            },
            role = {
                "AlarmWindow",  -- Thunderbird's calendar.
                "pop-up",       -- e.g. Google Chrome's (detached) Developer Tools.
            }
        },
        properties = {
            floating = true
        },
    },
    -- Quartus
    {
        rule = { class = "Quartus" },
        except = { type = "normal" },
        properties = {
            floating = true
        }
--[[

        callback = function(c)
            if c.type ~= "normal" then

                c:connect_signal("property::floating", function()
                    if c.floating then
                        naughty.notify { title = "true" }
                    else
                        naughty.notify { title = "false" }
                    end
                end)

                naughty.notify { title = "OPENED " .. c.name .. " TYPE " .. c.type }
                --c.floating = true
                --awful.titlebar.show(c)
                awful.client.floating.set(c, true)
                awful.placement.centered(c)
            end
        end
--]]
    },
    -- Add titlebars to normal clients and dialogs
    {
        rule_any = {
            type = {
                -- "normal",
                -- "dialog"
            }
        },
        properties = {
            titlebars_enabled = true
        }
    },
}

-- Function to execute when a new client appears.
client.connect_signal("manage", function (c)
    -- Set the windows at the slave,
    -- i.e. put it at the end of others instead of setting it master.
    -- if not awesome.startup then awful.client.setslave(c) end

    if awesome.startup and not c.size_hints.user_position and not c.size_hints.program_position then
        -- Prevent clients from being unreachable after screen count changes.
        awful.placement.no_offscreen(c)
    end
end)

-- Add a titlebar if titlebars_enabled is set to true in the rules.
client.connect_signal("request::titlebars", function(c)
    if c.titlebar_created then return end
    c.titlebar_created = true
    naughty.notify { title = "TB CREATE" }

    -- buttons for the titlebar
    local buttons = awful.util.table.join(
        awful.button({ }, 1, function()
            client.focus = c
            c:raise()
            awful.mouse.client.move(c)
        end),
        awful.button({ }, 3, function()
            client.focus = c
            c:raise()
            awful.mouse.client.resize(c)
        end)
    )

    awful.titlebar(c) : setup {
        { -- Left
            awful.titlebar.widget.iconwidget(c),
            buttons = buttons,
            layout  = wibox.layout.fixed.horizontal
        },
        { -- Middle
            { -- Title
                align  = "center",
                widget = awful.titlebar.widget.titlewidget(c)
            },
            buttons = buttons,
            layout  = wibox.layout.flex.horizontal
        },
        { -- Right
            awful.titlebar.widget.floatingbutton (c),
            awful.titlebar.widget.maximizedbutton(c),
            awful.titlebar.widget.stickybutton   (c),
            awful.titlebar.widget.ontopbutton    (c),
            awful.titlebar.widget.closebutton    (c),
            layout = wibox.layout.fixed.horizontal()
        },
        layout = wibox.layout.align.horizontal
    }
end)

-- A client should get focused / raised
client.connect_signal("request::activate", function(c, context, hints)
    client.focus = c
    c:raise()
    awful.ewmh.activate(c, context, hints)
end)

-- A client gets it's urgent property set
client.connect_signal("property::urgent", function()
    awful.client.urgent.jumpto()
end)

-- A client gets focused
client.connect_signal("focus", function(c)
    c.border_color = beautiful.border_focus
end)

-- A client gets unfocused
client.connect_signal("unfocus", function(c)
    c.border_color = beautiful.border_normal
end)

-- vim: filetype=lua:expandtab:shiftwidth=4:tabstop=4:softtabstop=4
