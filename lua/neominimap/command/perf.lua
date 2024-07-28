local api = vim.api
local buffer = require("neominimap.buffer")

local M = {}

---@param bufnr integer
local perf = function(bufnr)
    vim.schedule(function()
        require("plenary.profile").start("profile.log", {})
        buffer.internal_render(bufnr)
        require("plenary.profile").stop()
    end)
end

---@type table<string, Neominimap.Subcommand>
M.subcommand_tbl = {
    perf = {
        impl = function(args, opts)
            local bufnr = #args == 0 and api.nvim_get_current_buf() or tonumber(args[1])
            if bufnr then
                perf(bufnr)
            end
        end,
    },
}

return M
