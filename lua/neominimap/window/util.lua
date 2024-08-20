local M = {}
local api, fn = vim.api, vim.fn
local config = require("neominimap.config")

--- @param winid integer
--- @return boolean
M.is_terminal = function(winid)
    return fn.getwininfo(winid)[1].terminal ~= 0
end

--- @param winid integer?
--- @return boolean
M.is_cmdline = function(winid)
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
M.is_ordinary_window = function(winid)
    local cfg = api.nvim_win_get_config(winid)
    local not_external = not cfg["external"]
    local not_floating = cfg["relative"] == ""
    return not_external and not_floating
end

--- Returns the height of a window excluding the winbar
--- @param winid integer
--- @return integer
M.win_get_true_height = function(winid)
    local winheight = api.nvim_win_get_height(winid)

    if vim.wo[winid].winbar ~= "" then
        winheight = winheight - 1
    end

    return winheight
end

local default_winopt = {
    winhighlight = "Normal:NeominimapBackground,FloatBorder:NeominimapBorder,CursorLine:NeominimapCursorLine",
    wrap = false,
    foldcolumn = "0",
    signcolumn = "auto",
    number = false,
    relativenumber = false,
    scrolloff = 99999, -- To center minimap
    sidescrolloff = 0,
    winblend = 0,
    cursorline = true,
    spell = false,
    list = false,
    fillchars = "eob: ",
    winfixwidth = true,
}

---@param winid integer
---@return table
M.win_get_opt = function(winid)
    local winopt = vim.deepcopy(default_winopt)
    config.winopt(winopt, winid)
    return winopt
end

return M
