local api = vim.api

---@class Neominimap.Api.Tab.Handler
---@field refresh fun(tabid:integer)
---@field on fun(tabid:integer)
---@field off fun(tabid:integer)

---@param tabid integer
local function on(tabid)
    local var = require("neominimap.variables")
    var.t[tabid].enabled = true
    require("neominimap.window").get_tab_apis().on(tabid)
end

---@param tabid integer
local function off(tabid)
    local var = require("neominimap.variables")
    var.t[tabid].enabled = false
    require("neominimap.window").get_tab_apis().off(tabid)
end

---@param tabid integer
local function toggle(tabid)
    local var = require("neominimap.variables")
    if var.t[tabid].enabled then
        off(tabid)
    else
        on(tabid)
    end
end

---@param tabid integer
local function refresh(tabid)
    require("neominimap.window").get_tab_apis().refresh(tabid)
end

---@param tab_list table
---@return boolean
---@return string?
local valid_tab_list = function(tab_list)
    local is_valid, err = require("neominimap.api.util").validate_list_of_integers(tab_list)
    if not is_valid then
        return false, err
    end
    for _, tabid in ipairs(tab_list) do
        if not api.nvim_tabpage_is_valid(tabid) then
            return false, string.format("Tab %d is not valid.", tabid)
        end
    end
    return true
end

---@param func fun(tabid:integer)
---@return fun(tab_list:integer|integer[]|nil)
local wrap_tab_function = function(func)
    return function(tab_list)
        if tab_list == nil then
            tab_list = { api.nvim_get_current_tabpage() }
        elseif type(tab_list) ~= "table" then
            tab_list = { tab_list }
        end
        local is_valid, err = valid_tab_list(tab_list)
        if not is_valid then
            error(err)
        end
        vim.tbl_map(func, tab_list)
    end
end

return {
    on = wrap_tab_function(on),
    off = wrap_tab_function(off),
    toggle = wrap_tab_function(toggle),
    refresh = wrap_tab_function(refresh),
}
