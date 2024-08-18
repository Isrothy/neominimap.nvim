local api = vim.api

---@class Neominimap.Command.Win.Handler
---@field refresh fun(winid:integer)
---@field on fun(winid:integer)
---@field off fun(winid:integer)
---@field toggle fun(winid:integer)

local M = {}

---@param args string[]
---@return integer[]
local args_to_list = function(args)
    if #args == 0 then
        return { vim.api.nvim_get_current_win() }
    else
        local bufnr = {}
        for _, arg in ipairs(args) do
            local nr = tonumber(arg)
            local logger = require("neominimap.logger")
            if not nr then
                logger.notify(string.format("Window ID %s is not a number.", arg), vim.log.levels.ERROR)
            elseif not api.nvim_win_is_valid(nr) then
                logger.notify(string.format("Window ID %d is not valid.", nr), vim.log.levels.ERROR)
            else
                table.insert(bufnr, tonumber(arg))
            end
        end
        return bufnr
    end
end

---@type table<string, Neominimap.Subcommand>
M.subcommand_tbl = {
    winOn = {
        impl = function(args, opts)
            local win_list = args_to_list(args)
            local fun = require("neominimap.window").wincmd.on
            vim.tbl_map(fun, win_list)
        end,
    },
    winOff = {
        impl = function(args, opts)
            local win_list = args_to_list(args)
            local fun = require("neominimap.window").wincmd.off
            vim.tbl_map(fun, win_list)
        end,
    },
    winToggle = {
        impl = function(args, opts)
            local win_list = args_to_list(args)
            local fun = require("neominimap.window").wincmd.toggle
            vim.tbl_map(fun, win_list)
        end,
    },
    winRefresh = {
        impl = function(args, opts)
            local win_list = args_to_list(args)
            local fun = require("neominimap.window").wincmd.refresh
            vim.tbl_map(fun, win_list)
        end,
    },
}

return M
