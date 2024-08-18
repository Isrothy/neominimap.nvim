local M = {}

---@class Neominimap.Variables.Global
local g_default = {
    enabled = false, ---@type boolean Enable minimap globally
}

vim.g.neominimap_var = g_default

---@param name string
---@param value any
M.set_var = function(name, value)
    vim.g.neominmap_var[name] = value
end

---@param name string
---@return any
M.get_var = function(name)
    return vim.g.neominmap_var[name]
end

---@type Neominimap.Variables.Global
M.g = setmetatable({}, {
    __index = function(_, key)
        return M.get_var(key)
    end,
    __newindex = function(_, key, value)
        M.set_var(key, value)
    end,
})

return M
