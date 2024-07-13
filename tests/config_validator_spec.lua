local assert = require("luassert")

local M = {}

describe("Neominimap Config Validation", function()
    local validate_user_config = require("neominimap.config.validator").validate_user_config

    it("should validate correct config", function()
        local config = {
            auto_enable = true,
            log_level = "INFO",
            notification_level = "WARN",
            log_path = "/path/to/log",
            exclude_filetypes = { "help", "markdown" },
            exclude_buftypes = { "nofile", "quickfix" },
            buf_filter = function(bufnr)
                return true
            end,
            win_filter = function(winid)
                return true
            end,
            minimap_width = 20,
            x_multiplier = 4,
            y_multiplier = 1,
            delay = 200,
            z_index = 1,
            window_border = "single",
            diagnostic = {
                enabled = true,
                severity = vim.diagnostic.severity.WARN,
                priority = {
                    ERROR = 100,
                    WARN = 90,
                    INFO = 80,
                    HINT = 70,
                },
            },
            treesitter = {
                enabled = true,
                priority = 200,
            },
        }
        assert.is_true(validate_user_config(config))
    end)

    -- Invalid log_level (string)
    it("should invalidate incorrect log_level string", function()
        local config = {
            log_level = "INVALID_LEVEL",
        }
        assert.is_false(validate_user_config(config))
    end)

    -- Invalid log_level (number)
    it("should invalidate incorrect log_level number", function()
        local config = {
            log_level = 999,
        }
        assert.is_false(validate_user_config(config))
    end)

    -- Invalid notification_level (string)
    it("should invalidate incorrect notification_level string", function()
        local config = {
            notification_level = "INVALID_LEVEL",
        }
        assert.is_false(validate_user_config(config))
    end)

    -- Invalid notification_level (number)
    it("should invalidate incorrect notification_level number", function()
        local config = {
            notification_level = 999,
        }
        assert.is_false(validate_user_config(config))
    end)

    -- Valid exclude_filetypes
    it("should validate correct exclude_filetypes", function()
        local config = {
            exclude_filetypes = { "help", "markdown" },
        }
        assert.is_true(validate_user_config(config))
    end)

    -- Invalid exclude_filetypes
    it("should invalidate incorrect exclude_filetypes", function()
        local config = {
            exclude_filetypes = { 123, true },
        }
        assert.is_false(validate_user_config(config))
    end)

    -- Valid buf_filter
    it("should validate correct buf_filter", function()
        local config = {
            buf_filter = function(bufnr)
                return true
            end,
        }
        assert.is_true(validate_user_config(config))
    end)

    -- Invalid buf_filter
    it("should invalidate incorrect buf_filter", function()
        local config = {
            buf_filter = "not_a_function",
        }
        assert.is_false(validate_user_config(config))
    end)

    -- Valid window_border (string)
    it("should validate correct window_border string", function()
        local config = {
            window_border = "single",
        }
        assert.is_true(validate_user_config(config))
    end)

    -- Valid window_border (table)
    it("should validate correct window_border table", function()
        local config = {
            window_border = { "┌", "─", "┐", "│", "┘", "─", "└", "│" },
        }
        assert.is_true(validate_user_config(config))
    end)

    -- Invalid window_border
    it("should invalidate incorrect window_border", function()
        local config = {
            window_border = 123,
        }
        assert.is_false(validate_user_config(config))
    end)

    -- Valid diagnostic config
    it("should validate correct diagnostic config", function()
        local config = {
            diagnostic = {
                enabled = true,
                severity = vim.diagnostic.severity.ERROR,
                priority = {
                    ERROR = 100,
                    WARN = 90,
                    INFO = 80,
                    HINT = 70,
                },
            },
        }
        assert.is_true(validate_user_config(config))
    end)

    -- Invalid diagnostic config (severity)
    it("should invalidate incorrect diagnostic severity", function()
        local config = {
            diagnostic = {
                severity = "INVALID_SEVERITY",
            },
        }
        assert.is_false(validate_user_config(config))
    end)

    -- Invalid diagnostic config (priority)
    it("should invalidate incorrect diagnostic priority", function()
        local config = {
            diagnostic = {
                priority = {
                    ERROR = "high",
                },
            },
        }
        assert.is_false(validate_user_config(config))
    end)

    -- Valid treesitter config
    it("should validate correct treesitter config", function()
        local config = {
            treesitter = {
                enabled = true,
                priority = 200,
            },
        }
        assert.is_true(validate_user_config(config))
    end)

    -- Invalid treesitter config
    it("should invalidate incorrect treesitter config", function()
        local config = {
            treesitter = {
                enabled = "not_a_boolean",
            },
        }
        assert.is_false(validate_user_config(config))
    end)

    -- Valid z_index type
    it("should validate correct z_index type", function()
        local config = {
            z_index = 1,
        }
        assert.is_true(validate_user_config(config))
    end)

    -- Invalid z_index type
    it("should invalidate incorrect z_index type", function()
        local config = {
            z_index = "top",
        }
        assert.is_false(validate_user_config(config))
    end)

    -- Valid delay type
    it("should validate correct delay type", function()
        local config = {
            delay = 100,
        }
        assert.is_true(validate_user_config(config))
    end)

    -- Invalid delay type
    it("should invalidate incorrect delay type", function()
        local config = {
            delay = "fast",
        }
        assert.is_false(validate_user_config(config))
    end)
end)

return M
