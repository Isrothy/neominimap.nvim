local api = vim.api
local config = require("neominimap.config")

local M = {}

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

    if 2 * config.float.minimap_width + 4 > api.nvim_win_get_width(winid) then
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

---@param swinid integer
---@return integer? mwinid winid of the minimap window if created, nil otherwise
M.create_minimap_window = function(swinid)
    local tabid = api.nvim_win_get_tabpage(swinid)
    local logger = require("neominimap.logger")
    local util = require("neominimap.util")
    logger.log(string.format("Attempting to create minimap window for tab %d", tabid), vim.log.levels.TRACE)

    vim.cmd("noau vertical botright 1split")
    local mwinid = vim.api.nvim_get_current_win()
    api.nvim_set_current_win(swinid)

    local window_map = require("neominimap.window.split.window_map")
    window_map.set_minimap_winid(tabid, swinid)
    window_map.set_source_winid(tabid, swinid)

    api.nvim_win_set_width(mwinid, config:get_minimap_width())

    local winopt = require("neominimap.window.util").get_winopt(mwinid)
    for k, v in pairs(winopt) do
        vim.wo[mwinid][k] = v
    end

    logger.log(string.format("Attaching buffer %d to window %d", mwinid), vim.log.levels.TRACE)
    local buffer = require("neominimap.buffer")
    local sbufnr = api.nvim_win_get_buf(swinid)
    local mbufnr = buffer.get_minimap_bufnr(sbufnr)
    if mbufnr and api.nvim_buf_is_loaded(mbufnr) then
        logger.log(string.format("Buffer %d already attached to window %d", mbufnr, mwinid), vim.log.levels.TRACE)
        api.nvim_win_set_buf(mwinid, mbufnr)
    else
        logger.log("Buffer not available", vim.log.levels.TRACE)
        local empty_buffer = require("neominimap.buffer").get_empty_buffer()
        api.nvim_win_set_buf(mwinid, empty_buffer)
    end

    logger.log(string.format("Minimap window %d created", mwinid), vim.log.levels.TRACE)
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

return M
