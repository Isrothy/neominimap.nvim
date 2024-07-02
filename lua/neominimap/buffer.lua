local M = {}

local api = vim.api
local config = require("neominimap.config").get()
local util = require("neominimap.util")
local logger = require("neominimap.logger")

---@type table<integer, integer>
local bufnr_to_mbufnr = {}

--- The winid of the minimap attached to the given window
---@param bufnr integer
---@return integer?
M.get_minimap_bufnr = function(bufnr)
    return bufnr_to_mbufnr[bufnr]
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
    if config.max_lines and api.nvim_buf_line_count(bufnr) > config.max_lines then
        logger.log(
            string.format("Buffer %d should not generate minimap due to its line count", bufnr),
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
    local ret = util.noautocmd(function()
        logger.log(string.format("Starting to generate minimap for buffer %d", bufnr), vim.log.levels.TRACE)
        local mbufnr = api.nvim_create_buf(false, true)
        logger.log(
            string.format("Created a new buffer %d for minimap of buffer %d", mbufnr, bufnr),
            vim.log.levels.TRACE
        )
        M.set_minimap_bufnr(bufnr, mbufnr)

        vim.bo[mbufnr].buftype = "nofile"
        vim.bo[mbufnr].swapfile = false
        vim.bo[mbufnr].bufhidden = "hide"

        logger.log(string.format("Minimap for buffer %d generated successfully", bufnr), vim.log.levels.TRACE)
        return mbufnr
    end)()
    return ret
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
            M.wipe_out_minimap_buffer(bufnr)
        end
        return nil
    end
    local mbufnr = M.get_minimap_bufnr(bufnr)
    if not mbufnr then
        mbufnr = M.create_minimap_buffer(bufnr)
    end

    local minimap = require("neominimap.map.text").gen(bufnr)
    vim.bo[mbufnr].modifiable = true
    util.noautocmd(api.nvim_buf_set_lines)(mbufnr, 0, -1, true, minimap)
    vim.bo[mbufnr].modifiable = false

    logger.log(string.format("Minimap for buffer %d refreshed successfully", bufnr), vim.log.levels.TRACE)
    return mbufnr
end

--- Remove the minimap attached to the given buffer
--- @param bufnr integer
--- @return integer? mbufnr bufnr of the minimap buffer if successfully removed, nil otherwise
M.wipe_out_minimap_buffer = function(bufnr)
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

M.refresh_all_minimap_buffers = function()
    logger.log("Refreshing all minimap buffers", vim.log.levels.TRACE)
    local buffer_list = api.nvim_list_bufs()
    for _, bufnr in ipairs(buffer_list) do
        logger.log(string.format("Refreshing minimap for buffer %d", bufnr), vim.log.levels.TRACE)
        M.refresh_minimap_buffer(bufnr)
    end
    logger.log("All minimap buffers refreshed", vim.log.levels.TRACE)
end

M.wipe_out_all_minimap_buffers = function()
    logger.log("Wiping out all minimap buffers", vim.log.levels.TRACE)
    local buffer_list = M.list_buffers()
    for _, bufnr in ipairs(buffer_list) do
        logger.log(string.format("Wiping out minimap for buffer %d", bufnr), vim.log.levels.TRACE)
        M.wipe_out_minimap_buffer(bufnr)
    end
    logger.log("All minimap buffers wiped out", vim.log.levels.TRACE)
end

return M
