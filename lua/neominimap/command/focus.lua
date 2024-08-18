local api = vim.api

---@class Neominimap.Command.Focus.Handler
---@field focus fun(winid:integer)
---@field unfocus fun(mwinid:integer)
---@field toggleFocus fun(winid:integer)

local M = {}

---@type table<string, Neominimap.Subcommand>
M.subcommand_tbl = {
    focus = {
        impl = function()
            local logger = require("neominimap.logger")
            logger.log("Command focus triggered.", vim.log.levels.INFO)

            local winid = api.nvim_get_current_win()
            require("neominimap.window").focus_cmds.focus(winid)
        end,
    },
    unfocus = {
        impl = function()
            local logger = require("neominimap.logger")
            logger.log("Command unfocus triggered.", vim.log.levels.INFO)

            local winid = api.nvim_get_current_win()
            require("neominimap.window").focus_cmds.unfocus(winid)
        end,
    },
    toggleFocus = {
        impl = function()
            local logger = require("neominimap.logger")
            logger.log("Command toggleFocus triggered.", vim.log.levels.INFO)

            local winid = api.nvim_get_current_win()
            require("neominimap.window").focus_cmds.toggleFocus(winid)
        end,
    },
}

return M
