local M = {}

---@class Neominimap.InternalConfig
M.default_config = {
    auto_enable = true, ---@type boolean

    log_level = vim.log.levels.OFF, ---@type integer

    notification_level = vim.log.levels.INFO, ---@type integer

    log_path = vim.fn.stdpath("data") .. "/neominimap.log", ---@type string

    ---@type string[]
    exclude_filetypes = {
        "help",
    },

    ---@type string[]
    exclude_buftypes = {
        "nofile",
        "nowrite",
        "quickfix",
        "terminal",
        "prompt",
    },

    ---@type fun(bufnr: integer): boolean
    buf_filter = function()
        return true
    end,

    ---@type fun(winid: integer): boolean
    win_filter = function()
        return true
    end,

    max_minimap_height = nil, ---@type integer?
    minimap_width = 20, ---@type integer
    x_multiplier = 4, ---@type integer
    y_multiplier = 1, ---@type integer
    sync_cursor = true, ---@type boolean
    delay = 200, ---@type integer
    diagnostic = {
        enabled = true, ---@type boolean
        severity = vim.diagnostic.severity.WARN, ---@type integer
        priority = {
            ERROR = 100, ---@type integer
            WARN = 90, ---@type integer
            INFO = 80, ---@type integer
            HINT = 70, ---@type integer
        },
    },
    treesitter = {
        enabled = true, ---@type boolean
        priority = 200, ---@type integer
    },
    margin = {
        right = 0, ---@type integer
        top = 0, ---@type integer
        bottom = 0, ---@type integer
    },
    fold = {
        enabled = true, ---@type boolean
    },
    z_index = 1, ---@type integer
    window_border = "single", ---@type string | string[] | [string, string][]

    ---@type table | fun(winid: integer) : table
    winopt = {},

    ---@type table | fun(bufnr: integer) : table
    bufopt = {},
}

return M
