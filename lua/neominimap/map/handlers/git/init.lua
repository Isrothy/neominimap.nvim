local config = require("neominimap.config")
local api = vim.api

local name = "Built-in Git Signs"
---@type Neominimap.Map.Handler
return {
    name = name,
    mode = config.git.mode,
    namespace = api.nvim_create_namespace("neominimap_git"),
    autocmds = {
        {
            event = "User",
            opts = {
                pattern = "GitSignsUpdate",
                desc = "Update git annotations when git signs are updated",
                callback = function(apply, args)
                    require("neominimap.map.handlers.git.internal").onGitsignsUpdate(apply, args)
                end,
            },
        },
    },
    init = function() end,
    get_annotations = function(bufnr)
        return require("neominimap.map.handlers.git.internal").get_annotations(bufnr)
    end,
}
