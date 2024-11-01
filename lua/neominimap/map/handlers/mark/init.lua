local api = vim.api
local config = require("neominimap.config")

local name = "Built-in Mark"

---@type Neominimap.Map.Handler
return {
    name = name,
    mode = config.mark.mode,
    init = function()
        require("neominimap.events.mark")(config.mark.key)
    end,
    namespace = api.nvim_create_namespace("neominimap_mark"),
    autocmds = {
        {
            event = "BufWinEnter",
            opts = {
                desc = "Update mark annotations when entering window",
                callback = function(apply, args)
                    require("neominimap.map.handlers.mark.internal").onBufWinEnter(apply, args)
                end,
            },
        },
        {
            event = "TabEnter",
            opts = {
                desc = "Update marks annotations when entering tab",
                callback = function(apply, args)
                    require("neominimap.map.handlers.mark.internal").onTabEnter(apply, args)
                end,
            },
        },
        {
            event = "User",
            opts = {
                pattern = "Mark",
                desc = "Update marks annotations when mark event is triggered",
                callback = function(apply, args)
                    require("neominimap.map.handlers.mark.internal").onMarkEvnet(apply, args)
                end,
            },
        },
    },
    get_annotations = function(bufnr)
        return require("neominimap.map.handlers.mark.internal").get_annotation(bufnr)
    end,
}
