local M = {}

---@class Neominimap.InternalConfig
---@field auto_enable boolean
---@field exclude_filetypes (string[])
---@field exclude_buftypes (string[])
---@field max_lines number?
---@field max_minimap_height number?
---@field minimap_width number
---@field use_lsp boolean
---@field use_highlight boolean
---@field use_treesitter boolean
---@field use_git boolean
---@field z_index number
---@field show_cursor boolean
---@field screen_bounds Neominimap.ScreenBounds
---@field window_border string | string[]

---@enum Neominimap.ScreenBounds
M.SCREEN_BOUND = {
    lines = "lines",
    background = "background",
}

---@enum Neominimap.Relative
M.RELATIVE = {
    win = "win",
    editor = "editor",
}

---@type Neominimap.InternalConfig
M.default_config = {
    auto_enable = true,
    exclude_filetypes = { "help" },
    exclude_buftypes = { "nofile" },
    max_minimap_height = nil,
    max_lines = nil, -- If auto_enable is true, don't open the minimap for buffers which have more than this many lines.
    minimap_width = 20,
    use_lsp = true,
    use_highlight = true,
    use_treesitter = true,
    use_git = true,
    z_index = 1, -- The z-index the floating window will be on
    show_cursor = true,
    screen_bounds = M.SCREEN_BOUND.lines, -- How the visible area is displayed, "lines": lines above and below, "background": background color
    window_border = "single", -- The border style of the floating window (accepts all usual options)
    relative = M.RELATIVE.lines, -- What will be the minimap be placed relative to, "win": the current window, "editor": the entire editor
}

return M
