local M = {}

---@class Neominimap.Command.Global.Handler
---@field on fun()
---@field off fun()
---@field refresh fun()

local function open_minimap()
    local var = require("neominimap.variables")
    local logger = require("neominimap.logger")
    logger.log("var.g.enabled = " .. tostring(var.g.enabled), vim.log.levels.DEBUG)
    if var.g.enabled then
        return
    end
    var.set_var("enabled", true)
    -- var.g.enabled = true
    logger.log("var.g.enabled = " .. tostring(var.get_var("enabled")), vim.log.levels.DEBUG)
    require("neominimap.autocmds").create_autocmds()

    logger.log("Minimap is being opened. Initializing buffers and windows.", vim.log.levels.INFO)
    require("neominimap.buffer").global_cmds.on()
    require("neominimap.window").global_cmds.on()
    logger.log("Minimap has been successfully opened.", vim.log.levels.INFO)
end

local function close_minimap()
    local var = require("neominimap.variables")
    if not var.g.enabled then
        return
    end
    var.g.enabled = false
    require("neominimap.autocmds").clear_autocmds()

    local logger = require("neominimap.logger")
    logger.log("Minimap is being closed. Cleaning up buffers and windows.", vim.log.levels.INFO)
    require("neominimap.buffer").global_cmds.off()
    require("neominimap.window").global_cmds.off()
    logger.log("Minimap has been successfully closed.", vim.log.levels.INFO)
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
    require("neominimap.window").global_cmds.refresh()
    require("neominimap.buffer").global_cmds.refresh()
end

---@type table<string, Neominimap.Subcommand>
M.subcommand_tbl = {
    on = {
        impl = function()
            local logger = require("neominimap.logger")
            logger.log("Command on triggered.", vim.log.levels.INFO)
            open_minimap()
        end,
    },
    off = {
        impl = function()
            local logger = require("neominimap.logger")
            logger.log("Command off triggered.", vim.log.levels.INFO)
            close_minimap()
        end,
    },
    toggle = {
        impl = function()
            local logger = require("neominimap.logger")
            logger.log("Command toggle triggered.", vim.log.levels.INFO)
            toggle_minimap()
        end,
    },
    refresh = {
        impl = function()
            local logger = require("neominimap.logger")
            logger.log("Command refresh triggered.", vim.log.levels.INFO)
            refresh_minimap()
        end,
    },
}

return M
