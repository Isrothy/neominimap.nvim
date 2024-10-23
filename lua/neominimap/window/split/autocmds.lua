local api = vim.api
local config = require("neominimap.config")
local M = {}

---@param group string | integer
M.create_autocmds = function(group)
    api.nvim_create_autocmd("BufWinEnter", {
        group = group,
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
        group = group,
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
        group = group,
        callback = function(args)
            local logger = require("neominimap.logger")
            logger.log(
                string.format("WinClosed event triggered for window %d.", tonumber(args.match)),
                vim.log.levels.TRACE
            )
            vim.schedule(function()
                logger.log("Refreshing minimap window", vim.log.levels.TRACE)
                require("neominimap.window.split.internal").refresh_current_tab()
                logger.log("Minimap window refreshed.", vim.log.levels.TRACE)
            end)
        end,
    })
    api.nvim_create_autocmd("TabEnter", {
        group = group,
        callback = vim.schedule_wrap(function()
            local logger = require("neominimap.logger")
            local tid = api.nvim_get_current_tabpage()
            logger.log(string.format("TabEnter event triggered for tab %d.", tid), vim.log.levels.TRACE)
            vim.schedule(function()
                logger.log(string.format("Refreshing minimaps for tab ID: %d.", tid), vim.log.levels.TRACE)
                require("neominimap.window.split.internal").refresh_current_tab()
                logger.log(string.format("Minimaps refreshed for tab ID: %d.", tid), vim.log.levels.TRACE)
            end)
        end),
    })
    api.nvim_create_autocmd({ "CursorMoved", "CursorMovedI" }, {
        group = group,
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

    if config.split.fix_width then
        api.nvim_create_autocmd("WinResized", {
            group = group,
            desc = "Reset minimap width when window is resized",
            callback = function()
                local logger = require("neominimap.logger")
                logger.log("WinResized event triggered.", vim.log.levels.TRACE)
                vim.schedule(function()
                    logger.log("Resetting minimap width.", vim.log.levels.TRACE)
                    require("neominimap.window.split.internal").reset_minimap_width()
                    logger.log("Minimap width reset.", vim.log.levels.TRACE)
                end)
            end,
        })
    end

    api.nvim_create_autocmd("User", {
        group = group,
        pattern = { "MinimapBufferCreated", "MinimapBufferDeleted" },
        desc = "Refresh source window when buffer is created or deleted",
        callback = function()
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
        end,
    })
    api.nvim_create_autocmd("User", {
        group = group,
        pattern = "MinimapBufferTextUpdated",
        desc = "Reset cursor line when buffer text is updated",
        callback = function()
            local logger = require("neominimap.logger")
            logger.log("User Neominimap event triggered. patter: BufferTextUpdated", vim.log.levels.TRACE)
            vim.schedule(function()
                logger.log(string.format("Resetting cursor line"), vim.log.levels.TRACE)
                require("neominimap.window.split.internal").reset_mwindow_cursor_line()
                logger.log(string.format("Cursor line reset"), vim.log.levels.TRACE)
            end)
        end,
    })
end

return M
