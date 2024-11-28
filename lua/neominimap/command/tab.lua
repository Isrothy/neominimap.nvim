local M = {}

---@type table<string, Neominimap.Subcommand>type table<Neominimap.Command.Tab, Neominimap.Subcommand>
M.subcommand_tbl = {
    ["tabOn"] = {
        impl = function(args)
            local logger = require("neominimap.logger")
            logger.log("Command tabOn triggered.", vim.log.levels.INFO)
            require("neominimap.api").tab.enable(#args ~= 0 and vim.tbl_map(tonumber, args) or nil)
        end,
    },
    ["tabOff"] = {
        impl = function(args)
            local logger = require("neominimap.logger")
            logger.log("Command tabOff triggered.", vim.log.levels.INFO)
            require("neominimap.api").tab.disable(#args ~= 0 and vim.tbl_map(tonumber, args) or nil)
        end,
    },
    ["tabToggle"] = {
        impl = function(args)
            local logger = require("neominimap.logger")
            logger.log("Command tabToggle triggered.", vim.log.levels.INFO)
            require("neominimap.api").tab.toggle(#args ~= 0 and vim.tbl_map(tonumber, args) or nil)
        end,
    },
    ["tabRefresh"] = {
        impl = function(args)
            local logger = require("neominimap.logger")
            logger.log("Command tabRefresh triggered.", vim.log.levels.INFO)
            require("neominimap.api").tab.refresh(#args ~= 0 and vim.tbl_map(tonumber, args) or nil)
        end,
    },
}

return M
