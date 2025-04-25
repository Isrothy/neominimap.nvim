local api = vim.api
local config = require("neominimap.config")

local M = {}

---@param winid integer
---@return boolean
M.should_show_minimap_for_window = function(winid)
    local logger = require("neominimap.logger")
    logger.log.trace("Checking if window %d should be shown", winid)

    local var = require("neominimap.variables")
    if not api.nvim_win_is_valid(winid) then
        logger.log.warn("Window %d is not valid", winid)
        return false
    end

    if not var.g.enabled then
        logger.log.trace("Minimap is disabled. Skipping generation of minimap")
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

    if not config.win_filter(winid) then
        logger.log.trace("Window %d should not be shown due to win_filter", winid)
        return false
    end

    logger.log.trace("Minimap can be shown for window %d", winid)
    return true
end

---@param tabid integer
---@return boolean
M.should_show_minimap_for_tab = function(tabid)
    local logger = require("neominimap.logger")
    logger.log.trace("Checking if tab %d should be shown", tabid)

    if not api.nvim_tabpage_is_valid(tabid) then
        logger.log.warn("Tab %d is not valid", tabid)
        return false
    end

    local var = require("neominimap.variables")
    if not var.g.enabled then
        logger.log.trace("Minimap is disabled. Skipping generation of minimap")
        return false
    end
    if not var.t[tabid].enabled then
        logger.log.trace("Tab %d is not enabled. Skipping generation of minimap", tabid)
        return false
    end

    if config.split.close_if_last_window then
        logger.log.trace("Checking if tab has window")
        local win_list = api.nvim_tabpage_list_wins(tabid)
        local none_floating_count = 0
        for _, winid in ipairs(win_list) do
            if not require("neominimap.util").is_floating(winid) then
                none_floating_count = none_floating_count + 1
            end
        end
        local window_map = require("neominimap.window.split.window_map")
        if none_floating_count == 0 or (none_floating_count == 1 and window_map.get_minimap_winid(tabid) ~= nil) then
            logger.log.trace("Tab has no window, or only one non-floating window. Skipping generation of minimap")
            return false
        end
    end

    if not config.tab_filter(tabid) then
        logger.log.trace("Tab %d should not be shown due to tab_filter", tabid)
        return false
    end

    logger.log.trace("Minimap can be shown for tab %d", tabid)

    return true
end

---@return integer? mwinid winid of the minimap window if created, nil otherwise
M.create_minimap_window_in_current_tab = function()
    local tabid = api.nvim_get_current_tabpage()
    local winid = api.nvim_get_current_win()
    local logger = require("neominimap.logger")
    logger.log.trace("Attempting to create minimap window for tab %d", tabid)
    local util = require("neominimap.util")

    ---@type table<Neominimap.Config.SplitDirection, string>
    local dir_tbl = {
        ["left"] = "topleft",
        ["right"] = "botright",
        ["topleft"] = "topleft",
        ["botright"] = "botright",
        ["aboveleft"] = "aboveleft",
        ["rightbelow"] = "rightbelow",
    }
    vim.cmd(
        string.format(
            "noau vertical %s %dsplit",
            dir_tbl[config.split.direction] or "botright",
            config:get_minimap_width()
        )
    )
    local mwinid = vim.api.nvim_get_current_win()
    util.noautocmd(api.nvim_set_current_win)(winid)

    local window_map = require("neominimap.window.split.window_map")
    window_map.set_minimap_winid(tabid, mwinid)
    logger.log.trace("Minimap window %d set for tab %d", mwinid, tabid)

    logger.log.trace("Minimap window %d created", mwinid)

    logger.log.trace("Attaching a buffer to window %d", mwinid)
    local mbufnr = (function()
        if not M.should_show_minimap_for_window(winid) then
            logger.log.trace("Window %d should not be shown", winid)
            return nil
        end
        logger.log.trace("Window %d should be shown", winid)
        local buffer = require("neominimap.buffer")
        local sbufnr = api.nvim_win_get_buf(winid)
        local mbufnr = buffer.get_minimap_bufnr(sbufnr)
        if mbufnr == nil or not api.nvim_buf_is_valid(mbufnr) then
            logger.log.trace("Buffer not available")
            return require("neominimap.buffer").get_empty_buffer()
        end
        logger.log.trace("Buffer %d available", mbufnr)
        return mbufnr
    end)()
    if not mbufnr then
        local empty_buffer = require("neominimap.buffer").get_empty_buffer()
        api.nvim_win_set_buf(mwinid, empty_buffer)
    else
        api.nvim_win_set_buf(mwinid, mbufnr)
        window_map.set_source_winid(tabid, winid)
        M.reset_mwindow_cursor_line()
    end

    -- nvim_win_set_buf overwrites scrolloff and I don't know why
    logger.log.trace("Setting up window options %d", mwinid)
    require("neominimap.window.util").set_winopt(vim.wo[mwinid], mwinid)
    logger.log.trace("Minimap window options set.", mwinid)

    logger.log.trace("Minimap window %d created and set up.", mwinid)
    return mwinid
end

---@param tabid integer
---@return integer?
M.close_minimap_window = function(tabid)
    local logger = require("neominimap.logger")
    logger.log.trace("Attempting to close minimap window for tab %d", tabid)
    local window_map = require("neominimap.window.split.window_map")
    local mwinid = window_map.get_minimap_winid(tabid)
    window_map.set_minimap_winid(tabid, nil)
    window_map.set_source_winid(tabid, nil)
    if mwinid == nil or not api.nvim_win_is_valid(mwinid) then
        logger.log.trace("No minimap window found for tab %d", tabid)
        return nil
    end
    local ok, _ = pcall(require("neominimap.util").noautocmd(api.nvim_win_close), mwinid, true)
    if not ok then
        vim.cmd("noau qa!")
    end
    logger.log.trace("Minimap window %d closed", mwinid)
    return mwinid
end

M.close_minimap_window_for_all_tabs = function()
    local logger = require("neominimap.logger")
    logger.log.trace("Attempting to close minimap window for all tabs")
    require("neominimap.util").for_all_tabs(M.close_minimap_window)
    logger.log.trace("Minimap window for all tabs closed")
end

---@return boolean
local should_switch_window = function()
    local logger = require("neominimap.logger")
    logger.log.trace("Checking if window should be switched")

    local winid = api.nvim_get_current_win()
    if not M.should_show_minimap_for_window(winid) then
        logger.log.trace("Window %d should not be shown", winid)
        return false
    end

    local buffer = require("neominimap.buffer")
    local sbufnr = api.nvim_win_get_buf(winid)
    local mbufnr = buffer.get_minimap_bufnr(sbufnr)
    if mbufnr == nil or not api.nvim_buf_is_valid(mbufnr) then
        logger.log.trace("Minimap buffer not available")
        return false
    end

    return true
end

M.reset_minimap_width = function()
    local logger = require("neominimap.logger")
    logger.log.trace("Resetting minimap width")
    local window_map = require("neominimap.window.split.window_map")
    local tabid = api.nvim_get_current_tabpage()
    local mwinid = window_map.get_minimap_winid(tabid)
    if mwinid == nil or not api.nvim_win_is_valid(mwinid) then
        logger.log.trace("No minimap window found")
        return
    end

    local width = api.nvim_win_get_width(mwinid)
    local expected_width = config:get_minimap_width()

    if width ~= expected_width then
        local util = require("neominimap.util")
        util.noautocmd(api.nvim_win_set_width)(mwinid, expected_width)
        logger.log.trace("Minimap width set to %d", width)
    end
    logger.log.trace("Minimap width reset")
end

---Refresh minimap window
---If current window could have a minimap, switch.
M.refresh_source_in_current_tab = function()
    local logger = require("neominimap.logger")
    logger.log.trace("Refreshing minimap")

    logger.log.trace("Checking if minimap window exists")
    local window_map = require("neominimap.window.split.window_map")
    local tabid = api.nvim_get_current_tabpage()
    local winid = vim.api.nvim_get_current_win()
    local mwinid = window_map.get_minimap_winid(tabid)
    if mwinid == nil or not api.nvim_win_is_valid(mwinid) then
        logger.log.trace("No minimap window found")
        return
    end
    logger.log.trace("Minimap window %d found", mwinid)

    logger.log.trace("Setting source window")
    ---@type integer?
    local swinid = (function()
        if should_switch_window() then
            logger.log.trace("Switching to window %d", winid)
            return winid
        else
            logger.log.trace("Window should not be switched")
            local swinid = window_map.get_source_winid(tabid)
            if swinid ~= nil and M.should_show_minimap_for_window(swinid) then
                return swinid
            else
                return nil
            end
        end
    end)()

    window_map.set_source_winid(tabid, swinid)
    logger.log.trace("Source window set")

    logger.log.trace("Setting cursor line for minimap")
    M.reset_mwindow_cursor_line()

    logger.log.trace("Setting minimap buffer")
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
        logger.log.trace("Minimap buffer not available")
        api.nvim_win_set_buf(mwinid, buffer.get_empty_buffer())
    elseif api.nvim_win_get_buf(mwinid) ~= mbufnr then
        logger.log.trace("Switching to buffer %d", mbufnr)
        api.nvim_win_set_buf(mwinid, mbufnr)
    end
    logger.log.trace("Minimap buffer set", mbufnr)

    logger.log.trace("Setting up window options %d", mwinid)
    require("neominimap.window.util").set_winopt(vim.wo[mwinid], mwinid)
    logger.log.trace("Minimap window options set.", mwinid)

    logger.log.trace("Minimap refreshed")
end

M.refresh_current_tab = function()
    local logger = require("neominimap.logger")
    logger.log.trace("Refreshing minimap for current tab")
    local window_map = require("neominimap.window.split.window_map")
    local tabid = api.nvim_get_current_tabpage()

    if M.should_show_minimap_for_tab(tabid) then
        local mwinid = window_map.get_minimap_winid(tabid)
        if mwinid == nil or not api.nvim_win_is_valid(mwinid) then
            logger.log.trace("No minimap window found. Creating")
            M.create_minimap_window_in_current_tab()
            return
        end
        M.refresh_source_in_current_tab()
        if config.split.fix_width then
            M.reset_minimap_width()
        end
    else
        logger.log.trace("Tab should not have minimap")
        local mwinid = window_map.get_minimap_winid(tabid)
        if mwinid ~= nil and api.nvim_win_is_valid(mwinid) then
            M.close_minimap_window(tabid)
        end
    end
    logger.log.trace("Minimap refreshed for current tab")
end

---@return boolean
M.reset_mwindow_cursor_line = function()
    local logger = require("neominimap.logger")
    local window_map = require("neominimap.window.split.window_map")
    logger.log.trace("Resetting cursor line for minimap")
    local tabid = api.nvim_get_current_tabpage()
    local swinid = window_map.get_source_winid(tabid)
    local mwinid = window_map.get_minimap_winid(tabid)
    if not mwinid or not api.nvim_win_is_valid(mwinid) then
        logger.log.trace("Minimap window %d is not valid")
        return false
    end
    if not swinid or not api.nvim_win_is_valid(swinid) then
        logger.log.trace("Source window %d is not valid")
        return false
    end
    require("neominimap.window.util").sync_to_source(swinid, mwinid)
    logger.log.trace("Cursor line reset")
    return true
end

---@return boolean
M.reset_parent_window_cursor_line = function()
    local logger = require("neominimap.logger")
    local window_map = require("neominimap.window.split.window_map")
    logger.log.trace("Resetting cursor line for source window")
    local tabid = api.nvim_get_current_tabpage()
    local swinid = window_map.get_source_winid(tabid)
    local mwinid = window_map.get_minimap_winid(tabid)
    if not mwinid or not api.nvim_win_is_valid(mwinid) then
        logger.log.trace("Minimap window %d is not valid")
        return false
    end
    if not swinid or not api.nvim_win_is_valid(swinid) then
        logger.log.trace("Source window %d is not valid")
        return false
    end
    require("neominimap.window.util").sync_to_minimap(swinid, mwinid)
    logger.log.trace("Cursor line reset for parent of minimap window %d", mwinid)
    return true
end

M.focus = function()
    local logger = require("neominimap.logger")
    logger.log.trace("Focusing minimap")
    local tabid = api.nvim_get_current_tabpage()
    local mwinid = require("neominimap.window.split.window_map").get_minimap_winid(tabid)
    if not mwinid or not api.nvim_win_is_valid(mwinid) then
        logger.log.trace("Minimap window %d is not valid")
        return false
    end
    local util = require("neominimap.util")
    util.noautocmd(api.nvim_set_current_win)(mwinid)
    return true
end

M.unfocus = function()
    local logger = require("neominimap.logger")
    logger.log.trace("Unfocusing minimap")
    local tabid = api.nvim_get_current_tabpage()
    local swinid = require("neominimap.window.split.window_map").get_source_winid(tabid)
    if not swinid or not api.nvim_win_is_valid(swinid) then
        logger.log.trace("Source window %d is not valid")
        return false
    end
    local util = require("neominimap.util")
    util.noautocmd(api.nvim_set_current_win)(swinid)
    return true
end

return M
