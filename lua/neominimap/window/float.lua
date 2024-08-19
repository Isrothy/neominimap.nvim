local api = vim.api
local fn = vim.fn
local config = require("neominimap.config").get()

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
    local logger = require("neominimap.logger")
    local var = require("neominimap.variables")
    if not api.nvim_win_is_valid(winid) then
        logger.log(string.format("Window %d is not valid", winid), vim.log.levels.WARN)
        return false
    end

    if not var.g.enabled then
        logger.log("Minimap is disabled. Skipping generation of minimap", vim.log.levels.TRACE)
        return false
    end

    if not var.w[winid].enabled then
        logger.log(
            string.format("Window %d is not enabled. Skipping generation of minimap", winid),
            vim.log.levels.TRACE
        )
        return false
    end

    local bufnr = api.nvim_win_get_buf(winid)
    local buffer = require("neominimap.buffer")
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
    local logger = require("neominimap.logger")
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
        focusable = config.click.enabled,
        zindex = config.z_index,
        border = config.window_border,
    }
end

--- WARN: This function does not check whether a minimap should be created for this window nor if this window is valid.
--- Create the minimap attached to the given window
---@param winid integer
---@return integer? mwinid winid of the minimap window if created, nil otherwise
M.create_minimap_window = function(winid)
    local logger = require("neominimap.logger")
    local util = require("neominimap.util")
    logger.log(string.format("Attempting to create minimap for window %d", winid), vim.log.levels.TRACE)

    local bufnr = api.nvim_win_get_buf(winid)
    local buffer = require("neominimap.buffer")
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
        number = false,
        relativenumber = false,
        scrolloff = 99999, -- To center minimap
        sidescrolloff = 0,
        winblend = 0,
        cursorline = true,
        spell = false,
        list = false,
    }
    config.winopt(winopt, winid)
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
    local logger = require("neominimap.logger")
    local mwinid = M.get_minimap_winid(winid)
    M.set_minimap_winid(winid, nil)
    logger.log(string.format("Attempting to close minimap for window %d", winid), vim.log.levels.TRACE)
    if mwinid and api.nvim_win_is_valid(mwinid) then
        logger.log(string.format("Deleting minimap window %d", mwinid), vim.log.levels.TRACE)
        local util = require("neominimap.util")
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
    local logger = require("neominimap.logger")
    logger.log(string.format("Resetting cursor line for minimap of window %d", winid), vim.log.levels.TRACE)
    local mwinid = M.get_minimap_winid(winid)
    if not mwinid then
        logger.log(string.format("Minimap window %d is not valid", winid), vim.log.levels.TRACE)
        return false
    end
    local rowCol = vim.api.nvim_win_get_cursor(winid)
    local row = rowCol[1]
    local col = rowCol[2] + 1
    if config.fold.enabled then
        local bufnr = api.nvim_win_get_buf(winid)
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
    logger.log(string.format("Cursor line reset for minimap of window %d", winid), vim.log.levels.TRACE)
    return false
end

---@param mwinid integer
---@return boolean
M.reset_parent_window_cursor_line = function(mwinid)
    local logger = require("neominimap.logger")
    logger.log(string.format("Resetting cursor line for parent of minimap window %d", mwinid), vim.log.levels.TRACE)
    local winid = M.get_parent_winid(mwinid)
    if not winid then
        logger.log("Window not found", vim.log.levels.TRACE)
        return false
    end
    local bufnr = api.nvim_win_get_buf(winid)
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
        vim.schedule_wrap(util.noautocmd(vim.api.nvim_win_set_cursor))(winid, { row, 0 })
    end
    logger.log(string.format("Cursor line reset for parent of minimap window %d", mwinid), vim.log.levels.TRACE)
    return false
end

---@param winid integer
---@return boolean
M.focus = function(winid)
    local logger = require("neominimap.logger")
    logger.log(string.format("Focusing window %d", winid), vim.log.levels.TRACE)
    local mwinid = M.get_minimap_winid(winid)
    if not mwinid then
        logger.log(string.format("Minimap window %d is not valid", winid), vim.log.levels.TRACE)
        return false
    end
    local util = require("neominimap.util")
    util.noautocmd(api.nvim_set_current_win)(mwinid)
    logger.log(string.format("Window %d focused", winid), vim.log.levels.TRACE)
    return true
end

--- @param mwinid integer
--- @return boolean
M.unfocus = function(mwinid)
    local logger = require("neominimap.logger")
    logger.log(string.format("Unfocusing window %d", mwinid), vim.log.levels.TRACE)
    local winid = M.get_parent_winid(mwinid)
    if not winid then
        logger.log("Window not found", vim.log.levels.TRACE)
        return false
    end
    local util = require("neominimap.util")
    util.noautocmd(api.nvim_set_current_win)(winid)
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
    local logger = require("neominimap.logger")
    logger.log(string.format("Refreshing minimap for window %d", winid), vim.log.levels.TRACE)
    if not api.nvim_win_is_valid(winid) or not M.should_show_minimap(winid) then
        logger.log(string.format("Window %d is not valid or should not be shown", winid), vim.log.levels.TRACE)
        if M.get_minimap_winid(winid) then
            M.close_minimap_window(winid)
        end
        return nil
    end

    local bufnr = api.nvim_win_get_buf(winid)
    local buffer = require("neominimap.buffer")
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
    local util = require("neominimap.util")
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
    local logger = require("neominimap.logger")
    logger.log(string.format("Refreshing all minimaps in tab %d", tabid), vim.log.levels.TRACE)
    require("neominimap.util").for_all_windows_in_tab(M.refresh_minimap_window, tabid)
    logger.log(string.format("All minimaps in tab %d refreshed", tabid), vim.log.levels.TRACE)
end

--- Close all minimaps in the given tab
---@param tabid integer
M.close_minimap_in_tab = function(tabid)
    local logger = require("neominimap.logger")
    logger.log(string.format("Closing all minimaps in tab %d", tabid), vim.log.levels.TRACE)
    require("neominimap.util").for_all_windows_in_tab(M.close_minimap_window, tabid)
    logger.log(string.format("All minimaps in tab %d closed", tabid), vim.log.levels.TRACE)
end

--- Refresh all minimaps across tabs
M.refresh_all_minimap_windows = function()
    local logger = require("neominimap.logger")
    logger.log("Refreshing all minimap windows", vim.log.levels.TRACE)
    require("neominimap.util").for_all_windows(M.refresh_minimap_window)
    logger.log("All minimap windows refreshed", vim.log.levels.TRACE)
end

--- Close all minimaps across tabs
M.close_all_minimap_windows = function()
    local logger = require("neominimap.logger")
    logger.log("Closing all minimap windows", vim.log.levels.TRACE)
    require("neominimap.util").for_all_windows(M.close_minimap_window)
    logger.log("All minimap windows closed", vim.log.levels.TRACE)
end

---@type Neominimap.Command.Win.Handler
M.win_cmds = {
    ["winRefresh"] = vim.schedule_wrap(M.refresh_minimap_window),
    ["winOn"] = vim.schedule_wrap(M.refresh_minimap_window),
    ["winOff"] = vim.schedule_wrap(M.refresh_minimap_window),
}

---@type Neominimap.Command.Focus.Handler
M.focus_cmds = {
    ["focus"] = vim.schedule_wrap(function(winid)
        local ok = M.focus(winid)
        if not ok then
            local logger = require("neominimap.logger")
            logger.notify("Minimap can not be focused for current window", vim.log.levels.ERROR)
        end
    end),
    ["unfocus"] = vim.schedule_wrap(function(mwinid)
        local ok = M.unfocus(mwinid)
        if not ok then
            local logger = require("neominimap.logger")
            logger.notify("Minimap can not be unfocused for current window", vim.log.levels.ERROR)
        end
    end),
    ["toggleFocus"] = function(winid)
        if M.is_minimap_window(winid) then
            M.focus_cmds.unfocus(winid)
        else
            M.focus_cmds.focus(winid)
        end
    end,
}

---@type Neominimap.Command.Global.Handler
M.global_cmds = {
    ["on"] = vim.schedule_wrap(M.refresh_all_minimap_windows),
    ["off"] = vim.schedule_wrap(M.refresh_all_minimap_windows),
    ["refresh"] = vim.schedule_wrap(M.refresh_all_minimap_windows),
}

M.create_autocmds = function()
    if config.click.enabled and not config.click.auto_switch_focus then
        api.nvim_create_autocmd("WinEnter", {
            group = "Neominimap",
            callback = function()
                local winid = api.nvim_get_current_win()
                local logger = require("neominimap.logger")
                logger.log(string.format("WinEnter event triggered for window %d.", winid), vim.log.levels.TRACE)
                vim.schedule(function()
                    if M.is_minimap_window(winid) then
                        logger.log(string.format("Unfocusing minimap window %d.", winid), vim.log.levels.TRACE)
                        M.unfocus(winid)
                        logger.log(string.format("Minimap window %d unfocused.", winid), vim.log.levels.TRACE)
                    end
                end)
            end,
        })
    end

    api.nvim_create_autocmd("BufWinEnter", {
        group = "Neominimap",
        callback = function()
            local logger = require("neominimap.logger")
            local winid = api.nvim_get_current_win()
            logger.log(string.format("BufWinEnter event triggered for window %d.", winid), vim.log.levels.TRACE)
            vim.schedule(function()
                logger.log(string.format("Refreshing minimap window for window ID: %d.", winid), vim.log.levels.TRACE)
                M.refresh_minimap_window(winid)
                logger.log(string.format("Minimap window refreshed for window %d.", winid), vim.log.levels.TRACE)
            end)
        end,
    })
    api.nvim_create_autocmd("WinNew", {
        group = "Neominimap",
        callback = function()
            local logger = require("neominimap.logger")
            local winid = api.nvim_get_current_win()
            logger.log(string.format("WinNew event triggered for window %d.", winid), vim.log.levels.TRACE)
            vim.schedule(function()
                logger.log(string.format("Refreshing minimap window for window ID: %d.", winid), vim.log.levels.TRACE)
                M.refresh_minimap_window(winid)
                logger.log(string.format("Minimap window refreshed for window %d.", winid), vim.log.levels.TRACE)
            end)
        end,
    })
    api.nvim_create_autocmd("WinClosed", {
        group = "Neominimap",
        callback = function(args)
            local logger = require("neominimap.logger")
            logger.log(
                string.format("WinClosed event triggered for window %d.", tonumber(args.match)),
                vim.log.levels.TRACE
            )
            local winid = tonumber(args.match)
            vim.schedule(function()
                logger.log(string.format("Closing minimap for window %d.", winid), vim.log.levels.TRACE)
                ---@cast winid integer
                M.close_minimap_window(winid)
                logger.log(string.format("Minimap window closed for window %d.", winid), vim.log.levels.TRACE)
            end)
        end,
    })
    api.nvim_create_autocmd("TabEnter", {
        group = "Neominimap",
        callback = vim.schedule_wrap(function()
            local logger = require("neominimap.logger")
            local tid = api.nvim_get_current_tabpage()
            local window = require("neominimap.window")
            logger.log(string.format("TabEnter event triggered for tab %d.", tid), vim.log.levels.TRACE)
            logger.log(string.format("Refreshing minimaps for tab ID: %d.", tid), vim.log.levels.TRACE)
            window.refresh_minimaps_in_tab(tid)
        end),
    })
    api.nvim_create_autocmd("WinResized", {
        group = "Neominimap",
        callback = function()
            local logger = require("neominimap.logger")
            logger.log("WinResized event triggered.", vim.log.levels.TRACE)
            local win_list = vim.deepcopy(vim.v.event.windows)
            logger.log(string.format("Windows to be resized: %s", vim.inspect(win_list)), vim.log.levels.TRACE)
            for _, winid in ipairs(win_list) do
                vim.schedule(function()
                    logger.log(string.format("Refreshing minimaps for window: %d", winid), vim.log.levels.TRACE)
                    M.refresh_minimap_window(winid)
                    logger.log(string.format("Minimaps refreshed for window: %d", winid), vim.log.levels.TRACE)
                end)
            end
        end,
    })
    api.nvim_create_autocmd("WinScrolled", {
        group = "Neominimap",
        callback = function()
            local logger = require("neominimap.logger")
            logger.log("WinScrolled event triggered.", vim.log.levels.TRACE)
            local win_list = {}
            for winid, _ in pairs(vim.v.event) do
                if winid ~= "all" then
                    win_list[#win_list + 1] = tonumber(winid)
                end
            end
            logger.log(string.format("Windows to be scrolled: %s", vim.inspect(win_list)), vim.log.levels.TRACE)
            vim.schedule(function()
                for _, winid in ipairs(win_list) do
                    logger.log(string.format("Refreshing minimap for window %d.", winid), vim.log.levels.TRACE)
                    M.refresh_minimap_window(winid)
                    logger.log(string.format("Minimap refreshed for window %d.", winid), vim.log.levels.TRACE)
                end
            end)
        end,
    })
    api.nvim_create_autocmd({ "CursorMoved", "CursorMovedI" }, {
        group = "Neominimap",
        callback = function()
            local logger = require("neominimap.logger")
            logger.log("CursorMoved event triggered.", vim.log.levels.TRACE)
            local winid = api.nvim_get_current_win()
            logger.log(string.format("Window ID: %d", winid), vim.log.levels.TRACE)
            vim.schedule(function()
                if M.is_minimap_window(winid) then
                    if config.sync_cursor then
                        logger.log(
                            string.format("Resetting parent cursor line for minimap window %d.", winid),
                            vim.log.levels.TRACE
                        )
                        M.reset_parent_window_cursor_line(winid)
                        logger.log(
                            string.format("Parent cursor line reset for window %d.", winid),
                            vim.log.levels.TRACE
                        )
                    end
                else
                    logger.log(string.format("Resettting cursor line for window %d.", winid), vim.log.levels.TRACE)
                    M.reset_mwindow_cursor_line(winid)
                    logger.log(string.format("Cursor line reset for window %d.", winid), vim.log.levels.TRACE)
                end
            end)
        end,
    })
    api.nvim_create_autocmd("User", {
        group = "Neominimap",
        pattern = { "MinimapBufferCreated", "MinimapBufferDeleted" },
        callback = function(args)
            local logger = require("neominimap.logger")
            logger.log(
                "User Neominimap event triggered. patter: MinimapBufferCreated or MinimapBufferDeleted",
                vim.log.levels.TRACE
            )
            local bufnr = args.data.buf
            local win_list = require("neominimap.util").get_attached_window(bufnr)
            for _, winid in ipairs(win_list) do
                logger.log(string.format("Refreshing minimap for window %d.", winid), vim.log.levels.TRACE)
                M.refresh_minimap_window(winid)
                logger.log(string.format("Minimap refreshed for window %d.", winid), vim.log.levels.TRACE)
            end
        end,
    })
end

return M
