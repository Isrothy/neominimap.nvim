local M = {}

---@class Neominimap.Variables.Tab
local t_default = {}

---@param tab integer
---@param name string
---@param value any
M.tab_set_var = function(tab, name, value)
    local tbl = vim.t[tab].neominimap_var
    if not tbl then
        tbl = vim.deepcopy(t_default)
    end
    tbl[name] = value
    vim.t[tab].neominimap_var = tbl
end

---@param tab integer
---@param name string
---@return any
M.tab_get_var = function(tab, name)
    if not vim.t[tab].neominimap_var then
        vim.t[tab].neominimap_var = {}
    end
    return vim.t[tab].neominimap_var[name]
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
