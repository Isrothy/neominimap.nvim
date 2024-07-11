local M = {}
-- Code Point: The position of a character in the Neovim buffer, relative to the buffer, 1-indexed.
-- Map Point: The position of a dot in the minimap, 0-indexed.
-- Map Code Point: The position of a character in the minimap buffer, 1-indexed.

local config = require("neominimap.config").get()

local braille_chars = ""
    .. "⠀⠁⠂⠃⠄⠅⠆⠇⡀⡁⡂⡃⡄⡅⡆⡇⠈⠉⠊⠋⠌⠍⠎⠏⡈⡉⡊⡋⡌⡍⡎⡏"
    .. "⠐⠑⠒⠓⠔⠕⠖⠗⡐⡑⡒⡓⡔⡕⡖⡗⠘⠙⠚⠛⠜⠝⠞⠟⡘⡙⡚⡛⡜⡝⡞⡟"
    .. "⠠⠡⠢⠣⠤⠥⠦⠧⡠⡡⡢⡣⡤⡥⡦⡧⠨⠩⠪⠫⠬⠭⠮⠯⡨⡩⡪⡫⡬⡭⡮⡯"
    .. "⠰⠱⠲⠳⠴⠵⠶⠷⡰⡱⡲⡳⡴⡵⡶⡷⠸⠹⠺⠻⠼⠽⠾⠿⡸⡹⡺⡻⡼⡽⡾⡿"
    .. "⢀⢁⢂⢃⢄⢅⢆⢇⣀⣁⣂⣃⣄⣅⣆⣇⢈⢉⢊⢋⢌⢍⢎⢏⣈⣉⣊⣋⣌⣍⣎⣏"
    .. "⢐⢑⢒⢓⢔⢕⢖⢗⣐⣑⣒⣓⣔⣕⣖⣗⢘⢙⢚⢛⢜⢝⢞⢟⣘⣙⣚⣛⣜⣝⣞⣟"
    .. "⢠⢡⢢⢣⢤⢥⢦⢧⣠⣡⣢⣣⣤⣥⣦⣧⢨⢩⢪⢫⢬⢭⢮⢯⣨⣩⣪⣫⣬⣭⣮⣯"
    .. "⢰⢱⢲⢳⢴⢵⢶⢷⣰⣱⣲⣳⣴⣵⣶⣷⢸⢹⢺⢻⢼⢽⢾⢿⣸⣹⣺⣻⣼⣽⣾⣿"

local braille_codes = vim.fn.str2list(braille_chars)

--- @param bitmap integer
--- @return string
M.bitmap_to_code = function(bitmap)
    return braille_codes[bitmap + 1]
end

--- @param y integer
--- @param x integer
--- @return integer
M.map_point_to_flag = function(y, x)
    local relRow = bit.band(y, 3)
    local relCol = bit.band(x, 1)
    return bit.lshift(1, bit.bor(relRow, relCol * 4))
end

--- @param y integer
--- @param x integer
--- @return integer ...
M.map_point_to_mcode_point = function(y, x)
    return bit.rshift(y, 2) + 1, bit.rshift(x, 1) + 1
end

--- @param row integer
--- @param col integer
--- @return integer ...
M.code_point_to_map_point = function(row, col)
    return math.floor((row - 1) / config.y_multiplier), math.floor((col - 1) / config.x_multiplier)
end

--- @param row integer
--- @param col integer
--- @return integer ...
M.code_point_to_mcode_point = function(row, col)
    local y, x = M.code_point_to_map_point(row, col)
    return M.map_point_to_mcode_point(y, x)
end

return M
