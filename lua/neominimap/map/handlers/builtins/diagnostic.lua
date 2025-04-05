local api = vim.api
local diagnostic = vim.diagnostic
local config = require("neominimap.config")

local M = {}

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

api.nvim_set_hl(0, "NeominimapErrorIcon", { fg = colors.ERROR, default = true })
api.nvim_set_hl(0, "NeominimapWarnIcon", { fg = colors.WARN, default = true })
api.nvim_set_hl(0, "NeominimapInfoIcon", { fg = colors.INFO, default = true })
api.nvim_set_hl(0, "NeominimapHintIcon", { fg = colors.HINT, default = true })

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

---@type string[]
local icon_list = {
    config.diagnostic.icon.ERROR,
    config.diagnostic.icon.WARN,
    config.diagnostic.icon.INFO,
    config.diagnostic.icon.HINT,
}

---@param bufnr integer
---@return Neominimap.Map.Handler.Annotation[]
M.get_annotations = function(bufnr)
    --- @type vim.Diagnostic[]
    local diags = (function()
        if config.diagnostic.use_event_diagnostics then
            return require("neominimap.variables").b[bufnr].diagnostics
        else
            return diagnostic.get(bufnr, { severity = config.diagnostic.severity })
        end
    end)()

    ---@type Neominimap.Map.Handler.Annotation[]
    local annotation = {}
    local util = require("neominimap.util")
    for _, diag in ipairs(diags) do
        local severity = diag.severity
        ---@cast severity integer
        annotation[#annotation + 1] = {
            lnum = diag.lnum + 1,
            end_lnum = diag.end_lnum + 1,
            priority = priority_list[severity],
            icon = icon_list[severity],
            id = severity,
            highlight = colors_name[severity] .. util.capitalize(config.diagnostic.mode),
        }
    end
    return annotation
end

return M
