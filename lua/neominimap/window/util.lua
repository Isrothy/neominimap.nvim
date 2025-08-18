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
    winhighlight = table.concat({
        "Normal:NeominimapBackground",
        "FloatBorder:NeominimapBorder",
        "CursorLine:NeominimapCursorLine",
        "CursorLineNr:NeominimapCursorLineNr",
        "CursorLineSign:NeominimapCursorLineSign",
        "CursorLineFold:NeominimapCursorLineFold",
    }, ","),
    wrap = false,
    foldcolumn = "0",
    signcolumn = "auto",
    number = false,
    relativenumber = false,
    scrolloff = config.current_line_position == "center" and 99999 or 0,
    sidescrolloff = 0,
    winblend = 0,
    cursorline = true,
    spell = false,
    list = false,
    fillchars = "eob: ",
    winfixwidth = true,
}

---@param opt vim.wo
---@param winid integer
M.set_winopt = function(opt, winid)
    for k, v in pairs(default_winopt) do
        opt[k] = v
    end
    config.winopt(opt, winid)
end

---@param winid integer
---@param row integer
local function set_current_line_by_percentage(winid, row)
    local win_h = M.win_get_true_height(winid)
    local bufnr = api.nvim_win_get_buf(winid)
    local line_cnt = api.nvim_buf_line_count(bufnr)
    local topline = math.floor(row - (row * win_h) / line_cnt)
    row = math.max(1, math.min(row, line_cnt))
    topline = math.max(1, math.min(topline, line_cnt))
    return function()
        local view = vim.fn.winsaveview()
        view.topline = topline
        view.lnum = row - 1
        vim.fn.winrestview(view)
    end
end

---@param swinid integer
---@param mwinid integer
M.sync_to_minimap = function(swinid, mwinid)
    local logger = require("neominimap.logger")
    logger.log.trace("Syncing source with minimap")
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
            logger.log.warn("Failed to find the line number considering folded lines")
            row = 1
        else
            row = vrow
        end
    end
    local line_cnt = api.nvim_buf_line_count(bufnr)
    if row <= line_cnt then
        local util = require("neominimap.util")
        vim.schedule(function()
            local ok = util.noautocmd(pcall)(vim.api.nvim_win_set_cursor, swinid, { row, 0 })
            if not ok then
                logger.log.warn("Failed to set cursor")
            end
        end)
    end
    logger.log.trace("Source synced with minimap")
end

---@param swinid integer
---@param mwinid integer
M.sync_to_source = function(swinid, mwinid)
    local logger = require("neominimap.logger")
    logger.log.trace("Syncing minimap with source")
    local rowCol = vim.api.nvim_win_get_cursor(swinid)
    local row = rowCol[1]
    local col = rowCol[2] + 1
    if config.fold.enabled then
        local bufnr = api.nvim_win_get_buf(swinid)
        local fold = require("neominimap.map.fold")
        local vrow, hidden = fold.subtract_fold_lines(fold.get_cached_folds(bufnr), row)
        if hidden then
            logger.log.warn("failed to find the line number considering folded lines")
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
        vim.schedule(function()
            local ok = util.noautocmd(pcall)((function()
                if config.current_line_position == "center" then
                    return vim.api.nvim_win_set_cursor, mwinid, { row, 0 }
                else
                    return api.nvim_win_call, mwinid, set_current_line_by_percentage(mwinid, row)
                end
            end)())
            if not ok then
                logger.log.error("Failed to set cursor")
            end
        end)
    end
    logger.log.trace("Minimap synced with source")
end

return M
