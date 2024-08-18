local M = {}

---@class Neominimap.Variables.Buffer
local buffer_default = {
    enabled = true, ---@type boolean Enable minimap for this buffer.
    render = function() end, ---@type fun() Render minimap for this buffer. Genarate text and TreeSitter highlights.
    update_diagnostic = function() end, ---@type fun()
    update_git = function() end, ---@type fun()
    update_search = function() end, ---@type fun()
    cached_folds = {}, ---@type Neominimap.Fold[]
}

---@param name string
---@return string
local prefixed = function(name)
    return "neominimap_" .. name
end

---@param buffer integer
---@param name string
---@param value any
M.buf_set_var = function(buffer, name, value)
    vim.b[buffer][prefixed(name)] = value
end

---@param buffer integer
---@param name string
---@return any
M.buf_get_var = function(buffer, name)
    local prefixed_name = prefixed(name)
    if vim.b[buffer][prefixed_name] == nil then
        vim.b[buffer][prefixed_name] = buffer_default[name]
    end
    return vim.b[buffer][prefixed_name]
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
