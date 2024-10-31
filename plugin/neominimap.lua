local api = vim.api
local config = require("neominimap.config")

api.nvim_create_user_command("Neominimap", function(opts)
    local fargs = opts.fargs
    local subcommand_key = fargs[1]
    local args = #fargs > 1 and vim.list_slice(fargs, 2, #fargs) or {}
    local subcommand_tbl = require("neominimap.command").subcommand_tbl
    local subcommand = subcommand_tbl[subcommand_key]
    if not subcommand then
        local logger = require("neominimap.logger")
        logger.notify("Neominimap: Unknown command: " .. subcommand_key, vim.log.levels.ERROR)
        return
    end
    subcommand.impl(args, opts)
end, {
    nargs = "+",
    desc = "Neominimap command",
    complete = function(arg_lead, cmdline, _)
        local subcommand_tbl = require("neominimap.command").subcommand_tbl
        local subcmd_key, subcmd_arg_lead = cmdline:match("^['<,'>]*Neominimap[!]*%s(%S+)%s(.*)$")
        if subcmd_key and subcmd_arg_lead and subcommand_tbl[subcmd_key] and subcommand_tbl[subcmd_key].complete then
            return subcommand_tbl[subcmd_key].complete(subcmd_arg_lead)
        end
        if cmdline:match("^['<,'>]*Neominimap[!]*%s+%w*$") then
            local subcommand_keys = vim.tbl_keys(subcommand_tbl)
            return vim.iter(subcommand_keys)
                :filter(function(key)
                    return key:find(arg_lead) ~= nil
                end)
                :totable()
        end
    end,
    bang = false,
})
if config.auto_enable then
    require("neominimap.autocmds").create_autocmds()
end

-- local logger = require("neominimap.logger")
-- logger.log(vim.inspect(package.loaded), vim.log.levels.DEBUG)
