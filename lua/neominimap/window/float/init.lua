---@type Neominimap.Window
return {
    create_autocmds = function(group)
        local config = require("neominimap.config")
        local api = vim.api
        if config.click.enabled and not config.click.auto_switch_focus then
            api.nvim_create_autocmd("WinEnter", {
                group = group,
                callback = function()
                    require("neominimap.window.float.autocmds").focus_on_win_new()
                end,
            })
        end

        api.nvim_create_autocmd("BufWinEnter", {
            group = group,
            callback = function()
                require("neominimap.window.float.autocmds").on_buf_win_enter()
            end,
        })
        api.nvim_create_autocmd("WinNew", {
            group = group,
            callback = function()
                require("neominimap.window.float.autocmds").on_win_new()
            end,
        })
        api.nvim_create_autocmd("WinClosed", {
            group = group,
            callback = function(args)
                require("neominimap.window.float.autocmds").on_win_closed(args)
            end,
        })
        api.nvim_create_autocmd("TabEnter", {
            group = group,
            callback = function()
                require("neominimap.window.float.autocmds").on_tab_enter()
            end,
        })
        api.nvim_create_autocmd("WinResized", {
            group = group,
            callback = function()
                require("neominimap.window.float.autocmds").on_win_resized()
            end,
        })
        api.nvim_create_autocmd("WinScrolled", {
            group = group,
            callback = function()
                require("neominimap.window.float.autocmds").on_win_scrolled()
            end,
        })
        api.nvim_create_autocmd({ "CursorMoved", "CursorMovedI" }, {
            group = group,
            callback = function()
                require("neominimap.window.float.autocmds").on_cursor_moved()
            end,
        })
        api.nvim_create_autocmd("User", {
            group = group,
            pattern = { "MinimapBufferCreated", "MinimapBufferDeleted" },
            callback = function(args)
                require("neominimap.window.float.autocmds").on_minimap_buffer_created_or_deleted(args)
            end,
        })
        api.nvim_create_autocmd("User", {
            group = group,
            pattern = "MinimapBufferTextUpdated",
            desc = "Reset cursor line when buffer text is updated",
            callback = function(args)
                require("neominimap.window.float.autocmds").on_minimap_buffer_text_changed(args)
            end,
        })
    end,
    get_global_apis = function()
        local cmds = require("neominimap.window.float.apis")
        return cmds.global_apis
    end,
    get_win_apis = function()
        local cmds = require("neominimap.window.float.apis")
        return cmds.win_apis
    end,
    get_tab_apis = function()
        local cmds = require("neominimap.window.float.apis")
        return cmds.tab_apis
    end,
    get_focus_apis = function()
        local cmds = require("neominimap.window.float.apis")
        return cmds.focus_apis
    end,
}
