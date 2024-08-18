local api = vim.api

local M = {}

---@param bufnr integer
local perf = function(bufnr)
    vim.schedule(function()
        require("plenary.profile").start("profile.log", {})
        local logger = require("neominimap.logger")
        local buffer = require("neominimap.buffer")
        local start_time = vim.loop.hrtime()
        for _ = 1, 100 do
            buffer.internal_render(bufnr)
        end
        local end_time = vim.loop.hrtime()
        local duration = (end_time - start_time) / 1000000
        logger.notify(string.format("Minimap for buffer %d generated in %fms", bufnr, duration), vim.log.levels.INFO)
        require("plenary.profile").stop()
    end)
end

---@type table<string, Neominimap.Subcommand>
M.subcommand_tbl = {
    perf = {
        impl = function(args)
            local logger = require("neominimap.logger")
            logger.log("Command perf triggered.", vim.log.levels.INFO)

            local bufnr = #args == 0 and api.nvim_get_current_buf() or tonumber(args[1])
            if bufnr then
                perf(bufnr)
            end
        end,
    },
}

return M
