local M = {}

local config = require("neominimap.config")

local function lualib_available(name)
    local ok, _ = pcall(require, name)
    return ok
end

local check_neovim_version = function(health)
    if vim.fn.has("nvim-0.10") == 1 then
        health.ok("Neovim version is 0.10 or higher")
    else
        health.error("Neovim version is lower than 0.10")
    end
end

local check_lua_env = function(health)
    if not _G.jit then
        health.error(
            "Not running on LuaJIT! Non-JIT Lua runtimes are not officially supported by the plugin. Mileage may vary."
        )
    end
end

local check_configuration = function(health)
    local cfg = require("neominimap.config")
    local ok, err = require("neominimap.config.validator").validate_config(cfg)
    if ok then
        health.ok("neominimap: valid config")
    else
        health.error("neominimap: invalid config: " .. err)
    end
end

local check_treesitter = function(health)
    if config.treesitter.enabled then
        health.info("TreeSitter integration is enabled")
        if lualib_available("nvim-treesitter") then
            health.ok("TreeSitter is installed")
            local parsers = require("nvim-treesitter.parsers").available_parsers()
            if #parsers > 0 then
                health.ok("TreeSitter parsers are installed: " .. table.concat(parsers, ", "))
            else
                health.warn("No TreeSitter parsers installed")
            end
        else
            health.warn("TreeSitter is not installed")
        end
    else
        health.info("TreeSitter is disabled")
    end
end

local check_git = function(health)
    if config.git.enabled then
        health.info("Gitsigns integration is enabled")
        if lualib_available("gitsigns") then
            health.ok("Gitsigns is installed")
        else
            health.warn("Gitsigns is not installed")
        end
    else
        health.info("Git integration is disabled")
    end
end

M.check = function()
    local health = vim.health or require("health")

    -- Polyfill deprecated health api
    if vim.fn.has("nvim-0.10") ~= 1 then
        ---@diagnostic disable: deprecated
        health = {
            start = health.report_start,
            ok = health.report_ok,
            info = health.report_info,
            warn = health.report_warn,
            error = health.report_error,
        }
        ---@diagnostic enable: deprecated
    end

    check_neovim_version(health)
    check_lua_env(health)
    check_configuration(health)
    check_treesitter(health)
    check_git(health)
end

return M
