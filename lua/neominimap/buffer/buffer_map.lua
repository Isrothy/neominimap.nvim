-- A map of buffer number to minimap buffer number

local M = {}

local api = vim.api

---@type table<integer, integer>
local bufnr_to_mbufnr = {}

--- The buffer number of which the given minimap buffer is attached
---@param mbufnr integer
---@return integer?
M.get_source_bufnr = function(mbufnr)
    for bufnr, mbufnr_ in pairs(bufnr_to_mbufnr) do
        if mbufnr_ == mbufnr then
            return bufnr
        end
    end
    return nil
end

--- Return the minimap buffer number attached to the given buffer
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

--- Set the minimap buffer number attached to the given buffer
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

return M
