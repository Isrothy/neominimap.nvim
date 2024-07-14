local M = {}

local api = vim.api

---@type boolean
M.enabled = false

function M.open_minimap()
    if M.enabled then
        return
    end
    M.enabled = true
    local window = require("neominimap.window")
    local buffer = require("neominimap.buffer")
    local logger = require("neominimap.logger")
    require("neominimap.autocmds").create_autocmds()
    vim.schedule(function()
        logger.log("Minimap is being opened. Initializing buffers and windows.", vim.log.levels.INFO)
        buffer.refresh_all_minimap_buffers()
        window.refresh_all_minimap_windows()
        logger.log("Minimap has been successfully opened.", vim.log.levels.INFO)
    end)
end

function M.close_minimap()
    if not M.enabled then
        return
    end
    M.enabled = false
    local window = require("neominimap.window")
    local buffer = require("neominimap.buffer")
    local logger = require("neominimap.logger")
    require("neominimap.autocmds").clear_autocmds()
    vim.schedule(function()
        logger.log("Minimap is being closed. Cleaning up buffers and windows.", vim.log.levels.INFO)
        window.close_all_minimap_windows()
        buffer.delete_all_minimap_buffers()
        logger.log("Minimap has been successfully closed.", vim.log.levels.INFO)
    end)
end

function M.toggle_minimap()
    if M.enabled then
        M.close_minimap()
    else
        M.open_minimap()
    end
end

M.setup = function()
    local gid = api.nvim_create_augroup("Neominimap", { clear = true })
    api.nvim_create_autocmd("VimEnter", {
        group = gid,
        callback = vim.schedule_wrap(function()
            local logger = require("neominimap.logger")
            local config = require("neominimap.config").get()
            logger.log("VimEnter event triggered. Checking if minimap should auto-enable.", vim.log.levels.TRACE)
            if config.auto_enable then
                M.open_minimap()
            end
        end),
    })
end

return M
