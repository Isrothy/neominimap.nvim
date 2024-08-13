local api = vim.api
local fn = vim.fn
local util = require("neominimap.util")
local config = require("neominimap.config").get()
local fold = require("neominimap.map.fold")
local logger = require("neominimap.logger")
local buffer = require("neominimap.buffer")
local coord = require("neominimap.map.coord")

local M = {}

api.nvim_set_hl(0, "NeominimapBackground", { link = "Normal", default = true })
api.nvim_set_hl(0, "NeominimapBorder", { link = "FloatBorder", default = true })
api.nvim_set_hl(0, "NeominimapCursorLine", { link = "CursorLine", default = true })

--- @param winid integer
--- @return boolean
local is_terminal = function(winid)
    return fn.getwininfo(winid)[1].terminal ~= 0
end

--- @param winid integer?
--- @return boolean
local is_cmdline = function(winid)
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
local is_ordinary_window = function(winid)
    local cfg = api.nvim_win_get_config(winid)
    local not_external = not cfg["external"]
    local not_floating = cfg["relative"] == ""
    return not_external and not_floating
end

--- Returns the height of a window excluding the winbar
--- @param winid integer
--- @return integer
local win_get_true_height = function(winid)
    local winheight = api.nvim_win_get_height(winid)

    if vim.wo[winid].winbar ~= "" then
        winheight = winheight - 1
    end

    return winheight
end
---@type table<integer, integer>
local winid_to_mwinid = {}

--- The winid of the minimap attached to the given window
---@param winid integer
---@return integer?
M.get_minimap_winid = function(winid)
    local mwinid = winid_to_mwinid[winid]
    if mwinid ~= nil and not api.nvim_win_is_valid(mwinid) then
        winid_to_mwinid[winid] = nil
        return nil
    end
    return mwinid
end

---@param mwinid integer
---@return integer?
M.get_parent_winid = function(mwinid)
    for winid, mwinid_ in pairs(winid_to_mwinid) do
        if mwinid_ == mwinid then
            return winid
        end
    end
    return nil
end

--- Set the winid of the minimap attached to the given window
---@param winid integer
---@param mwinid integer?
M.set_minimap_winid = function(winid, mwinid)
    winid_to_mwinid[winid] = mwinid
end

--- Return the list of windows that one minimap is attached to
--- @return integer[]
M.list_windows = function()
    return vim.tbl_keys(winid_to_mwinid)
end

---@param mwinid integer
---@return boolean
M.is_minimap_window = function(mwinid)
    return M.get_parent_winid(mwinid) ~= nil
end

--- The height of the minimap, excluding the border
---@param winid integer
---@return integer
local get_minimap_height = function(winid)
    local minimap_window_height = win_get_true_height(winid) - config.margin.top - config.margin.bottom
    if config.max_minimap_height then
        minimap_window_height = math.min(minimap_window_height, config.max_minimap_height)
    end
    local border = config.window_border
    if type(border) == "string" then
        if border == "none" then
            return minimap_window_height
        elseif border == "shadow" then
            return minimap_window_height - 1
        else
            return minimap_window_height - 2
        end
    else
        local char = function(n)
            local b = border[n]
            return type(b) == "string" and b or b[1]
        end
        local minimap_height = minimap_window_height
        local up = (2 - 1) % #border + 1
        local down = (6 - 1) % #border + 1
        if char(up) ~= "" then
            minimap_height = minimap_height - 1
        end
        if char(down) ~= "" then
            minimap_height = minimap_height - 1
        end
        return minimap_height
    end
end

---@param winid integer
---@return boolean
M.should_show_minimap = function(winid)
    if not api.nvim_win_is_valid(winid) then
        logger.log(string.format("Window %d is not valid", winid), vim.log.levels.WARN)
        return false
    end

    if vim.w[winid].neominimap_disabled then
        logger.log(
            string.format("Window %d is not enabled. Skipping generation of minimap", winid),
            vim.log.levels.TRACE
        )
        return false
    end

    local bufnr = api.nvim_win_get_buf(winid)
    if not buffer.get_minimap_bufnr(bufnr) then
        logger.log(
            string.format("No minimap buffer available for buffer %d in window %d", bufnr, winid),
            vim.log.levels.TRACE
        )
        return false
    end

    if is_cmdline(winid) then
        logger.log(string.format("Window %d is in cmdline", winid), vim.log.levels.TRACE)
        return false
    end

    if is_terminal(winid) then
        logger.log(string.format("Window %d is in terminal", winid), vim.log.levels.TRACE)
        return false
    end

    if not is_ordinary_window(winid) then
        logger.log(string.format("Window %d is not an ordinary window", winid), vim.log.levels.TRACE)
        return false
    end

    if get_minimap_height(winid) <= 0 then
        logger.log(string.format("Height of window %d is too small", winid), vim.log.levels.TRACE)
        return false
    end

    if 2 * config.minimap_width + 4 > api.nvim_win_get_width(winid) then
        logger.log(string.format("Width of window %d is too small", winid), vim.log.levels.TRACE)
        return false
    end

    if not config.win_filter(winid) then
        logger.log(string.format("Window %d should not be shown due to win_filter", winid), vim.log.levels.TRACE)
        return false
    end

    logger.log(string.format("Minimap can be shown for window %d", winid), vim.log.levels.TRACE)
    return true
end

---@param winid integer
local get_window_config = function(winid)
    logger.log(string.format("Getting window configuration for window %d", winid), vim.log.levels.TRACE)

    local col = api.nvim_win_get_width(winid) - config.margin.right
    local row = config.margin.top
    local height = get_minimap_height(winid)

    return {
        relative = "win",
        win = winid,
        anchor = "NE",
        width = config.minimap_width,
        height = height,
        row = row,
        col = col,
        focusable = false,
        zindex = config.z_index,
        border = config.window_border,
    }
end

--- WARN: This function does not check whether a minimap should be created for this window nor if this window is valid.
--- Create the minimap attached to the given window
---@param winid integer
---@return integer? mwinid winid of the minimap window if created, nil otherwise
M.create_minimap_window = function(winid)
    logger.log(string.format("Attempting to create minimap for window %d", winid), vim.log.levels.TRACE)

    local bufnr = api.nvim_win_get_buf(winid)
    local mbufnr = buffer.get_minimap_bufnr(bufnr)

    if not mbufnr then
        logger.log(string.format("Minimap buffer not available for window %d", winid), vim.log.levels.TRACE)
        return nil
    end

    logger.log(string.format("Creating minimap window for window %d", winid), vim.log.levels.TRACE)
    local win_cfg = get_window_config(winid)
    win_cfg.noautocmd = true --Set noautocmd here for noautocmd can only set for none existing window
    local mwinid = util.noautocmd(api.nvim_open_win)(mbufnr, false, win_cfg)
    M.set_minimap_winid(winid, mwinid)

    local winopt = {
        winhighlight = "Normal:NeominimapBackground,FloatBorder:NeominimapBorder,CursorLine:NeominimapCursorLine",
        wrap = false,
        foldcolumn = "0",
        signcolumn = "auto",
        statuscolumn = "",
        number = false,
        relativenumber = false,
        scrolloff = 99999, -- To center minimap
        sidescrolloff = 0,
        winblend = 0,
        cursorline = true,
        spell = false,
    }

    local user_opt = type(config.winopt) == "function" and config.winopt(winid) or config.winopt
    if type(user_opt) == "table" then
        winopt = vim.tbl_deep_extend("force", winopt, user_opt)
    else
        logger.log_and_notify(
            string.format("Invalid type for winopt: expected table, got %s", type(user_opt)),
            vim.log.levels.ERROR
        )
    end
    for k, v in pairs(winopt) do
        vim.wo[mwinid][k] = v
    end

    logger.log(string.format("Minimap window %d created for window %d", mwinid, winid), vim.log.levels.TRACE)
    return mwinid
end

--- Close the minimap attached to the given window
---@param winid integer
---@return integer? mwinid winid of the minimap window if successfully removed, nil otherwise
M.close_minimap_window = function(winid)
    local mwinid = M.get_minimap_winid(winid)
    M.set_minimap_winid(winid, nil)
    logger.log(string.format("Attempting to close minimap for window %d", winid), vim.log.levels.TRACE)
    if mwinid and api.nvim_win_is_valid(mwinid) then
        logger.log(string.format("Deleting minimap window %d", mwinid), vim.log.levels.TRACE)
        util.noautocmd(api.nvim_win_close)(mwinid, true)
        return mwinid
    else
        logger.log(string.format("Minimap window %d is not valid or already closed", winid), vim.log.levels.TRACE)
    end
    return nil
end

---@param winid integer
---@return boolean
M.reset_mwindow_cursor_line = function(winid)
    logger.log(string.format("Resetting cursor line for window %d", winid), vim.log.levels.TRACE)
    local mwinid = M.get_minimap_winid(winid)
    if not mwinid then
        logger.log(string.format("Minimap window %d is not valid", winid), vim.log.levels.TRACE)
        return false
    end
    local rowCol = vim.api.nvim_win_get_cursor(winid)
    local row = rowCol[1]
    local col = rowCol[2]
    if config.fold.enabled then
        local bufnr = api.nvim_win_get_buf(winid)
        local vrow = fold.substract_fold_lines(fold.get_cached_folds(bufnr), row)
        if not vrow then
            logger.log("failed to find the line number considering folded lines", vim.log.levels.WARN)
            row = 1
        else
            row = vrow
        end
    end
    row, col = coord.codepoint_to_mcodepoint(row, col)
    local mbufnr = api.nvim_win_get_buf(mwinid)
    local line_cnt = api.nvim_buf_line_count(mbufnr)
    if row <= line_cnt then
        vim.schedule_wrap(util.noautocmd(vim.api.nvim_win_set_cursor))(mwinid, { row, 0 })
    end
    logger.log(string.format("Cursor line reset for window %d", winid), vim.log.levels.TRACE)
    return false
end

---@param mwinid integer
---@return boolean
M.reset_parent_window_cursor_line = function(mwinid)
    logger.log(string.format("Resetting cursor line for minimap window %d", mwinid), vim.log.levels.TRACE)
    local winid = M.get_parent_winid(mwinid)
    if not winid then
        logger.log("Window not found", vim.log.levels.TRACE)
        return false
    end
    local bufnr = api.nvim_win_get_buf(winid)
    local rowCol = vim.api.nvim_win_get_cursor(mwinid)
    local row = rowCol[1]
    local col = rowCol[2]
    row, col = coord.mcodepoint_to_codepoint(row, col)
    if config.fold.enabled then
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
        vim.schedule_wrap(util.noautocmd(vim.api.nvim_win_set_cursor))(winid, { row, 0 })
    end
    logger.log(string.format("Cursor line reset for minimap window %d", mwinid), vim.log.levels.TRACE)
    return false
end

---@param winid integer
---@return boolean
M.focus = function(winid)
    logger.log(string.format("Focusing window %d", winid), vim.log.levels.TRACE)
    local mwinid = M.get_minimap_winid(winid)
    if not mwinid then
        logger.log(string.format("Minimap window %d is not valid", winid), vim.log.levels.TRACE)
        return false
    end
    api.nvim_set_current_win(mwinid)
    logger.log(string.format("Window %d focused", winid), vim.log.levels.TRACE)
    return true
end

--- @param mwinid integer
--- @return boolean
M.unfocus = function(mwinid)
    logger.log(string.format("Unfocusing window %d", mwinid), vim.log.levels.TRACE)
    local winid = M.get_parent_winid(mwinid)
    if not winid then
        logger.log("Window not found", vim.log.levels.TRACE)
        return false
    end
    api.nvim_set_current_win(winid)
    logger.log(string.format("Window %d unfocused", mwinid), vim.log.levels.TRACE)
    return true
end

--- Refresh the minimap attached to the given window
--- Close window if minimap should not be shown or if the minimap buffer is not available
--- Otherwise, create the minimap if it does not exist
--- Otherwise, reset the window config
--- Reset the buffer if the it does not match the current window
---@param winid integer
---@return integer? mwinid winid of the minimap window if created, nil otherwise
M.refresh_minimap_window = function(winid)
    logger.log(string.format("Refreshing minimap for window %d", winid), vim.log.levels.TRACE)
    if not api.nvim_win_is_valid(winid) or not M.should_show_minimap(winid) then
        logger.log(string.format("Window %d is not valid or should not be shown", winid), vim.log.levels.TRACE)
        if M.get_minimap_winid(winid) then
            M.close_minimap_window(winid)
        end
        return nil
    end

    local bufnr = api.nvim_win_get_buf(winid)
    local mbufnr = buffer.get_minimap_bufnr(bufnr)
    if not mbufnr then
        logger.log(string.format("Minimap buffer not available for window %d", winid), vim.log.levels.TRACE)
        if M.get_minimap_winid(winid) then
            M.close_minimap_window(winid)
        end
        return nil
    end

    local mwinid = M.get_minimap_winid(winid) or M.create_minimap_window(winid)
    if not mwinid then
        logger.log(string.format("Failed to create minimap for window %d", winid), vim.log.levels.TRACE)
        return nil
    end

    local cfg = get_window_config(winid)
    util.noautocmd(api.nvim_win_set_config)(mwinid, cfg)

    if api.nvim_win_get_buf(mwinid) ~= mbufnr then
        api.nvim_win_set_buf(mwinid, mbufnr)
    end

    M.reset_mwindow_cursor_line(winid)

    logger.log(string.format("Minimap for window %d refreshed", winid), vim.log.levels.TRACE)
    return mwinid
end

--- Refresh all minimaps in the given tab
---@param tabid integer
M.refresh_minimaps_in_tab = function(tabid)
    logger.log(string.format("Refreshing all minimaps in tab %d", tabid), vim.log.levels.TRACE)
    local win_list = api.nvim_tabpage_list_wins(tabid)
    for _, winid in ipairs(win_list) do
        M.refresh_minimap_window(winid)
    end
    logger.log(string.format("All minimaps in tab %d refreshed", tabid), vim.log.levels.TRACE)
end

--- Close all minimaps in the given tab
---@param tabid integer
M.close_minimap_in_tab = function(tabid)
    logger.log(string.format("Closing all minimaps in tab %d", tabid), vim.log.levels.TRACE)
    local win_list = api.nvim_tabpage_list_wins(tabid)
    for _, winid in ipairs(win_list) do
        M.close_minimap_window(winid)
    end
    logger.log(string.format("All minimaps in tab %d closed", tabid), vim.log.levels.TRACE)
end

--- Refresh all minimaps across tabs
M.refresh_all_minimap_windows = function()
    logger.log("Refreshing all minimap windows", vim.log.levels.TRACE)
    local win_list = api.nvim_list_wins()
    for _, winid in ipairs(win_list) do
        M.refresh_minimap_window(winid)
    end
    logger.log("All minimap windows refreshed", vim.log.levels.TRACE)
end

--- Close all minimaps across tabs
M.close_all_minimap_windows = function()
    logger.log("Closing all minimap windows", vim.log.levels.TRACE)
    for _, winid in ipairs(M.list_windows()) do
        M.close_minimap_window(winid)
    end
end

return M
