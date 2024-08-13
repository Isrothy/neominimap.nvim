local api = vim.api

local M = {}

local args_to_list = function(args)
    if #args == 0 then
        return { vim.api.nvim_get_current_win() }
    else
        local bufnr = {}
        for _, arg in ipairs(args) do
            local nr = tonumber(arg)
            local logger = require("neominimap.logger")
            if not nr then
                logger.notify(string.format("Window ID %s is not a number.", arg), vim.log.levels.ERROR)
            elseif not api.nvim_win_is_valid(nr) then
                logger.notify(string.format("Window ID %d is not valid.", nr), vim.log.levels.ERROR)
            else
                table.insert(bufnr, tonumber(arg))
            end
        end
        return bufnr
    end
end

---@param winid integer
local refresh = function(winid)
    vim.schedule(function()
        local window = require("neominimap.window")
        window.refresh_minimap_window(winid)
    end)
end

---@param winid integer
local function enable(winid)
    vim.w[winid].neominimap_disabled = false
    refresh(winid)
end

---@param winid integer
local function disable(winid)
    vim.w[winid].neominimap_disabled = true
    refresh(winid)
end

---@param winid integer
local function toggle(winid)
    if vim.w[winid].neominimap_disabled then
        enable(winid)
    else
        disable(winid)
    end
end

---@type table<string, Neominimap.Subcommand>
M.subcommand_tbl = {
    winOn = {
        impl = function(args, opts)
            local winid = args_to_list(args)
            vim.tbl_map(enable, winid)
        end,
    },
    winOff = {
        impl = function(args, opts)
            local winid = args_to_list(args)
            vim.tbl_map(disable, winid)
        end,
    },
    winToggle = {
        impl = function(args, opts)
            local winid = args_to_list(args)
            vim.tbl_map(toggle, winid)
        end,
    },
    winRefresh = {
        impl = function(args, opts)
            local winid = args_to_list(args)
            vim.tbl_map(refresh, winid)
        end,
    },
}

return M
