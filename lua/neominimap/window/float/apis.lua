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

---@type Neominimap.Api.Global.Handler
M.global_apis = {
    ["enable"] = refresh_all,
    ["disable"] = refresh_all,
    ["refresh"] = refresh_all,
}

---@type Neominimap.Api.Tab.Handler
M.tab_apis = {
    ["enable"] = refresh_all_in_tab,
    ["disable"] = refresh_all_in_tab,
    ["refresh"] = refresh_all_in_tab,
}

---@type Neominimap.Api.Win.Handler
M.win_apis = {
    ["enable"] = refresh,
    ["disable"] = refresh,
    ["refresh"] = refresh,
}

---@type Neominimap.Api.Focus.Handler
M.focus_apis = {
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
    ["toggle_focus"] = function(winid)
        local window_map = require("neominimap.window.float.window_map")
        if window_map.is_minimap_window(winid) then
            M.focus_apis.unfocus(winid)
        else
            M.focus_apis.focus(winid)
        end
    end,
}

return M
