local M = {}

---@class Neominimap.InternalConfig
---@field auto_enable boolean
---@field log_path string
---@field log_level integer
---@field notification_level integer
---@field exclude_filetypes (string[])
---@field exclude_buftypes (string[])
---@field buf_filter fun(bufnr: integer): boolean
---@field win_filter fun(winid: integer): boolean
---@field max_minimap_height integer?
---@field minimap_width integer
---@field x_multiplier integer
---@field y_multiplier integer
---@field delay integer
---@field diagnostic Neominimap.InternalDiagnosticConfig
---@field treesitter Neominimap.InternalTreesitterConfig
---@field z_index integer
---@field window_border string | string[]
---@field margin Neominimap.InternalMargin

---@class Neominimap.InternalDiagnosticConfig
---@field enabled boolean
---@field severity integer
---@field priority Neominimap.InternalDiagnosticPriority

---@class Neominimap.InternalDiagnosticPriority
---@field ERROR integer
---@field WARN integer
---@field INFO integer
---@field HINT integer

---@class Neominimap.InternalTreesitterConfig
---@field enabled boolean
---@field priority integer

---@class Neominimap.InternalMargin
---@field right integer
---@field top integer
---@field bottom integer

---@enum Neominimap.Relative
M.RELATIVE = {
    win = "win",
    editor = "editor",
}

---@type Neominimap.InternalConfig
M.default_config = {
    auto_enable = true,
    log_level = vim.log.levels.OFF,
    notification_level = vim.log.levels.INFO,
    log_path = vim.fn.stdpath("data") .. "/neominimap.log",
    exclude_filetypes = { "help" },
    exclude_buftypes = {
        "nofile",
        "nowrite",
        "quickfix",
        "terminal",
        "prompt",
    },
    buf_filter = function()
        return true
    end,
    win_filter = function()
        return true
    end,
    max_minimap_height = nil,
    minimap_width = 20,
    x_multiplier = 4,
    y_multiplier = 1,
    delay = 200,
    diagnostic = {
        enabled = true,
        severity = vim.diagnostic.severity.WARN,
        priority = {
            ERROR = 100,
            WARN = 90,
            INFO = 80,
            HINT = 70,
        },
    },
    treesitter = {
        enabled = true,
        priority = 200,
    },
    margin = {
        right = 0,
        top = 0,
        bottom = 0,
    },
    z_index = 1, -- The z-index the floating window will be on
    window_border = "single", -- The border style of the floating window (accepts all usual options)
}

return M
