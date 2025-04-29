local M = {}

---@type table<string, Neominimap.Subcommand>
M.subcommand_tbl = {
    ["winOn"] = {
        impl = function(args)
            local logger = require("neominimap.logger")
            local msg = vim.deprecate("winOn", "WinEnable", "v4", "Neominimap")
            if msg then
                logger.notify(msg, vim.log.levels.WARN)
            end
            logger.log.info("Command winOn triggered.")
            require("neominimap.api").win.enable(#args ~= 0 and vim.tbl_map(tonumber, args) or nil)
        end,
    },
    ["winOff"] = {
        impl = function(args)
            local logger = require("neominimap.logger")
            local msg = vim.deprecate("winOff", "WinDisable", "v4", "Neominimap")
            if msg then
                logger.notify(msg, vim.log.levels.WARN)
            end
            logger.log.info("Command winOff triggered.")
            require("neominimap.api").win.disable(#args ~= 0 and vim.tbl_map(tonumber, args) or nil)
        end,
    },
    ["winToggle"] = {
        impl = function(args)
            local logger = require("neominimap.logger")
            local msg = vim.deprecate("winToggle", "WinToggle", "v4", "Neominimap")
            if msg then
                logger.notify(msg, vim.log.levels.WARN)
            end
            logger.log.info("Command winToggle triggered.")
            require("neominimap.api").win.toggle(#args ~= 0 and vim.tbl_map(tonumber, args) or nil)
        end,
    },
    ["winRefresh"] = {
        impl = function(args)
            local logger = require("neominimap.logger")
            local msg = vim.deprecate("winRefresh", "WinRefresh", "v4", "Neominimap")
            if msg then
                logger.notify(msg, vim.log.levels.WARN)
            end
            logger.log.info("Command winRefresh triggered.")
            require("neominimap.api").win.refresh(#args ~= 0 and vim.tbl_map(tonumber, args) or nil)
        end,
    },
    ["WinEnable"] = {
        impl = function(args)
            local logger = require("neominimap.logger")
            logger.log.info("Command WinEnable triggered.")
            require("neominimap.api").win.enable(#args ~= 0 and vim.tbl_map(tonumber, args) or nil)
        end,
    },
    ["WinDisable"] = {
        impl = function(args)
            local logger = require("neominimap.logger")
            logger.log.info("Command WinDisable triggered.")
            require("neominimap.api").win.disable(#args ~= 0 and vim.tbl_map(tonumber, args) or nil)
        end,
    },
    ["WinToggle"] = {
        impl = function(args)
            local logger = require("neominimap.logger")
            logger.log.info("Command WinToggle triggered.")
            require("neominimap.api").win.toggle(#args ~= 0 and vim.tbl_map(tonumber, args) or nil)
        end,
    },
    ["WinRefresh"] = {
        impl = function(args)
            local logger = require("neominimap.logger")
            logger.log.info("Command WinRefresh triggered.")
            require("neominimap.api").win.refresh(#args ~= 0 and vim.tbl_map(tonumber, args) or nil)
        end,
    },
}

return M
