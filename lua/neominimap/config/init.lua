local M = {}

---@return Neominimap.InternalConfig
M.get = function()
	local user_config = type(vim.g.neominimap) == "function" and vim.g.neominimap() or vim.g.neominimap or {}
	local confg = vim.tbl_deep_extend("force", require("neominimap.config.internal").default_config, user_config)
	return confg
end

return M
