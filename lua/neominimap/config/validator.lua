local M = {}

---@param value any
---@param expected_type string | string[]
---@param name string
---@return boolean
local function validate_type(value, expected_type, name)
    if type(expected_type) == "string" then
        if value ~= nil and type(value) ~= expected_type then
            vim.notify(
                string.format("Invalid type for %s: expected %s, got %s", name, expected_type, type(value)),
                vim.log.levels.ERROR
            )
            return false
        end
    else
        if value ~= nil and not vim.tbl_contains(expected_type, type(value)) then
            vim.notify(
                string.format(
                    "Invalid type for %s: expected one of %s, got %s",
                    name,
                    vim.inspect(expected_type),
                    type(value)
                ),
                vim.log.levels.ERROR
            )
            return false
        end
    end
    return true
end

---@param value any
---@param expected_type_table table
---@param name string
---@return boolean
local function validate_table(value, expected_type_table, name)
    if value ~= nil then
        for k, v in pairs(expected_type_table) do
            if not validate_type(value[k], v, name .. "." .. k) then
                return false
            end
        end
    end
    return true
end

---@param value any
---@param expected_values any[]
---@param name string
---@return boolean
local function validate_enum(value, expected_values, name)
    if value ~= nil then
        if not vim.tbl_contains(expected_values, value) then
            vim.notify(
                string.format(
                    "Invalid value for %s: expected one of %s, got %s",
                    name,
                    vim.inspect(expected_values),
                    value
                ),
                vim.log.levels.ERROR
            )
            return false
        end
    end
    return true
end

---@param value any
---@param expected_type string | string[]
---@param name string
---@return boolean
local function validate_array(value, expected_type, name)
    if value ~= nil then
        for _, v in ipairs(value) do
            if not validate_type(v, expected_type, name) then
                return false
            end
        end
    end
    return true
end

---@param value any
---@return boolean
local function validate_log_level(value)
    if value ~= nil then
        if type(value) == "string" then
            return validate_enum(value, vim.tbl_keys(vim.log.levels), "log_level")
        elseif type(value) == "number" then
            return validate_enum(value, vim.tbl_values(vim.log.levels), "log_level")
        else
            vim.notify(
                string.format("Invalid type for log_level: expected string or number, got %s", type(value)),
                vim.log.levels.ERROR
            )
            return false
        end
    end
    return true
end

---@param value any
---@return boolean
local function validate_notification_level(value)
    if value ~= nil then
        if type(value) == "string" then
            return validate_enum(value, vim.tbl_keys(vim.log.levels), "notification_level")
        elseif type(value) == "number" then
            return validate_enum(value, vim.tbl_values(vim.log.levels), "notification_level")
        else
            vim.notify(
                string.format("Invalid type for notification_level: expected string or number, got %s", type(value)),
                vim.log.levels.ERROR
            )
            return false
        end
    end
    return true
end

---@param value any
---@return boolean
local function validate_diagnostic(value)
    if value ~= nil then
        if type(value) == "table" then
            return true
                and validate_type(value.enabled, "boolean", "diagnostic.enabled")
                and validate_enum(value.severity, vim.diagnostic.severity, "diagnostic.severity")
                and validate_table(value.priority, {
                    ERROR = "number",
                    WARN = "number",
                    INFO = "number",
                    HINT = "number",
                }, "diagnostic.priority")
        else
            vim.notify(
                string.format("Invalid type for diagnostic: expected table, got %s", type(value)),
                vim.log.levels.ERROR
            )
            return false
        end
    end
    return true
end

---@param value any
---@return boolean
local function validate_treesitter(value)
    if value ~= nil then
        if type(value) == "table" then
            return true
                and validate_type(value.enabled, "boolean", "treesitter.enabled")
                and validate_type(value.priority, "number", "treesitter.priority")
        else
            vim.notify(
                string.format("Invalid type for treesitter: expected table, got %s", type(value)),
                vim.log.levels.ERROR
            )
            return false
        end
    end
    return true
end

---@param value any
---@return boolean
local function validate_margin(value)
    if value ~= nil then
        if type(value) == "table" then
            return true
                and validate_type(value.right, "number", "margin.right")
                and validate_type(value.top, "number", "margin.top")
                and validate_type(value.bottom, "number", "margin.bottom")
        else
            vim.notify(
                string.format("Invalid type for margin: expected table, got %s", type(value)),
                vim.log.levels.ERROR
            )
            return false
        end
    end
    return true
end

---@param config any
---@return boolean
M.validate_user_config = function(config)
    if config ~= nil then
        return true
            and validate_type(config.auto_enable, "boolean", "auto_enable")
            and validate_log_level(config.log_level)
            and validate_notification_level(config.notification_level)
            and validate_array(config.exclude_filetypes, "string", "exclude_filetypes")
            and validate_array(config.exclude_buftypes, "string", "exclude_buftypes")
            and validate_type(config.buf_filter, "function", "buf_filter")
            and validate_type(config.win_filter, "function", "win_filter")
            and validate_type(config.minimap_width, "number", "minimap_width")
            and validate_type(config.x_multiplier, "number", "x_multiplier")
            and validate_type(config.y_multiplier, "number", "y_multiplier")
            and validate_type(config.delay, "number", "delay")
            and validate_type(config.z_index, "number", "z_index")
            and validate_type(config.window_border, { "string", "table" }, "window_border")
            and validate_diagnostic(config.diagnostic)
            and validate_treesitter(config.treesitter)
            and validate_margin(config.margin)
    end
    return true
end

return M
