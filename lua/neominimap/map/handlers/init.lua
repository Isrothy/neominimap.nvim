local M = {}

local api = vim.api

---@class (exact) Annotation
---@field lnum integer The starting line (1 based)
---@field end_lnum integer The ending line (1 based)
---@field id integer
---@field priority integer
---@field line_highlight string
---@field sign_highlight string

---@enum Neominimap.Handler.Annotation
local AnnotationMode = {
    Sign = "sign",
    Line = "line",
}

---@enum Neominimap.Handler.SignKind
local SignKind = {
    Icon = "icon",
    Braille = "braille",
}

---@alias Neominimap.Handler.Apply fun(bufnr: integer, mbufnr: integer, namespace: integer, annotations: Annotation[])

---@type Neominimap.Handler.Apply
local apply_line = function(bufnr, mbufnr, namespace, annotations)
    api.nvim_buf_clear_namespace(mbufnr, namespace, 0, -1)

    ---@class Neominimap.Handler.Line
    ---@field hl string
    ---@field priority integer

    ---@type table<integer, Neominimap.Handler.Line>
    local lines = {}
    local coord = require("neominimap.map.coord")
    local fold = require("neominimap.map.fold")
    local cached_folds = fold.get_cached_folds(bufnr)
    for _, annotation in ipairs(annotations) do
        local start_row, end_row = fold.get_visiable_range(cached_folds, annotation.lnum, annotation.end_lnum)
        for row = start_row, end_row do
            local col = 1
            local mrow, _ = coord.codepoint_to_mcodepoint(row, col)
            if not lines[mrow] or lines[mrow].priority < annotation.priority then
                lines[mrow] = {
                    hl = annotation.line_highlight,
                    priority = annotation.priority,
                }
            end
        end
    end
    local line_count = api.nvim_buf_line_count(mbufnr)
    for lineNr, annotation in pairs(lines) do
        if lineNr <= line_count then
            api.nvim_buf_set_extmark(mbufnr, namespace, lineNr - 1, 0, {
                end_col = 0,
                end_row = lineNr,
                hl_group = annotation.hl,
                hl_mode = "combine",
                priority = annotation.priority,
            })
        end
    end
end

---@type Neominimap.Handler.Apply
local apply_sign = function(bufnr, mbufnr, namespace, annotations)
    api.nvim_buf_clear_namespace(mbufnr, namespace, 0, -1)

    ---@class Neominimap.Handler.Sign
    ---@field flag integer
    ---@field id integer
    ---@field hl string
    ---@field priority integer

    ---@type table<integer, Neominimap.Handler.Sign>
    local signs = {}
    local coord = require("neominimap.map.coord")
    local fold = require("neominimap.map.fold")
    local cached_folds = fold.get_cached_folds(bufnr)
    for _, annotation in ipairs(annotations) do
        local start_row, end_row = fold.get_visiable_range(cached_folds, annotation.lnum, annotation.end_lnum)
        for row = start_row, end_row do
            local col = 1
            local mrow, _ = coord.codepoint_to_mcodepoint(row, col)
            if
                not signs[mrow]
                or signs[mrow].priority < annotation.priority
                or (signs[mrow].priority == annotation.priority and signs[mrow].id < annotation.id)
            then
                signs[mrow] = {
                    flag = 0,
                    id = annotation.id,
                    hl = annotation.sign_highlight,
                    priority = annotation.priority,
                }
            end
            if signs[mrow].id == annotation.id then
                local y, x = coord.codepoint_to_map_point(row, col)
                signs[mrow].flag = bit.bor(signs[mrow].flag, coord.map_point_to_flag(y, x))
            end
        end
    end
    local line_count = api.nvim_buf_line_count(mbufnr)
    for lineNr, annotation in pairs(signs) do
        if lineNr <= line_count then
            api.nvim_buf_set_extmark(mbufnr, namespace, lineNr - 1, 0, {
                hl_mode = "combine",
                sign_text = " " .. coord.bitmap_to_char(annotation.flag),
                sign_hl_group = annotation.hl,
                priority = annotation.priority,
            })
        end
    end
end

---@type table<Neominimap.Handler.Annotation, Neominimap.Handler.Apply>
local fun_tbl = {
    [AnnotationMode.Sign] = apply_sign,
    [AnnotationMode.Line] = apply_line,
}

---@param bufnr integer
---@param mbufnr integer
---@param namespace integer
---@param annotations Annotation[]
---@param mode Neominimap.Handler.Annotation
M.apply = function(bufnr, mbufnr, namespace, annotations, mode)
    local logger = require("neominimap.logger")
    logger.log(
        string.format("Applying annotation for minimap buffer %d with namespace %d, mode: %s", mbufnr, namespace, mode),
        vim.log.levels.TRACE
    )
    fun_tbl[mode](bufnr, mbufnr, namespace, annotations)
    logger.log(
        string.format("Annotation for minimap buffer %d with namespace %d applied successfully", mbufnr, namespace),
        vim.log.levels.TRACE
    )
end

return M
