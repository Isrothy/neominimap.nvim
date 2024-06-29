local M = {}

-- Code Point: The position of a character in the Neovim buffer, relative to the buffer, 1-indexed.
-- Map Point: The position of a dot in the minimap, 0-indexed.
-- Map Code Point: The position of a character in the minimap buffer, 1-indexed.

local api = vim.api

local char = require("neominimap.char")
local bit = require("bit")
local config = require("neominimap.config").get()

local braille_chars = "⠀⠁⠂⠃⠄⠅⠆⠇⡀⡁⡂⡃⡄⡅⡆⡇⠈⠉⠊⠋⠌⠍⠎⠏⡈⡉⡊⡋⡌⡍⡎⡏"
    .. "⠐⠑⠒⠓⠔⠕⠖⠗⡐⡑⡒⡓⡔⡕⡖⡗⠘⠙⠚⠛⠜⠝⠞⠟⡘⡙⡚⡛⡜⡝⡞⡟"
    .. "⠠⠡⠢⠣⠤⠥⠦⠧⡠⡡⡢⡣⡤⡥⡦⡧⠨⠩⠪⠫⠬⠭⠮⠯⡨⡩⡪⡫⡬⡭⡮⡯"
    .. "⠰⠱⠲⠳⠴⠵⠶⠷⡰⡱⡲⡳⡴⡵⡶⡷⠸⠹⠺⠻⠼⠽⠾⠿⡸⡹⡺⡻⡼⡽⡾⡿"
    .. "⢀⢁⢂⢃⢄⢅⢆⢇⣀⣁⣂⣃⣄⣅⣆⣇⢈⢉⢊⢋⢌⢍⢎⢏⣈⣉⣊⣋⣌⣍⣎⣏"
    .. "⢐⢑⢒⢓⢔⢕⢖⢗⣐⣑⣒⣓⣔⣕⣖⣗⢘⢙⢚⢛⢜⢝⢞⢟⣘⣙⣚⣛⣜⣝⣞⣟"
    .. "⢠⢡⢢⢣⢤⢥⢦⢧⣠⣡⣢⣣⣤⣥⣦⣧⢨⢩⢪⢫⢬⢭⢮⢯⣨⣩⣪⣫⣬⣭⣮⣯"
    .. "⢰⢱⢲⢳⢴⢵⢶⢷⣰⣱⣲⣳⣴⣵⣶⣷⢸⢹⢺⢻⢼⢽⢾⢿⣸⣹⣺⣻⣼⣽⣾⣿"

local braille_codes = vim.fn.str2list(braille_chars)

---@param bitmap integer
---@return integer
local bitmap_to_code = function(bitmap)
    return braille_codes[bitmap + 1]
end

--- @param y integer
--- @param x integer
--- @return integer
local map_point_to_flag = function(y, x)
    local relRow = bit.band(y, 3)
    local relCol = bit.band(x, 1)
    return bit.lshift(1, bit.bor(relRow, relCol * 4))
end

--- @param y integer
--- @param x integer
--- @return integer ...
local map_point_to_mcode_point = function(y, x)
    return bit.rshift(y, 2) + 1, bit.rshift(x, 1) + 1
end

--- @param row integer
--- @param col integer
--- @return integer ...
local code_point_to_map_point = function(row, col)
    return (row - 1) / config.y_multiplier, (col - 1) / config.x_multiplier
end

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
--- @param bufnr integer
--- @return string[]
M.gen = function(bufnr)
    local lines = api.nvim_buf_get_lines(bufnr, 0, -1, true)
    local tabwidth = vim.bo[bufnr].tabstop

    local height = math.ceil(#lines / 4 / config.y_multiplier) -- In minimap, one char has 4 * 2 dots
    local width = config.minimap_width

    local map = {}

    for i = 1, height, 1 do
        map[#map + 1] = {}
        for j = 1, width, 1 do
            map[i][j] = 0
        end
    end

    for row, line in ipairs(lines) do
        local view_points = M.str_to_code_points(line, tabwidth)
        for _, col in ipairs(view_points) do
            local y, x = code_point_to_map_point(row, col)
            local mrow, mcol = map_point_to_mcode_point(y, x)
            if mcol > width then
                break
            end
            local flag = map_point_to_flag(y, x)
            map[mrow][mcol] = bit.bor(map[mrow][mcol], flag)
        end
    end

    for i, line in ipairs(map) do
        for j, _ in ipairs(line) do
            line[j] = bitmap_to_code(line[j])
        end
        map[i] = vim.fn.list2str(map[i])
    end

    return map
end

return M
