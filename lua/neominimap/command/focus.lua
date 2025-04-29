local M = {}

---@type table<string, Neominimap.Subcommand>
M.subcommand_tbl = {
    ["focus"] = {
        impl = function()
            local logger = require("neominimap.logger")
            local msg = vim.deprecate("focus", "Focus", "v4", "Neominimap")
            if msg then
                logger.notify(msg, vim.log.levels.WARN)
            end
            logger.log.info("Command focus triggered.")
            require("neominimap.api").focus.enable()
        end,
    },
    ["unfocus"] = {
        impl = function()
            local logger = require("neominimap.logger")
            local msg = vim.deprecate("unfocus", "Unfocus", "v4", "Neominimap")
            if msg then
                logger.notify(msg, vim.log.levels.WARN)
            end
            logger.log.info("Command unfocus triggered.")
            require("neominimap.api").focus.disable()
        end,
    },
    ["toggleFocus"] = {
        impl = function()
            local logger = require("neominimap.logger")
            local msg = vim.deprecate("toggleFocus", "ToggleFocus", "v4", "Neominimap")
            if msg then
                logger.notify(msg, vim.log.levels.WARN)
            end
            logger.log.info("Command toggleFocus triggered.")
            require("neominimap.api").focus.toggle()
        end,
    },
    ["Focus"] = {
        impl = function()
            local logger = require("neominimap.logger")
            logger.log.info("Command Focus triggered.")
            require("neominimap.api").focus.enable()
        end,
    },
    ["Unfocus"] = {
        impl = function()
            local logger = require("neominimap.logger")
            logger.log.info("Command Unfocus triggered.")
            require("neominimap.api").focus.disable()
        end,
    },
    ["ToggleFocus"] = {
        impl = function()
            local logger = require("neominimap.logger")
            logger.log.info("Command ToggleFocus triggered.")
            require("neominimap.api").focus.toggle()
        end,
    },
}

return M
