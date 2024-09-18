local M = {}

---@return string
M.plugin_name = function()
    return "Neominimap"
end

---@param short boolean
---@return fun():string
local filename = function(short)
    return function()
        local buffer_map = require("neominimap.buffer.buffer_map")
        local mbufnr = vim.api.nvim_get_current_buf()
        local sbufnr = buffer_map.get_source_bufnr(mbufnr)
        if sbufnr == nil or not vim.api.nvim_buf_is_valid(sbufnr) then
            return ""
        end
        local name = vim.api.nvim_buf_get_name(sbufnr)
        if short then
            name = vim.fn.fnamemodify(name, ":t")
        end
        return name
    end
end

M.fullname = filename(false)

M.shortname = filename(true)

---@return string
M.position = function()
    local pos = vim.api.nvim_win_get_cursor(0)
    local row = pos[1]
    local col = pos[2] + 1
    local coord = require("neominimap.map.coord")
    local y, x = coord.mcodepoint_to_codepoint(row, col)
    return string.format("%d:%d", y, x)
end

M.lualine_default = {
    winbar = {},
    sections = {
        lualine_a = {
            M.plugin_name,
        },
        lualine_c = {
            M.shortname,
        },
        lualine_z = {
            M.position,
            "progress",
        },
    },
    filetypes = { "neominimap" },
}

return M
