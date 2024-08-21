local cmds = require("neominimap.window.float.cmds")

---@type Neominimap.Window
return {
    create_autocmds = function()
        require("neominimap.window.float.autocmds").create_autocmds()
    end,
    global_cmds = cmds.global_cmds,
    win_cmds = cmds.win_cmds,
    tab_cmds = cmds.tab_cmds,
    focus_cmds = cmds.focus_cmds,
}
