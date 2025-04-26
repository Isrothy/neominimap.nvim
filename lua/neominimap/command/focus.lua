local api = vim.api

---@class Neominimap.Command.Focus.Handler
---@field focus fun(winid:integer)
---@field unfocus fun(mwinid:integer)
---@field toggleFocus fun(winid:integer)

local M = {}

---@type table<string, Neominimap.Subcommand>
M.subcommand_tbl = {
    ["focus"] = {
        impl = function()
            local logger = require("neominimap.logger")
            logger.log.info("Command focus triggered.")

            local winid = api.nvim_get_current_win()
            require("neominimap.window").get_focus_cmds().focus(winid)
        end,
    },
    ["unfocus"] = {
        impl = function()
            local logger = require("neominimap.logger")
            logger.log.info("Command unfocus triggered.")

            local winid = api.nvim_get_current_win()
            require("neominimap.window").get_focus_cmds().unfocus(winid)
        end,
    },
    ["toggleFocus"] = {
        impl = function()
            local logger = require("neominimap.logger")
            logger.log.info("Command toggleFocus triggered.")

            local winid = api.nvim_get_current_win()
            require("neominimap.window").get_focus_cmds().toggleFocus(winid)
        end,
    },
}

return M
