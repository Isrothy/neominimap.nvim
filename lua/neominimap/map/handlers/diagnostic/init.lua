local config = require("neominimap.config")
local api = vim.api
local name = "Built-in Diagnostic"

---@type Neominimap.Map.Handler
return {
    name = name,
    mode = config.diagnostic.mode,
    namespace = api.nvim_create_namespace("neominimap_diagnostic"),
    autocmds = {
        {
            event = "DiagnosticChanged",
            opts = {
                desc = "Update diagnostic annotations when diagnostics are changed",
                callback = function(apply, args)
                    require("neominimap.map.handlers.diagnostic.internal").onDiagnosticChanged(apply, args)
                end,
            },
        },
    },
    init = function() end,
    get_annotations = function(bufnr)
        return require("neominimap.map.handlers.diagnostic.internal").get_annotations(bufnr)
    end,
}
