local user_config = type(vim.g.neominimap) == "function" and vim.g.neominimap() or vim.g.neominimap or {}

local cfg = vim.tbl_deep_extend("force", require("neominimap.config.internal"), user_config)

local ok, err = require("neominimap.config.validator").validate_config(cfg)
if not ok then
    vim.notify("neominimap: invalid config: " .. err, vim.log.levels.ERROR)
end

return cfg
