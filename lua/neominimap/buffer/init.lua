local M = {}

---@param group string | integer
M.create_autocmds = function(group) -- To lazy load
    local api = vim.api
    api.nvim_create_autocmd({ "BufNew", "BufRead" }, {
        group = group,
        desc = "Create minimap buffer when buffer is opened",
        callback = function(args)
            require("neominimap.buffer.autocmds").on_buf_new(args)
        end,
    })

    api.nvim_create_autocmd("BufUnload", {
        group = group,
        desc = "Wipe out minimap buffer when buffer is closed",
        callback = function(args)
            require("neominimap.buffer.autocmds").on_buf_unload(args)
        end,
    })
    api.nvim_create_autocmd({ "TextChanged", "TextChangedI" }, {
        group = group,
        desc = "Update minimap buffer when text is changed",
        callback = function(args)
            require("neominimap.buffer.autocmds").on_text_change(args)
        end,
    })
    api.nvim_create_autocmd("User", {
        group = group,
        pattern = "MinimapBufferTextUpdated",
        desc = "Update annotations when buffer text is updated",
        callback = function(args)
            require("neominimap.buffer.autocmds").on_minimap_text_update(args)
        end,
    })
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
