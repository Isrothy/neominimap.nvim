local M = {}

local api = vim.api
local config = require("neominimap.config").get()

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
local toLineHighlight = {
    ["add"] = "NeominimapGitAddLine",
    ["change"] = "NeominimapGitChangeLine",
    ["delete"] = "NeominimapGitDeleteLine",
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

api.nvim_set_hl(0, "NeominimapGitAddLine", { bg = colors.add, default = true })
api.nvim_set_hl(0, "NeominimapGitChangeLine", { bg = colors.change, default = true })
api.nvim_set_hl(0, "NeominimapGitDeleteLine", { bg = colors.delete, default = true })

---@param bufnr integer
---@return Neominimap.Handler.Mark[]
M.get_marks = function(bufnr)
    local gitsigns = require("gitsigns")
    if not gitsigns then
        return {}
    end
    --- @type {type:string, added:{start: integer, count: integer}}[]
    local hunks = require("gitsigns").get_hunks(bufnr)
    if not hunks then
        return {}
    end
    ---@type Neominimap.Handler.Mark[]
    local marks = {}
    for _, hunk in ipairs(hunks) do
        local start = math.max(1, hunk.added.start)
        local end_ = start + math.max(0, hunk.added.count - 1)
        marks[#marks + 1] = {
            lnum = start,
            end_lnum = end_,
            priority = config.git.priority,
            id = toId[hunk.type],
            line_highlight = toLineHighlight[hunk.type],
            sign_highlight = toSignHighlight[hunk.type],
        }
    end
    return marks
end

return M
