local M = {}

---@type table<string, Neominimap.Subcommand>
M.subcommand_tbl = {
    ["on"] = {
        impl = function()
            local logger = require("neominimap.logger")
            logger.log.info("Command on triggered.")
            require("neominimap.api").enable()
        end,
    },
    ["off"] = {
        impl = function()
            local logger = require("neominimap.logger")
            logger.log.info("Command off triggered.")
            require("neominimap.api").disable()
        end,
    },
    ["toggle"] = {
        impl = function()
            local logger = require("neominimap.logger")
            logger.log.info("Command toggle triggered.")
            require("neominimap.api").toggle()
        end,
    },
    ["refresh"] = {
        impl = function()
            local logger = require("neominimap.logger")
            logger.log.info("Command refresh triggered.")
            require("neominimap.api").refresh()
        end,
    },
}

return M
