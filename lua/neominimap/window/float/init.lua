---@type Neominimap.Window
return {
    create_autocmds = function(group)
        require("neominimap.window.float.autocmds").create_autocmds(group)
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
