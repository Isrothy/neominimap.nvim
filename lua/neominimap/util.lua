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

return M
