local M = {}

local config = require("neominimap.config").get()

local function lualib_available(name)
    local ok, _ = pcall(require, name)
    return ok
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

    -- Check Neovim version
    if vim.fn.has("nvim-0.10") == 1 then
        health.ok("Neovim version is 0.10 or higher")
    else
        health.error("Neovim version is lower than 0.10")
    end

    if not _G.jit then
        health.error(
            "Not running on LuaJIT! Non-JIT Lua runtimes are not officially supported by the plugin. Mileage may vary."
        )
    end

    if config.treesitter.enabled then
        health.info("TreeSitter integration is enabled")
        -- Check for TreeSitter
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

    if config.git.enabled then
        health.info("Gitsigns integration is enabled")
        -- Check for gitsigns
        if lualib_available("gitsigns") then
            health.ok("Gitsigns is installed")
        else
            health.warn("Gitsigns is not installed")
        end
    else
        health.info("Git integration is disabled")
    end
end

return M
