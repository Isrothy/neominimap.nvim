local M = {}

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
M.is_white_space = function(code)
    return vim.tbl_contains(whitespace, code)
end

---@param code integer
---@return boolean
M.is_tab = function(code)
    return code == 0x09
end

---@param code integer
---@return boolean
M.is_fullwidth = function(code)
    return (code >= 0x4E00 and code <= 0x9FFF)
        or (code >= 0x3400 and code <= 0x4DBF)
        or (code >= 0xF900 and code <= 0xFAFF)
        or (code >= 0xFF00 and code <= 0xFFEF)
        or (code >= 0xAC00 and code <= 0xD7AF)
end

---@param code integer
---@return boolean
M.is_combining_character = function(code)
    return (code >= 0x0300 and code <= 0x036F)
        or (code >= 0x1DC0 and code <= 0x1DFF)
        or (code >= 0x20D0 and code <= 0x20FF)
        or (code >= 0xFE20 and code <= 0xFE2F)
end

return M
