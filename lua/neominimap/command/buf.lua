local M = {}

---@type table<string, Neominimap.Subcommand>
M.subcommand_tbl = {
    ["bufOn"] = {
        impl = function(args)
            local logger = require("neominimap.logger")
            logger.log.info("Command bufOn triggered.")
            require("neominimap.api").buf.enable(#args ~= 0 and vim.tbl_map(tonumber, args) or nil)
        end,
    },
    ["bufOff"] = {
        impl = function(args)
            local logger = require("neominimap.logger")
            logger.log.info("Command bufOff triggered.")
            require("neominimap.api").buf.disable(#args ~= 0 and vim.tbl_map(tonumber, args) or nil)
        end,
    },
    ["bufToggle"] = {
        impl = function(args)
            local logger = require("neominimap.logger")
            logger.log.info("Command bufToggle triggered.")
            require("neominimap.api").buf.toggle(#args ~= 0 and vim.tbl_map(tonumber, args) or nil)
        end,
    },
    ["bufRefresh"] = {
        impl = function(args)
            local logger = require("neominimap.logger")
            logger.log.info("Command bufRefresh triggered.")
            require("neominimap.api").buf.refresh(#args ~= 0 and vim.tbl_map(tonumber, args) or nil)
        end,
    },
}

return M
