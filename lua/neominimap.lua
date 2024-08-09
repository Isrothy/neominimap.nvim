local M = {}

local api = vim.api

---@param args string[]
---@param opts table
M.refresh = function(args, opts)
    require("neominimap.command.global").subcommand_tbl.refresh.impl(args, opts)
end

---@param args string[]
---@param opts table
M.on = function(args, opts)
    require("neominimap.command.global").subcommand_tbl.on.impl(args, opts)
end

---@param args string[]
---@param opts table
M.off = function(args, opts)
    require("neominimap.command.global").subcommand_tbl.off.impl(args, opts)
end

---@param args string[]
---@param opts table
M.toggle = function(args, opts)
    require("neominimap.command.global").subcommand_tbl.toggle.impl(args, opts)
end

---@param args string[]
---@param opts table
M.bufOn = function(args, opts)
    require("neominimap.command.buffer").subcommand_tbl.bufOn.impl(args, opts)
end

---@param args string[]
---@param opts table
M.bufOff = function(args, opts)
    require("neominimap.command.buffer").subcommand_tbl.bufOff.impl(args, opts)
end

---@param args string[]
---@param opts table
M.bufToggle = function(args, opts)
    require("neominimap.command.buffer").subcommand_tbl.bufToggle.impl(args, opts)
end

---@param args string[]
---@param opts table
M.bufRefresh = function(args, opts)
    require("neominimap.command.buffer").subcommand_tbl.bufRefresh.impl(args, opts)
end

---@param args string[]
---@param opts table
M.winOn = function(args, opts)
    require("neominimap.command.window").subcommand_tbl.winOn.impl(args, opts)
end

---@param args string[]
---@param opts table
M.winOff = function(args, opts)
    require("neominimap.command.window").subcommand_tbl.winOff.impl(args, opts)
end

---@param args string[]
---@param opts table
M.winToggle = function(args, opts)
    require("neominimap.command.window").subcommand_tbl.winToggle.impl(args, opts)
end

---@param args string[]
---@param opts table
M.winRefresh = function(args, opts)
    require("neominimap.command.window").subcommand_tbl.winRefresh.impl(args, opts)
end

---@param args string[]
---@param opts table
M.perf = function(args, opts)
    require("neominimap.command.perf").subcommand_tbl.perf.impl(args, opts)
end

---@param args string[]
---@param opts table
M.focus = function(args, opts)
    require("neominimap.command.focus").subcommand_tbl.focus.impl(args, opts)
end

---@param args string[]
---@param opts table
M.unfocus = function(args, opts)
    require("neominimap.command.focus").subcommand_tbl.unfocus.impl(args, opts)
end

---@param args string[]
---@param opts table
M.toggleFocus = function(args, opts)
    require("neominimap.command.focus").subcommand_tbl.toggleFocus.impl(args, opts)
end

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
