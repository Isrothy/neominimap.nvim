local M = {}

---@class Neominimap.Command.Global.Handler
---@field on fun()
---@field off fun()
---@field refresh fun()

---@type boolean
vim.g.neominimap_enabled = false

local function open_minimap()
    if vim.g.neominimap_enabled then
        return
    end
    vim.g.neominimap_enabled = true
    require("neominimap.autocmds").create_autocmds()

    local logger = require("neominimap.logger")
    logger.log("Minimap is being opened. Initializing buffers and windows.", vim.log.levels.INFO)
    require("neominimap.buffer").global_cmds.on()
    require("neominimap.window").global_cmds.on()
    logger.log("Minimap has been successfully opened.", vim.log.levels.INFO)
end

local function close_minimap()
    if not vim.g.neominimap_enabled then
        return
    end
    vim.g.neominimap_enabled = false
    require("neominimap.autocmds").clear_autocmds()

    local logger = require("neominimap.logger")
    logger.log("Minimap is being closed. Cleaning up buffers and windows.", vim.log.levels.INFO)
    require("neominimap.buffer").global_cmds.off()
    require("neominimap.window").global_cmds.off()
    logger.log("Minimap has been successfully closed.", vim.log.levels.INFO)
end

local function toggle_minimap()
    if vim.g.neominimap_enabled then
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
