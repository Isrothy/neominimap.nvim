--- This module implements a user autocmd for Search events
---
--- The data fields is populated depending on the specific search event:
--- - 'key' is set to the key pressed for n,N,& and * events
--- - 'hlsearch' is set to the current value when v:hlsearch changes
--- - 'pattern' is set to the current search pattern when a new search is
---    performed
---

local api, fn = vim.api, vim.fn
local M = {}

--- @param data any
local function exec_autocmd(data)
    api.nvim_exec_autocmds("User", {
        pattern = "Search",
        data = data,
    })
end

local last_hlsearch = vim.v.hlsearch

local timer = assert(vim.loop.new_timer())

-- default value of 'updatetime' is too long (4s). Make it 1s at most.
local interval = math.min(vim.o.updatetime, 1000)

timer:start(0, interval, function()
    -- Regularly check v:hlsearch
    if vim.v.hlsearch ~= last_hlsearch then
        last_hlsearch = vim.v.hlsearch
        vim.schedule(function()
            exec_autocmd({ hlsearch = last_hlsearch })
        end)
    end
end)

-- Refresh when activating search nav mappings
for _, seq in ipairs({ "n", "N", "&", "*" }) do
    if fn.maparg(seq) == "" then
        vim.keymap.set("n", seq, function()
            exec_autocmd({ key = seq })
            return seq
        end, { expr = true })
    end
end

local group = api.nvim_create_augroup("NeominimapSearch", {})

M.create_autocmds = function()
    api.nvim_create_autocmd({ "CmdlineEnter", "CmdLineChanged", "CmdlineLeave" }, {
        group = group,
        callback = function()
            if require("neominimap.util").is_search_mode() then
                exec_autocmd({ pattern = fn.getcmdline() })
            end
        end,
    })
    api.nvim_create_autocmd("User", {
        group = group,
        pattern = "Search",
        callback = function()
            local logger = require("neominimap.logger")
            logger.log("Search event triggered", vim.log.levels.TRACE)
            vim.schedule(function()
                local buffer = require("neominimap.buffer")
                local visible_buffers = require("neominimap.util").get_visible_buffers()
                for _, bufnr in ipairs(visible_buffers) do
                    logger.log(string.format("Updating search status for buffer %d.", bufnr), vim.log.levels.TRACE)
                    buffer.update_search(bufnr)
                    logger.log(string.format("Search status updated for buffer %d.", bufnr), vim.log.levels.TRACE)
                end
                logger.log("Search status refreshed.", vim.log.levels.TRACE)
            end)
        end,
    })
end

M.cleanup_autocmds = function()
    api.nvim_clear_autocmds({ group = group })
end

return M
