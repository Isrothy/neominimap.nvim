local M = {}

local config = require("neominimap.config")
local api = vim.api
local treesitter = vim.treesitter

local namespace = api.nvim_create_namespace("neominimap_treesitter")

---The most common elements in the given table
---@generic T
---@param tbl table<T,integer>
---@return table<T, boolean>
local function most_commons(tbl)
    local max = 0
    for _, count in pairs(tbl) do
        if count > max then
            max = count
        end
    end

    local result = {}
    for entry, count in pairs(tbl) do
        if count == max then
            result[entry] = true
        end
    end

    return result
end

---@param group string
local function resolve_hl_link(group)
    local hl = vim.api.nvim_get_hl(0, { name = group })
    while hl.link do
        group = hl.link
        hl = vim.api.nvim_get_hl(0, { name = group })
    end
    return hl
end

---@type table<string, string>
local hl_cache = {}

---@param hl_group string
---@return string
local get_or_create_hl_info = function(hl_group)
    if hl_cache[hl_group] then
        return hl_cache[hl_group]
    end
    local hl_info = resolve_hl_link(hl_group)
    local new_group = "Neominimap." .. hl_group
    api.nvim_set_hl(0, new_group, { fg = hl_info.fg and string.format("#%06x", hl_info.fg), default = true })
    hl_cache[hl_group] = new_group
    return new_group
end

---@class (exact) Neominimap.BufferHighlight
---@field start_row integer
---@field end_row integer
---@field start_col integer
---@field end_col integer
---@field group string

---@param bufnr integer
---@return Neominimap.BufferHighlight[]
local get_buffer_highlights = function(bufnr)
    local ts_utils = require("nvim-treesitter.ts_utils")
    if not ts_utils then
        return {}
    end
    local buf_highlighter = treesitter.highlighter.active[bufnr]
    local line_count = api.nvim_buf_line_count(bufnr)
    if buf_highlighter == nil then
        return {}
    end
    ---@type Neominimap.BufferHighlight[]
    local highlights = {}
    buf_highlighter.tree:for_each_tree(function(tstree, tree)
        if not tstree then
            return
        end

        local root = tstree:root()
        local lang = tree:lang()
        local query = treesitter.query.get(lang, "highlights")
        if not query then
            return
        end

        local iter = query:iter_captures(root, buf_highlighter.bufnr, 0, line_count + 1)

        for capture_id, node in iter do
            local hl_group = query.captures[capture_id]
            local start_row, start_col, end_row, end_col =
                ts_utils.get_vim_range({ treesitter.get_node_range(node) }, bufnr)
            highlights[#highlights + 1] = {
                start_row = start_row,
                start_col = start_col,
                end_row = end_row,
                end_col = end_col,
                group = hl_group,
            }
        end
    end)
    return highlights
end

---@class (exact) Neominimap.MinimapHighlight
---@field line integer
---@field col integer
---@field end_col integer
---@field group string

---Extracts the highlighting from the given buffer using treesitter.
---For any codepoint, the most common group will be chosen.
---If there are multiple groups with the same number of occurrences, all will be chosen.
---@param bufnr integer
---@return Neominimap.MinimapHighlight[]
M.extract_highlights_co = function(bufnr)
    local text = require("neominimap.map.text")
    local lines = api.nvim_buf_get_lines(bufnr, 0, -1, false)
    local tabwidth = vim.bo[bufnr].tabstop
    local line_count = #lines
    local minimap_width = config:get_minimap_width()
    local minimap_height = math.ceil(line_count / 4 / config.y_multiplier)

    ---@type integer[][]
    local utf8_pos_list = vim.tbl_map(vim.str_utf_pos, lines)
    ---@type integer[][]
    local code_point_list = vim.tbl_map(function(str)
        return text.codepoints_pos(str, tabwidth)
    end, lines)

    ---@type fun(row:integer, char_idx:integer):integer
    local char_idx_to_codepoint_idx = function(row, char_idx)
        local utf8_idx = text.byte_index_to_utf8_index(char_idx, utf8_pos_list[row])
        local code_point_idx = code_point_list[row][utf8_idx]
        return code_point_idx
    end

    local highlights = {}
    for row = 1, minimap_height do
        local line = {}
        for col = 1, minimap_width do
            line[col] = {}
        end
        highlights[row] = line
    end

    local fold = require("neominimap.map.fold")
    local coord = require("neominimap.map.coord")
    local folds = fold.get_cached_folds(bufnr)
    for _, h in ipairs(get_buffer_highlights(bufnr)) do
        local minimap_hl = get_or_create_hl_info("@" .. h.group)

        for row = h.start_row, h.end_row do
            local vrow, hide = fold.substract_fold_lines(folds, row)
            if not hide then
                local from = row == h.start_row and h.start_col or 1
                local to = row == h.end_row and h.end_col or string.len(lines[row])
                from = char_idx_to_codepoint_idx(row, from)
                to = char_idx_to_codepoint_idx(row, to)
                if from ~= nil and to ~= nil then
                    for col = from, to do
                        local mrow, mcol = coord.codepoint_to_mcodepoint(vrow, col)
                        if mcol > minimap_width then
                            break
                        end
                        highlights[mrow][mcol][minimap_hl] = (highlights[mrow][mcol][minimap_hl] or 0) + 1
                    end
                end
            end
        end
    end

    for y = 1, minimap_height do
        for x = 1, minimap_width do
            highlights[y][x] = most_commons(highlights[y][x])
        end
    end

    ---@type Neominimap.MinimapHighlight[]
    local ret = {}
    for y = 1, minimap_height do
        for x = 1, minimap_width do
            for group in pairs(highlights[y][x]) do
                -- For performance reasons, consecutive highlights are merged into one.
                local end_x = x
                while end_x < minimap_width and vim.tbl_contains(highlights[y][end_x + 1], group) do
                    highlights[y][end_x + 1][group] = nil
                    end_x = end_x + 1
                end
                ret[#ret + 1] = {
                    line = y - 1,
                    col = (x - 1) * 3,
                    end_col = end_x * 3,
                    group = group,
                }
            end
        end
    end

    return ret
end

--- Applies the given highlights to the given buffer.
--- If there are multiple highlights for the same position, all of them will be applied.
---@param mbufnr integer
---@param highlights Neominimap.MinimapHighlight[]
M.apply_co = function(mbufnr, highlights)
    api.nvim_buf_clear_namespace(mbufnr, namespace, 0, -1)
    for _, hl in ipairs(highlights) do
        api.nvim_buf_set_extmark(mbufnr, namespace, hl.line, hl.col, {
            end_col = hl.end_col,
            hl_group = hl.group,
        })
    end
end

return M
