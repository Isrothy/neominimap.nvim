local M = {}

---@type table<string, Neominimap.Subcommand>
M.subcommand_tbl = {
    ["focus"] = {
        impl = function()
            local logger = require("neominimap.logger")
            logger.log("Command focus triggered.", vim.log.levels.INFO)
            require("neominimap.api").focus()
        end,
    },
    ["unfocus"] = {
        impl = function()
            local logger = require("neominimap.logger")
            logger.log("Command unfocus triggered.", vim.log.levels.INFO)
            require("neominimap.api").unfocus()
        end,
    },
    ["toggleFocus"] = {
        impl = function()
            local logger = require("neominimap.logger")
            logger.log("Command toggleFocus triggered.", vim.log.levels.INFO)
            require("neominimap.api").toggle_focus()
        end,
    },
}

return M
