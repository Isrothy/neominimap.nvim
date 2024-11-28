---@type Neominimap.Window
return {
    create_autocmds = function(group)
        local api = vim.api
        local config = require("neominimap.config")
        api.nvim_create_autocmd("VimEnter", {
            group = group,
            callback = function()
                require("neominimap.window.split.autocmds").on_vim_enter()
            end,
        })
        api.nvim_create_autocmd("BufWinEnter", {
            group = group,
            callback = function(args)
                require("neominimap.window.split.autocmds").on_buf_win_enter(args)
            end,
        })
        api.nvim_create_autocmd({ "WinNew", "WinEnter" }, {
            group = group,
            callback = function(args)
                require("neominimap.window.split.autocmds").on_win_new(args)
            end,
        })
        api.nvim_create_autocmd("WinClosed", {
            group = group,
            callback = function(args)
                require("neominimap.window.split.autocmds").on_win_closed(args)
            end,
        })
        api.nvim_create_autocmd("TabEnter", {
            group = group,
            callback = function(args)
                require("neominimap.window.split.autocmds").on_tab_enter(args)
            end,
        })
        api.nvim_create_autocmd({ "CursorMoved", "CursorMovedI" }, {
            group = group,
            callback = function(args)
                require("neominimap.window.split.autocmds").on_cursor_moved(args)
            end,
        })

        if config.split.fix_width then
            api.nvim_create_autocmd("WinResized", {
                group = group,
                desc = "Reset minimap width when window is resized",
                callback = function(args)
                    require("neominimap.window.split.autocmds").fix_width_on_resize(args)
                end,
            })
        end

        api.nvim_create_autocmd("User", {
            group = group,
            pattern = { "MinimapBufferCreated", "MinimapBufferDeleted" },
            desc = "Refresh source window when buffer is created or deleted",
            callback = function(args)
                require("neominimap.window.split.autocmds").on_minimap_buffer_created_or_deleted(args)
            end,
        })
        api.nvim_create_autocmd("User", {
            group = group,
            pattern = "MinimapBufferTextUpdated",
            desc = "Reset cursor line when buffer text is updated",
            callback = function(args)
                require("neominimap.window.split.autocmds").on_minimap_buffer_text_changed(args)
            end,
        })
    end,
    get_global_apis = function()
        local apis = require("neominimap.window.split.apis")
        return apis.global_apis
    end,
    get_win_apis = function()
        local apis = require("neominimap.window.split.apis")
        return apis.win_apis
    end,
    get_tab_apis = function()
        local apis = require("neominimap.window.split.apis")
        return apis.tab_apis
    end,
    get_focus_apis = function()
        local apis = require("neominimap.window.split.apis")
        return apis.focus_apis
    end,
}
