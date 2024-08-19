local M = {}

M.create_autocmds = function() -- To lazy load
    require("neominimap.window.float.autocmds").create_autocmds()
end

M.global_cmds = require("neominimap.window.float.cmds").global_cmds
M.win_cmds = require("neominimap.window.float.cmds").win_cmds
M.focus_cmds = require("neominimap.window.float.cmds").focus_cmds

return M
