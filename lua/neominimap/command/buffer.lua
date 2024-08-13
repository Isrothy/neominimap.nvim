local api = vim.api

local M = {}

---@param bufnr integer
local refresh_attached_windows = function(bufnr)
    local win_list = api.nvim_list_wins()
    local updated_windows = {}
    for _, w in ipairs(win_list) do
        if api.nvim_win_get_buf(w) == bufnr then
            updated_windows[#updated_windows + 1] = w
        end
    end
    for _, winid in ipairs(updated_windows) do
        local window = require("neominimap.window")
        window.refresh_minimap_window(winid)
    end
end

---@param args string[]
---@return integer[]
local args_to_list = function(args)
    if #args == 0 then
        return { vim.api.nvim_get_current_buf() }
    else
        local bufnr = {}
        for _, arg in ipairs(args) do
            local nr = tonumber(arg)
            local logger = require("neominimap.logger")
            if not nr then
                logger.notify(string.format("Buffer number %s is not a number.", arg), vim.log.levels.ERROR)
            elseif not api.nvim_buf_is_valid(nr) then
                logger.notify(string.format("Buffer %d is not valid.", nr), vim.log.levels.ERROR)
            else
                table.insert(bufnr, tonumber(arg))
            end
        end
        return bufnr
    end
end

---@param bufnr integer
local refresh = function(bufnr)
    vim.schedule(function()
        local buffer = require("neominimap.buffer")
        buffer.refresh_minimap_buffer(bufnr)
        refresh_attached_windows(bufnr)
    end)
end

---@param bufnr integer
local function enable(bufnr)
    vim.b[bufnr].neominimap_disabled = false
    refresh(bufnr)
end

---@param bufnr integer
local function disable(bufnr)
    vim.b[bufnr].neominimap_disabled = true
    refresh(bufnr)
end

---@param bufnr integer
local function toggle(bufnr)
    if vim.b[bufnr].neominimap_disabled then
        enable(bufnr)
    else
        disable(bufnr)
    end
end

---@type table<string, Neominimap.Subcommand>
M.subcommand_tbl = {
    bufOn = {
        impl = function(args, opts)
            local bufnr = args_to_list(args)
            vim.tbl_map(enable, bufnr)
        end,
    },
    bufOff = {
        impl = function(args, opts)
            local bufnr = args_to_list(args)
            vim.tbl_map(disable, bufnr)
        end,
    },
    bufToggle = {
        impl = function(args, opts)
            local bufnr = args_to_list(args)
            vim.tbl_map(toggle, bufnr)
        end,
    },
    bufRefresh = {
        impl = function(args, opts)
            local bufnr = args_to_list(args)
            vim.tbl_map(refresh, bufnr)
        end,
    },
}

return M
