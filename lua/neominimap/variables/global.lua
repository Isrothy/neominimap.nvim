local M = {}

---@class Neominimap.Variables.Global
local g_default = {
    enabled = false, ---@type boolean Enable minimap globally
}

vim.g.neominimap_var = vim.deepcopy(g_default)

---@param name string
---@param value any
M.set_var = function(name, value)
    -- local logger = require("neominimap.logger")
    -- logger.log(string.format("Setting variable %s to %s", name, tostring(value)), vim.log.levels.DEBUG)
    local tbl = vim.g.neominimap_var
    tbl[name] = value
    vim.g.neominimap_var = tbl
end

---@param name string
---@return any
M.get_var = function(name)
    -- local logger = require("neominimap.logger")
    -- logger.log(string.format("Getting variable %s", name), vim.log.levels.DEBUG)
    -- logger.log(string.format("Variable %s is %s", name, tostring(vim.g.neominimap_var[name])), vim.log.levels.DEBUG)
    return vim.g.neominimap_var[name]
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
