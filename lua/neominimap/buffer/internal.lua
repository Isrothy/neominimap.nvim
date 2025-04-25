local M = {}

local api = vim.api
local config = require("neominimap.config")

local default_bufopt = {
    buftype = "nofile",
    filetype = "neominimap",
    swapfile = false,
    bufhidden = "hide",
    undolevels = -1,
    modifiable = false,
}

---@param opt vim.bo
---@param bufnr integer
local set_bufopt = function(opt, bufnr)
    for k, v in pairs(default_bufopt) do
        opt[k] = v
    end
    config.bufopt(opt, bufnr)
end

local noautocmd = require("neominimap.util").noautocmd
M.empty_buffer = noautocmd(api.nvim_create_buf)(false, true)
noautocmd(api.nvim_buf_set_lines)(M.empty_buffer, 0, -1, true, {})
for k, v in pairs(default_bufopt) do
    vim.bo[M.empty_buffer][k] = v
end

---@param bufnr integer
---@return boolean
M.should_generate_minimap = function(bufnr)
    local logger = require("neominimap.logger")
    local var = require("neominimap.variables")
    local filetype = vim.bo[bufnr].filetype
    local buftype = vim.bo[bufnr].buftype
    if not var.g.enabled then
        logger.log.trace("Neominimap is disabled. Skipping generation of minimap for buffer %d", bufnr)
        return false
    end
    if not var.b[bufnr].enabled then
        logger.log.trace("Buffer %d is not enabled. Skipping generation of minimap", bufnr)
        return false
    end
    if vim.tbl_contains(config.exclude_buftypes, buftype) then
        logger.log.trace("Buffer %d should not generate minimap due to its type %s", bufnr, buftype)
        return false
    end
    if vim.tbl_contains(config.exclude_filetypes, filetype) then
        logger.log.trace("Buffer %d should not generate minimap due to its filetype %s", bufnr, filetype)
        return false
    end
    if not config.buf_filter(bufnr) then
        logger.log.trace("Buffer %d should not generate minimap due to buf_filter", bufnr)
        return false
    end

    logger.log.trace("Buffer %d should generate minimap", bufnr)
    return true
end

---@async
---@param bufnr integer
M.internal_render_co = function(bufnr)
    local logger = require("neominimap.logger")
    local co_api = require("neominimap.cooperative.api")
    local co = require("neominimap.cooperative")
    logger.log.trace("Generating minimap for buffer %d", bufnr)
    local buffer_map = require("neominimap.buffer.buffer_map")
    local mbufnr_ = buffer_map.get_minimap_bufnr(bufnr)
    if not mbufnr_ or not api.nvim_buf_is_valid(mbufnr_) then
        logger.log.warn("Minimap buffer is not valid. Skipping generation of minimap.")
        return
    end

    logger.log.trace("Getting lines for buffer %d", bufnr)
    local lines = co_api.buf_get_lines_co(bufnr, 0, -1)

    if config.fold.enabled then
        logger.log.trace("Applying fold for buffer %d", bufnr)
        local fold = require("neominimap.map.fold")
        fold.cache_folds(bufnr)
        lines = fold.filter_folds(fold.get_cached_folds(bufnr), lines)
        logger.log.trace("Fold for buffer %d applied successfully", bufnr)
    end

    co.defer_co()

    local tabwidth = vim.bo[bufnr].tabstop

    logger.log.trace("Generating minimap text for buffer %d", bufnr)
    local text = require("neominimap.map.text")
    local minimap = text.gen_co(lines, tabwidth)

    co.defer_co()

    vim.bo[mbufnr_].modifiable = true

    logger.log.trace("Setting lines for buffer %d", mbufnr_)
    co_api.buf_set_lines_co(mbufnr_, 0, -1, minimap)
    logger.log.trace("Minimap for buffer %d generated successfully", bufnr)

    vim.bo[mbufnr_].modifiable = false

    co.defer_co()

    vim.api.nvim_exec_autocmds("User", {
        group = "Neominimap",
        pattern = "MinimapBufferTextUpdated",
        data = {
            buffer = bufnr,
        },
    })

    if config.treesitter.enabled then
        logger.log.trace("Generating treesitter diagnostics for buffer %d", bufnr)
        local treesitter = require("neominimap.map.treesitter")
        local highlights = treesitter.extract_highlights_co(bufnr)

        co.defer_co()

        treesitter.apply_co(mbufnr_, highlights)
        logger.log.trace("Treesitter diagnostics for buffer %d generated successfully", bufnr)
    end
end

--- Create the minimap attached to the given buffer if possible
--- Remove minimap buffer if there is already one
--- @param bufnr integer
--- @return integer mbufnr bufnr of the minimap buffer if created, nil otherwise
M.create_minimap_buffer = function(bufnr)
    local logger = require("neominimap.logger")
    logger.log.trace("Starting to generate minimap for buffer %d", bufnr)
    local util = require("neominimap.util")
    local mbufnr = util.noautocmd(function()
        return api.nvim_create_buf(false, true)
    end)()
    logger.log.trace("Created a new buffer %d for minimap of buffer %d", mbufnr, bufnr)

    local buffer_map = require("neominimap.buffer.buffer_map")
    buffer_map.set_minimap_bufnr(bufnr, mbufnr)

    set_bufopt(vim.bo[mbufnr], bufnr)

    local var = require("neominimap.variables")

    local worker = nil ---@type thread?
    var.b[bufnr].render = util.debounce(
        vim.schedule_wrap(function()
            if not api.nvim_buf_is_valid(bufnr) then
                return
            end
            local thread_table = require("neominimap.cooperative.thread_table")
            if worker and coroutine.status(worker) ~= "dead" then
                thread_table[worker] = nil
            end
            worker = coroutine.create(function()
                M.internal_render_co(bufnr)
            end)
            thread_table[worker] = true
            require("neominimap.cooperative").resume(worker)
        end),
        config.delay
    )

    local handlers = require("neominimap.map.handlers")
    local fun_list = {} ---@type table<string, fun()>
    for _, handler in ipairs(handlers.get_handlers()) do
        fun_list[handler.name] = util.debounce(
            vim.schedule_wrap(function()
                if not api.nvim_buf_is_valid(bufnr) then
                    return
                end
                logger.log.trace("Applying %s for buffer %d", handler.name, bufnr)
                local mbufnr_ = buffer_map.get_minimap_bufnr(bufnr)
                if not mbufnr_ or not api.nvim_buf_is_valid(mbufnr_) then
                    logger.log.warn("Minimap buffer is not valid. Skipping generation of minimap.")
                    return
                end
                handlers.apply(bufnr, mbufnr_, handler.namespace, handler.get_annotations(bufnr), handler.mode)
                logger.log.trace("Diagnostics for buffer %d generated successfully", bufnr)
            end),
            config.delay
        )
    end
    var.b[bufnr].update_handler = fun_list

    logger.log.trace("Minimap for buffer %d generated successfully", bufnr)

    api.nvim_exec_autocmds("User", {
        group = "Neominimap",
        pattern = "MinimapBufferCreated",
        data = {
            buffer = bufnr,
        },
    })
    return mbufnr
end

---@param bufnr integer
M.render = function(bufnr)
    local var = require("neominimap.variables")
    if api.nvim_buf_is_valid(bufnr) and var.b[bufnr].enabled then
        var.b[bufnr].render()
    end
end

---@param bufnr integer
---@param handler_name string
M.apply_handler = function(bufnr, handler_name)
    local var = require("neominimap.variables")
    if api.nvim_buf_is_valid(bufnr) and var.b[bufnr].enabled then
        -- local logger = require("neominimap.logger")
        local fun = var.b[bufnr].update_handler[handler_name]
        if fun ~= nil then
            fun()
        end
    end
end

--- Refresh the minimap attached to the given buffer if possible
--- Remove a buffer that is attached to it
--- @param bufnr integer
--- @return integer? mbufnr bufnr of the minimap buffer if created, nil otherwise
M.refresh_minimap_buffer = function(bufnr)
    local logger = require("neominimap.logger")
    local buffer_map = require("neominimap.buffer.buffer_map")
    logger.log.trace("Attempting to refresh minimap for buffer %d", bufnr)
    if not api.nvim_buf_is_valid(bufnr) or not M.should_generate_minimap(bufnr) then
        if buffer_map.get_minimap_bufnr(bufnr) then
            logger.log.trace("Buffer %d is not valid or should not generate minimap. Deleting existing minimap.", bufnr)
            M.delete_minimap_buffer(bufnr)
        end
        return nil
    end
    local mbufnr = buffer_map.get_minimap_bufnr(bufnr) or M.create_minimap_buffer(bufnr)

    M.render(bufnr)

    logger.log.trace("Minimap for buffer %d refreshed successfully", bufnr)
    return mbufnr
end

--- Remove the minimap attached to the given buffer
--- @param bufnr integer
--- @return integer? mbufnr bufnr of the minimap buffer if successfully removed, nil otherwise
M.delete_minimap_buffer = function(bufnr)
    local logger = require("neominimap.logger")
    if not api.nvim_buf_is_valid(bufnr) then
        logger.log.warn("Buffer %d is not valid. Skipping deletion of minimap.", bufnr)
        return nil
    end
    local buffer_map = require("neominimap.buffer.buffer_map")
    local mbufnr = buffer_map.get_minimap_bufnr(bufnr)
    if not mbufnr then
        logger.log.trace("No minimap buffer found for buffer %d. Skipping deletion.", bufnr)
        return nil
    end
    logger.log.trace("Deleting minimap for buffer %d", bufnr)
    local util = require("neominimap.util")
    util.noautocmd(api.nvim_buf_delete)(mbufnr, { force = true })
    logger.log.trace("Minimap buffer %d for buffer %d deleted successfully", mbufnr, bufnr)
    buffer_map.set_minimap_bufnr(bufnr, nil)
    api.nvim_exec_autocmds("User", {
        group = "Neominimap",
        pattern = "MinimapBufferDeleted",
        data = {
            buffer = bufnr,
        },
    })
    return bufnr
end

M.refresh_all_minimap_buffers = function()
    local logger = require("neominimap.logger")
    logger.log.trace("Refreshing all minimap buffers")
    require("neominimap.util").for_all_buffers(M.refresh_minimap_buffer)
    logger.log.trace("All minimap buffers refreshed")
end

M.delete_all_minimap_buffers = function()
    local logger = require("neominimap.logger")
    logger.log.trace("Wiping out all minimap buffers")
    require("neominimap.util").for_all_buffers(M.delete_minimap_buffer)
    logger.log.trace("All minimap buffers wiped out")
end

return M
