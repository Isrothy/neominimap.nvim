local M = {}

local refresh = vim.schedule_wrap(function(winid)
    require("neominimap.window.float.internal").refresh_minimap_window(winid)
end)

local refresh_all = vim.schedule_wrap(function()
    require("neominimap.window.float.internal").refresh_all_minimap_windows()
end)

local refresh_all_in_tab = vim.schedule_wrap(function(tabid)
    require("neominimap.window.float.internal").refresh_minimaps_in_tab(tabid)
end)

---@type Neominimap.Command.Global.Handler
M.global_cmds = {
    ["on"] = refresh_all,
    ["off"] = refresh_all,
    ["refresh"] = refresh_all,
}

---@type Neominimap.Command.Tab.Handler
M.tab_cmds = {
    ["tabRefresh"] = refresh_all_in_tab,
    ["tabOn"] = refresh_all_in_tab,
    ["tabOff"] = refresh_all_in_tab,
}

---@type Neominimap.Command.Win.Handler
M.win_cmds = {
    ["winRefresh"] = refresh,
    ["winOn"] = refresh,
    ["winOff"] = refresh,
}

---@type Neominimap.Command.Focus.Handler
M.focus_cmds = {
    ["focus"] = vim.schedule_wrap(function(winid)
        local ok = require("neominimap.window.float.internal").focus(winid)
        if not ok then
            local logger = require("neominimap.logger")
            logger.notify("Minimap can not be focused for current window", vim.log.levels.ERROR)
        end
    end),
    ["unfocus"] = vim.schedule_wrap(function(mwinid)
        local ok = require("neominimap.window.float.internal").unfocus(mwinid)
        if not ok then
            local logger = require("neominimap.logger")
            logger.notify("Minimap can not be unfocused for current window", vim.log.levels.ERROR)
        end
    end),
    ["toggleFocus"] = function(winid)
        local window_map = require("neominimap.window.float.window_map")
        if window_map.is_minimap_window(winid) then
            M.focus_cmds.unfocus(winid)
        else
            M.focus_cmds.focus(winid)
        end
    end,
}

return M
