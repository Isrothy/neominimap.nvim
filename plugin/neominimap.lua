local api = vim.api
local config = require("neominimap.config")

api.nvim_create_user_command("Neominimap", function(opts)
    require("neominimap.command").commands(opts)
end, {
    nargs = "+",
    desc = "Neominimap command",
    complete = function(arg_lead, cmdline, _)
        return require("neominimap.command").complete(arg_lead, cmdline)
    end,
    bang = false,
})
if config.auto_enable then
    require("neominimap.autocmds").create_autocmds()
end
