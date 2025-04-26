local M = {}

local api = vim.api
local config = require("neominimap.config")

--- The height of the minimap, excluding the border
---@param winid integer
---@return integer
local get_minimap_height = function(winid)
    local win_util = require("neominimap.window.util")
    local minimap_window_height = win_util.win_get_true_height(winid)
        - config.float.margin.top
        - config.float.margin.bottom
    if config.float.max_minimap_height then
        minimap_window_height = math.min(minimap_window_height, config.float.max_minimap_height)
    end
    local border = config.float.window_border
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
        logger.log.warn("Window %d is not valid", winid)
        return false
    end

    if not var.g.enabled then
        logger.log.trace("Minimap is disabled. Skipping generation of minimap")
        return false
    end

    local tabid = api.nvim_win_get_tabpage(winid)
    if not var.t[tabid].enabled then
        logger.log.trace("Window %d is not enabled. Skipping generation of minimap", winid)
        return false
    end

    if not var.w[winid].enabled then
        logger.log.trace("Window %d is not enabled. Skipping generation of minimap", winid)
        return false
    end

    local bufnr = api.nvim_win_get_buf(winid)
    local buffer = require("neominimap.buffer")
    if not buffer.get_minimap_bufnr(bufnr) then
        logger.log.trace("No minimap buffer available for buffer %d in window %d", bufnr, winid)
        return false
    end

    local win_util = require("neominimap.window.util")
    if win_util.is_cmdline(winid) then
        logger.log.trace("Window %d is in cmdline", winid)
        return false
    end

    if win_util.is_terminal(winid) then
        logger.log.trace("Window %d is in terminal", winid)
        return false
    end

    if not win_util.is_ordinary_window(winid) then
        logger.log.trace("Window %d is not an ordinary window", winid)
        return false
    end

    if get_minimap_height(winid) <= 0 then
        logger.log.trace("Height of window %d is too small", winid)
        return false
    end

    if 2 * config.float.minimap_width + 4 > api.nvim_win_get_width(winid) then
        logger.log.trace("Width of window %d is too small", winid)
        return false
    end

    if not config.win_filter(winid) then
        logger.log.trace("Window %d should not be shown due to win_filter", winid)
        return false
    end

    if not config.tab_filter(tabid) then
        logger.log.trace("Window %d should not be shown due to tab_filter", winid)
        return false
    end

    logger.log.trace("Minimap can be shown for window %d", winid)
    return true
end

---@param winid integer
local get_window_config = function(winid)
    local logger = require("neominimap.logger")
    logger.log.trace("Getting window configuration for window %d", winid)

    local col = api.nvim_win_get_width(winid) - config.float.margin.right
    local row = config.float.margin.top
    local height = get_minimap_height(winid)

    return {
        relative = "win",
        win = winid,
        anchor = "NE",
        width = config.float.minimap_width,
        height = height,
        row = row,
        col = col,
        focusable = config.click.enabled,
        zindex = config.float.z_index,
        border = config.float.window_border,
    }
end

--- WARN: This function does not check whether a minimap should be created for this window nor if this window is valid.
--- Create the minimap attached to the given window
---@param winid integer
---@return integer? mwinid winid of the minimap window if created, nil otherwise
M.create_minimap_window = function(winid)
    local logger = require("neominimap.logger")
    local util = require("neominimap.util")
    logger.log.trace("Attempting to create minimap for window %d", winid)

    local bufnr = api.nvim_win_get_buf(winid)
    local buffer = require("neominimap.buffer")
    local mbufnr = buffer.get_minimap_bufnr(bufnr)

    if not mbufnr then
        logger.log.trace("Minimap buffer not available for window %d", winid)
        return nil
    end

    logger.log.trace("Creating minimap window for window %d", winid)
    local win_cfg = get_window_config(winid)
    win_cfg.noautocmd = true --Set noautocmd here for noautocmd can only set for none existing window
    local mwinid = util.noautocmd(api.nvim_open_win)(mbufnr, false, win_cfg)
    local window_map = require("neominimap.window.float.window_map")
    window_map.set_minimap_winid(winid, mwinid)

    logger.log.trace("Setting up window options %d", mwinid)
    require("neominimap.window.util").set_winopt(vim.wo[mwinid], mwinid)
    logger.log.trace("Minimap window options set.", mwinid)

    logger.log.trace("Minimap window %d created for window %d", mwinid, winid)
    return mwinid
end

--- Close the minimap attached to the given window
---@param winid integer
---@return integer? mwinid winid of the minimap window if successfully removed, nil otherwise
M.close_minimap_window = function(winid)
    local logger = require("neominimap.logger")
    local window_map = require("neominimap.window.float.window_map")
    local mwinid = window_map.get_minimap_winid(winid)
    window_map.set_minimap_winid(winid, nil)
    logger.log.trace("Attempting to close minimap for window %d", winid)
    if mwinid and api.nvim_win_is_valid(mwinid) then
        logger.log.trace("Deleting minimap window %d", mwinid)
        local util = require("neominimap.util")
        util.noautocmd(api.nvim_win_close)(mwinid, true)
        return mwinid
    else
        logger.log.trace("Minimap window %d is not valid or already closed", winid)
    end
    return nil
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
    local window_map = require("neominimap.window.float.window_map")
    logger.log.trace("Refreshing minimap for window %d", winid)
    if not api.nvim_win_is_valid(winid) or not M.should_show_minimap(winid) then
        logger.log.trace("Window %d is not valid or should not be shown", winid)
        if window_map.get_minimap_winid(winid) then
            M.close_minimap_window(winid)
        end
        return nil
    end

    local bufnr = api.nvim_win_get_buf(winid)
    local buffer = require("neominimap.buffer")
    local mbufnr = buffer.get_minimap_bufnr(bufnr)
    if not mbufnr then
        logger.log.trace("Minimap buffer not available for window %d", winid)
        if window_map.get_minimap_winid(winid) then
            M.close_minimap_window(winid)
        end
        return nil
    end

    local mwinid = window_map.get_minimap_winid(winid) or M.create_minimap_window(winid)
    if not mwinid then
        logger.log.trace("Failed to create minimap for window %d", winid)
        return nil
    end

    local cfg = get_window_config(winid)
    api.nvim_win_set_config(mwinid, cfg)

    if api.nvim_win_get_buf(mwinid) ~= mbufnr then
        api.nvim_win_set_buf(mwinid, mbufnr)
    end

    logger.log.trace("Setting up window options %d", mwinid)
    require("neominimap.window.util").set_winopt(vim.wo[mwinid], mwinid)
    logger.log.trace("Minimap window options set.", mwinid)

    M.reset_mwindow_cursor_line(winid)

    logger.log.trace("Minimap for window %d refreshed", winid)
    return mwinid
end

--- Refresh all minimaps in the given tab
---@param tabid integer
M.refresh_minimaps_in_tab = function(tabid)
    local logger = require("neominimap.logger")
    logger.log.trace("Refreshing all minimaps in tab %d", tabid)
    require("neominimap.util").for_all_windows_in_tab(M.refresh_minimap_window, tabid)
    logger.log.trace("All minimaps in tab %d refreshed", tabid)
end

--- Close all minimaps in the given tab
---@param tabid integer
M.close_minimap_in_tab = function(tabid)
    local logger = require("neominimap.logger")
    logger.log.trace("Closing all minimaps in tab %d", tabid)
    require("neominimap.util").for_all_windows_in_tab(M.close_minimap_window, tabid)
    logger.log.trace("All minimaps in tab %d closed", tabid)
end

--- Refresh all minimaps across tabs
M.refresh_all_minimap_windows = function()
    local logger = require("neominimap.logger")
    logger.log.trace("Refreshing all minimap windows")
    require("neominimap.util").for_all_windows(M.refresh_minimap_window)
    logger.log.trace("All minimap windows refreshed")
end

--- Close all minimaps across tabs
M.close_all_minimap_windows = function()
    local logger = require("neominimap.logger")
    logger.log.trace("Closing all minimap windows")
    require("neominimap.util").for_all_windows(M.close_minimap_window)
    logger.log.trace("All minimap windows closed")
end

---@param winid integer
---@return boolean
M.reset_mwindow_cursor_line = function(winid)
    local logger = require("neominimap.logger")
    local window_map = require("neominimap.window.float.window_map")
    logger.log.trace("Resetting cursor line for minimap of window %d", winid)
    local mwinid = window_map.get_minimap_winid(winid)
    if not mwinid or not api.nvim_win_is_valid(mwinid) then
        logger.log.trace("Minimap window is not valid for %d", winid)
        return false
    end
    require("neominimap.window.util").sync_to_source(winid, mwinid)
    logger.log.trace("Cursor line reset for minimap of window %d", winid)
    return true
end

---@param mwinid integer
---@return boolean
M.reset_parent_window_cursor_line = function(mwinid)
    local logger = require("neominimap.logger")
    logger.log.trace("Resetting cursor line for parent of minimap window %d", mwinid)
    local window_map = require("neominimap.window.float.window_map")
    local winid = window_map.get_parent_winid(mwinid)
    if not winid or not api.nvim_win_is_valid(winid) then
        logger.log.trace("Window not found")
        return false
    end
    require("neominimap.window.util").sync_to_minimap(winid, mwinid)
    logger.log.trace("Cursor line reset for parent of minimap window %d", mwinid)
    return true
end

---@param winid integer
---@return boolean
M.focus = function(winid)
    local logger = require("neominimap.logger")
    local window_map = require("neominimap.window.float.window_map")
    logger.log.trace("Focusing window %d", winid)
    local mwinid = window_map.get_minimap_winid(winid)
    if not mwinid then
        logger.log.trace("Minimap window %d is not valid", winid)
        return false
    end
    local util = require("neominimap.util")
    util.noautocmd(api.nvim_set_current_win)(mwinid)
    logger.log.trace("Window %d focused", winid)
    return true
end

--- @param mwinid integer
--- @return boolean
M.unfocus = function(mwinid)
    local logger = require("neominimap.logger")
    logger.log.trace("Unfocusing window %d", mwinid)
    local window_map = require("neominimap.window.float.window_map")
    local winid = window_map.get_parent_winid(mwinid)
    if not winid then
        logger.log.trace("Window not found")
        return false
    end
    local util = require("neominimap.util")
    util.noautocmd(api.nvim_set_current_win)(winid)
    logger.log.trace("Window %d unfocused", mwinid)
    return true
end

return M
