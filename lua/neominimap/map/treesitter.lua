local M = {}

local config = require("neominimap.config").get()
local ts_utils = require("nvim-treesitter.ts_utils")
local coord = require("neominimap.map.coord")
local text = require("neominimap.map.text")
local logger = require("neominimap.logger")
local api = vim.api
local treesitter = vim.treesitter

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

---Extracts the highlighting from the given buffer using treesitter.
---For any codepoint, the most common group will be chosen.
---If there are multiple groups with the same number of occurrences, all will be chosen.
---@param bufnr integer
---@return table<string, boolean>[][]?
M.extract_ts_highlights = function(bufnr)
    local buf_highlighter = treesitter.highlighter.active[bufnr]
    if buf_highlighter == nil then
        return nil
    end

    local lines = api.nvim_buf_get_lines(bufnr, 0, -1, false)
    local tabwidth = vim.bo[bufnr].tabstop
    local line_count = #lines
    local minimap_width = config.minimap_width
    local minimap_height = math.ceil(line_count / 4 / config.y_multiplier)
    logger.log("Minimap height: " .. minimap_height .. ", minimap width: " .. minimap_width, vim.log.levels.DEBUG)

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

            logger.log(
                string.format(
                    "Extracted highlight %s, range: (%d,%d), (%d,%d)",
                    hl_group,
                    start_row,
                    start_col,
                    end_row,
                    end_col
                ),
                vim.log.levels.DEBUG
            )
            for row = start_row, end_row do
                local from = row == start_row and start_col or 1
                local to = row == end_row and end_col or string.len(lines[row])
                if to ~= 0 then
                    logger.log(string.format("from: %d, to: %d", from, to), vim.log.levels.DEBUG)
                    from = char_idx_to_codepoint_idx(row, from)
                    to = char_idx_to_codepoint_idx(row, to)

                    for col = from, to do
                        local minimap_row, minimap_col = coord.codepoint_to_mcodepoint(row, col)
                        highlights[minimap_row][minimap_col][hl_group] = (
                            highlights[minimap_row][minimap_col][hl_group] or 0
                        ) + 1
                    end
                end
            end
        end
    end)

    for y = 1, minimap_height do
        for x = 1, minimap_width do
            highlights[y][x] = most_commons(highlights[y][x])
        end
    end

    return highlights
end

local namespace = api.nvim_create_namespace("neominimap_treesitter")

--- Applies the given highlights to the given buffer.
--- If there are multiple highlights for the same position, all of them will be applied.
---@param highlights table<string, boolean>[][]
---@param mbufnr integer
M.apply = function(mbufnr, highlights)
    local minimap_height = api.nvim_buf_line_count(mbufnr)
    local minimap_width = config.minimap_width
    api.nvim_buf_clear_namespace(mbufnr, namespace, 0, -1)
    for y = 1, minimap_height do
        for x = 1, minimap_width do
            for group in pairs(highlights[y][x]) do
                -- For performance reasons, consecutive highlights are merged into one.
                local end_x = x
                while end_x < minimap_width and vim.tbl_contains(highlights[y][end_x + 1], group) do
                    highlights[y][end_x][group] = nil
                    end_x = end_x + 1
                end
                api.nvim_buf_set_extmark(mbufnr, namespace, y - 1, (x - 1) * 3, {
                    hl_group = "@" .. group,
                    end_col = end_x * 3,
                    priority = config.treesitter.priority,
                })
            end
        end
    end
end

return M
