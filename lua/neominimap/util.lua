local M = {}
local api, fn = vim.api, vim.fn

---@param word string
---@return string
M.capitalize = function(word)
    return word:sub(1, 1):upper() .. word:sub(2)
end

--- @return integer[]
M.get_visible_buffers = function()
    local visible_buffers = {}
    for _, win in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
        local buf = vim.api.nvim_win_get_buf(win)
        table.insert(visible_buffers, buf)
    end
    return visible_buffers
end

--- @param bufnr integer
--- @return integer[]
M.get_attached_window = function(bufnr)
    local win_list = api.nvim_list_wins()

    ---@type integer[]
    local attachec_windod = {}
    for _, w in ipairs(win_list) do
        if api.nvim_win_get_buf(w) == bufnr then
            attachec_windod[#attachec_windod + 1] = w
        end
    end

    return attachec_windod
end

M.is_floating = function(winid)
    return api.nvim_win_get_config(winid).relative ~= ""
end

--- @param f fun(bufnr: integer)
M.for_all_buffers = function(f)
    local buffer_list = api.nvim_list_bufs()
    vim.tbl_map(f, buffer_list)
end

--- @param f fun(winid: integer)
M.for_all_windows = function(f)
    local win_list = api.nvim_list_wins()
    vim.tbl_map(f, win_list)
end

--- @param tabid integer
--- @param f fun(winid: integer)
M.for_all_windows_in_tab = function(f, tabid)
    local win_list = api.nvim_tabpage_list_wins(tabid)
    vim.tbl_map(f, win_list)
end

--- @param f fun(tabid: integer)
M.for_all_tabs = function(f)
    local tab_list = api.nvim_list_tabpages()
    vim.tbl_map(f, tab_list)
end

---@return boolean
M.is_search_mode = function()
    if
        vim.o.incsearch
        and vim.o.hlsearch
        and api.nvim_get_mode().mode == "c"
        and vim.tbl_contains({ "/", "?" }, fn.getcmdtype())
    then
        return true
    end
    return false
end

--- @generic F: function
--- @param f F
--- @return F
function M.noautocmd(f)
    return function(...)
        local eventignore = vim.o.eventignore
        vim.o.eventignore = "all"
        local r = { pcall(f, ...) }
        vim.o.eventignore = eventignore
        if not r[1] then
            error(r[2])
        end
        return unpack(r, 2, table.maxn(r))
    end
end

--- Run callback when command is run
--- @param cmd string
--- @param augroup string|integer
--- @param f function()
function M.on_cmd(cmd, augroup, f)
    api.nvim_create_autocmd("CmdlineLeave", {
        group = augroup,
        callback = function()
            if fn.getcmdtype() == ":" and vim.startswith(fn.getcmdline(), cmd) then
                f()
            end
        end,
    })
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

--- @generic F: function
--- @param f F
--- @param callback fun()
--- @return F
M.finally = function(f, callback)
    return function(...)
        local args = { ... }
        local ret = f(unpack(args))
        callback()
        return ret
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
