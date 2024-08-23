local M = {}

---@class (exact) Annotation
---@field lnum integer The starting line (1 based)
---@field end_lnum integer The ending line (1 based)
---@field id integer
---@field priority integer
---@field icon string
---@field line_highlight string
---@field sign_highlight string
---@field icon_highlight string

---@alias Neominimap.Handler.Apply fun(bufnr: integer, mbufnr: integer, namespace: integer, annotations: Annotation[])

---@alias Neominimap.Handler.Annotation
---|"sign" -- Show braille signs in the sign column
---|"icon" -- Show icons in the sign column
---|"line" -- Highlight the background of the line on the minimap

M.apply = require("neominimap.map.handlers.application").apply

return M
