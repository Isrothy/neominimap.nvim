local api = vim.api
local config = require("neominimap.config")

local M = {}

---@param winid integer
---@return boolean
M.should_show_minimap_for_window = function(winid)
    local logger = require("neominimap.logger")
    logger.log(string.format("Checking if window %d should be shown", winid), vim.log.levels.TRACE)

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

    local win_util = require("neominimap.window.util")
    if win_util.is_cmdline(winid) then
        logger.log(string.format("Window %d is in cmdline", winid), vim.log.levels.TRACE)
        return false
    end

    if win_util.is_terminal(winid) then
        logger.log(string.format("Window %d is in terminal", winid), vim.log.levels.TRACE)
        return false
    end

    if not win_util.is_ordinary_window(winid) then
        logger.log(string.format("Window %d is not an ordinary window", winid), vim.log.levels.TRACE)
        return false
    end

    if not config.win_filter(winid) then
        logger.log(string.format("Window %d should not be shown due to win_filter", winid), vim.log.levels.TRACE)
        return false
    end

    logger.log(string.format("Minimap can be shown for window %d", winid), vim.log.levels.TRACE)
    return true
end

---@param tabid integer
---@return boolean
M.should_show_minimap_for_tab = function(tabid)
    local logger = require("neominimap.logger")
    logger.log(string.format("Checking if tab %d should be shown", tabid), vim.log.levels.TRACE)

    if not api.nvim_tabpage_is_valid(tabid) then
        logger.log(string.format("Tab %d is not valid", tabid), vim.log.levels.WARN)
        return false
    end

    local var = require("neominimap.variables")
    if not var.g.enabled then
        logger.log("Minimap is disabled. Skipping generation of minimap", vim.log.levels.TRACE)
        return false
    end
    if not var.t[tabid].enabled then
        logger.log(string.format("Tab %d is not enabled. Skipping generation of minimap", tabid), vim.log.levels.TRACE)
        return false
    end
    logger.log(string.format("Minimap can be shown for tab %d", tabid), vim.log.levels.TRACE)
    return true
end

---@return integer? mwinid winid of the minimap window if created, nil otherwise
M.create_minimap_window_in_current_tab = function()
    local tabid = api.nvim_get_current_tabpage()
    local winid = api.nvim_get_current_win()
    local logger = require("neominimap.logger")
    logger.log(string.format("Attempting to create minimap window for tab %d", tabid), vim.log.levels.TRACE)
    local util = require("neominimap.util")

    vim.cmd("noau vertical botright 1split")
    local mwinid = vim.api.nvim_get_current_win()
    util.noautocmd(api.nvim_set_current_win)(winid)

    local window_map = require("neominimap.window.split.window_map")
    window_map.set_minimap_winid(tabid, mwinid)
    logger.log(string.format("Minimap window %d set for tab %d", mwinid, tabid), vim.log.levels.TRACE)

    util.noautocmd(api.nvim_win_set_width)(mwinid, config:get_minimap_width())
    logger.log(string.format("Minimap window %d created", mwinid), vim.log.levels.TRACE)

    logger.log(string.format("Setting up window options %d", mwinid), vim.log.levels.TRACE)
    require("neominimap.window.util").set_winopt(vim.wo[mwinid], mwinid)
    logger.log(string.format("Minimap window options set.", mwinid), vim.log.levels.TRACE)

    logger.log(string.format("Attaching a buffer to window %d", mwinid), vim.log.levels.TRACE)
    local mbufnr = (function()
        if not M.should_show_minimap_for_window(winid) then
            logger.log(string.format("Window %d should not be shown", winid), vim.log.levels.TRACE)
            return nil
        end
        logger.log(string.format("Window %d should be shown", winid), vim.log.levels.TRACE)
        local buffer = require("neominimap.buffer")
        local sbufnr = api.nvim_win_get_buf(winid)
        local mbufnr = buffer.get_minimap_bufnr(sbufnr)
        if mbufnr == nil or not api.nvim_buf_is_valid(mbufnr) then
            logger.log("Buffer not available", vim.log.levels.TRACE)
            return require("neominimap.buffer").get_empty_buffer()
        end
        logger.log(string.format("Buffer %d available", mbufnr), vim.log.levels.TRACE)
        return mbufnr
    end)()
    if not mbufnr then
        local empty_buffer = require("neominimap.buffer").get_empty_buffer()
        util.noautocmd(api.nvim_win_set_buf)(mwinid, empty_buffer)
    else
        util.noautocmd(api.nvim_win_set_buf)(mwinid, mbufnr)
        window_map.set_source_winid(tabid, winid)
    end
    -- logger.log(tostring(tabid), vim.log.levels.DEBUG)
    -- logger.log(tostring(window_map.get_minimap_winid(tabid)), vim.log.levels.DEBUG)

    logger.log(string.format("Minimap window %d created and set up.", mwinid), vim.log.levels.TRACE)
    return mwinid
end

---@param tabid integer
---@return integer?
M.close_minimap_window = function(tabid)
    local logger = require("neominimap.logger")
    logger.log(string.format("Attempting to close minimap window for tab %d", tabid), vim.log.levels.TRACE)
    local window_map = require("neominimap.window.split.window_map")
    local mwinid = window_map.get_minimap_winid(tabid)
    window_map.set_minimap_winid(tabid, nil)
    window_map.set_source_winid(tabid, nil)
    if mwinid == nil or not api.nvim_win_is_valid(mwinid) then
        logger.log(string.format("No minimap window found for tab %d", tabid), vim.log.levels.TRACE)
        return nil
    end
    api.nvim_win_close(mwinid, true)
    logger.log(string.format("Minimap window %d closed", mwinid), vim.log.levels.TRACE)
    return mwinid
end

M.close_minimap_window_for_all_tabs = function()
    local logger = require("neominimap.logger")
    logger.log("Attempting to close minimap window for all tabs", vim.log.levels.TRACE)
    require("neominimap.util").for_all_tabs(M.close_minimap_window)
    logger.log("Minimap window for all tabs closed", vim.log.levels.TRACE)
end

---@return boolean
local should_switch_window = function()
    local logger = require("neominimap.logger")
    logger.log("Checking if window should be switched", vim.log.levels.TRACE)

    local winid = api.nvim_get_current_win()
    if not M.should_show_minimap_for_window(winid) then
        logger.log(string.format("Window %d should not be shown", winid), vim.log.levels.TRACE)
        return false
    end

    local buffer = require("neominimap.buffer")
    local sbufnr = api.nvim_win_get_buf(winid)
    local mbufnr = buffer.get_minimap_bufnr(sbufnr)
    if mbufnr == nil or not api.nvim_buf_is_valid(mbufnr) then
        logger.log("Minimap buffer not available", vim.log.levels.TRACE)
        return false
    end

    return true
end

---Refresh minimap window
---If current window could have a minimap, switch.
M.refresh_source_in_current_tab = function()
    local logger = require("neominimap.logger")
    logger.log("Refreshing minimap", vim.log.levels.TRACE)

    logger.log("Checking if minimap window exists", vim.log.levels.TRACE)
    local window_map = require("neominimap.window.split.window_map")
    local tabid = api.nvim_get_current_tabpage()
    local winid = vim.api.nvim_get_current_win()
    local mwinid = window_map.get_minimap_winid(tabid)
    if mwinid == nil or not api.nvim_win_is_valid(mwinid) then
        logger.log("No minimap window found", vim.log.levels.TRACE)
        return
    end
    logger.log(string.format("Minimap window %d found", mwinid), vim.log.levels.TRACE)

    logger.log("Resetting width for minimap", vim.log.levels.TRACE)
    local width = api.nvim_win_get_width(mwinid)
    local expected_width = config:get_minimap_width()
    if width ~= expected_width then
        require("neominimap.util").noautocmd(api.nvim_win_set_width)(mwinid, expected_width)
        logger.log(string.format("Minimap window %d width set", mwinid), vim.log.levels.TRACE)
    end

    logger.log("Setting source window", vim.log.levels.TRACE)
    ---@type integer?
    local swinid = (function()
        if should_switch_window() then
            logger.log(string.format("Switching to window %d", winid), vim.log.levels.TRACE)
            return winid
        else
            logger.log("Window should not be switched", vim.log.levels.TRACE)
            local swinid = window_map.get_source_winid(tabid)
            if swinid ~= nil and M.should_show_minimap_for_window(swinid) then
                return swinid
            else
                return nil
            end
        end
    end)()

    window_map.set_source_winid(tabid, swinid)
    logger.log(string.format("Source window set"), vim.log.levels.TRACE)

    logger.log("Setting minimap buffer", vim.log.levels.TRACE)
    local buffer = require("neominimap.buffer")
    ---@type integer?
    local mbufnr = (function()
        if not swinid or not api.nvim_win_is_valid(swinid) then
            return nil
        end
        local sbufnr = api.nvim_win_get_buf(swinid)
        return buffer.get_minimap_bufnr(sbufnr)
    end)()

    if mbufnr == nil or not api.nvim_buf_is_valid(mbufnr) then
        logger.log("Minimap buffer not available", vim.log.levels.TRACE)
        api.nvim_win_set_buf(mwinid, buffer.get_empty_buffer())
    else
        logger.log(string.format("Switching to buffer %d", mbufnr), vim.log.levels.TRACE)
        api.nvim_win_set_buf(mwinid, mbufnr)
    end
    logger.log(string.format("Minimap buffer set", mbufnr), vim.log.levels.TRACE)

    logger.log("Minimap refreshed", vim.log.levels.TRACE)
end

M.refresh_current_tab = function()
    local logger = require("neominimap.logger")
    logger.log("Refreshing minimap for tab", vim.log.levels.TRACE)
    local window_map = require("neominimap.window.split.window_map")
    local tabid = api.nvim_get_current_tabpage()
    if M.should_show_minimap_for_tab(tabid) then
        local mwinid = window_map.get_minimap_winid(tabid)
        if mwinid == nil or not api.nvim_win_is_valid(mwinid) then
            logger.log("No minimap window found. Creating", vim.log.levels.TRACE)
            M.create_minimap_window_in_current_tab()
            return
        end
        M.refresh_source_in_current_tab()
    else
        logger.log("Tab should not have minimap", vim.log.levels.TRACE)
        local mwinid = window_map.get_minimap_winid(tabid)
        if mwinid ~= nil and api.nvim_win_is_valid(mwinid) then
            M.close_minimap_window(tabid)
        end
        return
    end
end

---@return boolean
M.reset_mwindow_cursor_line = function()
    local logger = require("neominimap.logger")
    local window_map = require("neominimap.window.split.window_map")
    logger.log("Resetting cursor line for minimap", vim.log.levels.TRACE)
    local tabid = api.nvim_get_current_tabpage()
    local swinid = window_map.get_source_winid(tabid)
    local mwinid = window_map.get_minimap_winid(tabid)
    if not mwinid or not api.nvim_win_is_valid(mwinid) then
        logger.log("Minimap window %d is not valid", vim.log.levels.TRACE)
        return false
    end
    if not swinid or not api.nvim_win_is_valid(swinid) then
        logger.log("Source window %d is not valid", vim.log.levels.TRACE)
        return false
    end
    require("neominimap.window.util").sync_to_source(swinid, mwinid)
    logger.log("Cursor line reset", vim.log.levels.TRACE)
    return true
end

---@return boolean
M.reset_parent_window_cursor_line = function()
    local logger = require("neominimap.logger")
    local window_map = require("neominimap.window.split.window_map")
    logger.log("Resetting cursor line for source window", vim.log.levels.TRACE)
    local tabid = api.nvim_get_current_tabpage()
    local swinid = window_map.get_source_winid(tabid)
    local mwinid = window_map.get_minimap_winid(tabid)
    if not mwinid or not api.nvim_win_is_valid(mwinid) then
        logger.log("Minimap window %d is not valid", vim.log.levels.TRACE)
        return false
    end
    if not swinid or not api.nvim_win_is_valid(swinid) then
        logger.log("Source window %d is not valid", vim.log.levels.TRACE)
        return false
    end
    require("neominimap.window.util").sync_to_minimap(swinid, mwinid)
    logger.log(string.format("Cursor line reset for parent of minimap window %d", mwinid), vim.log.levels.TRACE)
    return true
end

M.focus = function()
    local logger = require("neominimap.logger")
    logger.log("Focusing minimap", vim.log.levels.TRACE)
    local tabid = api.nvim_get_current_tabpage()
    local mwinid = require("neominimap.window.split.window_map").get_minimap_winid(tabid)
    if not mwinid or not api.nvim_win_is_valid(mwinid) then
        logger.log("Minimap window %d is not valid", vim.log.levels.TRACE)
        return false
    end
    local util = require("neominimap.util")
    util.noautocmd(api.nvim_set_current_win)(mwinid)
    return true
end

M.unfocus = function()
    local logger = require("neominimap.logger")
    logger.log("Unfocusing minimap", vim.log.levels.TRACE)
    local tabid = api.nvim_get_current_tabpage()
    local swinid = require("neominimap.window.split.window_map").get_source_winid(tabid)
    if not swinid or not api.nvim_win_is_valid(swinid) then
        logger.log("Source window %d is not valid", vim.log.levels.TRACE)
        return false
    end
    local util = require("neominimap.util")
    util.noautocmd(api.nvim_set_current_win)(swinid)
    return true
end

return M
