function script_path()
    local str = debug.getinfo(2, "S").source:sub(2)
    return str:match("(.*/)")
end

function compute_scale_factor()
    local handle = io.popen("xdpyinfo | awk -F'[ x]+' '/resolution:/{print $3}'", 'r')
    if handle then
        local dpi = handle:read('*a')
        handle:close();
        if dpi and dpi ~= "" then
            if tonumber(dpi) >= 144 then
                return 2
            end
        end
    end
    return 1
end

return {
    terminal = "urxvt",
    editor = "vim",
    modkey = "Mod4",

    base_path = script_path(),
    resource_path = script_path() .. "/resources",
    ui_scale = compute_scale_factor()
}