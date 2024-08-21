local api = vim.api
local config = require("neominimap.config")
local M = {}

M.create_autocmds = function()
    api.nvim_create_autocmd("BufWinEnter", {
        group = "Neominimap",
        callback = function()
            local logger = require("neominimap.logger")
            local winid = api.nvim_get_current_win()
            logger.log(string.format("BufWinEnter event triggered for window %d.", winid), vim.log.levels.TRACE)
            vim.schedule(function()
                logger.log("Refreshing minimap window", vim.log.levels.TRACE)
                require("neominimap.window.split.internal").refresh_source_in_current_tab()
                logger.log("Minimap window refreshed.", vim.log.levels.TRACE)
            end)
        end,
    })
    api.nvim_create_autocmd({ "WinNew", "WinEnter" }, {
        group = "Neominimap",
        callback = function()
            local logger = require("neominimap.logger")
            local winid = api.nvim_get_current_win()
            logger.log(string.format("WinNew or WinEnter event triggered for window %d.", winid), vim.log.levels.TRACE)
            vim.schedule(function()
                logger.log("Refreshing minimap window", vim.log.levels.TRACE)
                require("neominimap.window.split.internal").refresh_source_in_current_tab()
                logger.log("Minimap window refreshed.", vim.log.levels.TRACE)
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
            vim.schedule(function()
                logger.log("Refreshing minimap window", vim.log.levels.TRACE)
                require("neominimap.window.split.internal").refresh_source_in_current_tab()
                logger.log("Minimap window refreshed.", vim.log.levels.TRACE)
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
            require("neominimap.window.split.internal").refresh_tab()
            logger.log(string.format("Minimaps refreshed for tab ID: %d.", tid), vim.log.levels.TRACE)
        end),
    })
    api.nvim_create_autocmd({ "CursorMoved", "CursorMovedI" }, {
        group = "Neominimap",
        callback = function()
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
                require("neominimap.window.split.internal").refresh_source_in_current_tab()
                logger.log(string.format("Minimap refreshed for window %d.", winid), vim.log.levels.TRACE)
            end
        end,
    })
end

return M
