local api = vim.api

local M = {}

local config = require("neominimap.config").get()
local gid = api.nvim_create_augroup("Neominimap", { clear = true })

M.create_autocmds = function()
    local logger = require("neominimap.logger")
    api.nvim_create_autocmd({ "BufNew", "BufRead" }, {
        group = gid,
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
        group = gid,
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
        group = gid,
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

    vim.api.nvim_create_autocmd("DiagnosticChanged", {
        group = gid,
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
    api.nvim_create_autocmd("BufWinEnter", {
        group = gid,
        callback = function()
            local winid = api.nvim_get_current_win()
            logger.log(string.format("BufWinEnter event triggered for window %d.", winid), vim.log.levels.TRACE)
            vim.schedule(function()
                local window = require("neominimap.window")
                logger.log(string.format("Refreshing minimap window for window ID: %d.", winid), vim.log.levels.TRACE)
                window.refresh_minimap_window(winid)
                logger.log(string.format("Minimap window refreshed for window %d.", winid), vim.log.levels.TRACE)
            end)
        end,
    })
    api.nvim_create_autocmd("WinNew", {
        group = gid,
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
        group = gid,
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
        group = gid,
        callback = vim.schedule_wrap(function()
            local tid = api.nvim_get_current_tabpage()
            local window = require("neominimap.window")
            logger.log(string.format("TabEnter event triggered for tab %d.", tid), vim.log.levels.TRACE)
            logger.log(string.format("Refreshing minimaps for tab ID: %d.", tid), vim.log.levels.TRACE)
            window.refresh_minimaps_in_tab(tid)
            logger.log(string.format("Minimaps refreshed for tab %d.", tid), vim.log.levels.TRACE)
        end),
    })
    api.nvim_create_autocmd("WinResized", {
        group = gid,
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
        group = gid,
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
        group = gid,
        callback = function()
            logger.log("CursorMoved event triggered.", vim.log.levels.TRACE)
            local winid = api.nvim_get_current_win()
            logger.log(string.format("Window ID: %d", winid), vim.log.levels.TRACE)
            vim.schedule(function()
                local window = require("neominimap.window")
                if window.is_minimap_window(winid) then
                    logger.log(
                        string.format("Resetting parent cursor line for minimap window %d.", winid),
                        vim.log.levels.TRACE
                    )
                    window.reset_parent_window_cursor_line(winid)
                    logger.log(string.format("Parent cursor line reset for window %d.", winid), vim.log.levels.TRACE)
                else
                    logger.log(string.format("Resettting cursor line for window %d.", winid), vim.log.levels.TRACE)
                    window.reset_mwindow_cursor_line(winid)
                    logger.log(string.format("Cursor line reset for window %d.", winid), vim.log.levels.TRACE)
                end
            end)
        end,
    })
    api.nvim_create_autocmd("User", {
        group = gid,
        pattern = "BufferTextUpdated",
        callback = function(args)
            logger.log("User Neominimap event triggered.", vim.log.levels.TRACE)
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
                for _, winid in ipairs(updated_windows) do
                    logger.log(string.format("Refreshing minimap for window %d.", winid), vim.log.levels.TRACE)
                    window.reset_mwindow_cursor_line(winid)
                    logger.log(string.format("Minimap refreshed for window %d.", winid), vim.log.levels.TRACE)
                end
            end)
        end,
    })
end

M.clear_autocmds = function()
    api.nvim_clear_autocmds({ group = gid })
end

return M
