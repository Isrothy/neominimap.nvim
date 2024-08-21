local api = vim.api
local config = require("neominimap.config")
local M = {}

M.create_autocmds = function()
    if config.click.enabled and not config.click.auto_switch_focus then
        api.nvim_create_autocmd("WinEnter", {
            group = "Neominimap",
            callback = function()
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
                require("neominimap.window.float.internal").refresh_minimap_window(winid)
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
                require("neominimap.window.float.internal").refresh_minimap_window(winid)
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
                logger.log(string.format("Refreshing minimap for window %d.", winid), vim.log.levels.TRACE)
                ---@cast winid integer
                require("neominimap.window.float.internal").refresh_minimap_window(winid)
                logger.log(string.format("Minimap window refreshed for window %d.", winid), vim.log.levels.TRACE)
            end)
        end,
    })
    api.nvim_create_autocmd("TabEnter", {
        group = "Neominimap",
        callback = vim.schedule_wrap(function()
            local logger = require("neominimap.logger")
            local tid = api.nvim_get_current_tabpage()
            logger.log(string.format("TabEnter event triggered for tab %d.", tid), vim.log.levels.TRACE)
            logger.log(string.format("Refreshing minimaps for tab ID: %d.", tid), vim.log.levels.TRACE)
            require("neominimap.window.float.internal").refresh_minimaps_in_tab(tid)
            logger.log(string.format("Minimaps refreshed for tab ID: %d.", tid), vim.log.levels.TRACE)
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
                    require("neominimap.window.float.internal").refresh_minimap_window(winid)
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
                    require("neominimap.window.float.internal").refresh_minimap_window(winid)
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
                require("neominimap.window.float.internal").refresh_minimap_window(winid)
                logger.log(string.format("Minimap refreshed for window %d.", winid), vim.log.levels.TRACE)
            end
        end,
    })
end
return M
