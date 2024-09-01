local api = vim.api
local M = {}

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
                    hl = annotation.highlight,
                    priority = annotation.priority,
                }
            end
        end
    end
    local line_count = api.nvim_buf_line_count(mbufnr)
    for lineNr, line_annotation in pairs(lines) do
        if lineNr <= line_count then
            api.nvim_buf_set_extmark(mbufnr, namespace, lineNr - 1, 0, {
                end_col = 0,
                end_row = lineNr,
                hl_group = line_annotation.hl,
                priority = line_annotation.priority,
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
                    hl = annotation.highlight,
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
    for lineNr, sign_annotation in pairs(signs) do
        if lineNr <= line_count then
            api.nvim_buf_set_extmark(mbufnr, namespace, lineNr - 1, 0, {
                sign_text = " " .. coord.bitmap_to_char(sign_annotation.flag),
                sign_hl_group = sign_annotation.hl,
                priority = sign_annotation.priority,
            })
        end
    end
end

---@type Neominimap.Handler.Apply
local apply_icon = function(bufnr, mbufnr, namespace, annotations)
    api.nvim_buf_clear_namespace(mbufnr, namespace, 0, -1)

    ---@class (strict) Neominimap.Handler.Icon
    ---@field id integer
    ---@field hl string
    ---@field icon string
    ---@field priority integer

    ---@type table<integer, Neominimap.Handler.Icon>
    local icons = {}
    local coord = require("neominimap.map.coord")
    local fold = require("neominimap.map.fold")
    local cached_folds = fold.get_cached_folds(bufnr)

    for _, annotation in ipairs(annotations) do
        local start_row, end_row = fold.get_visiable_range(cached_folds, annotation.lnum, annotation.end_lnum)
        for row = start_row, end_row do
            local col = 1
            local mrow, _ = coord.codepoint_to_mcodepoint(row, col)
            if
                not icons[mrow]
                or icons[mrow].priority < annotation.priority
                or (icons[mrow].priority == annotation.priority and icons[mrow].id < annotation.id)
            then
                icons[mrow] = {
                    id = annotation.id,
                    hl = annotation.highlight,
                    icon = annotation.icon,
                    priority = annotation.priority,
                }
            end
        end
    end
    local line_count = api.nvim_buf_line_count(mbufnr)
    for lineNr, icon_annotation in pairs(icons) do
        if lineNr <= line_count then
            api.nvim_buf_set_extmark(mbufnr, namespace, lineNr - 1, 0, {
                sign_text = icon_annotation.icon,
                sign_hl_group = icon_annotation.hl,
                priority = icon_annotation.priority,
            })
        end
    end
end

---@type table<Neominimap.Handler.Annotation.Mode, Neominimap.Handler.Apply>
local fun_tbl = {
    ["sign"] = apply_sign,
    ["icon"] = apply_icon,
    ["line"] = apply_line,
}

---@param bufnr integer
---@param mbufnr integer
---@param namespace integer
---@param annotations Neominimap.Map.Handler.Annotation[]
---@param mode Neominimap.Handler.Annotation.Mode
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
