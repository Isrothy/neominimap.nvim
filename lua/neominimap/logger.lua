local M = {}
local config = require("neominimap.config")
local levels = vim.log.levels

---@enum level
vim.log.levels = vim.log.levels

---@alias Neominimap.Log.Levels 0|1|2|3|4|5

---@type table<Neominimap.Log.Levels, string>
local level_names = {
    [levels.TRACE] = "TRACE",
    [levels.DEBUG] = "DEBUG",
    [levels.INFO] = "INFO",
    [levels.WARN] = "WARN",
    [levels.ERROR] = "ERROR",
    [levels.OFF] = "OFF",
}

---@param msg string
---@param level Neominimap.Log.Levels?
M.log = function(msg, level)
    local filepath = config.log_path
    level = level or levels.INFO
    if level >= config.log_level then
        local time = os.date("%Y-%m-%d %H:%M:%S")
        local f = io.open(filepath, "a+")
        if f then
            local info = debug.getinfo(2, "Sl")
            local log_message =
                string.format("[%s] [%-5s] [%s:%d] %s\n", time, level_names[level], info.short_src, info.currentline, msg)
            f:write(log_message)
            f:close()
        else
            M.notify("Error: Could not open log file at " .. filepath, levels.ERROR)
        end
    end
end

---@param msg string
---@param level Neominimap.Log.Levels?
M.notify = function(msg, level)
    level = level or levels.INFO
    if level >= config.notification_level then
        vim.notify(msg, level)
    end
end

return M
