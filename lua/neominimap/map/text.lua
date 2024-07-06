local M = {}

local api = vim.api

local char = require("neominimap.char")
local bit = require("bit")
local coord = require("neominimap.map.coord")
local config = require("neominimap.config").get()

--- Convert string to a list of view points of visible characters
---@param str string
---@param tabwidth integer
---@return integer[]
M.str_to_code_points = function(str, tabwidth)
    local view_points = {}
    local col = 0
    local char_list = vim.fn.str2list(str)
    for _, code in ipairs(char_list) do
        if char.is_tab(code) then
            local spaces_to_add = tabwidth - (col % tabwidth)
            col = col + spaces_to_add
        elseif char.is_white_space(code) then
            col = col + 1
        elseif char.is_fullwidth(code) then
            view_points[#view_points + 1] = col + 1
            view_points[#view_points + 1] = col + 2
            col = col + 2
        elseif not char.is_combining_character(code) then
            view_points[#view_points + 1] = col + 1
            col = col + 1
        end
    end
    return view_points
end

--- Generate minimap text for the buffer
--- @param lines string[]
--- @param tabwidth integer
--- @return string[]
M.gen = function(lines, tabwidth)
    local height = math.ceil(#lines / 4 / config.y_multiplier) -- In minimap, one char has 4 * 2 dots
    local width = config.minimap_width

    local map = {}
    for i = 1, height, 1 do
        map[i] = {}
        for j = 1, width, 1 do
            map[i][j] = 0
        end
    end

    for row, line in ipairs(lines) do
        local view_points = M.str_to_code_points(line, tabwidth)
        for _, col in ipairs(view_points) do
            local y, x = coord.code_point_to_map_point(row, col)
            local mrow, mcol = coord.map_point_to_mcode_point(y, x)
            if mcol > width then
                break
            end
            local flag = coord.map_point_to_flag(y, x)
            map[mrow][mcol] = bit.bor(map[mrow][mcol], flag)
        end
    end

    for i, line in ipairs(map) do
        for j, _ in ipairs(line) do
            line[j] = coord.bitmap_to_code(line[j])
        end
        map[i] = vim.fn.list2str(map[i])
    end

    return map
end

return M
