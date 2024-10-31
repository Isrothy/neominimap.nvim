local user_config = type(vim.g.neominimap) == "function" and vim.g.neominimap() or vim.g.neominimap or {}

return vim.tbl_deep_extend("force", require("neominimap.config.internal"), user_config)
