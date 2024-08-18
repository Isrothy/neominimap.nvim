local api = vim.api

---@class Neominimap.Command.Buf.Handler
---@field bufRefresh fun(winid:integer)
---@field bufOn fun(mwinid:integer)
---@field bufOff fun(winid:integer)

local M = {}

---@param args string[]
---@return integer[]
local args_to_list = function(args)
    if #args == 0 then
        return { vim.api.nvim_get_current_buf() }
    else
        local bufnr = {}
        for _, arg in ipairs(args) do
            local nr = tonumber(arg)
            local logger = require("neominimap.logger")
            if not nr then
                logger.notify(string.format("Buffer number %s is not a number.", arg), vim.log.levels.ERROR)
            elseif not api.nvim_buf_is_valid(nr) then
                logger.notify(string.format("Buffer %d is not valid.", nr), vim.log.levels.ERROR)
            else
                table.insert(bufnr, tonumber(arg))
            end
        end
        return bufnr
    end
end

---@param bufnr integer
local function bufOn(bufnr)
    local var = require("neominimap.variables")
    var.b[bufnr].enabled = true
    require("neominimap.buffer").buf_cmds.bufOn(bufnr)
end

---@param bufnr integer
local function bufOff(bufnr)
    local var = require("neominimap.variables")
    var.b[bufnr].enabled = false
    require("neominimap.buffer").buf_cmds.bufOff(bufnr)
end

---@param bufnr integer
local function bufToggle(bufnr)
    local var = require("neominimap.variables")
    if var.b[bufnr].enabled then
        bufOff(bufnr)
    else
        bufOn(bufnr)
    end
end

---@param bufnr integer
local function bufRefresh(bufnr)
    require("neominimap.buffer").buf_cmds.bufRefresh(bufnr)
end

---@type table<string, Neominimap.Subcommand>
M.subcommand_tbl = {
    ["bufOn"] = {
        impl = function(args)
            local logger = require("neominimap.logger")
            logger.log("Command bufOn triggered.", vim.log.levels.INFO)

            local buf_list = args_to_list(args)
            vim.tbl_map(bufOn, buf_list)
        end,
    },
    ["bufOff"] = {
        impl = function(args)
            local logger = require("neominimap.logger")
            logger.log("Command bufOff triggered.", vim.log.levels.INFO)

            local buf_list = args_to_list(args)
            vim.tbl_map(bufOff, buf_list)
        end,
    },
    ["bufToggle"] = {
        impl = function(args)
            local logger = require("neominimap.logger")
            logger.log("Command bufToggle triggered.", vim.log.levels.INFO)

            local buf_list = args_to_list(args)
            vim.tbl_map(bufToggle, buf_list)
        end,
    },
    ["bufRefresh"] = {
        impl = function(args)
            local logger = require("neominimap.logger")
            logger.log("Command bufRefresh triggered.", vim.log.levels.INFO)

            local bufnr = args_to_list(args)
            vim.tbl_map(bufRefresh, bufnr)
        end,
    },
}

return M
