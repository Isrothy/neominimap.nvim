local M = {}

M.create_autocmds = function() -- To lazy load
    require("neominimap.buffer.autocmds").create_autocmds()
end

M.get_minimap_bufnr = require("neominimap.buffer.buffer_map").get_minimap_bufnr
M.list_buffers = require("neominimap.buffer.buffer_map").list_buffers

M.buf_cmds = require("neominimap.buffer.cmds").buf_cmds
M.global_cmds = require("neominimap.buffer.cmds").global_cmds

---@return integer
M.get_empty_buffer = function()
    return require("neominimap.buffer.internal").empty_buffer
end

return M
