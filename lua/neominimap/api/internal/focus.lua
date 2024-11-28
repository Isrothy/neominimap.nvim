local api = vim.api

---@class Neominimap.Api.Focus.Handler
---@field focus fun(winid:integer)
---@field unfocus fun(mwinid:integer)
---@field toggle_focus fun(winid:integer)

local M = {}

M.focus = function()
    local winid = api.nvim_get_current_win()
    require("neominimap.window").get_focus_apis().focus(winid)
end

M.unfocus = function()
    local winid = api.nvim_get_current_win()
    require("neominimap.window").get_focus_apis().unfocus(winid)
end

M.toggle_focus = function()
    local winid = api.nvim_get_current_win()
    require("neominimap.window").get_focus_apis().toggle_focus(winid)
end

return M
