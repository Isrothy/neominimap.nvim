local M = {}

local api = vim.api
local config = require("neominimap.config").get()
local util = require("neominimap.util")
local logger = require("neominimap.logger")
local extensions = require("neominimap.map.extensions")
local diagnostic = require("neominimap.map.extensions.diagnostic")
local treesitter = require("neominimap.map.treesitter")
local text = require("neominimap.map.text")

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
    local filetype = vim.bo[bufnr].filetype
    local buftype = vim.bo[bufnr].buftype

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

--- Create the minimap attached to the given buffer if possible
--- Remove minimap buffer if there is already one
--- @param bufnr integer
--- @return integer mbufnr bufnr of the minimap buffer if created, nil otherwise
M.create_minimap_buffer = function(bufnr)
    logger.log(string.format("Starting to generate minimap for buffer %d", bufnr), vim.log.levels.TRACE)
    local mbufnr = util.noautocmd(function()
        return api.nvim_create_buf(false, true)
    end)()
    logger.log(string.format("Created a new buffer %d for minimap of buffer %d", mbufnr, bufnr), vim.log.levels.TRACE)
    M.set_minimap_bufnr(bufnr, mbufnr)

    vim.bo[mbufnr].buftype = "nofile"
    vim.bo[mbufnr].swapfile = false
    vim.bo[mbufnr].bufhidden = "hide"

    vim.b[bufnr].update_minimap_text = util.debounce(
        vim.schedule_wrap(function()
            logger.log(string.format("Generating minimap for buffer %d", bufnr), vim.log.levels.TRACE)

            logger.log(string.format("Getting lines for buffer %d", bufnr), vim.log.levels.TRACE)
            local lines = api.nvim_buf_get_lines(bufnr, 0, -1, false)

            local tabwidth = vim.bo[bufnr].tabstop

            logger.log(string.format("Generating minimap text for buffer %d", bufnr), vim.log.levels.TRACE)
            local minimap = text.gen(lines, tabwidth)

            vim.bo[mbufnr].modifiable = true

            logger.log(string.format("Setting lines for buffer %d", mbufnr), vim.log.levels.TRACE)
            util.noautocmd(api.nvim_buf_set_lines)(mbufnr, 0, -1, true, minimap)
            logger.log(string.format("Minimap for buffer %d generated successfully", bufnr), vim.log.levels.TRACE)

            vim.bo[mbufnr].modifiable = false

            vim.api.nvim_exec_autocmds("User", {
                group = "Neominimap",
                pattern = "BufferTextUpdated",
                data = {
                    buf = bufnr,
                },
            })

            if config.treesitter.enabled then
                logger.log(
                    string.format("Generating treesitter diagnostics for buffer %d", bufnr),
                    vim.log.levels.TRACE
                )
                local highlights = treesitter.extract_ts_highlights(bufnr)
                if highlights then
                    treesitter.apply(mbufnr, highlights)
                end
                logger.log(
                    string.format("Treesitter diagnostics for buffer %d generated successfully", bufnr),
                    vim.log.levels.TRACE
                )
            end
        end),
        config.delay
    )

    vim.b[bufnr].update_diagnostic = util.debounce(
        vim.schedule_wrap(function()
            logger.log(string.format("Generating diagnostics for buffer %d", bufnr), vim.log.levels.TRACE)
            extensions.apply(mbufnr, diagnostic.namespace, diagnostic.get_decorations(bufnr))
            logger.log(string.format("Diagnostics for buffer %d generated successfully", bufnr), vim.log.levels.TRACE)
        end),
        config.delay
    )

    logger.log(string.format("Minimap for buffer %d generated successfully", bufnr), vim.log.levels.TRACE)
    return mbufnr
end

---@param bufnr integer
M.update_text = function(bufnr)
    if api.nvim_buf_is_valid(bufnr) and vim.b[bufnr].update_minimap_text then
        vim.b[bufnr].update_minimap_text()
    end
end

---@param bufnr integer
M.update_diagnostics = function(bufnr)
    if api.nvim_buf_is_valid(bufnr) and vim.b[bufnr].update_diagnostic then
        vim.b[bufnr].update_diagnostic()
    end
end

--- Refresh the minimap attached to the given buffer if possible
--- Remove a buffer that is attached to it
--- @param bufnr integer
--- @return integer? mbufnr bufnr of the minimap buffer if created, nil otherwise
M.refresh_minimap_buffer = function(bufnr)
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

    M.update_text(bufnr)

    logger.log(string.format("Minimap for buffer %d refreshed successfully", bufnr), vim.log.levels.TRACE)
    return mbufnr
end

--- Remove the minimap attached to the given buffer
--- @param bufnr integer
--- @return integer? mbufnr bufnr of the minimap buffer if successfully removed, nil otherwise
M.delete_minimap_buffer = function(bufnr)
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
    util.noautocmd(api.nvim_buf_delete)(mbufnr, { force = true })
    logger.log(
        string.format("Minimap buffer %d for buffer %d deleted successfully", mbufnr, bufnr),
        vim.log.levels.TRACE
    )
    M.set_minimap_bufnr(bufnr, nil)
    return bufnr
end

M.update_all_diagnostics = function()
    logger.log("Updating all diagnostics", vim.log.levels.TRACE)
    local buffer_list = api.nvim_list_bufs()
    for _, bufnr in ipairs(buffer_list) do
        logger.log(string.format("Updating diagnostics for buffer %d", bufnr), vim.log.levels.TRACE)
        M.update_diagnostics(bufnr)
    end
    logger.log("All diagnostics updated", vim.log.levels.TRACE)
end

M.refresh_all_minimap_buffers = function()
    logger.log("Refreshing all minimap buffers", vim.log.levels.TRACE)
    local buffer_list = api.nvim_list_bufs()
    for _, bufnr in ipairs(buffer_list) do
        logger.log(string.format("Refreshing minimap for buffer %d", bufnr), vim.log.levels.TRACE)
        M.refresh_minimap_buffer(bufnr)
    end
    logger.log("All minimap buffers refreshed", vim.log.levels.TRACE)
end

M.delete_all_minimap_buffers = function()
    logger.log("Wiping out all minimap buffers", vim.log.levels.TRACE)
    local buffer_list = M.list_buffers()
    for _, bufnr in ipairs(buffer_list) do
        logger.log(string.format("Wiping out minimap for buffer %d", bufnr), vim.log.levels.TRACE)
        M.delete_minimap_buffer(bufnr)
    end
    logger.log("All minimap buffers wiped out", vim.log.levels.TRACE)
end

return M
