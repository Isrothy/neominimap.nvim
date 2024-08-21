---@alias Neominimap.Config.LayoutType "split" | "float"

---@class Neominimap.Internal.Config
local M = {
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

    -- How many columns a dot should span
    x_multiplier = 4, ---@type integer

    -- How many rows a dot should span
    y_multiplier = 1, ---@type integer

    --- Either `split` or `float`
    --- When layout is set to `float`,
    --- the minimap will be created in floating windows attached to all suitable windows
    --- When layout is set to `split`,
    --- the minimap will be created in one split window
    layout = "float", ---@type Neominimap.Config.LayoutType

    --- Used when `layout` is set to `split`
    split = {
        minimap_width = 20, ---@type integer
    },

    --- Used when `layout` is set to `float`
    float = {
        minimap_width = 20, ---@type integer

        --- If set to nil, there is no maximum height restriction
        --- @type integer
        max_minimap_height = nil,

        margin = {
            right = 0, ---@type integer
            top = 0, ---@type integer
            bottom = 0, ---@type integer
        },
        z_index = 1, ---@type integer

        --- Border style of the floating window.
        --- Accepts all usual border style options (e.g., "single", "double")
        --- @type string | string[] | [string, string][]
        window_border = "single",
    },

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

    fold = {
        -- Considering fold when rendering minimap
        enabled = true, ---@type boolean
    },

    ---Overrite the default winopt
    ---@param opt table
    ---@param winid integer the window id of the source window, NOT minimap window
    winopt = function(opt, winid) end,

    ---Overrite the default bufopt
    ---@param opt table
    ---@param bufnr integer the buffer id of the source buffer, NOT minimap buffer
    bufopt = function(opt, bufnr) end,
}

---@return integer
function M:get_minimap_width()
    return self[self.layout].minimap_width
end

return M
