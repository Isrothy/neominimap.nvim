local api = vim.api
local window = require("neominimap.window")
local logger = require("neominimap.logger")

local M = {}

---@type table<string, Neominimap.Subcommand>
M.subcommand_tbl = {
    focus = {
        impl = function(args, opts)
            local winid = api.nvim_get_current_win()
            if not window.focus(winid) then
                logger.notify("Minimap can not be focused for current window", vim.log.levels.ERROR)
            end
        end,
    },
    unfocus = {
        impl = function(args, opts)
            local winid = api.nvim_get_current_win()
            if not window.unfocus(winid) then
                logger.notify("Minimap can not be unfocused for current window", vim.log.levels.ERROR)
            end
        end,
    },
}

return M
