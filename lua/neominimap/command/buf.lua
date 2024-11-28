local M = {}

---@type table<string, Neominimap.Subcommand>
M.subcommand_tbl = {
    ["bufOn"] = {
        impl = function(args)
            local logger = require("neominimap.logger")
            logger.log("Command bufOn triggered.", vim.log.levels.INFO)
            require("neominimap.api").buf.on(#args ~= 0 and vim.tbl_map(tonumber, args) or nil)
        end,
    },
    ["bufOff"] = {
        impl = function(args)
            local logger = require("neominimap.logger")
            logger.log("Command bufOff triggered.", vim.log.levels.INFO)
            require("neominimap.api").buf.off(#args ~= 0 and vim.tbl_map(tonumber, args) or nil)
        end,
    },
    ["bufToggle"] = {
        impl = function(args)
            local logger = require("neominimap.logger")
            logger.log("Command bufToggle triggered.", vim.log.levels.INFO)
            require("neominimap.api").buf.toggle(#args ~= 0 and vim.tbl_map(tonumber, args) or nil)
        end,
    },
    ["bufRefresh"] = {
        impl = function(args)
            local logger = require("neominimap.logger")
            logger.log("Command bufRefresh triggered.", vim.log.levels.INFO)
            require("neominimap.api").buf.refresh(#args ~= 0 and vim.tbl_map(tonumber, args) or nil)
        end,
    },
}

return M
