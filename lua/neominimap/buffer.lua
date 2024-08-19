local M = {}

local api = vim.api
local config = require("neominimap.config").get()

---@type table<integer, integer>
local bufnr_to_mbufnr = {}

--- The winid of the minimap attached to the given window
---@param bufnr integer
---@return integer?
M.get_minimap_bufnr = function(bufnr)
    local mbufnr = bufnr_to_mbufnr[bufnr]
    if mbufnr ~= nil and not api.nvim_buf_is_valid(mbufnr) then
        bufnr_to_mbufnr[bufnr] = nil
        return nil
    end
    return mbufnr
end

--- Set the winid of the minimap attached to the given window
---@param bufnr integer
---@param mbufnr integer?
M.set_minimap_bufnr = function(bufnr, mbufnr)
    bufnr_to_mbufnr[bufnr] = mbufnr
end

--- Return the list of buffers that has a minimap buffer attached to
--- @return integer[]
M.list_buffers = function()
    return vim.tbl_keys(bufnr_to_mbufnr)
end

---@param bufnr integer
---@return boolean
M.should_generate_minimap = function(bufnr)
    local logger = require("neominimap.logger")
    local var = require("neominimap.variables")
    local filetype = vim.bo[bufnr].filetype
    local buftype = vim.bo[bufnr].buftype
    if not var.g.enabled then
        logger.log(
            string.format("Neominimap is disabled. Skipping generation of minimap for buffer %d", bufnr),
            vim.log.levels.TRACE
        )
        return false
    end
    if not var.b[bufnr].enabled then
        logger.log(
            string.format("Buffer %d is not enabled. Skipping generation of minimap", bufnr),
            vim.log.levels.TRACE
        )
        return false
    end
    if vim.tbl_contains(config.exclude_buftypes, buftype) then
        logger.log(
            string.format("Buffer %d should not generate minimap due to its type %s", bufnr, buftype),
            vim.log.levels.TRACE
        )
        return false
    end
    if vim.tbl_contains(config.exclude_filetypes, filetype) then
        logger.log(
            string.format("Buffer %d should not generate minimap due to its filetype %s", bufnr, filetype),
            vim.log.levels.TRACE
        )
        return false
    end
    if not config.buf_filter(bufnr) then
        logger.log(
            string.format("Buffer %d should not generate minimap due to buf_filter", bufnr),
            vim.log.levels.TRACE
        )
        return false
    end

    logger.log(string.format("Buffer %d should generate minimap", bufnr), vim.log.levels.TRACE)
    return true
end

---@param bufnr integer
M.internal_render = function(bufnr)
    local logger = require("neominimap.logger")
    logger.log(string.format("Generating minimap for buffer %d", bufnr), vim.log.levels.TRACE)
    local mbufnr_ = M.get_minimap_bufnr(bufnr)
    if not mbufnr_ or not api.nvim_buf_is_valid(mbufnr_) then
        logger.log(
            string.format("Minimap buffer %d is not valid. Skipping generation of minimap.", mbufnr_),
            vim.log.levels.WARN
        )
        return
    end

    logger.log(string.format("Getting lines for buffer %d", bufnr), vim.log.levels.TRACE)
    local lines = api.nvim_buf_get_lines(bufnr, 0, -1, false)

    if config.fold.enabled then
        logger.log(string.format("Applying fold for buffer %d", bufnr), vim.log.levels.TRACE)
        local fold = require("neominimap.map.fold")
        fold.cache_folds(bufnr)
        lines = fold.filter_folds(fold.get_cached_folds(bufnr), lines)
        logger.log(string.format("Fold for buffer %d applied successfully", bufnr), vim.log.levels.TRACE)
    end

    local tabwidth = vim.bo[bufnr].tabstop

    logger.log(string.format("Generating minimap text for buffer %d", bufnr), vim.log.levels.TRACE)
    local text = require("neominimap.map.text")
    local minimap = text.gen(lines, tabwidth)

    vim.bo[mbufnr_].modifiable = true

    logger.log(string.format("Setting lines for buffer %d", mbufnr_), vim.log.levels.TRACE)
    local util = require("neominimap.util")
    util.noautocmd(api.nvim_buf_set_lines)(mbufnr_, 0, -1, true, minimap)
    logger.log(string.format("Minimap for buffer %d generated successfully", bufnr), vim.log.levels.TRACE)

    vim.bo[mbufnr_].modifiable = false

    vim.api.nvim_exec_autocmds("User", {
        group = "Neominimap",
        pattern = "MinimapBufferTextUpdated",
        data = {
            buf = bufnr,
        },
    })

    if config.treesitter.enabled then
        logger.log(string.format("Generating treesitter diagnostics for buffer %d", bufnr), vim.log.levels.TRACE)
        local treesitter = require("neominimap.map.treesitter")
        local highlights = treesitter.extract_highlights(bufnr)
        treesitter.apply(mbufnr_, highlights)
        logger.log(
            string.format("Treesitter diagnostics for buffer %d generated successfully", bufnr),
            vim.log.levels.TRACE
        )
    end
end

--- Create the minimap attached to the given buffer if possible
--- Remove minimap buffer if there is already one
--- @param bufnr integer
--- @return integer mbufnr bufnr of the minimap buffer if created, nil otherwise
M.create_minimap_buffer = function(bufnr)
    local logger = require("neominimap.logger")
    logger.log(string.format("Starting to generate minimap for buffer %d", bufnr), vim.log.levels.TRACE)
    local util = require("neominimap.util")
    local mbufnr = util.noautocmd(function()
        return api.nvim_create_buf(false, true)
    end)()
    logger.log(string.format("Created a new buffer %d for minimap of buffer %d", mbufnr, bufnr), vim.log.levels.TRACE)
    M.set_minimap_bufnr(bufnr, mbufnr)

    local bufopt = {
        buftype = "nofile",
        filetype = "neominimap",
        swapfile = false,
        bufhidden = "hide",
        undolevels = -1,
    }

    config.bufopt(bufopt, bufnr)

    for k, v in pairs(bufopt) do
        vim.bo[mbufnr][k] = v
    end

    local var = require("neominimap.variables")

    var.b[bufnr].render = util.debounce(
        vim.schedule_wrap(function()
            M.internal_render(bufnr)
        end),
        config.delay
    )

    var.b[bufnr].update_diagnostic = util.debounce(
        vim.schedule_wrap(function()
            logger.log(string.format("Generating diagnostics for buffer %d", bufnr), vim.log.levels.TRACE)
            local mbufnr_ = M.get_minimap_bufnr(bufnr)
            if not mbufnr_ or not api.nvim_buf_is_valid(mbufnr_) then
                logger.log(
                    string.format("Minimap buffer is not valid. Skipping generation of minimap."),
                    vim.log.levels.WARN
                )
                return
            end
            local handlers = require("neominimap.map.handlers")
            local diagnostic = require("neominimap.map.handlers.diagnostic")
            handlers.apply(mbufnr_, diagnostic.namespace, diagnostic.get_marks(bufnr), config.diagnostic.mode)
            logger.log(string.format("Diagnostics for buffer %d generated successfully", bufnr), vim.log.levels.TRACE)
        end),
        config.delay
    )

    var.b[bufnr].update_git = util.debounce(
        vim.schedule_wrap(function()
            logger.log(string.format("Generating gitsigns for buffer %d", bufnr), vim.log.levels.TRACE)
            local mbufnr_ = M.get_minimap_bufnr(bufnr)
            if not mbufnr_ or not api.nvim_buf_is_valid(mbufnr_) then
                logger.log(
                    string.format("Minimap buffer is not valid. Skipping generation of minimap."),
                    vim.log.levels.WARN
                )
                return
            end
            local handlers = require("neominimap.map.handlers")
            local git = require("neominimap.map.handlers.git")
            handlers.apply(mbufnr_, git.namespace, git.get_marks(bufnr), config.git.mode)
            logger.log(string.format("Gitsigns for buffer %d generated successfully", bufnr), vim.log.levels.TRACE)
        end),
        config.delay
    )

    var.b[bufnr].update_search = util.debounce(
        vim.schedule_wrap(function()
            logger.log(string.format("Generating search for buffer %d", bufnr), vim.log.levels.TRACE)
            local mbufnr_ = M.get_minimap_bufnr(bufnr)
            if not mbufnr_ or not api.nvim_buf_is_valid(mbufnr_) then
                logger.log(
                    string.format("Minimap buffer is not valid. Skipping generation of minimap."),
                    vim.log.levels.WARN
                )
                return
            end
            local handlers = require("neominimap.map.handlers")
            local search = require("neominimap.map.handlers.search")
            handlers.apply(mbufnr_, search.namespace, search.get_marks(bufnr), config.search.mode)
            logger.log(string.format("Search for buffer %d generated successfully", bufnr), vim.log.levels.TRACE)
        end),
        config.delay
    )

    logger.log(string.format("Minimap for buffer %d generated successfully", bufnr), vim.log.levels.TRACE)

    api.nvim_exec_autocmds("User", {
        group = "Neominimap",
        pattern = "MinimapBufferCreated",
        data = {
            buf = bufnr,
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
M.update_diagnostics = function(bufnr)
    local var = require("neominimap.variables")
    if api.nvim_buf_is_valid(bufnr) and var.b[bufnr].enabled then
        var.b[bufnr].update_diagnostic()
    end
end

---@param bufnr integer
M.update_git = function(bufnr)
    local var = require("neominimap.variables")
    if api.nvim_buf_is_valid(bufnr) and var.b[bufnr].enabled then
        var.b[bufnr].update_git()
    end
end

---@param bufnr integer
M.update_search = function(bufnr)
    local var = require("neominimap.variables")
    if api.nvim_buf_is_valid(bufnr) and var.b[bufnr].enabled then
        var.b[bufnr].update_search()
    end
end

--- Refresh the minimap attached to the given buffer if possible
--- Remove a buffer that is attached to it
--- @param bufnr integer
--- @return integer? mbufnr bufnr of the minimap buffer if created, nil otherwise
M.refresh_minimap_buffer = function(bufnr)
    local logger = require("neominimap.logger")
    logger.log(string.format("Attempting to refresh minimap for buffer %d", bufnr), vim.log.levels.TRACE)
    if not api.nvim_buf_is_valid(bufnr) or not M.should_generate_minimap(bufnr) then
        if M.get_minimap_bufnr(bufnr) then
            logger.log(
                string.format(
                    "Buffer %d is not valid or should not generate minimap. Deleting existing minimap.",
                    bufnr
                ),
                vim.log.levels.TRACE
            )
            M.delete_minimap_buffer(bufnr)
        end
        return nil
    end
    local mbufnr = M.get_minimap_bufnr(bufnr) or M.create_minimap_buffer(bufnr)

    M.render(bufnr)

    logger.log(string.format("Minimap for buffer %d refreshed successfully", bufnr), vim.log.levels.TRACE)
    return mbufnr
end

--- Remove the minimap attached to the given buffer
--- @param bufnr integer
--- @return integer? mbufnr bufnr of the minimap buffer if successfully removed, nil otherwise
M.delete_minimap_buffer = function(bufnr)
    local logger = require("neominimap.logger")
    if not api.nvim_buf_is_valid(bufnr) then
        logger.log(string.format("Buffer %d is not valid. Skipping deletion of minimap.", bufnr), vim.log.levels.WARN)
        return nil
    end
    local mbufnr = M.get_minimap_bufnr(bufnr)
    if not mbufnr then
        logger.log(
            string.format("No minimap buffer found for buffer %d. Skipping deletion.", bufnr),
            vim.log.levels.TRACE
        )
        return nil
    end
    logger.log(string.format("Deleting minimap for buffer %d", bufnr), vim.log.levels.TRACE)
    local util = require("neominimap.util")
    util.noautocmd(api.nvim_buf_delete)(mbufnr, { force = true })
    logger.log(
        string.format("Minimap buffer %d for buffer %d deleted successfully", mbufnr, bufnr),
        vim.log.levels.TRACE
    )
    M.set_minimap_bufnr(bufnr, nil)
    api.nvim_exec_autocmds("User", {
        group = "Neominimap",
        pattern = "MinimapBufferDeleted",
        data = {
            buf = bufnr,
        },
    })
    return bufnr
end

M.update_all_diagnostics = function()
    local logger = require("neominimap.logger")
    logger.log("Updating all diagnostics", vim.log.levels.TRACE)
    local buffer_list = api.nvim_list_bufs()
    for _, bufnr in ipairs(buffer_list) do
        logger.log(string.format("Updating diagnostics for buffer %d", bufnr), vim.log.levels.TRACE)
        M.update_diagnostics(bufnr)
    end
    logger.log("All diagnostics updated", vim.log.levels.TRACE)
end

M.refresh_all_minimap_buffers = function()
    local logger = require("neominimap.logger")
    logger.log("Refreshing all minimap buffers", vim.log.levels.TRACE)
    local buffer_list = api.nvim_list_bufs()
    for _, bufnr in ipairs(buffer_list) do
        logger.log(string.format("Refreshing minimap for buffer %d", bufnr), vim.log.levels.TRACE)
        M.refresh_minimap_buffer(bufnr)
    end
    logger.log("All minimap buffers refreshed", vim.log.levels.TRACE)
end

M.delete_all_minimap_buffers = function()
    local logger = require("neominimap.logger")
    logger.log("Wiping out all minimap buffers", vim.log.levels.TRACE)
    local buffer_list = api.nvim_list_bufs()
    for _, bufnr in ipairs(buffer_list) do
        logger.log(string.format("Wiping out minimap for buffer %d", bufnr), vim.log.levels.TRACE)
        M.delete_minimap_buffer(bufnr)
    end
    logger.log("All minimap buffers wiped out", vim.log.levels.TRACE)
end

---@type Neominimap.Command.Buf.Handler
M.buf_cmds = {
    ["bufOn"] = vim.schedule_wrap(M.refresh_minimap_buffer),
    ["bufOff"] = vim.schedule_wrap(M.refresh_minimap_buffer),
    ["bufRefresh"] = vim.schedule_wrap(M.refresh_minimap_buffer),
}

---@type Neominimap.Command.Global.Handler
M.global_cmds = {
    ["on"] = vim.schedule_wrap(M.refresh_all_minimap_buffers),
    ["off"] = vim.schedule_wrap(M.refresh_all_minimap_buffers),
    ["refresh"] = vim.schedule_wrap(M.refresh_all_minimap_buffers),
}

M.create_git_autocmds = function()
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
                M.update_git(bufnr)
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
                M.update_git(bufnr)
                logger.log(string.format("Git signs refreshed for buffer %d.", bufnr), vim.log.levels.TRACE)
            end)
        end,
    })
end

M.create_diagnostic_autocmds = function()
    api.nvim_create_autocmd("DiagnosticChanged", {
        group = "Neominimap",
        desc = "Update diagnostic marks when diagnostics are changed",
        callback = function()
            local logger = require("neominimap.logger")
            logger.log("DiagnosticChanged event triggered.", vim.log.levels.TRACE)
            vim.schedule(function()
                logger.log("Updating diagnostics.", vim.log.levels.TRACE)
                M.update_all_diagnostics()
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
                M.update_diagnostics(bufnr)
                logger.log(string.format("Diagnostics refreshed for bufnr %d.", bufnr), vim.log.levels.TRACE)
            end)
        end,
    })
end

M.create_search_autocmds = function()
    api.nvim_create_autocmd("BufWinEnter", {
        group = "Neominimap",
        desc = "Update search marks when entering window",
        callback = function()
            local logger = require("neominimap.logger")
            logger.log("BufWinEnter event triggered.", vim.log.levels.TRACE)
            vim.schedule(function()
                local bufnr = api.nvim_get_current_buf()
                logger.log(string.format("Updating search status for buffer %d.", bufnr), vim.log.levels.TRACE)
                M.update_search(bufnr)
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
                M.update_search(bufnr)
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
                M.update_search(bufnr)
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
                    M.update_search(bufnr)
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
                M.refresh_minimap_buffer(bufnr)
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
                M.delete_minimap_buffer(bufnr)
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
                M.render(bufnr)
                logger.log(
                    string.format("Debounced text updating for buffer %d is called", bufnr),
                    vim.log.levels.TRACE
                )
            end)
        end,
    })

    if config.diagnostic.enabled then
        M.create_diagnostic_autocmds()
    end
    if config.git.enabled then
        M.create_git_autocmds()
    end
    if config.search.enabled then
        M.create_search_autocmds()
    end
end

return M
