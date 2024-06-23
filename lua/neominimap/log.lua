local M = {}
local config = require("neominimap.config").get()
local util = require("neominimap.util")

M.notify = function(msg, level, opt)
    if config.debug then
        local file = io.open(config.log_path, "a")
        if file then
            file:write(msg .. "\n")
            file:close()
        else
            vim.notify("file not found", vim.log.levels.ERROR)
        end
        -- util.noautocmd(vim.notify)("Neominimap: " .. msg, level, opt)
    end
end

return M
