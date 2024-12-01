local M = {}

local bit = require("bit")
local config = require("neominimap.config")

---Converts a byte index to its UTF-8 index
---@param byte_index integer
---@param utf8_pos integer[] a list of the starting byte positions of each UTF-8 codepoint
---@return integer
M.byte_index_to_utf8_index = function(byte_index, utf8_pos)
    local util = require("neominimap.util")
    return util.upper_bound(utf8_pos, byte_index) - 1
end

--- Gets a list of the starting view point positions of each UTF-8 codepoint in the given string.
---@param str string
---@param tabwidth integer
---@return integer[]
M.codepoints_pos = function(str, tabwidth)
    local char = require("neominimap.char")
    local pos = {}
    local col = 0
    local ok, char_list = pcall(vim.fn.str2list, str)
    if not ok then
        char_list = vim.fn.blob2list(str)
    end
    for idx, code in ipairs(char_list) do
        if char.is_tab(code) then
            local spaces_to_add = tabwidth - (col % tabwidth)
            pos[idx] = col + 1
            col = col + spaces_to_add
        elseif char.is_fullwidth(code) then
            pos[idx] = col + 1
            col = col + 2
        elseif char.is_combining_character(code) then
            pos[idx] = col
        else
            pos[idx] = col + 1
            col = col + 1
        end
    end
    return pos
end

--- Convert string to a list of view points of visible characters
---@param str string
---@param tabwidth integer
---@return integer[]
M.str_to_visible_codepoints = function(str, tabwidth)
    local char = require("neominimap.char")
    local view_points = {}
    local col = 0
    local ok, char_list = pcall(vim.fn.str2list, str)
    if not ok then
        char_list = vim.fn.blob2list(str)
    end
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
M.gen_co = function(lines, tabwidth)
    local height = math.ceil(#lines / 4 / config.y_multiplier) -- In minimap, one char has 4 * 2 dots
    local width = config:get_minimap_width()

    local co = require("neominimap.cooperative.init")

    local map = {}
    co.for_co(1, height, 1, 10000, function(i)
        map[i] = {}
        for j = 1, width, 1 do
            map[i][j] = 0
        end
    end)
    coroutine.yield()

    local coord = require("neominimap.map.coord")

    co.for_in_co(ipairs(lines))(3000, function(row, line)
        local view_points = M.str_to_visible_codepoints(line, tabwidth)
        for _, col in ipairs(view_points) do
            local y, x = coord.codepoint_to_map_point(row, col)
            local mrow, mcol = coord.map_point_to_mcodepoint(y, x)
            if mcol > width then
                break
            end
            local flag = coord.map_point_to_flag(y, x)
            map[mrow][mcol] = bit.bor(map[mrow][mcol], flag)
        end
    end)
    coroutine.yield()

    co.for_in_co(ipairs(lines))(3000, function(row, line)
        local view_points = M.str_to_visible_codepoints(line, tabwidth)
        for _, col in ipairs(view_points) do
            local y, x = coord.codepoint_to_map_point(row, col)
            local mrow, mcol = coord.map_point_to_mcodepoint(y, x)
            if mcol > width then
                break
            end
            local flag = coord.map_point_to_flag(y, x)
            map[mrow][mcol] = bit.bor(map[mrow][mcol], flag)
        end
    end)
    coroutine.yield()

    co.for_in_co(ipairs(map))(5000, function(i, line)
        for j, _ in ipairs(line) do
            line[j] = coord.bitmap_to_code(line[j])
        end
        map[i] = vim.fn.list2str(map[i])
    end)
    coroutine.yield()

    return map
end

return M
