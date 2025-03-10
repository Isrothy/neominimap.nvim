local M = {}

M.on_vim_enter = function()
    local logger = require("neominimap.logger")
    logger.log("VimEnter event triggered.", vim.log.levels.TRACE)
    vim.schedule(function()
        logger.log("Refreshing minimaps.", vim.log.levels.TRACE)
        require("neominimap.buffer.internal").refresh_all_minimap_buffers()
        logger.log("Minimaps refreshed.", vim.log.levels.TRACE)
    end)
end

M.on_buf_new = function(args)
    local logger = require("neominimap.logger")
    logger.log(string.format("BufNew or BufRead event triggered for buffer %d.", args.buf), vim.log.levels.TRACE)
    local bufnr = tonumber(args.buf)
    vim.schedule(function()
        ---@cast bufnr integer
        logger.log(string.format("Refreshing minimap for buffer %d.", bufnr), vim.log.levels.TRACE)
        require("neominimap.buffer.internal").refresh_minimap_buffer(bufnr)
        logger.log(string.format("Minimap buffer refreshed for buffer %d.", bufnr), vim.log.levels.TRACE)
    end)
end

M.on_buf_unload = function(args)
    local logger = require("neominimap.logger")
    logger.log(string.format("BufUnload event triggered for buffer %d.", args.buf), vim.log.levels.TRACE)
    local bufnr = tonumber(args.buf)
    vim.schedule(function()
        logger.log(string.format("Wiping out minimap for buffer %d.", bufnr), vim.log.levels.TRACE)
        ---@cast bufnr integer
        require("neominimap.buffer.internal").delete_minimap_buffer(bufnr)
        logger.log(string.format("Minimap buffer wiped out for buffer %d.", bufnr), vim.log.levels.TRACE)
    end)
end

M.on_text_change = function(args)
    local logger = require("neominimap.logger")
    logger.log(string.format("TextChanged event triggered for buffer %d.", args.buf), vim.log.levels.TRACE)
    local bufnr = tonumber(args.buf)
    vim.schedule(function()
        logger.log(string.format("Debounced updating text for buffer %d.", bufnr), vim.log.levels.TRACE)
        ---@cast bufnr integer
        require("neominimap.buffer.internal").render(bufnr)
        logger.log(string.format("Debounced text updating for buffer %d is called", bufnr), vim.log.levels.TRACE)
    end)
end

M.on_minimap_text_update = function(args)
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
end

return M
