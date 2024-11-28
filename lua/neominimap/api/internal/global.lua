---@class Neominimap.Api.Global.Handler
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

    logger.log("Minimap is being opened. Initializing buffers and windows.", vim.log.levels.INFO)
    require("neominimap.buffer").get_global_apis().on()
    require("neominimap.window").get_global_apis().on()
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
    require("neominimap.buffer").get_global_apis().off()
    require("neominimap.window").get_global_apis().off()
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
    require("neominimap.window").get_global_apis().refresh()
    require("neominimap.buffer").get_global_apis().refresh()
end

return {
    on = open_minimap,
    off = close_minimap,
    toggle = toggle_minimap,
    refresh = refresh_minimap,
}
