local api = vim.api
local config = require("neominimap.config")

---@type table<string, Neominimap.Map.Handler>
return {
    git = {
        name = "Built-in Git Signs",
        mode = config.git.mode,
        namespace = api.nvim_create_namespace("neominimap_git"),
        autocmds = {
            {
                event = "User",
                opts = {
                    pattern = "GitSignsUpdate",
                    desc = "Update git annotations when git signs are updated",
                    get_buffers = function(args)
                        local data = args.data
                        if not data then
                            return nil
                        end
                        ---@type integer
                        return tonumber(args.data.buffer)
                    end,
                },
            },
        },
        init = function() end,
        get_annotations = function(bufnr)
            return require("neominimap.map.handlers.builtins.git").get_annotations(bufnr)
        end,
    },
    mini_diff = {
        name = "Built-in Mini Diff",
        mode = config.mini_diff.mode,
        namespace = api.nvim_create_namespace("neominimap_minidiff"),
        autocmds = {
            {
                event = "User",
                opts = {
                    pattern = "MiniDiffUpdated",
                    desc = "Update mini diff annotations when mini diff signs are updated",
                    get_buffers = function(args)
                        local data = args.data
                        if not data then
                            return nil
                        end
                        ---@type integer
                        return tonumber(args.data.buffer)
                    end,
                },
            },
        },
        init = function() end,
        get_annotations = function(bufnr)
            return require("neominimap.map.handlers.builtins.mini_diff").get_annotations(bufnr)
        end,
    },
    diagnostic = {
        name = "Built-in Diagnostic",
        mode = config.diagnostic.mode,
        namespace = api.nvim_create_namespace("neominimap_diagnostic"),
        autocmds = {
            {
                event = "DiagnosticChanged",
                opts = {
                    desc = "Update diagnostic annotations when diagnostics are changed",
                    get_buffers = function(args)
                        return tonumber(args.buf)
                    end,
                },
            },
        },
        init = function() end,
        get_annotations = function(bufnr)
            return require("neominimap.map.handlers.builtins.diagnostic").get_annotations(bufnr)
        end,
    },
    search = {
        name = "Built-in Search",
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
                    get_buffers = function(_)
                        return api.nvim_get_current_buf()
                    end,
                },
            },
            {
                event = "TabEnter",
                opts = {
                    desc = "Update search annotations when entering tab",
                    get_buffers = function(_)
                        return require("neominimap.util").get_visible_buffers()
                    end,
                },
            },
            {
                event = "User",
                opts = {
                    pattern = "Search",
                    desc = "Update search annotations when search event is triggered",
                    get_buffers = function(_)
                        return require("neominimap.util").get_visible_buffers()
                    end,
                },
            },
        },
        get_annotations = function(bufnr)
            return require("neominimap.map.handlers.builtins.search").get_annotations(bufnr)
        end,
    },
    mark = {
        name = "Built-in Mark",
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
                    get_buffers = function(_)
                        return api.nvim_get_current_buf()
                    end,
                },
            },
            {
                event = "TabEnter",
                opts = {
                    desc = "Update marks annotations when entering tab",
                    get_buffers = function(_)
                        return require("neominimap.util").get_visible_buffers()
                    end,
                },
            },
            {
                event = "User",
                opts = {
                    pattern = "Mark",
                    desc = "Update marks annotations when mark event is triggered",
                    get_buffers = function(_)
                        return require("neominimap.util").get_visible_buffers()
                    end,
                },
            },
        },
        get_annotations = function(bufnr)
            return require("neominimap.map.handlers.builtins.mark").get_annotation(bufnr)
        end,
    },
}
