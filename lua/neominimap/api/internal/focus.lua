local api = vim.api

---@class Neominimap.Api.Focus.Handler
---@field focus fun(winid:integer)
---@field unfocus fun(mwinid:integer)
---@field toggle_focus fun(winid:integer)

local M = {}

M.enable = function()
    local winid = api.nvim_get_current_win()
    require("neominimap.window").get_focus_apis().focus(winid)
end

M.disable = function()
    local winid = api.nvim_get_current_win()
    require("neominimap.window").get_focus_apis().unfocus(winid)
end

M.toggle = function()
    local winid = api.nvim_get_current_win()
    require("neominimap.window").get_focus_apis().toggle_focus(winid)
end

return M
