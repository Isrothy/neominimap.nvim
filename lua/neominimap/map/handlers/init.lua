local M = {}
local api = vim.api
local config = require("neominimap.config")

---@class (exact) Neominimap.Map.Handler.Annotation
---@field lnum integer The starting line (1 based)
---@field end_lnum integer The ending line (1 based)
---@field id integer
---@field priority integer
---@field icon? string
---@field highlight string

---@class (exact) Neominimap.Map.Handler
---@field name string
---@field mode Neominimap.Handler.Annotation.Mode
---@field namespace integer | string
---@field autocmds {event: (string|string[]), opts?: Neominimap.Map.Handler.Autocmd.Keyset}[]
---@field init fun()
---@field get_annotations fun(bufnr: integer): Neominimap.Map.Handler.Annotation[]

---@class Neominimap.Map.Handler.Autocmd.Keyset : vim.api.keyset.create_autocmd
---@field callback fun(apply: fun(bufnr:integer), args: any)

---@alias Neominimap.Handler.Apply fun(bufnr: integer, mbufnr: integer, namespace: integer, annotations: Neominimap.Map.Handler.Annotation[])

---@alias Neominimap.Handler.Annotation.Mode
---|"sign" -- Show braille signs in the sign column
---|"icon" -- Show icons in the sign column
---|"line" -- Highlight the background of the line on the minimap

---@type Neominimap.Map.Handler[]
local handlers = {}

---@return Neominimap.Map.Handler[]
M.get_handlers = function()
    return handlers
end

---@param handler Neominimap.Map.Handler
M.register = function(handler)
    handler.init()
    handlers[#handlers + 1] = handler
end

M.create_autocmds = function()
    ---@param handler Neominimap.Map.Handler
    vim.tbl_map(function(handler)
        ---@param autocmd {event: string|string[], opts: Neominimap.Map.Handler.Autocmd.Keyset}
        vim.tbl_map(function(autocmd)
            ---@type Neominimap.Map.Handler.Autocmd.Keyset
            local opts = vim.tbl_extend("force", autocmd.opts or {}, { group = "Neominimap" })
            local callback = opts.callback
            opts.callback = function(args)
                callback(function(bufnr)
                    require("neominimap.buffer").apply_handler(bufnr, handler.name)
                end, args)
            end
            api.nvim_create_autocmd(autocmd.event, opts)
        end, handler.autocmds)
    end, handlers)
end

M.apply = require("neominimap.map.handlers.application").apply

---@type string[]
local builtins = {
    "git",
    "diagnostic",
    "search",
    "mark",
}

vim.tbl_map(function(name)
    if config[name].enabled then
        M.register(require("neominimap.map.handlers." .. name))
    end
end, builtins)

vim.tbl_map(M.register, config.handlers)

return M
