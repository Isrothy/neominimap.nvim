local M = {}

local api = vim.api

local refresh = vim.schedule_wrap(function()
    require("neominimap.window.split.internal").refresh_source_in_current_tab()
end)

local refresh_tab = vim.schedule_wrap(function()
    require("neominimap.window.split.internal").refresh_current_tab()
end)

---@type Neominimap.Api.Global.Handler
M.global_apis = {
    ["on"] = vim.schedule_wrap(function()
        require("neominimap.window.split.internal").create_minimap_window_in_current_tab()
    end),
    ["off"] = vim.schedule_wrap(function()
        require("neominimap.window.split.internal").close_minimap_window_for_all_tabs()
    end),
    ["refresh"] = refresh,
}

---@type Neominimap.Api.Tab.Handler
M.tab_apis = {
    ["refresh"] = refresh_tab,
    ["on"] = refresh_tab,
    ["off"] = refresh_tab,
}

---@type Neominimap.Api.Win.Handler
M.win_apis = {
    ["refresh"] = refresh,
    ["on"] = refresh,
    ["off"] = refresh,
}

---@type Neominimap.Api.Focus.Handler
M.focus_apis = {
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
    ["toggle_focus"] = function()
        local tabid = api.nvim_get_current_tabpage()
        local winid = api.nvim_get_current_win()
        local window_map = require("neominimap.window.split.window_map")
        if window_map.is_minimap_window(tabid, winid) then
            M.focus_apis.unfocus(0)
        else
            M.focus_apis.focus(0)
        end
    end,
}
return M
