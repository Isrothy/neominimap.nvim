local M = {}

local api = vim.api

--- Replace tabs with spaces
---@param str string
---@param tabwidth integer
---@return string
M.replace_tabs = function(str, tabwidth)
    -- TODO: do this function
end

--- Generate minimap text for the buffer
--- @param bufnr integer
--- @return string[]
M.gen = function(bufnr)
    local lines = api.nvim_buf_get_lines(bufnr, 0, -1, true)
    -- TODO: replace this dummy function
    return lines
end

return M
