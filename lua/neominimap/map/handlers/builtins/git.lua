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
    add = get_hl_fg("GitSignsAdd"),
    change = get_hl_fg("GitSignsChange"),
    delete = get_hl_fg("GitSignsDelete"),
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

api.nvim_set_hl(0, "NeominimapGitAddSign", { fg = colors.add, default = true })
api.nvim_set_hl(0, "NeominimapGitChangeSign", { fg = colors.change, default = true })
api.nvim_set_hl(0, "NeominimapGitDeleteSign", { fg = colors.delete, default = true })

api.nvim_set_hl(0, "NeominimapGitAddIcon", { fg = colors.add, default = true })
api.nvim_set_hl(0, "NeominimapGitChangeIcon", { fg = colors.change, default = true })
api.nvim_set_hl(0, "NeominimapGitDeleteIcon", { fg = colors.delete, default = true })

api.nvim_set_hl(0, "NeominimapGitAddLine", { bg = colors.add, default = true })
api.nvim_set_hl(0, "NeominimapGitChangeLine", { bg = colors.change, default = true })
api.nvim_set_hl(0, "NeominimapGitDeleteLine", { bg = colors.delete, default = true })

---@param bufnr integer
---@return Neominimap.Map.Handler.Annotation[]
M.get_annotations = function(bufnr)
    local ok, gitsigns = pcall(require, "gitsigns")
    if not ok or not gitsigns then
        return {}
    end
    --- @type {type:string, added:{start: integer, count: integer}}[]
    local hunks = gitsigns.get_hunks(bufnr)
    if not hunks then
        return {}
    end
    local util = require("neominimap.util")
    ---@type Neominimap.Map.Handler.Annotation[]
    local annotation = {}
    for _, hunk in ipairs(hunks) do
        local start = math.max(1, hunk.added.start)
        local end_ = start + math.max(0, hunk.added.count - 1)
        annotation[#annotation + 1] = {
            lnum = start,
            end_lnum = end_,
            priority = config.git.priority,
            id = toId[hunk.type],
            icon = toIcon[hunk.type],
            highlight = "NeominimapGit" .. util.capitalize(hunk.type) .. util.capitalize(config.git.mode),
        }
    end
    return annotation
end

return M
