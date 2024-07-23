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
        minimap_width = { cfg.minimap_width, "number", true },
        x_multiplier = { cfg.x_multiplier, "number", true },
        y_multiplier = { cfg.y_multiplier, "number", true },
        delay = { cfg.delay, "number", true },

        ["diagnostic.enabled"] = { cfg.diagnostic.enabled, "boolean", true },
        ["diagnostic.severity"] = { cfg.diagnostic.severity, "number", true },
        ["diagnostic.priority.ERROR"] = { cfg.diagnostic.priority.ERROR, "number", true },
        ["diagnostic.priority.WARN"] = { cfg.diagnostic.priority.WARN, "number", true },
        ["diagnostic.priority.INFO"] = { cfg.diagnostic.priority.INFO, "number", true },
        ["diagnostic.priority.HINT"] = { cfg.diagnostic.priority.HINT, "number", true },

        ["treesitter.enabled"] = { cfg.treesitter.enabled, "boolean", true },
        ["treesitter.priority"] = { cfg.treesitter.priority, "number", true },

        ["margin.right"] = { cfg.margin.right, "number", true },
        ["margin.top"] = { cfg.margin.top, "number", true },
        ["margin.bottom"] = { cfg.margin.bottom, "number", true },

        z_index = { cfg.z_index, "number", true },
        window_border = { cfg.window_border, { "string", "table" }, true },
        winopt = { cfg.winopt, { "table", "function" }, true },
        bufopt = { cfg.bufopt, { "table", "function" }, true },
    })
end

return M
