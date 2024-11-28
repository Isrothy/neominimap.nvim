local M = {}

---@type table<string, Neominimap.Subcommand>
M.subcommand_tbl = {
    ["on"] = {
        impl = function()
            local logger = require("neominimap.logger")
            logger.log("Command on triggered.", vim.log.levels.INFO)
            require("neominimap.api").on()
        end,
    },
    ["off"] = {
        impl = function()
            local logger = require("neominimap.logger")
            logger.log("Command off triggered.", vim.log.levels.INFO)
            require("neominimap.api").off()
        end,
    },
    ["toggle"] = {
        impl = function()
            local logger = require("neominimap.logger")
            logger.log("Command toggle triggered.", vim.log.levels.INFO)
            require("neominimap.api").toggle()
        end,
    },
    ["refresh"] = {
        impl = function()
            local logger = require("neominimap.logger")
            logger.log("Command refresh triggered.", vim.log.levels.INFO)
            require("neominimap.api").refresh()
        end,
    },
}

return M
