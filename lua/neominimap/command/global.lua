local M = {}

---@class Neominimap.Command.Global.Handler
---@field on fun()
---@field off fun()
---@field toggle fun()
---@field refresh fun()

---@type boolean
vim.g.neominimap_enabled = false

local function open_minimap()
    if vim.g.neominimap_enabled then
        return
    end
    vim.g.neominimap_enabled = true
    require("neominimap.autocmds").create_autocmds()
    vim.schedule(function()
        local logger = require("neominimap.logger")
        local window = require("neominimap.window")
        local buffer = require("neominimap.buffer")
        logger.log("Minimap is being opened. Initializing buffers and windows.", vim.log.levels.INFO)
        buffer.refresh_all_minimap_buffers()
        window.refresh_all_minimap_windows()
        logger.log("Minimap has been successfully opened.", vim.log.levels.INFO)
    end)
end

local function close_minimap()
    if not vim.g.neominimap_enabled then
        return
    end
    vim.g.neominimap_enabled = false
    require("neominimap.autocmds").clear_autocmds()
    vim.schedule(function()
        local logger = require("neominimap.logger")
        local window = require("neominimap.window")
        local buffer = require("neominimap.buffer")
        logger.log("Minimap is being closed. Cleaning up buffers and windows.", vim.log.levels.INFO)
        window.close_all_minimap_windows()
        buffer.delete_all_minimap_buffers()
        logger.log("Minimap has been successfully closed.", vim.log.levels.INFO)
    end)
end

local function toggle_minimap()
    if vim.g.neominimap_enabled then
        close_minimap()
    else
        open_minimap()
    end
end

local function refresh_minimap()
    vim.schedule(function()
        local window = require("neominimap.window")
        local buffer = require("neominimap.buffer")
        buffer.refresh_all_minimap_buffers()
        window.refresh_all_minimap_windows()
    end)
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
