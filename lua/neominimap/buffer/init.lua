local M = {}

---@param group string | integer
M.create_autocmds = function(group) -- To lazy load
    require("neominimap.buffer.autocmds").create_autocmds(group)
end

M.get_minimap_bufnr = require("neominimap.buffer.buffer_map").get_minimap_bufnr
M.list_buffers = require("neominimap.buffer.buffer_map").list_buffers

M.buf_cmds = require("neominimap.buffer.cmds").buf_cmds
M.global_cmds = require("neominimap.buffer.cmds").global_cmds

---@param bufnr integer
---@param handler_name string
M.apply_handler = function(bufnr, handler_name)
    require("neominimap.buffer.internal").apply_handler(bufnr, handler_name)
end

---@return integer
M.get_empty_buffer = function()
    return require("neominimap.buffer.internal").empty_buffer
end

return M
