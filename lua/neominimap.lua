local M = {}

local api = vim.api

M.setup = function()
    local gid = api.nvim_create_augroup("Neominimap", { clear = true })

    ---@param opts table
    local commands = function(opts)
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
    end
    api.nvim_create_user_command("Neominimap", commands, {
        nargs = "+",
        desc = "Neominimap command",
        complete = function(arg_lead, cmdline, _)
            local subcommand_tbl = require("neominimap.command").subcommand_tbl
            local subcmd_key, subcmd_arg_lead = cmdline:match("^['<,'>]*Neominimap[!]*%s(%S+)%s(.*)$")
            if
                subcmd_key
                and subcmd_arg_lead
                and subcommand_tbl[subcmd_key]
                and subcommand_tbl[subcmd_key].complete
            then
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
    api.nvim_create_autocmd("VimEnter", {
        group = gid,
        callback = vim.schedule_wrap(function()
            local logger = require("neominimap.logger")
            local config = require("neominimap.config").get()
            logger.log("VimEnter event triggered. Checking if minimap should auto-enable.", vim.log.levels.TRACE)
            if config.auto_enable then
                vim.cmd("Neominimap on")
            end
        end),
    })
end

return M
