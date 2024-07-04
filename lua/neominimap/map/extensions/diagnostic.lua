local M = {}

local api = vim.api
local diagnostic = vim.diagnostic
local config = require("neominimap.config").get()
local colors = config.diagnostic.colors

M.namespace = api.nvim_create_namespace("neominimap_diagnostic")

api.nvim_set_hl(0, "NeominimapErrorFg", { fg = colors.ERROR, default = true })
api.nvim_set_hl(0, "NeominimapWarnFg", { fg = colors.WARN, default = true })
api.nvim_set_hl(0, "NeominimapInfoFg", { fg = colors.INFO, default = true })
api.nvim_set_hl(0, "NeominimapHintFg", { fg = colors.HINT, default = true })

api.nvim_set_hl(0, "NeominimapErrorBg", { bg = colors.ERROR, default = true })
api.nvim_set_hl(0, "NeominimapWarnBg", { bg = colors.WARN, default = true })
api.nvim_set_hl(0, "NeominimapInfoBg", { bg = colors.INFO, default = true })
api.nvim_set_hl(0, "NeominimapHintBg", { bg = colors.HINT, default = true })

local colors_name = {
    "NeominimapError",
    "NeominimapWarn",
    "NeominimapInfo",
    "NeominimapHint",
}

local priority_list = {
    config.diagnostic.priority.ERROR,
    config.diagnostic.priority.WARN,
    config.diagnostic.priority.INFO,
    config.diagnostic.priority.HINT,
}

---@param bufnr integer
---@return Neominimap.Decoration[]
M.get_decorations = function(bufnr)
    local diags = diagnostic.get(bufnr, {
        severity = {
            min = config.diagnostic.severity,
        },
    })
    local ret = {}
    for _, diag in ipairs(diags) do
        ret[#ret + 1] = {
            lnum = diag.lnum + 1,
            end_lnum = diag.end_lnum + 1,
            col = diag.col + 1,
            end_col = diag.end_col + 1,
            priority = priority_list[diag.severity],
            color = colors_name[diag.severity],
        }
    end
    return ret
end

return M
