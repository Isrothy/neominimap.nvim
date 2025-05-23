local api = vim.api
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
    add = get_hl_fg("MiniDiffSignAdd"),
    change = get_hl_fg("MiniDiffSignChange"),
    delete = get_hl_fg("MiniDiffSignDelete"),
}

---@type table<string, string>
local toIcon = {
    ["add"] = config.git.icon.add,
    ["change"] = config.git.icon.change,
    ["delete"] = config.git.icon.delete,
}

---@type table<string, integer>
local toId = {
    ["add"] = 1,
    ["change"] = 2,
    ["delete"] = 3,
}

api.nvim_set_hl(0, "NeominimapMiniDiffAddSign", { fg = colors.add, default = true })
api.nvim_set_hl(0, "NeominimapMiniDiffChangeSign", { fg = colors.change, default = true })
api.nvim_set_hl(0, "NeominimapMiniDiffDeleteSign", { fg = colors.delete, default = true })

api.nvim_set_hl(0, "NeominimapMiniDiffAddIcon", { fg = colors.add, default = true })
api.nvim_set_hl(0, "NeominimapMiniDiffChangeIcon", { fg = colors.change, default = true })
api.nvim_set_hl(0, "NeominimapMiniDiffDeleteIcon", { fg = colors.delete, default = true })

api.nvim_set_hl(0, "NeominimapMiniDiffAddLine", { bg = colors.add, default = true })
api.nvim_set_hl(0, "NeominimapMiniDiffChangeLine", { bg = colors.change, default = true })
api.nvim_set_hl(0, "NeominimapMiniDiffDeleteLine", { bg = colors.delete, default = true })

---@param bufnr integer
---@return Neominimap.Map.Handler.Annotation[]
M.get_annotations = function(bufnr)
    local ok, minidif = pcall(require, "mini.diff")
    if not ok or not minidif then
        return {}
    end
    local data = minidif.get_buf_data(bufnr)
    if not data then
        return {}
    end
    --- @type {buf_start: number, buf_count:number, type: "add" | "change" | "delete"}[]
    local hunks = data.hunks
    if not hunks then
        return {}
    end
    local util = require("neominimap.util")
    ---@type Neominimap.Map.Handler.Annotation[]
    local annotation = {}
    for _, hunk in ipairs(hunks) do
        local start = math.max(1, hunk.buf_start)
        local end_ = start + math.max(0, hunk.buf_count - 1)
        annotation[#annotation + 1] = {
            lnum = start,
            end_lnum = end_,
            priority = config.git.priority,
            id = toId[hunk.type],
            icon = toIcon[hunk.type],
            highlight = "NeominimapMiniDiff" .. util.capitalize(hunk.type) .. util.capitalize(config.git.mode),
        }
    end
    return annotation
end

return M
