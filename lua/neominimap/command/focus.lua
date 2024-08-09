local api = vim.api
local window = require("neominimap.window")
local logger = require("neominimap.logger")

local M = {}

---@param winid integer
local focus = function(winid)
    if not window.focus(winid) then
        logger.notify("Minimap can not be focused for current window", vim.log.levels.ERROR)
    end
end

---@param mwinid integer
local unfocus = function(mwinid)
    if not window.unfocus(mwinid) then
        logger.notify("Minimap can not be unfocused for current window", vim.log.levels.ERROR)
    end
end

---@type table<string, Neominimap.Subcommand>
M.subcommand_tbl = {
    focus = {
        impl = function(args, opts)
            local winid = api.nvim_get_current_win()
            if not window.is_minimap_window(winid) then
                focus(winid)
            end
        end,
    },
    unfocus = {
        impl = function(args, opts)
            local winid = api.nvim_get_current_win()
            if window.is_minimap_window(winid) then
                unfocus(winid)
            end
        end,
    },
    toggleFocus = {
        impl = function(args, opts)
            local winid = api.nvim_get_current_win()
            if window.is_minimap_window(winid) then
                unfocus(winid)
            else
                focus(winid)
            end
        end,
    },
}

return M
