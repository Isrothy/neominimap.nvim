local M = {}

local api = vim.api

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
    api.nvim_create_autocmd("User", {
        group = "Neominimap",
        pattern = "MinimapBufferTextUpdated",
        desc = "Update annotations when buffer text is updated",
        callback = function(args)
            local bufnr = args.data.buffer
            local logger = require("neominimap.logger")
            logger.log("User Neominimap event triggered. patter: BufferTextUpdated", vim.log.levels.TRACE)
            logger.log(string.format("Buffer ID: %d", bufnr), vim.log.levels.TRACE)
            vim.schedule(function()
                local buffer = require("neominimap.buffer")
                local handlers = require("neominimap.map.handlers").get_handlers()
                for _, handler in ipairs(handlers) do
                    buffer.apply_handler(bufnr, handler.name)
                end
            end)
        end,
    })
end

return M
