local M = {}
local config = require("neominimap.config").get()
local util = require("neominimap.util")

M.notify = function(msg, level, opt)
    if config.debug then
        util.noautocmd(vim.notify)("Neominimap: " .. msg, level, opt)
    end
end

return M
