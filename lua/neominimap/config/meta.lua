local M = {}

---@class (exact) Neominimap.UserConfig
---@field auto_enable? boolean
---@field log_path? string
---@field log_level? Neominimap.Log.Levels
---@field notification_level? Neominimap.Log.Levels
---@field exclude_filetypes? string[]
---@field exclude_buftypes? string[]
---@field buf_filter? fun(bufnr: integer): boolean
---@field win_filter? fun(winid: integer): boolean
---@field x_multiplier? integer
---@field y_multiplier? integer
---@field sync_cursor? boolean
---@field layout? Neominimap.Config.LayoutType
---@field float? Neominimap.FloatConfig
---@field split? Neominimap.SplitConfig
---@field click? Neominimap.ClickConfig
---@field delay? integer
---@field diagnostic? Neominimap.DiagnosticConfig
---@field git? Neominimap.GitConfig
---@field treesitter? Neominimap.TreesitterConfig
---@field search? Neominimap.SearchConfig
---@field mark? Neominimap.MarkConfig
---@field fold? Neominimap.FoldConfig
---@field winopt? fun(opt: vim.wo, winid: integer)
---@field bufopt? fun(opt: vim.bo, bufnr: integer)
---@field handler? Neominimap.Map.Handler[]

---@class (exact) Neominimap.SplitConfig
---@field minimap_width? integer
---@field fix_width? boolean
---@field direction? Neominimap.Config.SplitDirection
---@field close_if_last_window? boolean

---@class (exact) Neominimap.FloatConfig
---@field max_minimap_height? integer
---@field minimap_width? integer
---@field margin? {right?: integer, top?: integer, bottom?: integer}
---@field z_index? integer
---@field window_border? string | string[] | [string, string][]

---@class (exact) Neominimap.DiagnosticConfig
---@field enabled? boolean
---@field mode? Neominimap.Handler.Annotation.Mode
---@field severity? vim.diagnostic.SeverityInt
---@field priority? {ERROR?: integer, WARN?: integer, INFO?: integer, HINT?: integer}
---@field icon? {ERROR?: string, WARN?: string, INFO?: string, HINT?: string}

---@class (exact) Neominimap.GitConfig
---@field enabled? boolean
---@field mode? Neominimap.Handler.Annotation.Mode
---@field priority? integer
---@field icon? {add?: string, change?: string, delete?: string}

---@class (exact) Neominimap.SearchConfig
---@field enabled? boolean
---@field mode? Neominimap.Handler.Annotation.Mode
---@field priority? integer
---@field icon? string

---@class (exact) Neominimap.MarkConfig
---@field enabled? boolean
---@field mode? Neominimap.Handler.Annotation.Mode
---@field priority? integer
---@field key? string
---@field show_builtins? boolean

---@class (exact) Neominimap.TreesitterConfig
---@field enabled? boolean
---@field priority? integer

---@class (exact) Neominimap.ClickConfig
---@field enabled? boolean
---@field auto_switch_focus? boolean

---@class (exact) Neominimap.FoldConfig
---@field enabled? boolean

---@type Neominimap.UserConfig | fun():Neominimap.UserConfig | nil
vim.g.neominimap = vim.g.neominimap

return M
