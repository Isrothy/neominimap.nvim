local api, fn = vim.api, vim.fn
local config = require("neominimap.config")
local M = {}

local builtin_marks = {
    "'.",
    "'^",
    "''",
    "'\"",
    "'<",
    "'>",
    "'[",
    "']",
}

--- @param m string mark name
--- @return boolean
local function is_builtin(m)
    return vim.list_contains(builtin_marks, m)
end

api.nvim_set_hl(0, "NeominimapMarkSign", { link = "Normal", default = true })
api.nvim_set_hl(0, "NeominimapMarkIcon", { link = "Normal", default = true })
api.nvim_set_hl(0, "NeominimapMarkLine", { link = "CursorLine", default = true })

---@alias Neominimap.Map.Handler.Mark {mark:string, pos:integer[], file:string}

---@param bufnr integer
---@return Neominimap.Map.Handler.Mark[]
local get_marks = function(bufnr)
    ---@type Neominimap.Map.Handler.Mark[]
    local marks = {}
    local current_file = api.nvim_buf_get_name(bufnr)
    for _, mark in ipairs(fn.getmarklist()) do
        ---@cast mark Neominimap.Map.Handler.Mark
        local mark_file = fn.fnamemodify(mark.file, ":p:a")
        if mark_file == current_file and mark.mark:find("[a-zA-Z]") ~= nil then
            marks[#marks + 1] = mark
        end
    end
    for _, mark in ipairs(vim.fn.getmarklist(bufnr)) do
        marks[#marks + 1] = mark
    end
    return marks
end

---@param bufnr integer
---@return Neominimap.Map.Handler.Mark[]
M.get_annotation = function(bufnr)
    local marks = get_marks(bufnr)
    local util = require("neominimap.util")
    local annotation = {}
    for _, mark in ipairs(marks) do
        local lnum = mark.pos[2]
        if config.mark.show_builtins or not is_builtin(mark.mark) then
            annotation[#annotation + 1] = {
                lnum = lnum,
                end_lnum = lnum,
                priority = config.mark.priority,
                id = 1,
                icon = string.sub(mark.mark, 2, 3),
                highlight = "NeominimapMark" .. util.capitalize(config.mark.mode),
            }
        end
    end
    return annotation
end

return M
