local M = {}

---@class Neominimap.Command.Global.Handler
---@field on fun()
---@field off fun()
---@field refresh fun()

local function open_minimap()
    local var = require("neominimap.variables")
    local logger = require("neominimap.logger")
    if var.g.enabled then
        return
    end
    var.g.enabled = true
    require("neominimap.autocmds").create_autocmds()

    logger.log.info("Minimap is being opened. Initializing buffers and windows.")
    require("neominimap.buffer").get_global_cmds().on()
    require("neominimap.window").get_global_cmds().on()
    logger.log.info("Minimap has been successfully opened.")
end

local function close_minimap()
    local var = require("neominimap.variables")
    if not var.g.enabled then
        return
    end
    var.g.enabled = false
    require("neominimap.autocmds").clear_autocmds()

    local logger = require("neominimap.logger")
    logger.log.info("Minimap is being closed. Cleaning up buffers and windows.")
    require("neominimap.buffer").get_global_cmds().off()
    require("neominimap.window").get_global_cmds().off()
    logger.log.info("Minimap has been successfully closed.")
end

local function toggle_minimap()
    local var = require("neominimap.variables")
    if var.g.enabled then
        close_minimap()
    else
        open_minimap()
    end
end

local function refresh_minimap()
    require("neominimap.window").get_global_cmds().refresh()
    require("neominimap.buffer").get_global_cmds().refresh()
end

---@type table<string, Neominimap.Subcommand>
M.subcommand_tbl = {
    ["on"] = {
        impl = function()
            local logger = require("neominimap.logger")
            logger.log.info("Command on triggered.")
            open_minimap()
        end,
    },
    ["off"] = {
        impl = function()
            local logger = require("neominimap.logger")
            logger.log.info("Command off triggered.")
            close_minimap()
        end,
    },
    ["toggle"] = {
        impl = function()
            local logger = require("neominimap.logger")
            logger.log.info("Command toggle triggered.")
            toggle_minimap()
        end,
    },
    ["refresh"] = {
        impl = function()
            local logger = require("neominimap.logger")
            logger.log.info("Command refresh triggered.")
            refresh_minimap()
        end,
    },
}

return M
