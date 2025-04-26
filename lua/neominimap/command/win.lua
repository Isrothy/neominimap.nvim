local api = vim.api

---@class Neominimap.Command.Win.Handler
---@field winRefresh fun(winid:integer)
---@field winOn fun(winid:integer)
---@field winOff fun(winid:integer)

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

---@param winid integer
local winOn = function(winid)
    local var = require("neominimap.variables")
    var.w[winid].enabled = true
    require("neominimap.window").get_win_cmds().winOn(winid)
end

---@param winid integer
local winOff = function(winid)
    local var = require("neominimap.variables")
    var.w[winid].enabled = false
    require("neominimap.window").get_win_cmds().winOff(winid)
end

---@param winid integer
local winToggle = function(winid)
    local var = require("neominimap.variables")
    if var.w[winid].enabled then
        winOff(winid)
    else
        winOn(winid)
    end
end

---@param winid integer
local function winRefresh(winid)
    require("neominimap.window").get_win_cmds().winRefresh(winid)
end

---@type table<string, Neominimap.Subcommand>
M.subcommand_tbl = {
    ["winOn"] = {
        impl = function(args)
            local logger = require("neominimap.logger")
            logger.log.trace("Command winOn triggered.")

            local win_list = args_to_list(args)
            vim.tbl_map(winOn, win_list)
        end,
    },
    ["winOff"] = {
        impl = function(args)
            local logger = require("neominimap.logger")
            logger.log.trace("Command winOff triggered.")

            local win_list = args_to_list(args)
            vim.tbl_map(winOff, win_list)
        end,
    },
    ["winToggle"] = {
        impl = function(args)
            local logger = require("neominimap.logger")
            logger.log.trace("Command winToggle triggered.")

            local win_list = args_to_list(args)
            vim.tbl_map(winToggle, win_list)
        end,
    },
    ["winRefresh"] = {
        impl = function(args)
            local logger = require("neominimap.logger")
            logger.log.trace("Command winRefresh triggered.")

            local win_list = args_to_list(args)
            vim.tbl_map(winRefresh, win_list)
        end,
    },
}

return M
