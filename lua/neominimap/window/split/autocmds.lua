local api = vim.api
local config = require("neominimap.config")
local M = {}

M.on_vim_enter = function()
    local logger = require("neominimap.logger")
    logger.log.trace("VimEnter event triggered.")
    vim.schedule(function()
        logger.log.trace("Refreshing minimaps.")
        require("neominimap.window.split.internal").refresh_current_tab()
        logger.log.trace("Minimaps refreshed.")
    end)
end

M.on_buf_win_enter = function(args)
    local logger = require("neominimap.logger")
    local winid = api.nvim_get_current_win()
    logger.log.trace("BufWinEnter event triggered for window %d.", winid)
    vim.schedule(function()
        logger.log.trace("Refreshing minimap window")
        require("neominimap.window.split.internal").refresh_current_tab()
        require("neominimap.window.split.internal").refresh_source_in_current_tab()
        logger.log.trace("Minimap window refreshed.")
    end)
end

M.on_win_new = function(args)
    local logger = require("neominimap.logger")
    local winid = api.nvim_get_current_win()
    logger.log.trace("WinNew or WinEnter event triggered for window %d.", winid)
    vim.schedule(function()
        logger.log.trace("Refreshing minimap window")
        require("neominimap.window.split.internal").refresh_current_tab()
        require("neominimap.window.split.internal").refresh_source_in_current_tab()
        logger.log.trace("Minimap window refreshed.")
    end)
end

M.on_win_closed = function(args)
    local logger = require("neominimap.logger")
    local winid = tonumber(args.match)
    logger.log.trace("WinClosed event triggered for window %d.", winid)
    if winid == nil then
        return
    end
    local window_map = require("neominimap.window.split.window_map")
    local tabid = api.nvim_win_get_tabpage(winid)
    if window_map.is_minimap_window(tabid, winid) and not config.split.persist then
        logger.log.trace("This is a minimap window. Close minimap for current tab")
        local var = require("neominimap.variables")
        var.t[tabid].enabled = false
    end
    vim.schedule(function()
        logger.log.trace("Refreshing minimap window")
        require("neominimap.window.split.internal").refresh_current_tab()
        logger.log.trace("Minimap window refreshed.")
    end)
end

M.on_tab_enter = function(args)
    local logger = require("neominimap.logger")
    local tid = api.nvim_get_current_tabpage()
    logger.log.trace("TabEnter event triggered for tab %d.", tid)
    vim.schedule(function()
        logger.log.trace("Refreshing minimaps for tab ID: %d.", tid)
        require("neominimap.window.split.internal").refresh_current_tab()
        logger.log.trace("Minimaps refreshed for tab ID: %d.", tid)
    end)
end

M.on_cursor_moved = function(args)
    local logger = require("neominimap.logger")
    logger.log.trace("CursorMoved event triggered.")
    local winid = api.nvim_get_current_win()
    local tabid = api.nvim_win_get_tabpage(winid)
    logger.log.trace("Window ID: %d", winid)
    vim.schedule(function()
        local window_map = require("neominimap.window.split.window_map")
        local internal = require("neominimap.window.split.internal")
        if not window_map.is_minimap_window(tabid, winid) then
            logger.log.trace("Resettting cursor line for window %d.", winid)
            internal.reset_mwindow_cursor_line()
            logger.log.trace("Cursor line reset for window %d.", winid)
        elseif config.sync_cursor then
            logger.log.trace("Resetting parent cursor line")
            internal.reset_parent_window_cursor_line()
            logger.log.trace("Parent cursor line reset")
        end
    end)
end

M.fix_width_on_resize = function(args)
    local logger = require("neominimap.logger")
    logger.log.trace("WinResized event triggered.")
    vim.schedule(function()
        logger.log.trace("Resetting minimap width.")
        require("neominimap.window.split.internal").reset_minimap_width()
        logger.log.trace("Minimap width reset.")
    end)
end

M.on_minimap_buffer_created_or_deleted = function(args)
    local logger = require("neominimap.logger")
    logger.log.trace("User Neominimap event triggered. patter: MinimapBufferCreated or MinimapBufferDeleted")
    vim.schedule(function()
        logger.log.trace("Refreshing source window.")
        require("neominimap.window.split.internal").refresh_current_tab()
        logger.log.trace("Source window refreshed.")
    end)
end

M.on_minimap_buffer_text_changed = function(args)
    local logger = require("neominimap.logger")
    logger.log.trace("User Neominimap event triggered. patter: BufferTextUpdated")
    vim.schedule(function()
        logger.log.trace("Resetting cursor line")
        require("neominimap.window.split.internal").reset_mwindow_cursor_line()
        logger.log.trace("Cursor line reset")
    end)
end

return M
