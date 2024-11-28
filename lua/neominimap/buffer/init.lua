local M = {}

---@param group string | integer
M.create_autocmds = function(group) -- To lazy load
    local api = vim.api

    api.nvim_create_autocmd("VimEnter", {
        group = group,
        desc = "Create minimap buffer on VimEnter",
        callback = function()
            require("neominimap.buffer.autocmds").on_vim_enter()
        end,
    })

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

--- Return the minimap buffer number attached to the given buffer
---@param bufnr integer
---@return integer?
M.get_minimap_bufnr = function(bufnr)
    return require("neominimap.buffer.buffer_map").get_minimap_bufnr(bufnr)
end

--- Return the list of buffers that has a minimap buffer attached to
M.list_buffers = function()
    return require("neominimap.buffer.buffer_map").list_buffers()
end

--- @return Neominimap.Api.Buf.Handler
M.get_buf_apis = function()
    return require("neominimap.buffer.apis").buf_apis
end

--- @return Neominimap.Api.Global.Handler
M.get_global_apis = function()
    return require("neominimap.buffer.apis").global_apis
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
