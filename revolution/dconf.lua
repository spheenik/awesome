-- Grab environment we need
local gdebug = require("gears.debug")
local protected_call = require("gears.protected_call");
local lgi = require("lgi")
local Gio = lgi.Gio
local GObject = lgi.GObject

local this = { }

function this.start()
    protected_call(function()
        local settings = Gio.Settings.new('org.gnome.desktop.interface')

        --local factor = settings:get_double('text-scaling-factor')
        --print(('got factor %d'):format(factor))

        local DConf = lgi.package 'DConf'

        local specDouble = GObject.ParamSpecDouble(
                'value',
                nil,
                nil,
                0.5,
                3.0,
                1.0,
                { 'READABLE', 'WRITABLE' }
        )

        DConf:class('Holder', GObject.Object, { })
        DConf.Holder._property.value = specDouble

        function DConf.Holder._property_set:value(new_value)
            gdebug.print_warning(('changed from %s to %s'):format(self.priv.value, new_value))
            self.priv.value = new_value
            if awesome then
                awesome.emit_signal("revolution::scale_changed", new_value)
            end
        end

        local holder = DConf.Holder()

        settings:bind(
                'text-scaling-factor',
                holder,
                'value',
                1
        )
    end)
end

return this
