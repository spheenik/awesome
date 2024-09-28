-- awesome_mode: api-level=4:screen=on
-- If LuaRocks is installed, make sure that packages installed through it are
-- found (e.g. lgi). If LuaRocks is not installed, do nothing.
pcall(require, "luarocks.loader")

-- @DOC_REQUIRE_SECTION@
-- Standard awesome library
local gears = require("gears")
local gdebug = require("gears.debug")
local awful = require("awful")
require("awful.autofocus")
-- Widget and layout library
local wibox = require("wibox")
-- Theme handling library
local beautiful = require("beautiful")
-- Notification library
local naughty = require("naughty")
-- Declarative object management
local ruled = require("ruled")
local menubar = require("menubar")
local hotkeys_popup = require("awful.hotkeys_popup").widget
-- Custom
local revolution = require("revolution")
local config = require("config")

-- {{{ Error handling
-- Check if awesome encountered an error during startup and fell back to
-- another config (This code will only ever execute for the fallback config)
-- @DOC_ERROR_HANDLING@
naughty.connect_signal("request::display_error", function(message, startup)
    naughty.notification {
        urgency = "critical",
        title   = "Oops, an error happened"..(startup and " during startup!" or "!"),
        message = message
    }
end)
-- }}}

-- {{{ Variable definitions
-- @DOC_LOAD_THEME@
-- Themes define colours, icons, font and wallpapers.
beautiful.init(config.base_path .. "/theme.lua")

-- Menubar configuration
menubar.utils.terminal = config.terminal -- Set the terminal for applications that require it
-- }}}

-- {{{ Tag layout
-- @DOC_LAYOUT@
-- Table of layouts to cover with awful.layout.inc, order matters.
tag.connect_signal("request::default_layouts", function()
    awful.layout.append_default_layouts({
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
    })
end)

-- {{{ Wallpaper
-- @DOC_WALLPAPER@
screen.connect_signal("request::wallpaper", function(s)
    awful.wallpaper {
        screen = s,
        widget = {
            image  = gears.surface.crop_surface {
                surface = gears.surface.load_uncached(beautiful.wallpaper),
                ratio = s.geometry.width/s.geometry.height,
            },
            widget = wibox.widget.imagebox
        }
    }
end)
-- }}}

-- {{{ Wibar

-- Create a laucher widget and a main menu
myawesomemenu = {
    { "hotkeys", function() hotkeys_popup.show_help(nil, awful.screen.focused()) end },
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

-- Create a systray
mysystray = wibox.widget.systray()

-- Create a clock
myclock = revolution.widget.conky()
myclock:set_value("${time %H:%M}")
myclock:set_value_color(beautiful.fg_normal)
awful.tooltip({
    objects = { myclock },
    timer_function = function()
        return os.date("Today is %A %B %d %Y\nThe time is %T")
    end,
})

-- @DOC_FOR_EACH_SCREEN@
screen.connect_signal("request::desktop_decoration", function(s)

    -- Each screen has its own tag table.
    awful.tag({ "1", "2", "3", "4", "5", "6", "7", "8", "9" }, s, awful.layout.layouts[1])

    -- Create a taglist widget
    s.mytaglist = awful.widget.taglist {
        screen  = s,
        filter  = awful.widget.taglist.filter.all,
        buttons = {
            awful.button({ }, 1, function(t) t:view_only() end),
            awful.button({ modkey }, 1, function(t)
                if client.focus then
                    client.focus:move_to_tag(t)
                end
            end),
            awful.button({ }, 3, awful.tag.viewtoggle),
            awful.button({ modkey }, 3, function(t)
                if client.focus then
                    client.focus:toggle_tag(t)
                end
            end),
            awful.button({ }, 4, function(t) awful.tag.viewprev(t.screen) end),
            awful.button({ }, 5, function(t) awful.tag.viewnext(t.screen) end),
        }
    }

    -- Create an imagebox widget which will contain an icon indicating which layout we're using.
    -- We need one layoutbox per screen.
    s.mylayoutbox = awful.widget.layoutbox {
        screen  = s,
        buttons = {
            awful.button({ }, 1, function () awful.layout.inc( 1) end),
            awful.button({ }, 3, function () awful.layout.inc(-1) end),
            awful.button({ }, 4, function () awful.layout.inc(-1) end),
            awful.button({ }, 5, function () awful.layout.inc( 1) end),
        }
    }

    -- @DOC_WIBAR@
    -- Create the wibox
    s.mywibox = awful.wibar {
        position = "bottom",
        screen   = s,
        -- @DOC_SETUP_WIDGETS@
        widget   = {
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
                wibox.container.background(
                        wibox.container.margin(mysystray, config.scale(7), config.scale(7), config.scale(2), config.scale(2)),
                        "#000000"
                ),
                myclock,
                s.mylayoutbox
            }
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
    awful.key({ config.modkey }, "r", function() awful.spawn(config.rofi.." -show run", false) end,
        {description = "show run dialog", group = "launcher"}),

    -- Show windows
    awful.key({ config.modkey }, "w", function() awful.spawn(config.rofi.." -show window", false) end,
        {description = "show open windows", group = "client"}),

    -- Volume Control
    awful.key({ }, "XF86AudioRaiseVolume", function ()
        awful.spawn("pactl -- set-sink-mute @DEFAULT_SINK@ 0", false)
        awful.spawn("pactl -- set-sink-volume @DEFAULT_SINK@ +4%", false)
        awful.spawn("pactl -- play-sample volumewav", false)
    end),
    awful.key({ }, "XF86AudioLowerVolume", function ()
        awful.spawn("pactl -- set-sink-mute @DEFAULT_SINK@ 0", false)
        awful.spawn("pactl -- set-sink-volume @DEFAULT_SINK@ -4%", false)
        awful.spawn("pactl -- play-sample volumewav", false)
    end),
    awful.key({ }, "XF86AudioMute", function()
        awful.spawn("pactl -- set-sink-mute @DEFAULT_SINK@ toggle", false)
        awful.spawn("pactl -- play-sample volumewav", false)
    end),
    awful.key({ }, "XF86MonBrightnessUp", function()
        awful.spawn("light -A 10", false)
    end),
    awful.key({ }, "XF86MonBrightnessDown", function()
        awful.spawn("light -U 10", false)
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
        {description = "maximize", group = "client"}),

        awful.key({ config.modkey, "Control" }, "i", function(c)
            local props = {
                "window", "pid",
                "group_window", "leader_window",
                "startup_id",
                "instance", "class",
                "type", "name", "role", "modal"}
            for _, name in pairs(props) do
                print(("%s: %s"):format(name, c[name]))
            end
            print("---")
        end,
        { description = "dump client info", group = "client" })

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


-- {{{ Rules
-- Rules to apply to new clients.
-- @DOC_RULES@
ruled.client.connect_signal("request::rules", function()

    -- @DOC_GLOBAL_RULE@
    -- All clients will match this rule.
    ruled.client.append_rule {
        id         = "global",
        rule       = { },
        properties = {
            focus = awful.client.focus.filter,
            raise = true,
            keys = clientkeys,
            buttons = clientbuttons,
            screen = awful.screen.preferred,
            placement = awful.placement.no_overlap + awful.placement.no_offscreen,
            maximized_vertical = false,
            maximized_horizontal = false,
            titlebars_enabled = false,
        }
    }

    -- @DOC_FLOATING_RULE@
    -- Dialogs
    ruled.client.append_rule {
        id       = "dialog",
        rule_any = {
            type    = { "dialog" }
        },
        properties = { titlebars_enabled = true }
    }

    -- @DOC_FLOATING_RULE@
    -- Floating clients.
    ruled.client.append_rule {
        id       = "floating",
        rule_any = {
            instance = { "copyq", "pinentry", "plugin-container", "ProjectGenesis" },
            class    = {
                "Arandr", "Blueman-manager", "Gpick", "Kruler", "Sxiv",
                "Tor Browser", "Wpa_gui", "veromix", "xtightvncviewer",
                "MPlayer", "mpv", "pinentry", "feh"
            },
            -- Note that the name property shown in xprop might be set slightly after creation of the client
            -- and the name shown there might not match defined rules here.
            name    = {
                "Event Tester",  -- xev.
                "Steam -.*News.*",   -- Steam News Popup
                "Dota VConsole Client",
                "Transfer Agent",
                "Dota Record Parser",
                "GLFW.*",
            },
            role    = {
                "AlarmWindow",    -- Thunderbird's calendar.
                "ConfigManager",  -- Thunderbird's about:config.
                "pop-up",         -- e.g. Google Chrome's (detached) Developer Tools.
            }
        },
        properties = { floating = true }
    }
end)


-- {{{ Titlebars
-- @DOC_TITLEBARS@
-- Add a titlebar if titlebars_enabled is set to true in the rules.
client.connect_signal("request::titlebars", function(c)
    -- buttons for the titlebar
    local buttons = {
        awful.button({ }, 1, function()
            c:activate { context = "titlebar", action = "mouse_move"  }
        end),
        awful.button({ }, 3, function()
            c:activate { context = "titlebar", action = "mouse_resize"}
        end),
    }

    awful.titlebar(c).widget = {
        { -- Left
            awful.titlebar.widget.iconwidget(c),
            buttons = buttons,
            layout  = wibox.layout.fixed.horizontal
        },
        { -- Middle
            { -- Title
                halign = "center",
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
-- }}}

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

-- {{{ Notifications

ruled.notification.connect_signal('request::rules', function()
    -- All notifications will match this rule.
    ruled.notification.append_rule {
        rule       = { },
        properties = {
            screen           = awful.screen.preferred,
            implicit_timeout = 5,
        }
    }
end)

naughty.connect_signal("request::display", function(n)
    naughty.layout.box { notification = n }
end)



-- Function to execute when a new client appears.
--client.connect_signal("manage", function (c)
--    -- Set the windows at the slave,
--    -- i.e. put it at the end of others instead of setting it master.
--    -- if not awesome.startup then awful.client.setslave(c) end
--
--    if awesome.startup and not c.size_hints.user_position and not c.size_hints.program_position then
--        -- Prevent clients from being unreachable after screen count changes.
--        awful.placement.no_offscreen(c)
--    end
--end)




-- vim: filetype=lua:expandtab:shiftwidth=4:tabstop=4:softtabstop=4
