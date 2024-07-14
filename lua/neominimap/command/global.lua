local logger = require("neominimap.logger")
local window = require("neominimap.window")
local buffer = require("neominimap.buffer")

local M = {}

---@type boolean
M.enabled = false

local function open_minimap()
    if M.enabled then
        return
    end
    M.enabled = true
    require("neominimap.autocmds").create_autocmds()
    vim.schedule(function()
        logger.log("Minimap is being opened. Initializing buffers and windows.", vim.log.levels.INFO)
        buffer.refresh_all_minimap_buffers()
        window.refresh_all_minimap_windows()
        logger.log("Minimap has been successfully opened.", vim.log.levels.INFO)
    end)
end

local function close_minimap()
    if not M.enabled then
        return
    end
    M.enabled = false
    require("neominimap.autocmds").clear_autocmds()
    vim.schedule(function()
        logger.log("Minimap is being closed. Cleaning up buffers and windows.", vim.log.levels.INFO)
        window.close_all_minimap_windows()
        buffer.delete_all_minimap_buffers()
        logger.log("Minimap has been successfully closed.", vim.log.levels.INFO)
    end)
end

local function toggle_minimap()
    if M.enabled then
        close_minimap()
    else
        open_minimap()
    end
end

local function refresh_minimap()
    vim.schedule(function()
        buffer.refresh_all_minimap_buffers()
        window.refresh_all_minimap_windows()
    end)
end

---@type table<string, Neominimap.Subcommand>
M.subcommand_tbl = {
    on = {
        impl = function(args, opts)
            open_minimap()
        end,
    },
    off = {
        impl = function(args, opts)
            close_minimap()
        end,
    },
    toggle = {
        impl = function(args, opts)
            toggle_minimap()
        end,
    },
    refresh = {
        impl = function(args, opts)
            refresh_minimap()
        end,
    },
}

return M
