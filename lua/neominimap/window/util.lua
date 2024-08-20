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
M.get_winopt = function(winid)
    local winopt = vim.deepcopy(default_winopt)
    config.winopt(winopt, winid)
    return winopt
end

---@param swinid integer
---@param mwinid integer
M.sync_to_minimap = function(swinid, mwinid)
    local logger = require("neominimap.logger")
    logger.log("Syncing source with minimap", vim.log.levels.TRACE)
    local bufnr = api.nvim_win_get_buf(swinid)
    local rowCol = vim.api.nvim_win_get_cursor(mwinid)
    local row = rowCol[1]
    local col = rowCol[2] + 1
    local coord = require("neominimap.map.coord")
    row, col = coord.mcodepoint_to_codepoint(row, col)
    if config.fold.enabled then
        local fold = require("neominimap.map.fold")
        local vrow = fold.add_fold_lines(fold.get_cached_folds(bufnr), row)
        if not vrow then
            logger.log("Failed to find the line number considering folded lines", vim.log.levels.WARN)
            row = 1
        else
            row = vrow
        end
    end
    local line_cnt = api.nvim_buf_line_count(bufnr)
    if row <= line_cnt then
        local util = require("neominimap.util")
        vim.schedule_wrap(util.noautocmd(vim.api.nvim_win_set_cursor))(swinid, { row, 0 })
    end
    logger.log("Source synced with minimap", vim.log.levels.TRACE)
end

---@param swinid integer
---@param mwinid integer
M.sync_to_source = function(swinid, mwinid)
    local logger = require("neominimap.logger")
    logger.log("Syncing minimap with source", vim.log.levels.TRACE)
    local rowCol = vim.api.nvim_win_get_cursor(swinid)
    local row = rowCol[1]
    local col = rowCol[2] + 1
    if config.fold.enabled then
        local bufnr = api.nvim_win_get_buf(swinid)
        local fold = require("neominimap.map.fold")
        local vrow = fold.substract_fold_lines(fold.get_cached_folds(bufnr), row)
        if not vrow then
            logger.log("failed to find the line number considering folded lines", vim.log.levels.WARN)
            row = 1
        else
            row = vrow
        end
    end
    local coord = require("neominimap.map.coord")
    row, col = coord.codepoint_to_mcodepoint(row, col)
    local mbufnr = api.nvim_win_get_buf(mwinid)
    local line_cnt = api.nvim_buf_line_count(mbufnr)
    if row <= line_cnt then
        local util = require("neominimap.util")
        vim.schedule_wrap(util.noautocmd(vim.api.nvim_win_set_cursor))(mwinid, { row, 0 })
    end
    logger.log("Minimap synced with source", vim.log.levels.TRACE)
end

return M
