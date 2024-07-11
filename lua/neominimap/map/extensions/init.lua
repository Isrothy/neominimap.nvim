local M = {}

local api = vim.api
local coord = require("neominimap.map.coord")
local logger = require("neominimap.logger")

---@class Neominimap.Decoration
---@field lnum integer The starting line (1 based)
---@field end_lnum integer The ending line (1 based)
---@field col integer The starting column (1 based)
---@field end_col integer The ending column (1 based)
---@field priority integer
---@field color string

---@enum Neominimap.Placement
local Placement = {
    LEFT = "LEFT",
    RIGHT = "RIGHT",
    BG = "BG",
}

---@param mbufnr integer
---@param namespace integer
---@param decorations Neominimap.Decoration[]
M.apply_bg = function(mbufnr, namespace, decorations)
    logger.log(
        string.format("Applying decorations for minimap buffer %d with namespace %d", mbufnr, namespace),
        vim.log.levels.TRACE
    )
    api.nvim_buf_clear_namespace(mbufnr, namespace, 0, -1)
    local lines = {}
    logger.log(string.format("Applying decorations: %s", vim.inspect(decorations)), vim.log.levels.DEBUG)
    for _, decoration in ipairs(decorations) do
        for i = decoration.lnum, decoration.end_lnum, 1 do
            local row, col = i, 1
            local mrow, _ = coord.map_point_to_mcodepoint(row, col)
            if not lines[mrow] or lines[mrow].priority < decoration.priority then
                lines[mrow] = {
                    color = decoration.color,
                    priority = decoration.priority,
                }
            end
        end
    end
    logger.log(string.format("Applying lines: %s", vim.inspect(lines)), vim.log.levels.DEBUG)
    local line_count = api.nvim_buf_line_count(mbufnr)
    for lineNr, decoration in pairs(lines) do
        if lineNr <= line_count then
            api.nvim_buf_set_extmark(mbufnr, namespace, lineNr - 1, 0, {
                end_col = 0,
                end_row = lineNr,
                hl_group = decoration.color .. "Bg",
                -- hl_group = "Function",
                hl_mode = "combine",
                priority = decoration.priority,
            })
        end
    end
end

---@param mbufnr integer
---@param namespace integer
---@param decorations Neominimap.Decoration[]
---@param opts table?
M.apply = function(mbufnr, namespace, decorations, opts)
    M.apply_bg(mbufnr, namespace, decorations)
end

return M
