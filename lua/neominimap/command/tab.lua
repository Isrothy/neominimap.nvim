local api = vim.api

---@class Neominimap.Command.Tab.Handler
---@field tabRefresh fun(tabid:integer)
---@field tabOn fun(tabid:integer)
---@field tabOff fun(tabid:integer)

local M = {}

---@param args string[]
---@return integer[]
local args_to_list = function(args)
    if #args == 0 then
        return { api.nvim_get_current_tabpage() }
    else
        local tabnr = {}
        for _, arg in ipairs(args) do
            local nr = tonumber(arg)
            local logger = require("neominimap.logger")
            if not nr then
                logger.notify(string.format("Tab ID %s is not a number.", arg), vim.log.levels.ERROR)
            elseif not api.nvim_tabpage_is_valid(nr) then
                logger.notify(string.format("Tab %d is not valid.", nr), vim.log.levels.ERROR)
            else
                table.insert(tabnr, tonumber(arg))
            end
        end
        return tabnr
    end
end

---@param tabid integer
local function tabOn(tabid)
    local var = require("neominimap.variables")
    var.t[tabid].enabled = true
    require("neominimap.window").get_tab_cmds().tabOn(tabid)
end

---@param tabid integer
local function tabOff(tabid)
    local var = require("neominimap.variables")
    var.t[tabid].enabled = false
    require("neominimap.window").get_tab_cmds().tabOff(tabid)
end

---@param tabid integer
local function tabToggle(tabid)
    local var = require("neominimap.variables")
    if var.t[tabid].enabled then
        tabOff(tabid)
    else
        tabOn(tabid)
    end
end

---@param tabid integer
local function tabRefresh(tabid)
    require("neominimap.window").get_tab_cmds().tabRefresh(tabid)
end

---@type table<string, Neominimap.Subcommand>type table<Neominimap.Command.Tab, Neominimap.Subcommand>
M.subcommand_tbl = {
    ["tabOn"] = {
        impl = function(args)
            local logger = require("neominimap.logger")
            logger.log("Command tabOn triggered.", vim.log.levels.INFO)

            local tab_list = args_to_list(args)
            vim.tbl_map(tabOn, tab_list)
        end,
    },
    ["tabOff"] = {
        impl = function(args)
            local logger = require("neominimap.logger")
            logger.log("Command tabOff triggered.", vim.log.levels.INFO)

            local tab_list = args_to_list(args)
            vim.tbl_map(tabOff, tab_list)
        end,
    },
    ["tabToggle"] = {
        impl = function(args)
            local logger = require("neominimap.logger")
            logger.log("Command tabToggle triggered.", vim.log.levels.INFO)

            local tab_list = args_to_list(args)
            vim.tbl_map(tabToggle, tab_list)
        end,
    },
    ["tabRefresh"] = {
        impl = function(args)
            local logger = require("neominimap.logger")
            logger.log("Command tabRefresh triggered.", vim.log.levels.INFO)

            local tabnr = args_to_list(args)
            vim.tbl_map(tabRefresh, tabnr)
        end,
    },
}

return M
