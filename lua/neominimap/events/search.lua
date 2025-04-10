--- This code is adapted from the Satellite.nvim project by Lewis6991.
--- Satellite.nvim is available under the MIT License at https://github.com/lewis6991/satellite.nvim.

--- This module implements a user autocmd for Search events
---
--- The data fields is populated depending on the specific search event:
--- - 'key' is set to the key pressed for n,N,& and * events
--- - 'hlsearch' is set to the current value when v:hlsearch changes
--- - 'pattern' is set to the current search pattern when a new search is
---    performed

local api, fn = vim.api, vim.fn

local group = api.nvim_create_augroup("NeominimapSearch", {})

--- @param data any
local function exec_autocmd(data)
    api.nvim_exec_autocmds("User", {
        pattern = "Search",
        data = data,
    })
end

local last_hlsearch = vim.v.hlsearch

-- default value of 'updatetime' is too long (4s). Make it 1s at most.
local interval = math.min(vim.o.updatetime, 1000)

local function check_hlsearch()
    if vim.v.hlsearch ~= last_hlsearch then
        last_hlsearch = vim.v.hlsearch
        vim.schedule(function()
            exec_autocmd({ hlsearch = last_hlsearch })
        end)
    end
    vim.defer_fn(check_hlsearch, interval)
end

vim.defer_fn(check_hlsearch, interval)

vim.on_key(function(key)
    if api.nvim_get_mode().mode == "n" and key:match("[nN&*]") then
        exec_autocmd({ key = key })
    end
end)

api.nvim_create_autocmd({ "CmdlineEnter", "CmdLineChanged", "CmdlineLeave" }, {
    group = group,
    callback = function()
        if require("neominimap.util").is_search_mode() then
            exec_autocmd({ pattern = fn.getcmdline() })
        end
    end,
})
