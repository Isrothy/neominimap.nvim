local api = vim.api
local config = require("neominimap.config")

---@type Neominimap.Map.Handler
local git_handler = {
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
}

---@type Neominimap.Map.Handler
local mini_diff_handler = {
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
}

---@type Neominimap.Map.Handler
local diagnostic_handler = {
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
}

---@type Neominimap.Map.Handler
local search_handler = {
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
}

---@type Neominimap.Map.Handler
local mark_handler = {
    name = "Built-in Mark",
    mode = config.mark.mode,
    init = function() end,
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
    },
    get_annotations = function(bufnr)
        return require("neominimap.map.handlers.builtins.mark").get_annotation(bufnr)
    end,
}

if vim.fn.has("nvim-0.12") ~= 1 then
    mark_handler.init = function()
        require("neominimap.events.mark")(config.mark.key)
    end
    table.insert(mark_handler.autocmds, {
        event = "User",
        opts = {
            pattern = "Mark",
            desc = "Update marks annotations when mark event is triggered",
            get_buffers = function(_)
                return require("neominimap.util").get_visible_buffers()
            end,
        },
    })
else
    table.insert(mark_handler.autocmds, {
        event = "MarkSet",
        opts = {
            desc = "Update marks annotations when mark event is triggered",
            get_buffers = function(_)
                return require("neominimap.util").get_visible_buffers()
            end,
        },
    })
end

---@type table<string, Neominimap.Map.Handler>
return {
    git = git_handler,
    mini_diff = mini_diff_handler,
    diagnostic = diagnostic_handler,
    search = search_handler,
    mark = mark_handler,
}
