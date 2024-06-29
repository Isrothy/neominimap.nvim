local M = {}

local api = vim.api

local logger = require("neominimap.logger")

local whitespace = {
    0x9,
    0xA,
    0xB,
    0xC,
    0xD,
    0x20,
    0x85,
    0xA0,
    0x1680,
    0x2000,
    0x2001,
}

---@param code integer
---@return boolean
local is_white_space = function(code)
    return vim.tbl_contains(whitespace, code)
end

---@param code integer
---@return boolean
local is_tab = function(code)
    return code == 0x09
end

---@param code integer
---@return boolean
local is_fullwidth = function(code)
    return (code >= 0x4E00 and code <= 0x9FFF)
        or (code >= 0x3400 and code <= 0x4DBF)
        or (code >= 0xF900 and code <= 0xFAFF)
        or (code >= 0xFF00 and code <= 0xFFEF)
        or (code >= 0xAC00 and code <= 0xD7AF)
end

---@param code integer
---@return boolean
local function is_combining_character(code)
    return (code >= 0x0300 and code <= 0x036F)
        or (code >= 0x1DC0 and code <= 0x1DFF)
        or (code >= 0x20D0 and code <= 0x20FF)
        or (code >= 0xFE20 and code <= 0xFE2F)
end

--- Convert string to a list of view points of visible characters
---@param str string
---@param tabwidth integer
---@return integer[]
M.to_view_points = function(str, tabwidth)
    local view_points = {}
    local col = 0
    local char_list = vim.fn.str2list(str)
    for _, code in ipairs(char_list) do
        if is_tab(code) then
            local spaces_to_add = tabwidth - (col % tabwidth)
            col = col + spaces_to_add
        elseif is_white_space(code) then
            col = col + 1
        elseif is_fullwidth(code) then
            table.insert(view_points, col + 1)
            table.insert(view_points, col + 2)
            col = col + 2
        elseif not is_combining_character(code) then
            table.insert(view_points, col + 1)
            col = col + 1
        end
    end
    return view_points
end

--- Generate minimap text for the buffer
--- @param bufnr integer
--- @return string[]
M.gen = function(bufnr)
    local lines = api.nvim_buf_get_lines(bufnr, 0, -1, true)
    local tabwidth = vim.bo[bufnr].tabstop
    -- TODO: replace this dummy function
    return lines
end

if vim.g.testing then
    M.is_white_space = is_white_space
    M.is_tab = is_tab
    M.is_fullwidth = is_fullwidth
    M.is_combining_character = is_combining_character
end

return M
