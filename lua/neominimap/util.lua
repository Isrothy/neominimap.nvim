local M = {}

--- @return integer[]
M.get_visible_buffers = function()
    local visible_buffers = {}
    for _, win in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
        local buf = vim.api.nvim_win_get_buf(win)
        table.insert(visible_buffers, buf)
    end
    return visible_buffers
end

---@return boolean
M.is_search_mode = function()
    if
        vim.o.incsearch
        and vim.o.hlsearch
        and vim.api.nvim_get_mode().mode == "c"
        and vim.tbl_contains({ "/", "?" }, vim.fn.getcmdtype())
    then
        return true
    end
    return false
end
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
