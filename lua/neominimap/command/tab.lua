local M = {}

---@type table<string, Neominimap.Subcommand>type table<Neominimap.Command.Tab, Neominimap.Subcommand>
M.subcommand_tbl = {
    ["tabOn"] = {
        impl = function(args)
            local logger = require("neominimap.logger")
            logger.log.info("Command tabOn triggered.")
            require("neominimap.api").tab.enable(#args ~= 0 and vim.tbl_map(tonumber, args) or nil)
        end,
    },
    ["tabOff"] = {
        impl = function(args)
            local logger = require("neominimap.logger")
            logger.log.info("Command tabOff triggered.")
            require("neominimap.api").tab.disable(#args ~= 0 and vim.tbl_map(tonumber, args) or nil)
        end,
    },
    ["tabToggle"] = {
        impl = function(args)
            local logger = require("neominimap.logger")
            logger.log.info("Command tabToggle triggered.")
            require("neominimap.api").tab.toggle(#args ~= 0 and vim.tbl_map(tonumber, args) or nil)
        end,
    },
    ["tabRefresh"] = {
        impl = function(args)
            local logger = require("neominimap.logger")
            logger.log.info("Command tabRefresh triggered.")
            require("neominimap.api").tab.refresh(#args ~= 0 and vim.tbl_map(tonumber, args) or nil)
        end,
    },
}

return M
