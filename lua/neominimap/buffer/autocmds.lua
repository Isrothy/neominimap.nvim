local M = {}

local api = vim.api
local config = require("neominimap.config")

local create_git_autocmds = function()
    api.nvim_create_autocmd("User", {
        pattern = "GitSignsUpdate",
        desc = "Update git marks when git signs are updated",
        callback = function(args)
            local logger = require("neominimap.logger")
            logger.log("GitSignsUpdate event triggered.", vim.log.levels.TRACE)
            vim.schedule(function()
                logger.log("Updating git signs.", vim.log.levels.TRACE)
                if not args.data or not args.data.buffer then
                    logger.log("Buffer ID not found.", vim.log.levels.WARN)
                    return
                end
                local bufnr = tonumber(args.data.buffer)
                ---@cast bufnr integer
                require("neominimap.buffer.internal").update_git(bufnr)
                logger.log("Git signs updated.", vim.log.levels.TRACE)
            end)
        end,
    })
    api.nvim_create_autocmd("User", {
        group = "Neominimap",
        pattern = "MinimapBufferTextUpdated",
        desc = "Update git marks when buffer text is updated",
        callback = function(args)
            local bufnr = args.data.buf
            local logger = require("neominimap.logger")
            logger.log("User Neominimap event triggered. patter: BufferTextUpdated", vim.log.levels.TRACE)
            logger.log(string.format("Buffer ID: %d", bufnr), vim.log.levels.TRACE)
            vim.schedule(function()
                logger.log(string.format("Refreshing git signs for buffer %d.", bufnr), vim.log.levels.TRACE)
                require("neominimap.buffer.internal").update_git(bufnr)
                logger.log(string.format("Git signs refreshed for buffer %d.", bufnr), vim.log.levels.TRACE)
            end)
        end,
    })
end

local create_diagnostic_autocmds = function()
    api.nvim_create_autocmd("DiagnosticChanged", {
        group = "Neominimap",
        desc = "Update diagnostic marks when diagnostics are changed",
        callback = function()
            local logger = require("neominimap.logger")
            logger.log("DiagnosticChanged event triggered.", vim.log.levels.TRACE)
            vim.schedule(function()
                logger.log("Updating diagnostics.", vim.log.levels.TRACE)
                require("neominimap.buffer.internal").update_all_diagnostics()
                logger.log("Diagnostics updated.", vim.log.levels.TRACE)
            end)
        end,
    })
    api.nvim_create_autocmd("User", {
        group = "Neominimap",
        pattern = "MinimapBufferTextUpdated",
        desc = "Update diagnostic marks when buffer text is updated",
        callback = function(args)
            local bufnr = args.data.buf
            local logger = require("neominimap.logger")
            logger.log("User Neominimap event triggered. patter: BufferTextUpdated", vim.log.levels.TRACE)
            logger.log(string.format("Buffer ID: %d", bufnr), vim.log.levels.TRACE)
            vim.schedule(function()
                logger.log(string.format("Refreshing diagnostics for buffer %d.", bufnr), vim.log.levels.TRACE)
                require("neominimap.buffer.internal").update_diagnostics(bufnr)
                logger.log(string.format("Diagnostics refreshed for bufnr %d.", bufnr), vim.log.levels.TRACE)
            end)
        end,
    })
end

local create_search_autocmds = function()
    api.nvim_create_autocmd("BufWinEnter", {
        group = "Neominimap",
        desc = "Update search marks when entering window",
        callback = function()
            local logger = require("neominimap.logger")
            logger.log("BufWinEnter event triggered.", vim.log.levels.TRACE)
            vim.schedule(function()
                local bufnr = api.nvim_get_current_buf()
                logger.log(string.format("Updating search status for buffer %d.", bufnr), vim.log.levels.TRACE)
                require("neominimap.buffer.internal").update_search(bufnr)
                logger.log(string.format("Search status updated for buffer %d.", bufnr), vim.log.levels.TRACE)
            end)
        end,
    })
    api.nvim_create_autocmd("TabEnter", {
        group = "Neominimap",
        desc = "Update search marks when entering tab",
        callback = vim.schedule_wrap(function()
            local tid = api.nvim_get_current_tabpage()
            local logger = require("neominimap.logger")
            logger.log(string.format("TabEnter event triggered for tab %d.", tid), vim.log.levels.TRACE)
            logger.log("Refreshing search status.", vim.log.levels.TRACE)
            local visiable_buffers = require("neominimap.util").get_visible_buffers()
            for _, bufnr in ipairs(visiable_buffers) do
                logger.log(string.format("Updating search status for buffer %d.", bufnr), vim.log.levels.TRACE)
                require("neominimap.buffer.internal").update_search(bufnr)
                logger.log(string.format("Search status updated for buffer %d.", bufnr), vim.log.levels.TRACE)
            end
            logger.log("Search status refreshed.", vim.log.levels.TRACE)
        end),
    })
    api.nvim_create_autocmd("User", {
        group = "Neominimap",
        pattern = "MinimapBufferTextUpdated",
        desc = "Update search marks when buffer text is updated",
        callback = function(args)
            local bufnr = args.data.buf
            local logger = require("neominimap.logger")
            logger.log("User Neominimap event triggered. patter: BufferTextUpdated", vim.log.levels.TRACE)
            logger.log(string.format("Buffer ID: %d", bufnr), vim.log.levels.TRACE)
            vim.schedule(function()
                logger.log(string.format("Refreshing search status for buffer %d.", bufnr), vim.log.levels.TRACE)
                require("neominimap.buffer.internal").update_search(bufnr)
                logger.log(string.format("Search status refreshed for buffer %d.", bufnr), vim.log.levels.TRACE)
            end)
        end,
    })
    require("neominimap.events.search")
    api.nvim_create_autocmd("User", {
        group = "Neominimap",
        pattern = "Search",
        desc = "Update search marks when search event is triggered",
        callback = function()
            local logger = require("neominimap.logger")
            logger.log("Search event triggered", vim.log.levels.TRACE)
            vim.schedule(function()
                local visible_buffers = require("neominimap.util").get_visible_buffers()
                for _, bufnr in ipairs(visible_buffers) do
                    logger.log(string.format("Updating search status for buffer %d.", bufnr), vim.log.levels.TRACE)
                    require("neominimap.buffer.internal").update_search(bufnr)
                    logger.log(string.format("Search status updated for buffer %d.", bufnr), vim.log.levels.TRACE)
                end
                logger.log("Search status refreshed.", vim.log.levels.TRACE)
            end)
        end,
    })
end

M.create_autocmds = function()
    api.nvim_create_autocmd({ "BufNew", "BufRead" }, {
        group = "Neominimap",
        desc = "Create minimap buffer when buffer is opened",
        callback = function(args)
            local logger = require("neominimap.logger")
            logger.log(
                string.format("BufNew or BufRead event triggered for buffer %d.", args.buf),
                vim.log.levels.TRACE
            )
            local bufnr = tonumber(args.buf)
            vim.schedule(function()
                ---@cast bufnr integer
                logger.log(string.format("Refreshing minimap for buffer %d.", bufnr), vim.log.levels.TRACE)
                -- local tabid = api.nvim_get_current_tabpage()
                -- logger.log(string.format("tabid: " .. tostring(tabid)), vim.log.levels.DEBUG)
                -- logger.log(string.format("Minimap WinId: " .. tostring(require("neominimap.window.split.window_map").get_minimap_winid(tabid))), vim.log.levels.DEBUG)
                require("neominimap.buffer.internal").refresh_minimap_buffer(bufnr)
                logger.log(string.format("Minimap buffer refreshed for buffer %d.", bufnr), vim.log.levels.TRACE)
            end)
        end,
    })

    api.nvim_create_autocmd("BufUnload", {
        group = "Neominimap",
        desc = "Wipe out minimap buffer when buffer is closed",
        callback = function(args)
            local logger = require("neominimap.logger")
            logger.log(string.format("BufUnload event triggered for buffer %d.", args.buf), vim.log.levels.TRACE)
            local bufnr = tonumber(args.buf)
            vim.schedule(function()
                logger.log(string.format("Wiping out minimap for buffer %d.", bufnr), vim.log.levels.TRACE)
                ---@cast bufnr integer
                require("neominimap.buffer.internal").delete_minimap_buffer(bufnr)
                logger.log(string.format("Minimap buffer wiped out for buffer %d.", bufnr), vim.log.levels.TRACE)
            end)
        end,
    })
    api.nvim_create_autocmd({ "TextChanged", "TextChangedI" }, {
        group = "Neominimap",
        desc = "Update minimap buffer when text is changed",
        callback = function(args)
            local logger = require("neominimap.logger")
            logger.log(string.format("TextChanged event triggered for buffer %d.", args.buf), vim.log.levels.TRACE)
            local bufnr = tonumber(args.buf)
            vim.schedule(function()
                logger.log(string.format("Debounced updating text for buffer %d.", bufnr), vim.log.levels.TRACE)
                ---@cast bufnr integer
                require("neominimap.buffer.internal").render(bufnr)
                logger.log(
                    string.format("Debounced text updating for buffer %d is called", bufnr),
                    vim.log.levels.TRACE
                )
            end)
        end,
    })

    if config.diagnostic.enabled then
        create_diagnostic_autocmds()
    end
    if config.git.enabled then
        create_git_autocmds()
    end
    if config.search.enabled then
        create_search_autocmds()
    end
end

return M
