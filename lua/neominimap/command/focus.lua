local api = vim.api

local M = {}

---@param winid integer
local focus = function(winid)
    local window = require("neominimap.window")
    if not window.focus(winid) then
        local logger = require("neominimap.logger")
        logger.notify("Minimap can not be focused for current window", vim.log.levels.ERROR)
    end
end

---@param mwinid integer
local unfocus = function(mwinid)
    local window = require("neominimap.window")
    if not window.unfocus(mwinid) then
        local logger = require("neominimap.logger")
        logger.notify("Minimap can not be unfocused for current window", vim.log.levels.ERROR)
    end
end

---@type table<string, Neominimap.Subcommand>
M.subcommand_tbl = {
    focus = {
        impl = function(args, opts)
            local winid = api.nvim_get_current_win()
            local window = require("neominimap.window")
            if not window.is_minimap_window(winid) then
                focus(winid)
            end
        end,
    },
    unfocus = {
        impl = function(args, opts)
            local winid = api.nvim_get_current_win()
            local window = require("neominimap.window")
            if window.is_minimap_window(winid) then
                unfocus(winid)
            end
        end,
    },
    toggleFocus = {
        impl = function(args, opts)
            local winid = api.nvim_get_current_win()
            local window = require("neominimap.window")
            if window.is_minimap_window(winid) then
                unfocus(winid)
            else
                focus(winid)
            end
        end,
    },
}

return M
