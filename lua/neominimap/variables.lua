-- A wrapper around vim.g, vim.b, vim.w and vim.t
-- Facilitates better integration with static analysis tools

---@class Neominimap.VariableManager
---@field scope table The scope (`vim.b`, `vim.t`, `vim.w` or `vim.g`).
---@field default table The default values for variables in this scope.

local VariableManager = {}
VariableManager.__index = VariableManager

---@param name string
---@return string
local function prefixed_name(name)
    return "neominimap_" .. name
end

---@param scope table
---@param default table
function VariableManager.new(scope, default)
    return setmetatable({
        scope = scope,
        default = default,
    }, VariableManager)
end

---@param id integer?
---@param name string
---@param value any
function VariableManager:set_var(id, name, value)
    local key = prefixed_name(name)
    local scope = id == nil and self.scope or self.scope[id]
    scope[key] = value
end

---@param id integer?
---@param name string
---@return any
function VariableManager:get_var(id, name)
    local key = prefixed_name(name)
    local scope = id == nil and self.scope or self.scope[id]
    if scope[key] == nil then
        scope[key] = self.default[name]
    end
    return scope[key]
end

---@param id integer
---@return table
function VariableManager:get_instance(id)
    return setmetatable({}, {
        __index = function(_, k)
            return self:get_var(id, k)
        end,
        __newindex = function(_, k, v)
            self:set_var(id, k, v)
        end,
    })
end

---@return table
function VariableManager:global_table()
    return setmetatable({}, {
        __index = function(_, k)
            if type(k) == "number" then
                return self:get_instance(k)
            else
                return self:get_var(nil, k)
            end
        end,
        __newindex = function(_, k, v)
            self:set_var(nil, k, v)
        end,
    })
end

---@class Neominimap.Variables.Global
local global_default = {
    enabled = require("neominimap.config").auto_enable, ---@type boolean Enable minimap globally
}

---@class Neominimap.Variables.Buffer
local buffer_default = {
    enabled = true, ---@type boolean Enable minimap for this buffer.
    render = function() end, ---@type fun() Render minimap for this buffer. Genarate text and TreeSitter highlights.
    update_handler = {}, ---@type table<string, fun()>
    cached_folds = {}, ---@type Neominimap.Fold[]
}

---@class Neominimap.Variables.Window
local window_default = {
    enabled = true, ---@type boolean Enable minimap for this window.
}

---@class Neominimap.Variables.Tabpage
local tabpage_default = {
    enabled = true, ---@type boolean Enable minimap for this tab.
}

local global = VariableManager.new(vim.g, global_default)
local buffer = VariableManager.new(vim.b, buffer_default)
local window = VariableManager.new(vim.w, window_default)
local tabpage = VariableManager.new(vim.t, tabpage_default)

return {
    g = global:global_table(),
    b = buffer:global_table(),
    w = window:global_table(),
    t = tabpage:global_table(),

    --- Set a global variable
    ---@type fun(name:string, value:any)
    set_var = function(name, value)
        global:set_var(nil, name, value)
    end,

    --- Get a global variable
    ---@type fun(name:string):any
    get_var = function(name)
        return global:get_var(nil, name)
    end,

    --- Set a buffer-scoped variable
    ---@type fun(buffer:integer, name:string, value:any)
    buffer_set_var = buffer.set_var,

    --- Get a buffer-scoped variable
    ---@type fun(buffer:integer, name:string):any
    buffer_get_var = buffer.get_var,

    --- Set a window-scoped variable
    ---@type fun(window:integer, name:string, value:any)
    window_set_var = window.set_var,

    --- Get a window-scoped variable
    ---@type fun(window:integer, name:string):any
    window_get_var = window.get_var,

    --- Set a tab-scoped variable
    ---@type fun(tab:integer, name:string, value:any)
    tab_set_var = tabpage.set_var,

    --- Get a tab-scoped variable
    ---@type fun(tab:integer, name:string):any
    tab_get_var = tabpage.get_var,
}
