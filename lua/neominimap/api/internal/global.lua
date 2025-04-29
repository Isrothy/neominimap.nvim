---@class Neominimap.Api.Global.Handler
---@field enable fun()
---@field disable fun()
---@field refresh fun()

local function enable()
    local var = require("neominimap.variables")
    local logger = require("neominimap.logger")
    if var.g.enabled then
        return
    end
    var.g.enabled = true
    require("neominimap.autocmds").create_autocmds()

    logger.log("Minimap is being opened. Initializing buffers and windows.", vim.log.levels.INFO)
    require("neominimap.buffer").get_global_apis().enable()
    require("neominimap.window").get_global_apis().enable()
    logger.log("Minimap has been successfully opened.", vim.log.levels.INFO)
end

local function disable()
    local var = require("neominimap.variables")
    if not var.g.enabled then
        return
    end
    var.g.enabled = false
    require("neominimap.autocmds").clear_autocmds()

    local logger = require("neominimap.logger")
    logger.log("Minimap is being closed. Cleaning up buffers and windows.", vim.log.levels.INFO)
    require("neominimap.buffer").get_global_apis().disable()
    require("neominimap.window").get_global_apis().disable()
    logger.log("Minimap has been successfully closed.", vim.log.levels.INFO)
end

local enabled = function()
    local var = require("neominimap.variables")
    return var.g.enabled
end

local function toggle()
    local var = require("neominimap.variables")
    if var.g.enabled then
        disable()
    else
        enable()
    end
end

local function refresh()
    require("neominimap.window").get_global_apis().refresh()
    require("neominimap.buffer").get_global_apis().refresh()
end

return {
    enable = enable,
    disable = disable,
    enabled = enabled,
    toggle = toggle,
    refresh = refresh,
}
