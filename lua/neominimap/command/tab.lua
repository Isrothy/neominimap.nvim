local M = {}

---@type table<string, Neominimap.Subcommand>
M.subcommand_tbl = {
    ["tabOn"] = {
        impl = function(args)
            local logger = require("neominimap.logger")
            local msg = vim.deprecate("tabOn", "TabEnable", "v4", "Neominimap")
            if msg then
                logger.notify(msg, vim.log.levels.WARN)
            end
            logger.log.info("Command tabOn triggered.")
            require("neominimap.api").tab.enable(#args ~= 0 and vim.tbl_map(tonumber, args) or nil)
        end,
    },
    ["tabOff"] = {
        impl = function(args)
            local logger = require("neominimap.logger")
            local msg = vim.deprecate("tabOff", "TabDisable", "v4", "Neominimap")
            if msg then
                logger.notify(msg, vim.log.levels.WARN)
            end
            logger.log.info("Command tabOff triggered.")
            require("neominimap.api").tab.disable(#args ~= 0 and vim.tbl_map(tonumber, args) or nil)
        end,
    },
    ["tabToggle"] = {
        impl = function(args)
            local logger = require("neominimap.logger")
            local msg = vim.deprecate("tabToggle", "TabToggle", "v4", "Neominimap")
            if msg then
                logger.notify(msg, vim.log.levels.WARN)
            end
            logger.log.info("Command tabToggle triggered.")
            require("neominimap.api").tab.toggle(#args ~= 0 and vim.tbl_map(tonumber, args) or nil)
        end,
    },
    ["tabRefresh"] = {
        impl = function(args)
            local logger = require("neominimap.logger")
            local msg = vim.deprecate("tabRefresh", "TabRefresh", "v4", "Neominimap")
            if msg then
                logger.notify(msg, vim.log.levels.WARN)
            end
            logger.log.info("Command tabRefresh triggered.")
            require("neominimap.api").tab.refresh(#args ~= 0 and vim.tbl_map(tonumber, args) or nil)
        end,
    },
    ["TabEnable"] = {
        impl = function(args)
            local logger = require("neominimap.logger")
            logger.log.info("Command TabEnable triggered.")
            require("neominimap.api").tab.enable(#args ~= 0 and vim.tbl_map(tonumber, args) or nil)
        end,
    },
    ["TabDisable"] = {
        impl = function(args)
            local logger = require("neominimap.logger")
            logger.log.info("Command TabDisable triggered.")
            require("neominimap.api").tab.disable(#args ~= 0 and vim.tbl_map(tonumber, args) or nil)
        end,
    },
    ["TabToggle"] = {
        impl = function(args)
            local logger = require("neominimap.logger")
            logger.log.info("Command TabToggle triggered.")
            require("neominimap.api").tab.toggle(#args ~= 0 and vim.tbl_map(tonumber, args) or nil)
        end,
    },
    ["TabRefresh"] = {
        impl = function(args)
            local logger = require("neominimap.logger")
            logger.log.info("Command TabRefresh triggered.")
            require("neominimap.api").tab.refresh(#args ~= 0 and vim.tbl_map(tonumber, args) or nil)
        end,
    },
}

return M
