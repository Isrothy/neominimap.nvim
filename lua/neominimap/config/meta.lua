local M = {}

---@class (exact) Neominimap.UserConfig
---@field auto_enable? boolean
---@field log_path? string
---@field log_level? integer
---@field notification_level? integer
---@field exclude_filetypes? string[]
---@field exclude_buftypes? string[]
---@field buf_filter? fun(bufnr: integer): boolean
---@field win_filter? fun(winid: integer): boolean
---@field max_win_height? integer
---@field minimap_width? integer
---@field x_multiplier? integer
---@field y_multiplier? integer
---@field sync_cursor? boolean
---@field click? Neominimap.ClickConfig
---@field delay? integer
---@field diagnostic? Neominimap.DiagnosticConfig
---@field git? Neominimap.GitConfig
---@field treesitter? Neominimap.TreesitterConfig
---@field search? Neominimap.SearchConfig
---@field margin? Neominimap.MarginConfig
---@field fold? Neominimap.FoldConfig
---@field z_index? integer
---@field window_border? string | string[] | [string, string][]
---@field winopt? fun(opt: table, winid: integer)
---@field bufopt? fun(opt: table, bufnr: integer)

---@class (exact) Neominimap.DiagnosticConfig
---@field enabled? boolean
---@field mode? Neominimap.Handler.MarkMode
---@field severity? integer
---@field priority? Neominimap.DiagnosticPriority

---@class (exact) Neominimap.DiagnosticPriority
---@field ERROR? integer
---@field WARN? integer
---@field INFO? integer
---@field HINT? integer

---@class (exact) Neominimap.GitConfig
---@field enabled? boolean
---@field mode? Neominimap.Handler.MarkMode
---@field priority? integer

---@class (exact) Neominimap.SearchConfig
---@field enabled? boolean
---@field mode? Neominimap.Handler.MarkMode
---@field priority? integer

---@class (exact) Neominimap.TreesitterConfig
---@field enabled? boolean
---@field priority? integer

---@class (exact) Neominimap.MarginConfig
---@field right? integer
---@field top? integer
---@field bottom? integer

---@class (exact) Neominimap.ClickConfig
---@field enabled? boolean
---@field auto_switch_focus? boolean

---@class (exact) Neominimap.FoldConfig
---@field enabled? boolean

---@type Neominimap.UserConfig | fun():Neominimap.UserConfig | nil
vim.g.neominimap = vim.g.neominimap

return M
