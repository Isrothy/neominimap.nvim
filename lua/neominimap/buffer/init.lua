local M = {}

---@param group string | integer
M.create_autocmds = function(group) -- To lazy load
    require("neominimap.buffer.autocmds").create_autocmds(group)
end

--- The winid of the minimap attached to the given window
---@param bufnr integer
M.get_minimap_bufnr = function(bufnr)
    return require("neominimap.buffer.buffer_map").get_minimap_bufnr(bufnr)
end

--- Return the list of buffers that has a minimap buffer attached to
M.list_buffers = function()
    return require("neominimap.buffer.buffer_map").list_buffers()
end

--- @return Neominimap.Command.Buf.Handler
M.get_buf_cmds = function()
    return require("neominimap.buffer.cmds").buf_cmds
end

--- @return Neominimap.Command.Global.Handler
M.get_global_cmds = function()
    return require("neominimap.buffer.cmds").global_cmds
end

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
