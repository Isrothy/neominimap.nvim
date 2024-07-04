local M = {}

local api = vim.api
local diagnostic = vim.diagnostic
local config = require("neominimap.config").get()
local colors = config.diagnostic.colors

M.namespace = api.nvim_create_namespace("neominimap_diagnostic")

api.nvim_set_hl(M.namespace, "NeominimapErrorFg", { fg = colors.ERROR })
api.nvim_set_hl(M.namespace, "NeominimapWarnFg", { fg = colors.WARN })
api.nvim_set_hl(M.namespace, "NeominimapInfoFg", { fg = colors.INFO })
api.nvim_set_hl(M.namespace, "NeominimapHintFg", { fg = colors.HINT })

api.nvim_set_hl(M.namespace, "NeominimapErrorBg", { bg = colors.ERROR })
api.nvim_set_hl(M.namespace, "NeominimapWarnBg", { bg = colors.WARN })
api.nvim_set_hl(M.namespace, "NeominimapInfoBg", { bg = colors.INFO })
api.nvim_set_hl(M.namespace, "NeominimapHintBg", { bg = colors.HINT })

local colors_name = {
    "NeominimapError",
    "NeominimapWarn",
    "NeominimapInfo",
    "NeominimapHintFg",
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
