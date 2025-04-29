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
---@field level integer The level on the language tree. 0 = root

---@async
---@param bufnr integer
---@return Neominimap.BufferHighlight[]
local get_buffer_highlights_co = function(bufnr)
    local ok, ts_utils = pcall(require, "nvim-treesitter.ts_utils")
    if not ok or not ts_utils then
        return {}
    end
    local co = require("neominimap.cooperative")
    local co_api = require("neominimap.cooperative.api")
    local highlights = {} ---@type Neominimap.BufferHighlight[]

    ---@param parser vim.treesitter.LanguageTree
    ---@param level integer
    local function traverse(parser, level)
        local trees = (function()
            if vim.fn.has("0.11") then
                return co_api.parse_language_tree_co(parser)
            else
                parser:parse()
                return parser:trees()
            end
        end)()

        -- local logger = require("neominimap.logger")
        -- logger.notify("Traversing " .. trees, vim.log.levels.DEBUG)

        co.for_in_co(pairs(trees))(100, function(_, tree) ---@cast tree TSTree
            local root = tree:root()
            local query = treesitter.query.get(parser:lang(), "highlights")
            if not query then
                return
            end
            local iter = query:iter_captures(root, bufnr)
            co.for_in_co(iter)(5000, function(capture_id, node)
                local hl_group = query.captures[capture_id]
                local start_row, start_col, end_row, end_col =
                    ts_utils.get_vim_range({ treesitter.get_node_range(node) }, bufnr)
                highlights[#highlights + 1] = {
                    start_row = start_row,
                    start_col = start_col,
                    end_row = end_row,
                    end_col = end_col,
                    group = hl_group,
                    level = level,
                }
            end)
        end)

        co.for_in_co(pairs(parser:children()))(1, function(_, child_parser)
            traverse(child_parser, level + 1)
        end)
    end

    local ok, parser = pcall(treesitter.get_parser, bufnr)
    if not ok or not parser then
        return {}
    end

    traverse(parser, 0)

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
---@async
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

    local co = require("neominimap.cooperative")

    local highlights = {}
    co.for_co(1, minimap_height, 1, 10000, function(row)
        local line = {}
        for col = 1, minimap_width do
            line[col] = { level = 0, groups = {} }
        end
        highlights[row] = line
    end)
    co.defer_co()

    local fold = require("neominimap.map.fold")
    local coord = require("neominimap.map.coord")
    local folds = fold.get_cached_folds(bufnr)
    co.for_in_co(ipairs(get_buffer_highlights_co(bufnr)))(2000, function(_, h) ---@cast h Neominimap.BufferHighlight
        local minimap_hl = get_or_create_hl_info("@" .. h.group)

        for row = h.start_row, h.end_row do
            local vrow, hide = fold.subtract_fold_lines(folds, row)
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
                        local ceil = highlights[mrow][mcol]
                        if ceil.level < h.level then
                            ceil.level = h.level
                            ceil.groups = {}
                        end
                        if ceil.level == h.level then
                            ceil.groups[minimap_hl] = (ceil.groups[minimap_hl] or 0) + 1
                        end
                    end
                end
            end
        end
    end)
    co.defer_co()

    co.for_co(1, minimap_height, 1, 5000, function(y)
        for x = 1, minimap_width do
            highlights[y][x] = most_commons(highlights[y][x].groups)
        end
    end)
    co.defer_co()

    ---@type Neominimap.MinimapHighlight[]
    local ret = {}
    co.for_co(1, minimap_height, 1, 5000, function(y)
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
    end)

    return ret
end

--- Applies the given highlights to the given buffer.
--- If there are multiple highlights for the same position, all of them will be applied.
---@async
---@param mbufnr integer
---@param highlights Neominimap.MinimapHighlight[]
M.apply_co = function(mbufnr, highlights)
    api.nvim_buf_clear_namespace(mbufnr, namespace, 0, -1)
    local co = require("neominimap.cooperative")
    co.for_in_co(ipairs(highlights))(5000, function(_, hl)
        api.nvim_buf_set_extmark(mbufnr, namespace, hl.line, hl.col, {
            end_col = hl.end_col,
            hl_group = hl.group,
        })
    end)
end

return M
