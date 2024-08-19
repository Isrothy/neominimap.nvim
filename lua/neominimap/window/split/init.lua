local cmds = require("neominimap.window.split.cmds")

---@type Neominimap.Window
return {
    create_autocmds = function()
        require("neominimap.window.split.autocmds").create_autocmds()
    end,
    global_cmds = cmds.global_cmds,
    win_cmds = cmds.win_cmds,
    focus_cmds = cmds.focus_cmds,
}
