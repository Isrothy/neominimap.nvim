local config = require("neominimap.config")

local api = vim.api

api.nvim_set_hl(0, "NeominimapBackground", { link = "Normal", default = true })
api.nvim_set_hl(0, "NeominimapBorder", { link = "FloatBorder", default = true })
api.nvim_set_hl(0, "NeominimapCursorLine", { link = "CursorLine", default = true })
api.nvim_set_hl(0, "NeominimapCursorLineSign", { link = "CursorLineSign", default = true })
api.nvim_set_hl(0, "NeominimapCursorLineNr", { link = "CursorLineSign", default = true })
api.nvim_set_hl(0, "NeominimapCursorLineFold", { link = "CursorLineSign", default = true })

---@class Neominimap.Window
---@field create_autocmds fun(group: string | integer)
---@field get_global_apis fun():Neominimap.Api.Global.Handler
---@field get_win_apis fun():Neominimap.Api.Win.Handler
---@field get_tab_apis fun():Neominimap.Api.Tab.Handler
---@field get_focus_apis fun():Neominimap.Api.Focus.Handler

---@type table<Neominimap.Config.LayoutType,fun():Neominimap.Window>
local tbl = {
    ["float"] = function()
        return require("neominimap.window.float")
    end,
    ["split"] = function()
        return require("neominimap.window.split")
    end,
}

---@type Neominimap.Window
return tbl[config.layout]()
