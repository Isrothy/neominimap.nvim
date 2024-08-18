local api = vim.api

local M = {}

local config = require("neominimap.config").get()

M.create_autocmds = function()
    local logger = require("neominimap.logger")
    api.nvim_create_autocmd({ "BufNew", "BufRead" }, {
        group = "Neominimap",
        callback = function(args)
            logger.log(
                string.format("BufNew or BufRead event triggered for buffer %d.", args.buf),
                vim.log.levels.TRACE
            )
            local bufnr = tonumber(args.buf)
            local buffer = require("neominimap.buffer")
            vim.schedule(function()
                ---@cast bufnr integer
                logger.log(string.format("Refreshing minimap for buffer %d.", bufnr), vim.log.levels.TRACE)
                buffer.refresh_minimap_buffer(bufnr)
                logger.log(string.format("Minimap buffer refreshed for buffer %d.", bufnr), vim.log.levels.TRACE)
            end)
        end,
    })
    api.nvim_create_autocmd("BufUnload", {
        group = "Neominimap",
        callback = function(args)
            logger.log(string.format("BufUnload event triggered for buffer %d.", args.buf), vim.log.levels.TRACE)
            local bufnr = tonumber(args.buf)
            local buffer = require("neominimap.buffer")
            vim.schedule(function()
                logger.log(string.format("Wiping out minimap for buffer %d.", bufnr), vim.log.levels.TRACE)
                ---@cast bufnr integer
                buffer.delete_minimap_buffer(bufnr)
                logger.log(string.format("Minimap buffer wiped out for buffer %d.", bufnr), vim.log.levels.TRACE)
            end)
        end,
    })
    api.nvim_create_autocmd({ "TextChanged", "TextChangedI" }, {
        group = "Neominimap",
        callback = function(args)
            logger.log(string.format("TextChanged event triggered for buffer %d.", args.buf), vim.log.levels.TRACE)
            local bufnr = tonumber(args.buf)
            local buffer = require("neominimap.buffer")
            vim.schedule(function()
                logger.log(string.format("Debounced updating text for buffer %d.", bufnr), vim.log.levels.TRACE)
                ---@cast bufnr integer
                buffer.render(bufnr)
                logger.log(
                    string.format("Debounced text updating for buffer %d is called", bufnr),
                    vim.log.levels.TRACE
                )
            end)
        end,
    })

    if config.click.enabled and not config.click.auto_switch_focus then
        api.nvim_create_autocmd("WinEnter", {
            group = "Neominimap",
            callback = function()
                local winid = api.nvim_get_current_win()
                logger.log(string.format("WinEnter event triggered for window %d.", winid), vim.log.levels.TRACE)
                vim.schedule(function()
                    local window = require("neominimap.window")
                    if window.is_minimap_window(winid) then
                        logger.log(string.format("Unfocusing minimap window %d.", winid), vim.log.levels.TRACE)
                        window.unfocus(winid)
                        logger.log(string.format("Minimap window %d unfocused.", winid), vim.log.levels.TRACE)
                    end
                end)
            end,
        })
    end

    if config.diagnostic.enabled then
        api.nvim_create_autocmd("DiagnosticChanged", {
            group = "Neominimap",
            callback = function()
                logger.log("DiagnosticChanged event triggered.", vim.log.levels.TRACE)
                vim.schedule(function()
                    local buffer = require("neominimap.buffer")
                    logger.log("Updating diagnostics.", vim.log.levels.TRACE)
                    buffer.update_all_diagnostics()
                    logger.log("Diagnostics updated.", vim.log.levels.TRACE)
                end)
            end,
        })
    end

    if config.git.enabled then
        api.nvim_create_autocmd("User", {
            pattern = "GitSignsUpdate",
            callback = function(args)
                logger.log("GitSignsUpdate event triggered.", vim.log.levels.TRACE)
                vim.schedule(function()
                    local buffer = require("neominimap.buffer")
                    logger.log("Updating git signs.", vim.log.levels.TRACE)
                    if not args.data or not args.data.buffer then
                        logger.log("Buffer ID not found.", vim.log.levels.WARN)
                        return
                    end
                    local bufnr = tonumber(args.data.buffer)
                    ---@cast bufnr integer
                    buffer.update_git(bufnr)
                    logger.log("Git signs updated.", vim.log.levels.TRACE)
                end)
            end,
        })
    end

    api.nvim_create_autocmd("BufWinEnter", {
        group = "Neominimap",
        callback = function()
            local winid = api.nvim_get_current_win()
            logger.log(string.format("BufWinEnter event triggered for window %d.", winid), vim.log.levels.TRACE)
            vim.schedule(function()
                local window = require("neominimap.window")
                logger.log(string.format("Refreshing minimap window for window ID: %d.", winid), vim.log.levels.TRACE)
                window.refresh_minimap_window(winid)
                logger.log(string.format("Minimap window refreshed for window %d.", winid), vim.log.levels.TRACE)

                if config.search.enabled then
                    logger.log("Refreshing search status.", vim.log.levels.TRACE)
                    local bufnr = api.nvim_get_current_buf()
                    local buffer = require("neominimap.buffer")
                    logger.log(string.format("Updating search status for buffer %d.", bufnr), vim.log.levels.TRACE)
                    buffer.update_search(bufnr)
                    logger.log(string.format("Search status updated for buffer %d.", bufnr), vim.log.levels.TRACE)
                    logger.log("Search status refreshed.", vim.log.levels.TRACE)
                end
            end)
        end,
    })
    api.nvim_create_autocmd("WinNew", {
        group = "Neominimap",
        callback = function()
            local winid = api.nvim_get_current_win()
            logger.log(string.format("WinNew event triggered for window %d.", winid), vim.log.levels.TRACE)
            vim.schedule(function()
                local window = require("neominimap.window")
                logger.log(string.format("Refreshing minimap window for window ID: %d.", winid), vim.log.levels.TRACE)
                window.refresh_minimap_window(winid)
                logger.log(string.format("Minimap window refreshed for window %d.", winid), vim.log.levels.TRACE)
            end)
        end,
    })
    api.nvim_create_autocmd("WinClosed", {
        group = "Neominimap",
        callback = function(args)
            logger.log(
                string.format("WinClosed event triggered for window %d.", tonumber(args.match)),
                vim.log.levels.TRACE
            )
            local winid = tonumber(args.match)
            vim.schedule(function()
                local window = require("neominimap.window")
                logger.log(string.format("Closing minimap for window %d.", winid), vim.log.levels.TRACE)
                ---@cast winid integer
                window.close_minimap_window(winid)
                logger.log(string.format("Minimap window closed for window %d.", winid), vim.log.levels.TRACE)
            end)
        end,
    })
    api.nvim_create_autocmd("TabEnter", {
        group = "Neominimap",
        callback = vim.schedule_wrap(function()
            local tid = api.nvim_get_current_tabpage()
            local window = require("neominimap.window")
            logger.log(string.format("TabEnter event triggered for tab %d.", tid), vim.log.levels.TRACE)
            logger.log(string.format("Refreshing minimaps for tab ID: %d.", tid), vim.log.levels.TRACE)
            window.refresh_minimaps_in_tab(tid)
            if config.search.enabled then
                logger.log("Refreshing search status.", vim.log.levels.TRACE)
                local buffer = require("neominimap.buffer")
                local visiable_buffers = require("neominimap.util").get_visible_buffers()
                for _, bufnr in ipairs(visiable_buffers) do
                    logger.log(string.format("Updating search status for buffer %d.", bufnr), vim.log.levels.TRACE)
                    buffer.update_search(bufnr)
                    logger.log(string.format("Search status updated for buffer %d.", bufnr), vim.log.levels.TRACE)
                end
                logger.log("Search status refreshed.", vim.log.levels.TRACE)
            end
            logger.log(string.format("Minimaps refreshed for tab %d.", tid), vim.log.levels.TRACE)
        end),
    })
    api.nvim_create_autocmd("WinResized", {
        group = "Neominimap",
        callback = function()
            logger.log("WinResized event triggered.", vim.log.levels.TRACE)
            local win_list = vim.deepcopy(vim.v.event.windows)
            logger.log(string.format("Windows to be resized: %s", vim.inspect(win_list)), vim.log.levels.TRACE)
            local window = require("neominimap.window")
            for _, winid in ipairs(win_list) do
                vim.schedule(function()
                    logger.log(string.format("Refreshing minimaps for window: %d", winid), vim.log.levels.TRACE)
                    window.refresh_minimap_window(winid)
                    logger.log(string.format("Minimaps refreshed for window: %d", winid), vim.log.levels.TRACE)
                end)
            end
        end,
    })
    api.nvim_create_autocmd("WinScrolled", {
        group = "Neominimap",
        callback = function()
            logger.log("WinScrolled event triggered.", vim.log.levels.TRACE)
            local win_list = {}
            for winid, _ in pairs(vim.v.event) do
                if winid ~= "all" then
                    win_list[#win_list + 1] = tonumber(winid)
                end
            end
            logger.log(string.format("Windows to be scrolled: %s", vim.inspect(win_list)), vim.log.levels.TRACE)
            local window = require("neominimap.window")
            vim.schedule(function()
                for _, winid in ipairs(win_list) do
                    logger.log(string.format("Refreshing minimap for window %d.", winid), vim.log.levels.TRACE)
                    window.refresh_minimap_window(winid)
                    logger.log(string.format("Minimap refreshed for window %d.", winid), vim.log.levels.TRACE)
                end
            end)
        end,
    })
    api.nvim_create_autocmd({ "CursorMoved", "CursorMovedI" }, {
        group = "Neominimap",
        callback = function()
            logger.log("CursorMoved event triggered.", vim.log.levels.TRACE)
            local winid = api.nvim_get_current_win()
            logger.log(string.format("Window ID: %d", winid), vim.log.levels.TRACE)
            vim.schedule(function()
                local window = require("neominimap.window")
                if window.is_minimap_window(winid) then
                    if config.sync_cursor then
                        logger.log(
                            string.format("Resetting parent cursor line for minimap window %d.", winid),
                            vim.log.levels.TRACE
                        )
                        window.reset_parent_window_cursor_line(winid)
                        logger.log(
                            string.format("Parent cursor line reset for window %d.", winid),
                            vim.log.levels.TRACE
                        )
                    end
                else
                    logger.log(string.format("Resettting cursor line for window %d.", winid), vim.log.levels.TRACE)
                    window.reset_mwindow_cursor_line(winid)
                    logger.log(string.format("Cursor line reset for window %d.", winid), vim.log.levels.TRACE)
                end
            end)
        end,
    })
    api.nvim_create_autocmd("User", {
        group = "Neominimap",
        pattern = "BufferTextUpdated",
        callback = function(args)
            logger.log("User Neominimap event triggered. patter: BufferTextUpdated", vim.log.levels.TRACE)
            local window = require("neominimap.window")
            local buffer = require("neominimap.buffer")
            local win_list = window.list_windows()
            local bufnr = args.data.buf
            local updated_windows = {}
            for _, w in ipairs(win_list) do
                if api.nvim_win_get_buf(w) == bufnr then
                    updated_windows[#updated_windows + 1] = w
                end
            end
            logger.log(string.format("Windows to be refreshed: %s", vim.inspect(updated_windows)), vim.log.levels.TRACE)
            logger.log(string.format("Buffer ID: %d", bufnr), vim.log.levels.TRACE)
            vim.schedule(function()
                if config.diagnostic.enabled then
                    logger.log(string.format("Refreshing diagnostics for buffer %d.", bufnr), vim.log.levels.TRACE)
                    buffer.update_diagnostics(bufnr)
                    logger.log(string.format("Diagnostics refreshed for bufnr %d.", bufnr), vim.log.levels.TRACE)
                end
                if config.git.enabled then
                    logger.log(string.format("Refreshing git status for buffer %d.", bufnr), vim.log.levels.TRACE)
                    buffer.update_git(bufnr)
                    logger.log(string.format("Git status refreshed for buffer %d.", bufnr), vim.log.levels.TRACE)
                end
                if config.search.enabled then
                    logger.log(string.format("Refreshing search status for buffer %d.", bufnr), vim.log.levels.TRACE)
                    buffer.update_search(bufnr)
                    logger.log(string.format("Search status refreshed for buffer %d.", bufnr), vim.log.levels.TRACE)
                end
                for _, winid in ipairs(updated_windows) do
                    logger.log(string.format("Refreshing minimap for window %d.", winid), vim.log.levels.TRACE)
                    window.reset_mwindow_cursor_line(winid)
                    logger.log(string.format("Minimap refreshed for window %d.", winid), vim.log.levels.TRACE)
                end
            end)
        end,
    })
    api.nvim_create_autocmd("User", {
        group = "Neominimap",
        pattern = "MinimapBufferRefreshed",
        callback = function(args)
            logger.log("User Neominimap event triggered. patter: MinimapBufferRefreshed", vim.log.levels.TRACE)
            local window = require("neominimap.window")
            local bufnr = args.data.buf
            local win_list = require("neominimap.util").get_attached_window(bufnr)
            for _, winid in ipairs(win_list) do
                logger.log(string.format("Refreshing minimap for window %d.", winid), vim.log.levels.TRACE)
                window.refresh_minimap_window(winid)
                logger.log(string.format("Minimap refreshed for window %d.", winid), vim.log.levels.TRACE)
            end
        end,
    })
    if config.search.enabled then
        require("neominimap.autocmds.search")
        api.nvim_create_autocmd("User", {
            group = "Neominimap",
            pattern = "Search",
            callback = function()
                logger.log("Search event triggered", vim.log.levels.TRACE)
                vim.schedule(function()
                    local buffer = require("neominimap.buffer")
                    local visible_buffers = require("neominimap.util").get_visible_buffers()
                    for _, bufnr in ipairs(visible_buffers) do
                        logger.log(string.format("Updating search status for buffer %d.", bufnr), vim.log.levels.TRACE)
                        buffer.update_search(bufnr)
                        logger.log(string.format("Search status updated for buffer %d.", bufnr), vim.log.levels.TRACE)
                    end
                    logger.log("Search status refreshed.", vim.log.levels.TRACE)
                end)
            end,
        })
    end
end

M.clear_autocmds = function()
    api.nvim_clear_autocmds({ group = "Neominimap" })
end

return M
