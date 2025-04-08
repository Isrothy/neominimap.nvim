local M = {}

---@param path string The path to the field being validated
---@param tbl table The table to validate
---@see vim.validate
---@return boolean is_valid
---@return string|nil error_message
local function validate_path(path, tbl)
    local ok, err = pcall(vim.validate, tbl)
    return ok, err and path .. "." .. err
end

local function is_handler(handler)
    return validate_path("", {
        name = { handler.name, "string" },
        mode = { handler.mode, "string" },
        namespace = { handler.namespace, { "number", "string" } },
        autocmds = { handler.autocmds, "table" },
        init = { handler.init, "function" },
        get_annotations = { handler.get_annotations, "function" },
    })
end

---@param f fun(x:any):boolean
---@return fun(arr:table):boolean
local function is_array_of(f)
    return function(tbl)
        if type(tbl) ~= "table" then
            return false
        end
        for _, v in ipairs(tbl) do
            if not f(v) then
                return false
            end
        end
        return true
    end
end

---@type fun(x:any):boolean
local is_array_of_strings = is_array_of(function(x)
    return type(x) == "string"
end)

---@type fun(x:any):boolean
local is_array_of_handlers = is_array_of(is_handler)

---@param cfg Neominimap.Internal.Config
---@return boolean is_valid
---@return string|nil error_message
M.validate_config = function(cfg)
    return validate_path("vim.g.neominimap", {
        auto_enable = { cfg.auto_enable, "boolean" },
        log_level = { cfg.log_level, "number" },
        notification_level = { cfg.notification_level, "number" },
        log_path = { cfg.log_path, "string" },
        exclude_filetypes = { cfg.exclude_filetypes, is_array_of_strings, "list of string" },
        exclude_buftypes = { cfg.exclude_buftypes, is_array_of_strings, "list of string" },
        buf_filter = { cfg.buf_filter, "function" },
        win_filter = { cfg.win_filter, "function" },
        tab_filter = { cfg.tab_filter, "function" },
        x_multiplier = { cfg.x_multiplier, "number" },
        y_multiplier = { cfg.y_multiplier, "number" },
        sync_cursor = { cfg.sync_cursor, "boolean" },
        delay = { cfg.delay, "number" },

        layout = { cfg.layout, "string" },

        split = { cfg.split, "table" },
        ["split.direction"] = { cfg.split.direction, "string" },
        ["split.minimap_width"] = { cfg.split.minimap_width, "number" },
        ["split.fix_width"] = { cfg.split.fix_width, "boolean" },
        ["split.close_if_last_window"] = { cfg.split.close_if_last_window, "boolean" },

        float = { cfg.float, "table" },
        ["float.minimap_width"] = { cfg.float.minimap_width, "number" },
        ["float.max_minimap_height"] = { cfg.float.max_minimap_height, "number", true },
        ["float.margin"] = { cfg.float.margin, "table" },
        ["float.margin.right"] = { cfg.float.margin.right, "number" },
        ["float.margin.top"] = { cfg.float.margin.top, "number" },
        ["float.margin.bottom"] = { cfg.float.margin.bottom, "number" },
        ["float.z_index"] = { cfg.float.z_index, "number" },
        ["float.window_border"] = { cfg.float.window_border, { "string", "table" } },

        diagnostic = { cfg.diagnostic, "table" },
        ["diagnostic.enabled"] = { cfg.diagnostic.enabled, "boolean" },
        ["diagnostic.severity"] = { cfg.diagnostic.severity, "number" },
        ["diagnostic.mode"] = { cfg.diagnostic.mode, "string" },
        ["diagnostic.priority.ERROR"] = { cfg.diagnostic.priority.ERROR, "number" },
        ["diagnostic.priority.WARN"] = { cfg.diagnostic.priority.WARN, "number" },
        ["diagnostic.priority.INFO"] = { cfg.diagnostic.priority.INFO, "number" },
        ["diagnostic.priority.HINT"] = { cfg.diagnostic.priority.HINT, "number" },

        git = { cfg.git, "table" },
        ["git.enabled"] = { cfg.git.enabled, "boolean" },
        ["git.mode"] = { cfg.git.mode, "string" },
        ["git.priority"] = { cfg.git.priority, "number" },

        mini_diff = { cfg.mini_diff, "table" },
        ["mini_diff.enabled"] = { cfg.git.enabled, "boolean" },
        ["mini_diff.mode"] = { cfg.git.mode, "string" },
        ["mini_diff.priority"] = { cfg.git.priority, "number" },

        search = { cfg.search, "table" },
        ["search.enabled"] = { cfg.search.enabled, "boolean" },
        ["search.mode"] = { cfg.search.mode, "string" },
        ["search.priority"] = { cfg.search.priority, "number" },

        mark = { cfg.mark, "table" },
        ["mark.enabled"] = { cfg.mark.enabled, "boolean" },
        ["mark.mode"] = { cfg.mark.mode, "string" },
        ["mark.priority"] = { cfg.mark.priority, "number" },
        ["mark.key"] = { cfg.mark.key, "string" },
        ["mark.show_builtins"] = { cfg.mark.show_builtins, "boolean" },

        click = { cfg.click, "table" },
        ["click.enabled"] = { cfg.click.enabled, "boolean" },
        ["click.auto_switch_focus"] = { cfg.click.auto_switch_focus, "boolean" },

        treesitter = { cfg.treesitter, "table" },
        ["treesitter.enabled"] = { cfg.treesitter.enabled, "boolean" },
        ["treesitter.priority"] = { cfg.treesitter.priority, "number" },

        fold = { cfg.fold, "table" },
        ["fold.enabled"] = { cfg.fold.enabled, "boolean" },

        winopt = { cfg.winopt, { "table", "function" } },
        bufopt = { cfg.bufopt, { "table", "function" } },

        handlers = { cfg.handlers, is_array_of_handlers, "list of handler" },
    })
end

return M
