local M = {}

---@type table<string, Neominimap.Subcommand>
M.subcommand_tbl = {
    ["on"] = {
        impl = function()
            local logger = require("neominimap.logger")
            local msg = vim.deprecate("on", "Enable", "v4", "Neominimap")
            if msg then
                logger.notify(msg, vim.log.levels.WARN)
            end
            logger.log.info("Command on triggered.")
            require("neominimap.api").enable()
        end,
    },
    ["off"] = {
        impl = function()
            local logger = require("neominimap.logger")
            local msg = vim.deprecate("off", "Disable", "v4", "Neominimap")
            if msg then
                logger.notify(msg, vim.log.levels.WARN)
            end
            logger.log.info("Command off triggered.")
            require("neominimap.api").disable()
        end,
    },
    ["toggle"] = {
        impl = function()
            local logger = require("neominimap.logger")
            local msg = vim.deprecate("toggle", "Toggle", "v4", "Neominimap")
            if msg then
                logger.notify(msg, vim.log.levels.WARN)
            end
            logger.log.info("Command toggle triggered.")
            require("neominimap.api").toggle()
        end,
    },
    ["refresh"] = {
        impl = function()
            local logger = require("neominimap.logger")
            local msg = vim.deprecate("refresh", "Refresh", "v4", "Neominimap")
            if msg then
                logger.notify(msg, vim.log.levels.WARN)
            end
            logger.log.info("Command refresh triggered.")
            require("neominimap.api").refresh()
        end,
    },
    ["Enable"] = {
        impl = function()
            local logger = require("neominimap.logger")
            logger.log.info("Command Enable triggered.")
            require("neominimap.api").enable()
        end,
    },
    ["Disable"] = {
        impl = function()
            local logger = require("neominimap.logger")
            logger.log.info("Command Disable triggered.")
            require("neominimap.api").disable()
        end,
    },
    ["Toggle"] = {
        impl = function()
            local logger = require("neominimap.logger")
            logger.log.info("Command Toggle triggered.")
            require("neominimap.api").toggle()
        end,
    },
    ["Refresh"] = {
        impl = function()
            local logger = require("neominimap.logger")
            logger.log.info("Command Refresh triggered.")
            require("neominimap.api").refresh()
        end,
    },
}

return M
