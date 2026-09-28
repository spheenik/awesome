function read_stdout_synchronously(command)
    local f = assert(io.popen(command, "r"), "failed to open " .. command)
    local content = assert(f:read("*a"), "failed to read output from " .. command)
    f:close()
    return content
end

function determine_sensors()
    local base = '/sys/class/hwmon/hwmon';
    local names = read_stdout_synchronously('find '..base..'* -type l -printf "%p " -exec cat {}/name \\;')

    local lookup = {}
    for entry in names:gmatch("([^\n]*)\n?") do
        local parts = {}
        for part in entry:gmatch("([^ ]*) ?") do
            table.insert(parts, part)
        end

        local index = tonumber(parts[1]:sub(base:len() + 1))
        local driver = parts[2];
        print(("index: %i, driver: %s"):format(index, driver))

        if (lookup[name] == nil) then
            lookup[name] = {}
        end
        table.insert(lookup[name], index)
        index = index + 1
    end
    return lookup
end

determine_sensors();
