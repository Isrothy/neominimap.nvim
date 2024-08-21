local api = vim.api

local M = {}

api.nvim_create_augroup("Neominimap", { clear = true })

M.create_autocmds = function()
    require("neominimap.buffer").create_autocmds()
    require("neominimap.window").create_autocmds()
end

M.clear_autocmds = function()
    api.nvim_clear_autocmds({ group = "Neominimap" })
end

return M
