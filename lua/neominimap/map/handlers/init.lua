local M = {}

---@class (exact) Neominimap.Handler.Annotation
---@field lnum integer The starting line (1 based)
---@field end_lnum integer The ending line (1 based)
---@field id integer
---@field priority integer
---@field icon string
---@field line_highlight string
---@field sign_highlight string
---@field icon_highlight string

---@class (exact) Neominimap.Handler
---@field mode Neominimap.Handler.Annotation.Mode
---@field namespace integer
---@field events {event: string, pattern: string}[]
---@field init fun()
---@field get_annotations fun(bufnr: integer): Neominimap.Handler.Annotation[]

---@alias Neominimap.Handler.Apply fun(bufnr: integer, mbufnr: integer, namespace: integer, annotations: Neominimap.Handler.Annotation[])

---@alias Neominimap.Handler.Annotation.Mode
---|"sign" -- Show braille signs in the sign column
---|"icon" -- Show icons in the sign column
---|"line" -- Highlight the background of the line on the minimap

M.apply = require("neominimap.map.handlers.application").apply

return M
