local config = require("neominimap.config")

local api = vim.api

api.nvim_set_hl(0, "NeominimapBackground", { link = "Normal", default = true })
api.nvim_set_hl(0, "NeominimapBorder", { link = "FloatBorder", default = true })
api.nvim_set_hl(0, "NeominimapCursorLine", { link = "CursorLine", default = true })
api.nvim_set_hl(0, "NeominimapCursorLineSign", { link = "CursorLineSign", default = true })
api.nvim_set_hl(0, "NeominimapCursorLineNr", { link = "CursorLineSign", default = true })
api.nvim_set_hl(0, "NeominimapCursorLineFold", { link = "CursorLineSign", default = true })

---@class Neominimap.Window
---@field create_autocmds fun()
---@field global_cmds Neominimap.Command.Global.Handler
---@field win_cmds Neominimap.Command.Win.Handler
---@field tab_cmds Neominimap.Command.Tab.Handler
---@field focus_cmds Neominimap.Command.Focus.Handler

---@type table<Neominimap.Config.LayoutType, Neominimap.Window>
local tbl = {
    ["float"] = require("neominimap.window.float"),
    ["split"] = require("neominimap.window.split"),
}

return tbl[config.layout]
