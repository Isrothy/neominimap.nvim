local api = vim.api
local config = require("neominimap.config")
local M = {}

M.on_vim_enter = function()
    local logger = require("neominimap.logger")
    logger.log("VimEnter event triggered.", vim.log.levels.TRACE)
    vim.schedule(function()
        logger.log("Refreshing minimaps.", vim.log.levels.TRACE)
        require("neominimap.window.split.internal").refresh_current_tab()
        logger.log("Minimaps refreshed.", vim.log.levels.TRACE)
    end)
end

M.on_buf_win_enter = function(args)
    local logger = require("neominimap.logger")
    local winid = api.nvim_get_current_win()
    logger.log(string.format("BufWinEnter event triggered for window %d.", winid), vim.log.levels.TRACE)
    vim.schedule(function()
        logger.log("Refreshing minimap window", vim.log.levels.TRACE)
        require("neominimap.window.split.internal").refresh_current_tab()
        require("neominimap.window.split.internal").refresh_source_in_current_tab()
        logger.log("Minimap window refreshed.", vim.log.levels.TRACE)
    end)
end

M.on_win_new = function(args)
    local logger = require("neominimap.logger")
    local winid = api.nvim_get_current_win()
    logger.log(string.format("WinNew or WinEnter event triggered for window %d.", winid), vim.log.levels.TRACE)
    vim.schedule(function()
        logger.log("Refreshing minimap window", vim.log.levels.TRACE)
        require("neominimap.window.split.internal").refresh_current_tab()
        require("neominimap.window.split.internal").refresh_source_in_current_tab()
        logger.log("Minimap window refreshed.", vim.log.levels.TRACE)
    end)
end

M.on_win_closed = function(args)
    local logger = require("neominimap.logger")
    local winid = tonumber(args.match)
    logger.log(string.format("WinClosed event triggered for window %d.", winid), vim.log.levels.TRACE)
    if winid == nil then
        return
    end
    local window_map = require("neominimap.window.split.window_map")
    local tabid = api.nvim_win_get_tabpage(winid)
    if window_map.is_minimap_window(tabid, winid) and not config.split.persist then
        logger.log("This is a minimap window. Close minimap for current tab", vim.log.levels.TRACE)
        local var = require("neominimap.variables")
        var.t[tabid].enabled = false
    end
    vim.schedule(function()
        logger.log("Refreshing minimap window", vim.log.levels.TRACE)
        require("neominimap.window.split.internal").refresh_current_tab()
        logger.log("Minimap window refreshed.", vim.log.levels.TRACE)
    end)
end

M.on_tab_enter = function(args)
    local logger = require("neominimap.logger")
    local tid = api.nvim_get_current_tabpage()
    logger.log(string.format("TabEnter event triggered for tab %d.", tid), vim.log.levels.TRACE)
    vim.schedule(function()
        logger.log(string.format("Refreshing minimaps for tab ID: %d.", tid), vim.log.levels.TRACE)
        require("neominimap.window.split.internal").refresh_current_tab()
        logger.log(string.format("Minimaps refreshed for tab ID: %d.", tid), vim.log.levels.TRACE)
    end)
end

M.on_cursor_moved = function(args)
    local logger = require("neominimap.logger")
    logger.log("CursorMoved event triggered.", vim.log.levels.TRACE)
    local winid = api.nvim_get_current_win()
    local tabid = api.nvim_win_get_tabpage(winid)
    logger.log(string.format("Window ID: %d", winid), vim.log.levels.TRACE)
    vim.schedule(function()
        local window_map = require("neominimap.window.split.window_map")
        local internal = require("neominimap.window.split.internal")
        if not window_map.is_minimap_window(tabid, winid) then
            logger.log(string.format("Resettting cursor line for window %d.", winid), vim.log.levels.TRACE)
            internal.reset_mwindow_cursor_line()
            logger.log(string.format("Cursor line reset for window %d.", winid), vim.log.levels.TRACE)
        elseif config.sync_cursor then
            logger.log(string.format("Resetting parent cursor line"), vim.log.levels.TRACE)
            internal.reset_parent_window_cursor_line()
            logger.log(string.format("Parent cursor line reset"), vim.log.levels.TRACE)
        end
    end)
end

M.fix_width_on_resize = function(args)
    local logger = require("neominimap.logger")
    logger.log("WinResized event triggered.", vim.log.levels.TRACE)
    vim.schedule(function()
        logger.log("Resetting minimap width.", vim.log.levels.TRACE)
        require("neominimap.window.split.internal").reset_minimap_width()
        logger.log("Minimap width reset.", vim.log.levels.TRACE)
    end)
end

M.on_minimap_buffer_created_or_deleted = function(args)
    local logger = require("neominimap.logger")
    logger.log(
        "User Neominimap event triggered. patter: MinimapBufferCreated or MinimapBufferDeleted",
        vim.log.levels.TRACE
    )
    vim.schedule(function()
        logger.log(string.format("Refreshing source window."), vim.log.levels.TRACE)
        require("neominimap.window.split.internal").refresh_current_tab()
        logger.log(string.format("Source window refreshed."), vim.log.levels.TRACE)
    end)
end

M.on_minimap_buffer_text_changed = function(args)
    local logger = require("neominimap.logger")
    logger.log("User Neominimap event triggered. patter: BufferTextUpdated", vim.log.levels.TRACE)
    vim.schedule(function()
        logger.log(string.format("Resetting cursor line"), vim.log.levels.TRACE)
        require("neominimap.window.split.internal").reset_mwindow_cursor_line()
        logger.log(string.format("Cursor line reset"), vim.log.levels.TRACE)
    end)
end

return M
