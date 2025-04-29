local M = {}

---@type table<string, Neominimap.Subcommand>
M.subcommand_tbl = {
    ["bufOn"] = {
        impl = function(args)
            local logger = require("neominimap.logger")
            local msg = vim.deprecate("bufOn", "BufEnable", "v4", "Neominimap")
            if msg then
                logger.notify(msg, vim.log.levels.WARN)
            end
            logger.log.info("Command bufOn triggered.")
            require("neominimap.api").buf.enable(#args ~= 0 and vim.tbl_map(tonumber, args) or nil)
        end,
    },
    ["bufOff"] = {
        impl = function(args)
            local logger = require("neominimap.logger")
            local msg = vim.deprecate("bufOff", "BufDisable", "v4", "Neominimap")
            if msg then
                logger.notify(msg, vim.log.levels.WARN)
            end
            logger.log.info("Command bufOff triggered.")
            require("neominimap.api").buf.disable(#args ~= 0 and vim.tbl_map(tonumber, args) or nil)
        end,
    },
    ["bufToggle"] = {
        impl = function(args)
            local logger = require("neominimap.logger")
            local msg = vim.deprecate("bufToggle", "BufToggle", "v4", "Neominimap")
            if msg then
                logger.notify(msg, vim.log.levels.WARN)
            end
            logger.log.info("Command bufToggle triggered.")
            require("neominimap.api").buf.toggle(#args ~= 0 and vim.tbl_map(tonumber, args) or nil)
        end,
    },
    ["bufRefresh"] = {
        impl = function(args)
            local logger = require("neominimap.logger")
            local msg = vim.deprecate("bufRefresh", "BufRefresh", "v4", "Neominimap")
            if msg then
                logger.notify(msg, vim.log.levels.WARN)
            end
            logger.log.info("Command bufRefresh triggered.")
            require("neominimap.api").buf.refresh(#args ~= 0 and vim.tbl_map(tonumber, args) or nil)
        end,
    },
    ["BufEnable"] = {
        impl = function(args)
            local logger = require("neominimap.logger")
            logger.log.info("Command BufEnable triggered.")
            require("neominimap.api").buf.enable(#args ~= 0 and vim.tbl_map(tonumber, args) or nil)
        end,
    },
    ["BufDisable"] = {
        impl = function(args)
            local logger = require("neominimap.logger")
            logger.log.info("Command BufDisable triggered.")
            require("neominimap.api").buf.disable(#args ~= 0 and vim.tbl_map(tonumber, args) or nil)
        end,
    },
    ["BufToggle"] = {
        impl = function(args)
            local logger = require("neominimap.logger")
            logger.log.info("Command BufToggle triggered.")
            require("neominimap.api").buf.toggle(#args ~= 0 and vim.tbl_map(tonumber, args) or nil)
        end,
    },
    ["BufRefresh"] = {
        impl = function(args)
            local logger = require("neominimap.logger")
            logger.log.info("Command BufRefresh triggered.")
            require("neominimap.api").buf.refresh(#args ~= 0 and vim.tbl_map(tonumber, args) or nil)
        end,
    },
}

return M
