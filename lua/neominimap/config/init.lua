local validator = require("neominimap.config.validator")

local M = {}

local user_config = type(vim.g.neominimap) == "function" and vim.g.neominimap() or vim.g.neominimap or {}

local cfg = vim.tbl_deep_extend("force", require("neominimap.config.internal").default_config, user_config)

local ok, err = validator.validate_config(cfg)
if not ok then
    vim.notify("neominimap: invalid config: " .. err, vim.log.levels.ERROR)
end

---@return Neominimap.InternalConfig
M.get = function()
    return cfg
end

return M
