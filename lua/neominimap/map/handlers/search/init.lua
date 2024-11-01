local api = vim.api

local config = require("neominimap.config")

local name = "Built-in Search"
---@type Neominimap.Map.Handler
return {
    name = name,
    mode = config.search.mode,
    init = function()
        require("neominimap.events.search")
    end,
    namespace = api.nvim_create_namespace("neominimap_search"),
    autocmds = {
        {
            event = "BufWinEnter",
            opts = {
                desc = "Update search annotations when entering window",
                callback = function(apply, args)
                    require("neominimap.map.handlers.search.internal").onBufWinEnter(apply, args)
                end,
            },
        },
        {
            event = "TabEnter",
            opts = {
                desc = "Update search annotations when entering tab",
                callback = function(apply, args)
                    require("neominimap.map.handlers.search.internal").onTabEnter(apply, args)
                end,
            },
        },
        {
            event = "User",
            opts = {
                pattern = "Search",
                desc = "Update search annotations when search event is triggered",
                callback = function(apply, args)
                    require("neominimap.map.handlers.search.internal").onSearchEvent(apply, args)
                end,
            },
        },
    },
    get_annotations = function(bufnr)
        return require("neominimap.map.handlers.search.internal").get_annotations(bufnr)
    end,
}
