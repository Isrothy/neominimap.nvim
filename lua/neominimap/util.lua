local bit = require("bit")

local M = {}

--- @generic F: function
--- @param f F
--- @return F
M.noautocmd = function(f)
    return function(...)
        local eventignore = vim.o.eventignore
        vim.o.eventignore = "all"
        local r = { f(...) }
        vim.o.eventignore = eventignore
        return unpack(r)
    end
end

--- @generic F: function
--- @param f F
--- @param delay number
--- @return F
M.debounce = function(f, delay)
    local timer = nil
    return function(...)
        local args = { ... }
        if timer then
            vim.uv.timer_stop(timer)
        end
        timer = vim.uv.new_timer()
        vim.uv.timer_start(timer, delay, 0, function()
            f(unpack(args))
        end)
    end
end

--- Returns the first index of a value that is greater than or equal to the given value
--- @generic T
--- @param arr T[]
--- @param value T
--- @return integer
M.lower_bound = function(arr, value)
    local low, high = 1, #arr + 1

    while low < high do
        local mid = bit.rshift(low + high, 1)
        if arr[mid] < value then
            low = mid + 1
        else
            high = mid
        end
    end

    return low
end

--- Returns the first index of a value that is greater than the given value
--- @generic T
--- @param arr T[]
--- @param value T
--- @return integer
M.upper_bound = function(arr, value)
    local low, high = 1, #arr + 1

    while low < high do
        local mid = bit.rshift(low + high, 1)
        if arr[mid] <= value then
            low = mid + 1
        else
            high = mid
        end
    end

    return low
end

return M
