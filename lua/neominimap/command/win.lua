local M = {}

---@type table<string, Neominimap.Subcommand>
M.subcommand_tbl = {
    ["winOn"] = {
        impl = function(args)
            local logger = require("neominimap.logger")
            logger.log.info("Command winOn triggered.")
            require("neominimap.api").win.enable(#args ~= 0 and vim.tbl_map(tonumber, args) or nil)
        end,
    },
    ["winOff"] = {
        impl = function(args)
            local logger = require("neominimap.logger")
            logger.log.info("Command winOff triggered.")
            require("neominimap.api").win.disable(#args ~= 0 and vim.tbl_map(tonumber, args) or nil)
        end,
    },
    ["winToggle"] = {
        impl = function(args)
            local logger = require("neominimap.logger")
            logger.log.info("Command winToggle triggered.")
            require("neominimap.api").win.toggle(#args ~= 0 and vim.tbl_map(tonumber, args) or nil)
        end,
    },
    ["winRefresh"] = {
        impl = function(args)
            local logger = require("neominimap.logger")
            logger.log.info("Command winRefresh triggered.")
            require("neominimap.api").win.refresh(#args ~= 0 and vim.tbl_map(tonumber, args) or nil)
        end,
    },
}

return M
