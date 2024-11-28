---@class Neominimap.Api.Win.Handler
---@field refresh fun(winid:integer)
---@field enable fun(winid:integer)
---@field disable fun(winid:integer)

---@param winid integer
local enable = function(winid)
    local var = require("neominimap.variables")
    var.w[winid].enabled = true
    require("neominimap.window").get_win_apis().enable(winid)
end

---@param winid integer
local disable = function(winid)
    local var = require("neominimap.variables")
    var.w[winid].enabled = false
    require("neominimap.window").get_win_apis().disable(winid)
end

---@param winid integer
local toggle = function(winid)
    local var = require("neominimap.variables")
    if var.w[winid].enabled then
        disable(winid)
    else
        enable(winid)
    end
end

---@param winid integer
local function refresh(winid)
    require("neominimap.window").get_win_apis().refresh(winid)
end

---@param win_list table
---@return boolean
---@return string?
local validate_win_list = function(win_list)
    local is_valid, err = require("neominimap.api.util").validate_list_of_integers(win_list)
    if not is_valid then
        return false, err
    end
    for _, winid in ipairs(win_list) do
        if not vim.api.nvim_win_is_valid(winid) then
            return false, string.format("Window %d is not valid.", winid)
        end
    end
    return true
end

---@param func fun(winid:integer)
---@return fun(win_list:integer|integer[]|nil)
local wrap_win_function = function(func)
    return function(win_list)
        if win_list == nil then
            win_list = { vim.api.nvim_get_current_win() }
        elseif type(win_list) ~= "table" then
            win_list = { win_list }
        end
        local is_valid, err = validate_win_list(win_list)
        if not is_valid then
            error(err)
        end
        vim.tbl_map(func, win_list)
    end
end

return {
    enable = wrap_win_function(enable),
    disable = wrap_win_function(disable),
    toggle = wrap_win_function(toggle),
    refresh = wrap_win_function(refresh),
}
