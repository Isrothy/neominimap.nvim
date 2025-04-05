local api = vim.api
local config = require("neominimap.config")
local M = {}

M.focus_on_win_new = function()
    local winid = api.nvim_get_current_win()
    local logger = require("neominimap.logger")
    logger.log(string.format("WinEnter event triggered for window %d.", winid), vim.log.levels.TRACE)
    vim.schedule(function()
        local window_map = require("neominimap.window.float.window_map")
        if window_map.is_minimap_window(winid) then
            logger.log(string.format("Unfocusing minimap window %d.", winid), vim.log.levels.TRACE)
            require("neominimap.window.float.internal").unfocus(winid)
            logger.log(string.format("Minimap window %d unfocused.", winid), vim.log.levels.TRACE)
        end
    end)
end

M.on_buf_win_enter = function()
    local logger = require("neominimap.logger")
    local winid = api.nvim_get_current_win()
    logger.log(string.format("BufWinEnter event triggered for window %d.", winid), vim.log.levels.TRACE)
    vim.schedule(function()
        logger.log(string.format("Refreshing minimap window for window ID: %d.", winid), vim.log.levels.TRACE)
        require("neominimap.window.float.internal").refresh_minimap_window(winid)
        logger.log(string.format("Minimap window refreshed for window %d.", winid), vim.log.levels.TRACE)
    end)
end

M.on_win_new = function()
    local logger = require("neominimap.logger")
    local winid = api.nvim_get_current_win()
    logger.log(string.format("WinNew event triggered for window %d.", winid), vim.log.levels.TRACE)
    vim.schedule(function()
        logger.log(string.format("Refreshing minimap window for window ID: %d.", winid), vim.log.levels.TRACE)
        require("neominimap.window.float.internal").refresh_minimap_window(winid)
        logger.log(string.format("Minimap window refreshed for window %d.", winid), vim.log.levels.TRACE)
    end)
end

M.on_win_closed = function(args)
    local logger = require("neominimap.logger")
    logger.log(string.format("WinClosed event triggered for window %d.", tonumber(args.match)), vim.log.levels.TRACE)
    local winid = tonumber(args.match)
    vim.schedule(function()
        logger.log(string.format("Refreshing minimap for window %d.", winid), vim.log.levels.TRACE)
        ---@cast winid integer
        require("neominimap.window.float.internal").refresh_minimap_window(winid)
        logger.log(string.format("Minimap window refreshed for window %d.", winid), vim.log.levels.TRACE)
    end)
end

M.on_tab_enter = function()
    local logger = require("neominimap.logger")
    local tid = api.nvim_get_current_tabpage()
    logger.log(string.format("TabEnter event triggered for tab %d.", tid), vim.log.levels.TRACE)
    vim.schedule(function()
        logger.log(string.format("Refreshing minimaps for tab ID: %d.", tid), vim.log.levels.TRACE)
        require("neominimap.window.float.internal").refresh_minimaps_in_tab(tid)
        logger.log(string.format("Minimaps refreshed for tab ID: %d.", tid), vim.log.levels.TRACE)
    end)
end

M.on_win_resized = function()
    local logger = require("neominimap.logger")
    logger.log("WinResized event triggered.", vim.log.levels.TRACE)
    local win_list = vim.deepcopy(vim.v.event.windows)
    logger.log(string.format("Windows to be resized: %s", vim.inspect(win_list)), vim.log.levels.TRACE)
    if win_list then
        for _, winid in ipairs(win_list) do
            vim.schedule(function()
                logger.log(string.format("Refreshing minimaps for window: %d", winid), vim.log.levels.TRACE)
                require("neominimap.window.float.internal").refresh_minimap_window(winid)
                logger.log(string.format("Minimaps refreshed for window: %d", winid), vim.log.levels.TRACE)
            end)
        end
    end
end

M.on_win_scrolled = function()
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
            require("neominimap.window.float.internal").refresh_minimap_window(winid)
            logger.log(string.format("Minimap refreshed for window %d.", winid), vim.log.levels.TRACE)
        end
    end)
end

M.on_cursor_moved = function()
    local logger = require("neominimap.logger")
    logger.log("CursorMoved event triggered.", vim.log.levels.TRACE)
    local winid = api.nvim_get_current_win()
    logger.log(string.format("Window ID: %d", winid), vim.log.levels.TRACE)
    vim.schedule(function()
        local window_map = require("neominimap.window.float.window_map")
        local internal = require("neominimap.window.float.internal")
        if not window_map.is_minimap_window(winid) then
            logger.log(string.format("Resettting cursor line for window %d.", winid), vim.log.levels.TRACE)
            internal.reset_mwindow_cursor_line(winid)
            logger.log(string.format("Cursor line reset for window %d.", winid), vim.log.levels.TRACE)
        elseif config.sync_cursor then
            logger.log(
                string.format("Resetting parent cursor line for minimap window %d.", winid),
                vim.log.levels.TRACE
            )
            internal.reset_parent_window_cursor_line(winid)
            logger.log(string.format("Parent cursor line reset for window %d.", winid), vim.log.levels.TRACE)
        end
    end)
end

M.on_minimap_buffer_created_or_deleted = function(args)
    local logger = require("neominimap.logger")
    logger.log(
        "User Neominimap event triggered. patter: MinimapBufferCreated or MinimapBufferDeleted",
        vim.log.levels.TRACE
    )
    local bufnr = args.data.buffer
    local win_list = require("neominimap.util").get_attached_window(bufnr)
    vim.schedule(function()
        for _, winid in ipairs(win_list) do
            logger.log(string.format("Refreshing minimap for window %d.", winid), vim.log.levels.TRACE)
            require("neominimap.window.float.internal").refresh_minimap_window(winid)
            logger.log(string.format("Minimap refreshed for window %d.", winid), vim.log.levels.TRACE)
        end
    end)
end

M.on_minimap_buffer_text_changed = function(args)
    local logger = require("neominimap.logger")
    local bufnr = args.data.buffer
    logger.log("User Neominimap event triggered. patter: BufferTextUpdated", vim.log.levels.TRACE)
    logger.log(string.format("Buffer ID: %d", bufnr), vim.log.levels.TRACE)
    local win_list = require("neominimap.util").get_attached_window(bufnr)
    vim.schedule(function()
        for _, winid in ipairs(win_list) do
            logger.log(string.format("Resetting cursor line for window %d.", winid), vim.log.levels.TRACE)
            require("neominimap.window.float.internal").reset_mwindow_cursor_line(winid)
            logger.log(string.format("Cursor line reset for window %d.", winid), vim.log.levels.TRACE)
        end
    end)
end

return M
