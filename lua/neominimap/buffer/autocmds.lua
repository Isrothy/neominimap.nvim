local M = {}

M.on_vim_enter = function()
    local logger = require("neominimap.logger")
    logger.log.trace("VimEnter event triggered.")
    vim.schedule(function()
        logger.log.trace("Refreshing minimaps.")
        require("neominimap.buffer.internal").refresh_all_minimap_buffers()
        logger.log.trace("Minimaps refreshed.")
    end)
end

M.on_buf_new = function(args)
    local logger = require("neominimap.logger")
    logger.log.trace("BufNew or BufRead event triggered for buffer %d.", args.buf)
    local bufnr = tonumber(args.buf)
    vim.schedule(function()
        ---@cast bufnr integer
        logger.log.trace("Refreshing minimap for buffer %d.", bufnr)
        require("neominimap.buffer.internal").refresh_minimap_buffer(bufnr)
        logger.log.trace("Minimap buffer refreshed for buffer %d.", bufnr)
    end)
end

M.on_buf_unload = function(args)
    local config = require("neominimap.config")
    local logger = require("neominimap.logger")
    logger.log.trace("BufUnload event triggered for buffer %d.", args.buf)
    local bufnr = tonumber(args.buf)
    if not bufnr then
        return
    end
    local buffer_map = require("neominimap.buffer.buffer_map")
    local sbufnr = buffer_map.get_source_bufnr(bufnr)
    if sbufnr then
        logger.log.trace("This is a minimap buffer")
        if config.buffer.persist then
            logger.log.trace("Not deleting minimap buffer for source buffer.")
            vim.schedule(function()
                logger.log.trace("Refreshing minimap buffer for source buffer %d.", sbufnr)
                require("neominimap.buffer.internal").refresh_minimap_buffer(sbufnr)
                logger.log.trace("Minimap buffer refreshed for source buffer %d.", sbufnr)
            end)
        else
            logger.log.trace("Deleting minimap buffer for source buffer.")
            local var = require("neominimap.variables")
            var.b[sbufnr].enabled = false
            vim.schedule(function()
                logger.log.trace("Deleting minimap buffer for source buffer %d.", sbufnr)
                require("neominimap.buffer.internal").delete_minimap_buffer(sbufnr)
                logger.log.trace("Minimap buffer deleted for source buffer %d.", sbufnr)
            end)
        end
    else
        vim.schedule(function()
            logger.log.trace("Wiping out minimap for buffer %d.", bufnr)
            require("neominimap.buffer.internal").delete_minimap_buffer(bufnr)
            logger.log.trace("Minimap buffer wiped out for buffer %d.", bufnr)
        end)
    end
end

M.on_text_change = function(args)
    local logger = require("neominimap.logger")
    logger.log.trace("TextChanged event triggered for buffer %d.", args.buf)
    local bufnr = tonumber(args.buf)
    vim.schedule(function()
        logger.log.trace("Debounced updating text for buffer %d.", bufnr)
        ---@cast bufnr integer
        require("neominimap.buffer.internal").render(bufnr)
        logger.log.trace("Debounced text updating for buffer %d is called", bufnr)
    end)
end

M.on_minimap_text_update = function(args)
    local bufnr = args.data.buffer
    local logger = require("neominimap.logger")
    logger.log.trace("User Neominimap event triggered. pattern: BufferTextUpdated")
    logger.log.trace("Buffer ID: %d", bufnr)
    vim.schedule(function()
        local buffer = require("neominimap.buffer")
        local handlers = require("neominimap.map.handlers").get_handlers()
        for _, handler in ipairs(handlers) do
            buffer.apply_handler(bufnr, handler.name)
        end
    end)
end

return M
