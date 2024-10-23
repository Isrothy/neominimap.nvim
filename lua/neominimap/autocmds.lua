local api = vim.api

local M = {}

local group = api.nvim_create_augroup("Neominimap", { clear = true })

M.create_autocmds = function()
    require("neominimap.buffer").create_autocmds(group)
    require("neominimap.window").create_autocmds(group)
    require("neominimap.map.handlers").create_autocmds(group)
end

M.clear_autocmds = function()
    api.nvim_clear_autocmds({ group = group })
end

return M
