local M = {}

local user_config = type(vim.g.neominimap) == "function" and vim.g.neominimap() or vim.g.neominimap or {}

if type(user_config.log_level) == "string" then
    user_config.log_level = vim.log.levels[user_config.log_level]
end
if type(user_config.notification_level) == "string" then
    user_config.notification_level = vim.log.levels[user_config.notification_level]
end

local confg = vim.tbl_deep_extend("force", require("neominimap.config.internal").default_config, user_config)

---@return Neominimap.InternalConfig
M.get = function()
    return confg
end

return M
