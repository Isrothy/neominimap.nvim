local M = {}

local config = require("neominimap.config")

---@class Neominimap.Variables.Global
local global_default = {
    enabled = config.auto_enable, ---@type boolean Enable minimap globally
}

vim.g.neominimap_var = vim.deepcopy(global_default)

---@param name string
---@return string
local prefixed = function(name)
    return "neominimap_" .. name
end

---@param name string
---@param value any
M.set_var = function(name, value)
    vim.g[prefixed(name)] = value
end

---@param name string
---@return any
M.get_var = function(name)
    local prefixed_name = prefixed(name)
    if vim.g[prefixed_name] == nil then
        vim.g[prefixed_name] = global_default[name]
    end
    return vim.g[prefixed_name]
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
