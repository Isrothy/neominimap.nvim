local M = {}

local api = vim.api
local config = require("neominimap.config")

M.namespace = api.nvim_create_namespace("neominimap_git")

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
local toSignHighlight = {
    ["add"] = "NeominimapGitAddSign",
    ["change"] = "NeominimapGitChangeSign",
    ["delete"] = "NeominimapGitDeleteSign",
}

---@type table<string, string>
local toIconHighlight = {
    ["add"] = "NeominimapGitAddIcon",
    ["change"] = "NeominimapGitChangeIcon",
    ["delete"] = "NeominimapGitDeleteIcon",
}

---@type table<string, string>
local toLineHighlight = {
    ["add"] = "NeominimapGitAddLine",
    ["change"] = "NeominimapGitChangeLine",
    ["delete"] = "NeominimapGitDeleteLine",
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

api.nvim_set_hl(0, "NeominimapGitAddSign", { fg = colors.add, bg = "NONE", default = true })
api.nvim_set_hl(0, "NeominimapGitChangeSign", { fg = colors.change, bg = "NONE", default = true })
api.nvim_set_hl(0, "NeominimapGitDeleteSign", { fg = colors.delete, bg = "NONE", default = true })

api.nvim_set_hl(0, "NeominimapGitAddIcon", { fg = colors.add, default = true })
api.nvim_set_hl(0, "NeominimapGitChangeIcon", { fg = colors.change, default = true })
api.nvim_set_hl(0, "NeominimapGitDeleteIcon", { fg = colors.delete, default = true })

api.nvim_set_hl(0, "NeominimapGitAddLine", { bg = colors.add, default = true })
api.nvim_set_hl(0, "NeominimapGitChangeLine", { bg = colors.change, default = true })
api.nvim_set_hl(0, "NeominimapGitDeleteLine", { bg = colors.delete, default = true })

---@param bufnr integer
---@return Annotation[]
M.get_annotations = function(bufnr)
    local gitsigns = require("gitsigns")
    if not gitsigns then
        return {}
    end
    --- @type {type:string, added:{start: integer, count: integer}}[]
    local hunks = require("gitsigns").get_hunks(bufnr)
    if not hunks then
        return {}
    end
    ---@type Annotation[]
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
            line_highlight = toLineHighlight[hunk.type],
            sign_highlight = toSignHighlight[hunk.type],
            icon_highlight = toIconHighlight[hunk.type],
        }
    end
    return annotation
end

return M
