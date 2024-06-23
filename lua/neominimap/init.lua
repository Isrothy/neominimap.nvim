local M = {}

local api = vim.api
local log = require("neominimap.log")
local config = require("neominimap.config").get()

---@type boolean
M.enabled = false

function M.open_minimap()
    if M.enabled then
        return
    end
    M.enabled = true
    local window = require("neominimap.window")
    local buffer = require("neominimap.buffer")
    log.notify("opening minimap", vim.log.levels.INFO)
    buffer.create_all_minimap_buffers()
    window.create_all_minimap_windows()
    window.refresh_all_minimap_windows()
    log.notify("opened minimap", vim.log.levels.INFO)
end

function M.close_minimap()
    if not M.enabled then
        return
    end
    M.enabled = false
    local window = require("neominimap.window")
    local buffer = require("neominimap.buffer")
    log.notify("closing minimap", vim.log.levels.INFO)
    window.close_all_minimap_windows()
    buffer.remove_all_minimap_buffers()
    log.notify("closed minimap", vim.log.levels.INFO)
end

function M.toggle_minimap()
    if M.enabled then
        M.close_minimap()
    else
        M.open_minimap()
    end
end

M.setup = function()
    local ns = api.nvim_create_namespace("neominimap")
    api.nvim_set_hl(ns, "NeominimapBackground", { link = "Normal", default = true })
    api.nvim_set_hl(ns, "NeominimapBorder", { link = "FloatBorder", default = true })

    local gid = api.nvim_create_augroup("Neominimap", { clear = true })
    -- api.nvim_create_autocmd({ "BufRead", "BufNew" }, {
    --     group = gid,
    --     callback = vim.schedule_wrap(function()
    --         -- log.notify("BufRead or BufNew triggered", vim.log.levels.INFO)
    --         if M.enabled then
    --             local buffer = require("neominimap.buffer")
    --             local bufnr = api.nvim_get_current_buf()
    --             buffer.create_minimap_buffer(bufnr)
    --         end
    --     end),
    -- })
    -- api.nvim_create_autocmd("BufDelete", {
    --     group = gid,
    --     callback = vim.schedule_wrap(function()
    --         -- log.notify("BufDelete triggered", vim.log.levels.INFO)
    --         local buffer = require("neominimap.buffer")
    --         local bufnr = api.nvim_get_current_buf()
    --         buffer.remove_minimap_buffer(bufnr)
    --     end),
    -- })
    -- api.nvim_create_autocmd("WinNew", {
    --     group = gid,
    --     callback = function(args)
    --         vim.schedule_wrap(function()
    --             -- log.notify("WinNew triggered", vim.log.levels.INFO)
    --             local winid = args.match
    --             if M.enabled then
    --                 local window = require("neominimap.window")
    --                 window.create_minimap_window(winid)
    --                 window.refresh_code_minimap(winid)
    --             end
    --         end)
    --     end,
    -- })
    api.nvim_create_autocmd("VimEnter", {
        group = gid,
        callback = vim.schedule_wrap(function()
            if config.auto_enable then
                M.open_minimap()
            end
        end),
    })
    api.nvim_create_autocmd("WinClosed", {
        group = gid,
        callback = function(args)
            local winid = tonumber(args.match) -- FUCK LUA API
            vim.schedule(function()
                log.notify(tostring(winid) .. " is to be removed", vim.log.levels.INFO)
                local window = require("neominimap.window")
                ---@cast winid integer
                window.close_minimap_window(winid)
            end)
        end,
    })
    -- api.nvim_create_autocmd("TabEnter", {
    --     group = gid,
    --     callback = vim.schedule_wrap(function()
    --         -- log.notify("TabEnter triggered", vim.log.levels.INFO)
    --         local window = require("neominimap.window")
    --         local tid = api.nvim_get_current_tabpage()
    --         window.refresh_minimaps_in_tab(tid)
    --     end),
    -- })
    api.nvim_create_autocmd("WinResized", {
        group = gid,
        callback = function()
            log.notify("WinResized is triggered", vim.log.levels.INFO)
            local win_list = vim.deepcopy(vim.v.event.windows)
            vim.schedule(function()
                if M.enabled then
                    local window = require("neominimap.window")
                    for _, winid in ipairs(win_list) do
                        window.create_minimap_window(winid)
                        window.refresh_minimap_window(winid)
                    end
                end
            end)
        end,
    })
    api.nvim_create_autocmd("WinScrolled", {
        group = gid,
        callback = function()
            log.notify("WinScrolled is triggered", vim.log.levels.INFO)
            local win_list = {}
            for winid, _ in pairs(vim.v.event) do
                if winid ~= "all" then
                    win_list[#win_list + 1] = tonumber(winid)
                end
            end
            vim.schedule(function()
                if M.enabled then
                    local window = require("neominimap.window")
                    for _, winid in ipairs(win_list) do
                        window.refresh_minimap_window(winid)
                    end
                end
            end)
        end,
    })
end

return M
