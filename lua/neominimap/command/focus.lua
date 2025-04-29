local M = {}

---@type table<string, Neominimap.Subcommand>
M.subcommand_tbl = {
    ["focus"] = {
        impl = function()
            local logger = require("neominimap.logger")
            logger.log.info("Command focus triggered.")
            require("neominimap.api").focus.enable()
        end,
    },
    ["unfocus"] = {
        impl = function()
            local logger = require("neominimap.logger")
            logger.log.info("Command unfocus triggered.")
            require("neominimap.api").focus.disable()
        end,
    },
    ["toggleFocus"] = {
        impl = function()
            local logger = require("neominimap.logger")
            logger.log.info("Command toggleFocus triggered.")
            require("neominimap.api").focus.toggle()
        end,
    },
}

return M
