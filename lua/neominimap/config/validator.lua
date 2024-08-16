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
local is_string_array = is_array_of(function(x)
    return type(x) == "string"
end)

---@param cfg any
---@return boolean
M.validate_config = function(cfg)
    return validate_path("vim.g.neominimap", {
        auto_enable = { cfg.auto_enable, "boolean" },
        log_level = { cfg.log_level, "number" },
        notification_level = { cfg.notification_level, "number" },
        log_path = { cfg.log_path, "string" },
        exclude_filetypes = { cfg.exclude_filetypes, is_string_array, "list of string" },
        exclude_buftypes = { cfg.exclude_buftypes, is_string_array, "list of string" },
        buf_filter = { cfg.buf_filter, "function" },
        win_filter = { cfg.win_filter, "function" },
        max_minimap_height = { cfg.max_win_height, "number", true },
        minimap_width = { cfg.minimap_width, "number" },
        x_multiplier = { cfg.x_multiplier, "number" },
        y_multiplier = { cfg.y_multiplier, "number" },
        sync_cursor = { cfg.sync_cursor, "boolean" },
        delay = { cfg.delay, "number" },

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

        search = { cfg.search, "table" },
        ["search.enabled"] = { cfg.search.enabled, "boolean" },
        ["search.mode"] = { cfg.search.mode, "string" },
        ["search.priority"] = { cfg.search.priority, "number" },

        click = { cfg.click, "table" },
        ["click.enabled"] = { cfg.click.enabled, "boolean" },
        ["click.auto_switch_focus"] = { cfg.click.auto_switch_focus, "boolean" },

        treesitter = { cfg.treesitter, "table" },
        ["treesitter.enabled"] = { cfg.treesitter.enabled, "boolean" },
        ["treesitter.priority"] = { cfg.treesitter.priority, "number" },

        margin = { cfg.margin, "table" },
        ["margin.right"] = { cfg.margin.right, "number" },
        ["margin.top"] = { cfg.margin.top, "number" },
        ["margin.bottom"] = { cfg.margin.bottom, "number" },

        fold = { cfg.fold, "table" },
        ["fold.enabled"] = { cfg.fold.enabled, "boolean" },

        z_index = { cfg.z_index, "number" },
        window_border = { cfg.window_border, { "string", "table" } },
        winopt = { cfg.winopt, { "table", "function" } },
        bufopt = { cfg.bufopt, { "table", "function" } },
    })
end

return M
