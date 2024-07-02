local M = {}

---@class Neominimap.InternalConfig
---@field auto_enable boolean
---@field log_path string
---@field log_level integer
---@field notification_level integer
---@field exclude_filetypes (string[])
---@field exclude_buftypes (string[])
---@field max_lines number?
---@field max_minimap_height number?
---@field minimap_width number
---@field x_multiplier integer
---@field y_multiplier integer
---@field delay integer
---@field use_lsp boolean
---@field use_highlight boolean
---@field use_treesitter boolean
---@field use_git boolean
---@field z_index number
---@field show_cursor boolean
---@field window_border string | string[]

---@enum Neominimap.Relative
M.RELATIVE = {
    win = "win",
    editor = "editor",
}

---@type Neominimap.InternalConfig
M.default_config = {
    auto_enable = true,
    exclude_filetypes = { "help" },
    log_level = vim.log.levels.OFF,
    notification_level = vim.log.levels.INFO,
    log_path = vim.fn.stdpath("data") .. "/neominimap.log",
    exclude_buftypes = {
        "nofile",
        "nowrite",
        "quickfix",
        "terminal",
        "prompt",
    },
    max_minimap_height = nil,
    max_lines = nil, -- If auto_enable is true, don't open the minimap for buffers which have more than this many lines.
    minimap_width = 20,
    x_multiplier = 4,
    y_multiplier = 1,
    delay = 200,
    use_lsp = true,
    use_highlight = true,
    use_treesitter = true,
    use_git = true,
    z_index = 1, -- The z-index the floating window will be on
    show_cursor = true,
    window_border = "single", -- The border style of the floating window (accepts all usual options)
    relative = M.RELATIVE.lines, -- What will be the minimap be placed relative to, "win": the current window, "editor": the entire editor
}

return M
