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
    buffer.wipe_out_all_minimap_buffers()
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
    api.nvim_set_hl(0, "NeominimapBackground", { link = "Normal", default = true })
    api.nvim_set_hl(0, "NeominimapBorder", { link = "FloatBorder", default = true })

    local gid = api.nvim_create_augroup("Neominimap", { clear = true })
    api.nvim_create_autocmd("VimEnter", {
        group = gid,
        callback = vim.schedule_wrap(function()
            log.notify("VimEnter is triggered", vim.log.levels.INFO)
            if config.auto_enable then
                M.open_minimap()
            end
        end),
    })
    api.nvim_create_autocmd({ "BufReadPost", "BufNewFile" }, {
        group = gid,
        callback = function(args)
            log.notify("BufReadPost or BufNew is triggered", vim.log.levels.INFO)
            log.notify("New Buffer is loaded " .. tostring(args.buf), vim.log.levels.INFO)
            vim.schedule(function()
                if M.enabled then
                    local buffer = require("neominimap.buffer")
                    local bufnr = tonumber(args.buf)
                    ---@cast bufnr integer
                    buffer.create_minimap_buffer(bufnr)
                end
            end)
        end,
    })
    api.nvim_create_autocmd("BufWipeout", {
        group = gid,
        callback = function(args)
            log.notify("BufWipeout is triggered", vim.log.levels.INFO)
            log.notify("Buf " .. tostring(args.buf) .. " is to be wiped out", vim.log.levels.INFO)
            vim.schedule(function()
                local buffer = require("neominimap.buffer")
                local bufnr = tonumber(args.buf)
                ---@cast bufnr integer
                buffer.wipe_out_minimap_buffer(bufnr)
            end)
        end,
    })
    api.nvim_create_autocmd("BufWinEnter", {
        group = gid,
        callback = vim.schedule_wrap(function()
            log.notify("BufWinEnter is triggered", vim.log.levels.INFO)
            if M.enabled then
                local winid = api.nvim_get_current_win()
                log.notify("Winid: " .. tostring(winid), vim.log.levels.INFO)
                local window = require("neominimap.window")
                window.refresh_minimap_window(winid)
            end
        end),
    })
    api.nvim_create_autocmd("WinNew", {
        group = gid,
        callback = function(args)
            log.notify("WinNew is triggered", vim.log.levels.INFO)
            vim.schedule(function()
                local winid = api.nvim_get_current_win()
                log.notify("Window " .. tostring(winid) .. " is created", vim.log.levels.INFO)
                if M.enabled then
                    local window = require("neominimap.window")
                    window.refresh_minimap_window(winid)
                end
            end)
        end,
    })
    api.nvim_create_autocmd("WinClosed", {
        group = gid,
        callback = function(args)
            log.notify("WinClosed is triggered", vim.log.levels.INFO)
            local winid = tonumber(args.match) -- FUCK LUA API
            vim.schedule(function()
                log.notify(tostring(winid) .. " is to be removed", vim.log.levels.INFO)
                local window = require("neominimap.window")
                ---@cast winid integer
                window.close_minimap_window(winid)
            end)
        end,
    })
    api.nvim_create_autocmd("TabEnter", {
        group = gid,
        callback = vim.schedule_wrap(function()
            log.notify("TabEnter is triggered", vim.log.levels.INFO)
            local window = require("neominimap.window")
            local tid = api.nvim_get_current_tabpage()
            window.refresh_minimaps_in_tab(tid)
        end),
    })
    api.nvim_create_autocmd("WinResized", {
        group = gid,
        callback = function()
            log.notify("WinResized is triggered", vim.log.levels.INFO)
            local win_list = vim.deepcopy(vim.v.event.windows)
            log.notify(vim.inspect(win_list) .. " is resized", vim.log.levels.INFO)
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
            log.notify(vim.inspect(win_list) .. " is scrolled", vim.log.levels.INFO)
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
