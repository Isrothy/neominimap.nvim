local M = {}

local fn = vim.fn
local api = vim.api

--- @param winid integer
--- @return boolean
function M.is_terminal(winid)
    return fn.getwininfo(winid)[1].terminal ~= 0
end

--- @param winid integer?
--- @return boolean
function M.is_cmdline(winid)
    winid = winid or api.nvim_get_current_win()
    if not api.nvim_win_is_valid(winid) then
        return false
    end
    if fn.win_gettype(winid) == "command" then
        return true
    end
    local bufnr = api.nvim_win_get_buf(winid)
    return api.nvim_buf_get_name(bufnr) == "[Command Line]"
end

--- Returns true for ordinary windows (not floating and not external), and false
--- otherwise.
--- @param winid integer
--- @return boolean
function M.is_ordinary_window(winid)
    local cfg = api.nvim_win_get_config(winid)
    local not_external = not cfg["external"]
    local not_floating = cfg["relative"] == ""
    return not_external and not_floating
end

--- @generic F: function
--- @param f F
--- @return F
function M.noautocmd(f)
    return function(...)
        local eventignore = vim.o.eventignore
        vim.o.eventignore = "all"
        local r = { f(...) }
        vim.o.eventignore = eventignore
        return unpack(r)
    end
end

return M
