local M = {}
local api = vim.api
local config = require("neominimap.config")

---@class (exact) Neominimap.Handler.Annotation
---@field lnum integer The starting line (1 based)
---@field end_lnum integer The ending line (1 based)
---@field id integer
---@field priority integer
---@field icon? string
---@field highlight string

---@class (exact) Neominimap.Handler
---@field name string
---@field mode Neominimap.Handler.Annotation.Mode
---@field namespace integer
---@field autocmds {event: (string|string[]), opts?: vim.api.keyset.create_autocmd}[]
---@field init fun()
---@field get_annotations fun(bufnr: integer): Neominimap.Handler.Annotation[]

---@alias Neominimap.Handler.Apply fun(bufnr: integer, mbufnr: integer, namespace: integer, annotations: Neominimap.Handler.Annotation[])

---@alias Neominimap.Handler.Annotation.Mode
---|"sign" -- Show braille signs in the sign column
---|"icon" -- Show icons in the sign column
---|"line" -- Highlight the background of the line on the minimap

---@type Neominimap.Handler[]
local handlers = {}

---@return Neominimap.Handler[]
M.get_handlers = function()
    return handlers
end

M.register = function(handler)
    handler.init()
    handlers[#handlers + 1] = handler
end

M.create_autocmds = function()
    for _, handler in ipairs(handlers) do
        for _, autocmd in ipairs(handler.autocmds) do
            ---@type vim.api.keyset.create_autocmd
            local opts = vim.tbl_extend("force", autocmd.opts or {}, { group = "Neominimap" })
            api.nvim_create_autocmd(autocmd.event, opts)
        end
    end
end

M.apply = require("neominimap.map.handlers.application").apply

---@type string[]
local builtins = {
    "git",
    "diagnostic",
    "search",
    "mark",
}

for _, name in ipairs(builtins) do
    if config[name].enabled then
        M.register(require("neominimap.map.handlers." .. name))
    end
end

return M
