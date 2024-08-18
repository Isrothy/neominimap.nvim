local M = {}

---@class Neominimap.InternalConfig
M.default_config = {
    -- Enable the plugin by default
    auto_enable = true, ---@type boolean

    -- Log level
    log_level = vim.log.levels.OFF, ---@type integer

    -- Notification level
    notification_level = vim.log.levels.INFO, ---@type integer

    -- Path to the log file
    log_path = vim.fn.stdpath("data") .. "/neominimap.log", ---@type string

    -- Minimap will not be created for buffers of these types
    ---@type string[]
    exclude_filetypes = {
        "help",
    },

    -- Minimap will not be created for buffers of these types
    ---@type string[]
    exclude_buftypes = {
        "nofile",
        "nowrite",
        "quickfix",
        "terminal",
        "prompt",
    },

    -- When false is returned, the minimap will not be created for this buffer
    ---@type fun(bufnr: integer): boolean
    buf_filter = function()
        return true
    end,

    -- When false is returned, the minimap will not be created for this window
    ---@type fun(winid: integer): boolean
    win_filter = function()
        return true
    end,

    -- Maximum height for the minimap
    -- If set to nil, there is no maximum height restriction
    max_minimap_height = nil, ---@type integer?

    -- Width of the minimap window
    minimap_width = 20, ---@type integer

    -- How many columns a dot should span
    x_multiplier = 4, ---@type integer

    -- How many rows a dot should span
    y_multiplier = 1, ---@type integer

    -- For performance issue, when text changed,
    -- minimap is refreshed after a certain delay
    -- Set the delay in milliseconds
    delay = 200, ---@type integer

    -- Sync the cursor position with the minimap
    sync_cursor = true, ---@type boolean

    click = {
        -- Enable mouse click on minimap
        enabled = false, ---@type boolean
        -- Automatically switch focus to minimap when clicked
        auto_switch_focus = true, ---@type boolean
    },

    diagnostic = {
        enabled = true, ---@type boolean
        severity = vim.diagnostic.severity.WARN, ---@type integer
        mode = "line", ---@type Neominimap.Handler.MarkMode
        priority = {
            ERROR = 100, ---@type integer
            WARN = 90, ---@type integer
            INFO = 80, ---@type integer
            HINT = 70, ---@type integer
        },
    },

    git = {
        enabled = true, ---@type boolean
        mode = "sign", ---@type Neominimap.Handler.MarkMode
        priority = 6, ---@type integer
    },

    search = {
        enabled = false, ---@type boolean
        mode = "line", ---@type Neominimap.Handler.MarkMode
        priority = 20, ---@type integer
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
        -- Considering fold when rendering minimap
        enabled = true, ---@type boolean
    },

    -- Z-index of the floating window
    z_index = 1, ---@type integer

    -- Border style of the floating window
    -- Accepts all usual border style options (e.g., "single", "double")
    window_border = "single", ---@type string | string[] | [string, string][]

    ---Overrite the default winopt
    ---@param opt table
    ---@param winid integer the window id of the parent window, NOT minimap window
    winopt = function(opt, winid) end,

    ---Overrite the default bufopt
    ---@param opt table
    ---@param bufnr integer the buffer id of the parent buffer, NOT minimap buffer
    bufopt = function(opt, bufnr) end,
}

return M
