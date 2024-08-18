local M = {}

---@class Neominimap.Variables.Buffer
local b_default = {
    enabled = true, ---@type boolean Enable minimap for this buffer
}

---@param buffer integer
---@param name string
---@param value any
M.buf_set_var = function(buffer, name, value)
    local tbl = vim.b[buffer].neominimap_var
    if not tbl then
        vim.b[buffer].neominimap_var = vim.deepcopy(b_default)
    end
    tbl[name] = value
    vim.b[buffer].neominimap_var = tbl
end

---@param buffer integer
---@param name string
---@return any
M.buf_get_var = function(buffer, name)
    if not vim.b[buffer].neominimap_var then
        vim.b[buffer].neominimap_var = vim.deepcopy(b_default)
    end
    return vim.b[buffer].neominimap_var[name]
end

---@param buffer integer
---@return Neominimap.Variables.Buffer
local get_n = function(buffer)
    return setmetatable({}, {
        __index = function(_, k)
            return M.buf_get_var(buffer, k)
        end,
        __newindex = function(_, k, v)
            M.buf_set_var(buffer, k, v) -- Use the specific buffer here
        end,
    })
end

---@type table<integer, Neominimap.Variables.Buffer> | Neominimap.Variables.Buffer
M.b = setmetatable({}, {
    __index = function(_, k)
        if type(k) == "number" then
            return get_n(k)
        else
            return M.buf_get_var(0, k)
        end
    end,
    __newindex = function(_, k, v)
        M.buf_set_var(0, k, v)
    end,
})

return M
