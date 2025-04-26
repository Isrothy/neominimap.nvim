local api = vim.api
local config = require("neominimap.config")
local M = {}

M.focus_on_win_new = function()
    local winid = api.nvim_get_current_win()
    local logger = require("neominimap.logger")
    logger.log.trace("WinEnter event triggered for window %d.", winid)
    vim.schedule(function()
        local window_map = require("neominimap.window.float.window_map")
        if window_map.is_minimap_window(winid) then
            logger.log.trace("Unfocusing minimap window %d.", winid)
            require("neominimap.window.float.internal").unfocus(winid)
            logger.log.trace("Minimap window %d unfocused.", winid)
        end
    end)
end

M.on_buf_win_enter = function()
    local logger = require("neominimap.logger")
    local winid = api.nvim_get_current_win()
    logger.log.trace("BufWinEnter event triggered for window %d.", winid)
    vim.schedule(function()
        logger.log.trace("Refreshing minimap window for window ID: %d.", winid)
        require("neominimap.window.float.internal").refresh_minimap_window(winid)
        logger.log.trace("Minimap window refreshed for window %d.", winid)
    end)
end

M.on_win_new = function()
    local logger = require("neominimap.logger")
    local winid = api.nvim_get_current_win()
    logger.log.trace("WinNew event triggered for window %d.", winid)
    vim.schedule(function()
        logger.log.trace("Refreshing minimap window for window ID: %d.", winid)
        require("neominimap.window.float.internal").refresh_minimap_window(winid)
        logger.log.trace("Minimap window refreshed for window %d.", winid)
    end)
end

M.on_win_closed = function(args)
    local logger = require("neominimap.logger")
    local winid = tonumber(args.match)
    logger.log.trace("WinClosed event triggered for window %d.", winid)
    if not winid then
        return
    end
    local window_map = require("neominimap.window.float.window_map")
    if window_map.is_minimap_window(winid) and not config.float.persist then
        logger.log.trace("This is a minimap window. Close minimap for current window")
        local var = require("neominimap.variables")
        local swinid = window_map.get_parent_winid(winid)
        if swinid then
            var.w[swinid].enabled = false
        end
    end
    vim.schedule(function()
        logger.log.trace("Refreshing minimap for window %d.", winid)
        require("neominimap.window.float.internal").refresh_minimap_window(winid)
        logger.log.trace("Minimap window refreshed for window %d.", winid)
    end)
end

M.on_tab_enter = function()
    local logger = require("neominimap.logger")
    local tid = api.nvim_get_current_tabpage()
    logger.log.trace("TabEnter event triggered for tab %d.", tid)
    vim.schedule(function()
        logger.log.trace("Refreshing minimaps for tab ID: %d.", tid)
        require("neominimap.window.float.internal").refresh_minimaps_in_tab(tid)
        logger.log.trace("Minimaps refreshed for tab ID: %d.", tid)
    end)
end

M.on_win_resized = function()
    local logger = require("neominimap.logger")
    logger.log.trace("WinResized event triggered.")
    local win_list = vim.deepcopy(vim.v.event.windows)
    logger.log.trace("Windows to be resized: %s", vim.inspect(win_list))
    if win_list then
        for _, winid in ipairs(win_list) do
            vim.schedule(function()
                logger.log.trace("Refreshing minimaps for window: %d", winid)
                require("neominimap.window.float.internal").refresh_minimap_window(winid)
                logger.log.trace("Minimaps refreshed for window: %d", winid)
            end)
        end
    end
end

M.on_win_scrolled = function()
    local logger = require("neominimap.logger")
    logger.log.trace("WinScrolled event triggered.")
    local win_list = {}
    for winid, _ in pairs(vim.v.event) do
        if winid ~= "all" then
            win_list[#win_list + 1] = tonumber(winid)
        end
    end
    logger.log.trace("Windows to be scrolled: %s", vim.inspect(win_list))
    vim.schedule(function()
        for _, winid in ipairs(win_list) do
            logger.log.trace("Refreshing minimap for window %d.", winid)
            require("neominimap.window.float.internal").refresh_minimap_window(winid)
            logger.log.trace("Minimap refreshed for window %d.", winid)
        end
    end)
end

M.on_cursor_moved = function()
    local logger = require("neominimap.logger")
    logger.log.trace("CursorMoved event triggered.")
    local winid = api.nvim_get_current_win()
    logger.log.trace("Window ID: %d", winid)
    vim.schedule(function()
        local window_map = require("neominimap.window.float.window_map")
        local internal = require("neominimap.window.float.internal")
        if not window_map.is_minimap_window(winid) then
            logger.log.trace("Resettting cursor line for window %d.", winid)
            internal.reset_mwindow_cursor_line(winid)
            logger.log.trace("Cursor line reset for window %d.", winid)
        elseif config.sync_cursor then
            logger.log.trace("Resetting parent cursor line for minimap window %d.", winid)
            internal.reset_parent_window_cursor_line(winid)
            logger.log.trace("Parent cursor line reset for window %d.", winid)
        end
    end)
end

M.on_minimap_buffer_created_or_deleted = function(args)
    local logger = require("neominimap.logger")
    logger.log.trace("User Neominimap event triggered. patter: MinimapBufferCreated or MinimapBufferDeleted")
    local bufnr = args.data.buffer
    local win_list = require("neominimap.util").get_attached_window(bufnr)
    vim.schedule(function()
        for _, winid in ipairs(win_list) do
            logger.log.trace("Refreshing minimap for window %d.", winid)
            require("neominimap.window.float.internal").refresh_minimap_window(winid)
            logger.log.trace("Minimap refreshed for window %d.", winid)
        end
    end)
end

M.on_minimap_buffer_text_changed = function(args)
    local logger = require("neominimap.logger")
    local bufnr = args.data.buffer
    logger.log.trace("User Neominimap event triggered. patter: BufferTextUpdated")
    logger.log.trace("Buffer ID: %d", bufnr)
    local win_list = require("neominimap.util").get_attached_window(bufnr)
    vim.schedule(function()
        for _, winid in ipairs(win_list) do
            logger.log.trace("Resetting cursor line for window %d.", winid)
            require("neominimap.window.float.internal").reset_mwindow_cursor_line(winid)
            logger.log.trace("Cursor line reset for window %d.", winid)
        end
    end)
end

return M
