local M = {}

local api = vim.api
local coord = require("neominimap.map.coord")
local config = require("neominimap.config").get()
local logger = require("neominimap.logger")

---@class (exact) Neominimap.Handler.Mark
---@field lnum integer The starting line (1 based)
---@field end_lnum integer The ending line (1 based)
---@field id integer
---@field priority integer
---@field line_highlight string
---@field sign_highlight string

---@enum Neominimap.Handler.MarkMode
local MarkMode = {
    Sign = "sign",
    Line = "line",
}

---@alias Neominimap.Handler.Apply fun(mbufnr: integer, namespace: integer, marks: Neominimap.Handler.Mark[])

---@type Neominimap.Handler.Apply
local apply_line = function(mbufnr, namespace, marks)
    api.nvim_buf_clear_namespace(mbufnr, namespace, 0, -1)

    ---@class Neominimap.Handler.Line
    ---@field hl string
    ---@field priority integer

    ---@type table<integer, Neominimap.Handler.Line>
    local lines = {}
    for _, mark in ipairs(marks) do
        for i = mark.lnum, mark.end_lnum, 1 do
            local row, col = i, 1
            local mrow, _ = coord.codepoint_to_mcodepoint(row, col)
            if not lines[mrow] or lines[mrow].priority < mark.priority then
                lines[mrow] = {
                    hl = mark.line_highlight,
                    priority = mark.priority,
                }
            end
        end
    end
    local line_count = api.nvim_buf_line_count(mbufnr)
    for lineNr, mark in pairs(lines) do
        if lineNr <= line_count then
            api.nvim_buf_set_extmark(mbufnr, namespace, lineNr - 1, 0, {
                end_col = 0,
                end_row = lineNr,
                hl_group = mark.hl,
                hl_mode = "combine",
                priority = mark.priority,
            })
        end
    end
end

---@type Neominimap.Handler.Apply
local apply_sign = function(mbufnr, namespace, marks)
    api.nvim_buf_clear_namespace(mbufnr, namespace, 0, -1)

    ---@class Neominimap.Handler.Sign
    ---@field flag integer
    ---@field id integer
    ---@field hl string
    ---@field priority integer

    ---@type table<integer, Neominimap.Handler.Sign>
    local signs = {}
    for _, mark in ipairs(marks) do
        for i = mark.lnum, mark.end_lnum, 1 do
            local row, col = i, 1
            local mrow, _ = coord.codepoint_to_mcodepoint(row, col)
            if
                not signs[mrow]
                or signs[mrow].priority < mark.priority
                or (signs[mrow].priority == mark.priority and signs[mrow].id < mark.id)
            then
                signs[mrow] = {
                    flag = 0,
                    id = mark.id,
                    hl = mark.sign_highlight,
                    priority = mark.priority,
                }
            end
            if signs[mrow].id == mark.id then
                local y, x = coord.codepoint_to_map_point(row, col)
                signs[mrow].flag = bit.bor(signs[mrow].flag, coord.map_point_to_flag(y, x))
            end
        end
    end
    local line_count = api.nvim_buf_line_count(mbufnr)
    for lineNr, mark in pairs(signs) do
        if lineNr <= line_count then
            api.nvim_buf_set_extmark(mbufnr, namespace, lineNr - 1, 0, {
                hl_mode = "combine",
                sign_text = " " .. coord.bitmap_to_char(mark.flag),
                sign_hl_group = mark.hl,
                priority = mark.priority,
            })
        end
    end
end

---@type table<Neominimap.Handler.MarkMode, Neominimap.Handler.Apply>
local fun_tbl = {
    [MarkMode.Sign] = apply_sign,
    [MarkMode.Line] = apply_line,
}
---@param mbufnr integer
---@param namespace integer
---@param marks Neominimap.Handler.Mark[]
---@param mode Neominimap.Handler.MarkMode
M.apply = function(mbufnr, namespace, marks, mode)
    logger.log(
        string.format("Applying marks for minimap buffer %d with namespace %d, mode: %s", mbufnr, namespace, mode),
        vim.log.levels.TRACE
    )
    fun_tbl[mode](mbufnr, namespace, marks)
    logger.log(
        string.format("Marks for minimap buffer %d with namespace %d applied successfully", mbufnr, namespace),
        vim.log.levels.TRACE
    )
end

return M
