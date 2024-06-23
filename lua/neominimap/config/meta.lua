local M = {}

---@class Neominimap.UserConfig
---@field auto_enable boolean?
---@field exclude_filetypes (string[])?
---@field exclude_buftypes (string[])?
---@field max_lines number?
---@field max_minimap_height number?
---@field minimap_width number?
---@field use_lsp boolean?
---@field use_highlight boolean?
---@field use_treesitter boolean?
---@field use_git boolean?
---@field z_index number?
---@field show_cursor boolean?
---@field screen_bounds Neominimap.ScreenBounds?
---@field window_border (string | string[])?

---@type Neominimap.UserConfig | fun():Neominimap.UserConfig | nil
vim.g.neominimap = vim.g.neominimap

return M
