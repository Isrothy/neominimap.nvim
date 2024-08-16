local M = {}

local api = vim.api
local diagnostic = vim.diagnostic
local config = require("neominimap.config").get()

M.namespace = api.nvim_create_namespace("neominimap_diagnostic")

---@param name string
---@return string
local get_hl_fg = function(name)
    local hl = vim.api.nvim_get_hl(0, { name = name, link = false })
    return hl.fg and string.format("#%06x", hl.fg) or "NONE"
end

---@type table<string, string>
local colors = {
    ERROR = get_hl_fg("DiagnosticError"),
    WARN = get_hl_fg("DiagnosticWarn"),
    INFO = get_hl_fg("DiagnosticInfo"),
    HINT = get_hl_fg("DiagnosticHint"),
}

api.nvim_set_hl(0, "NeominimapErrorSign", { fg = colors.ERROR, default = true })
api.nvim_set_hl(0, "NeominimapWarnSign", { fg = colors.WARN, default = true })
api.nvim_set_hl(0, "NeominimapInfoSign", { fg = colors.INFO, default = true })
api.nvim_set_hl(0, "NeominimapHintSign", { fg = colors.HINT, default = true })

api.nvim_set_hl(0, "NeominimapErrorLine", { bg = colors.ERROR, default = true })
api.nvim_set_hl(0, "NeominimapWarnLine", { bg = colors.WARN, default = true })
api.nvim_set_hl(0, "NeominimapInfoLine", { bg = colors.INFO, default = true })
api.nvim_set_hl(0, "NeominimapHintLine", { bg = colors.HINT, default = true })

---@type string[]
local colors_name = {
    "NeominimapError",
    "NeominimapWarn",
    "NeominimapInfo",
    "NeominimapHint",
}

---@type integer[]
local priority_list = {
    config.diagnostic.priority.ERROR,
    config.diagnostic.priority.WARN,
    config.diagnostic.priority.INFO,
    config.diagnostic.priority.HINT,
}

---@param bufnr integer
---@return Neominimap.Handler.Mark[]
M.get_marks = function(bufnr)
    local diags = diagnostic.get(bufnr, {
        severity = {
            min = config.diagnostic.severity,
        },
    })
    ---@type Neominimap.Handler.Mark[]
    local marks = {}
    for _, diag in ipairs(diags) do
        local severity = diag.severity
        ---@cast severity integer
        marks[#marks + 1] = {
            lnum = diag.lnum + 1,
            end_lnum = diag.end_lnum + 1,
            priority = priority_list[severity],
            id = severity,
            line_highlight = colors_name[severity] .. "Line",
            sign_highlight = colors_name[severity] .. "Sign",
        }
    end
    return marks
end

return M
