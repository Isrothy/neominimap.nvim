local M = {}

---@type table<string, Neominimap.Subcommand>
M.subcommand_tbl = {
    ["focus"] = {
        impl = function()
            local logger = require("neominimap.logger")
            logger.log("Command focus triggered.", vim.log.levels.INFO)
            require("neominimap.api").focus.enable()
        end,
    },
    ["unfocus"] = {
        impl = function()
            local logger = require("neominimap.logger")
            logger.log("Command unfocus triggered.", vim.log.levels.INFO)
            require("neominimap.api").focus.disable()
        end,
    },
    ["toggleFocus"] = {
        impl = function()
            local logger = require("neominimap.logger")
            logger.log("Command toggleFocus triggered.", vim.log.levels.INFO)
            require("neominimap.api").focus.toggle()
        end,
    },
}

return M
