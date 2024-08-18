local M = {}

---@class Neominimap.Variables.Tab
local tab_default = {}

---@param name string
---@return string
local prefixed = function(name)
    return "neominimap_" .. name
end

---@param tab integer
---@param name string
---@param value any
M.tab_set_var = function(tab, name, value)
    vim.t[tab][prefixed(name)] = value
end

---@param tab integer
---@param name string
---@return any
M.tab_get_var = function(tab, name)
    local prefixed_name = prefixed(name)
    if vim.t[tab][prefixed_name] == nil then
        vim.t[tab][prefixed_name] = tab_default[name]
    end
    return vim.t[tab][prefixed_name]
end

---@param tab integer
---@return Neominimap.Variables.Tab
local get_t = function(tab)
    return setmetatable({}, {
        __index = function(_, k)
            return M.tab_get_var(tab, k)
        end,
        __newindex = function(_, k, v)
            M.tab_set_var(tab, k, v)
        end,
    })
end

---@type table<integer, Neominimap.Variables.Tab> | Neominimap.Variables.Tab
M.t = setmetatable({}, {
    __index = function(_, k)
        if type(k) == "number" then
            return get_t(k)
        else
            return M.tab_get_var(0, k)
        end
    end,
    __newindex = function(_, k, v)
        M.tab_set_var(0, k, v)
    end,
})

return M
