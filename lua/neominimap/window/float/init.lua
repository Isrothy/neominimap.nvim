---@type Neominimap.Window
return {
    create_autocmds = function(group)
        local config = require("neominimap.config")
        local api = vim.api
        if config.click.enabled and not config.click.auto_switch_focus then
            api.nvim_create_autocmd("WinEnter", {
                group = group,
                callback = function()
                    require("neominimap.window.float.autocmds").focusOnWinNew()
                end,
            })
        end

        api.nvim_create_autocmd("BufWinEnter", {
            group = group,
            callback = function()
                require("neominimap.window.float.autocmds").onBufWinEnter()
            end,
        })
        api.nvim_create_autocmd("WinNew", {
            group = group,
            callback = function()
                require("neominimap.window.float.autocmds").onWinNew()
            end,
        })
        api.nvim_create_autocmd("WinClosed", {
            group = group,
            callback = function(args)
                require("neominimap.window.float.autocmds").onwinClosed(args)
            end,
        })
        api.nvim_create_autocmd("TabEnter", {
            group = group,
            callback = function()
                require("neominimap.window.float.autocmds").onTabEnter()
            end,
        })
        api.nvim_create_autocmd("WinResized", {
            group = group,
            callback = function()
                require("neominimap.window.float.autocmds").onWinResized()
            end,
        })
        api.nvim_create_autocmd("WinScrolled", {
            group = group,
            callback = function()
                require("neominimap.window.float.autocmds").onWinScrolled()
            end,
        })
        api.nvim_create_autocmd({ "CursorMoved", "CursorMovedI" }, {
            group = group,
            callback = function()
                require("neominimap.window.float.autocmds").onCursorMoved()
            end,
        })
        api.nvim_create_autocmd("User", {
            group = group,
            pattern = { "MinimapBufferCreated", "MinimapBufferDeleted" },
            callback = function(args)
                require("neominimap.window.float.autocmds").onMinimapBufferCreatedOrDeleted(args)
            end,
        })
        api.nvim_create_autocmd("User", {
            group = group,
            pattern = "MinimapBufferTextUpdated",
            desc = "Reset cursor line when buffer text is updated",
            callback = function(args)
                require("neominimap.window.float.autocmds").onMinimapBufferTextChanged(args)
            end,
        })
    end,
    get_global_cmds = function()
        local cmds = require("neominimap.window.float.cmds")
        return cmds.global_cmds
    end,
    get_win_cmds = function()
        local cmds = require("neominimap.window.float.cmds")
        return cmds.win_cmds
    end,
    get_tab_cmds = function()
        local cmds = require("neominimap.window.float.cmds")
        return cmds.tab_cmds
    end,
    get_focus_cmds = function()
        local cmds = require("neominimap.window.float.cmds")
        return cmds.focus_cmds
    end,
}
