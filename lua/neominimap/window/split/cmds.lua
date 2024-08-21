local M = {}

local api = vim.api

local refresh = vim.schedule_wrap(function()
    require("neominimap.window.split.internal").refresh_source_in_current_tab()
end)

local refresh_tab = vim.schedule_wrap(function()
    require("neominimap.window.split.internal").refresh_current_tab()
end)

---@type Neominimap.Command.Global.Handler
M.global_cmds = {
    ["on"] = vim.schedule_wrap(function()
        require("neominimap.window.split.internal").create_minimap_window_in_current_tab()
    end),
    ["off"] = vim.schedule_wrap(function()
        require("neominimap.window.split.internal").close_minimap_window_for_all_tabs()
    end),
    ["refresh"] = refresh,
}

---@type Neominimap.Command.Tab.Handler
M.tab_cmds = {
    ["tabRefresh"] = refresh_tab,
    ["tabOn"] = refresh_tab,
    ["tabOff"] = refresh_tab,
}

---@type Neominimap.Command.Win.Handler
M.win_cmds = {
    ["winRefresh"] = refresh,
    ["winOn"] = refresh,
    ["winOff"] = refresh,
}

---@type Neominimap.Command.Focus.Handler
M.focus_cmds = {
    ["focus"] = vim.schedule_wrap(function()
        local ok = require("neominimap.window.split.internal").focus()
        if not ok then
            local logger = require("neominimap.logger")
            logger.notify("Minimap can not be focused for current window", vim.log.levels.ERROR)
        end
    end),
    ["unfocus"] = vim.schedule_wrap(function()
        local ok = require("neominimap.window.split.internal").unfocus()
        if not ok then
            local logger = require("neominimap.logger")
            logger.notify("Minimap can not be unfocused for current window", vim.log.levels.ERROR)
        end
    end),
    ["toggleFocus"] = function()
        local tabid = api.nvim_get_current_tabpage()
        local winid = api.nvim_get_current_win()
        local window_map = require("neominimap.window.split.window_map")
        if window_map.is_minimap_window(tabid, winid) then
            M.focus_cmds.unfocus(0)
        else
            M.focus_cmds.focus(0)
        end
    end,
}
return M
