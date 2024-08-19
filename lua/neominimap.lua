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
    require("neominimap.autocmds")
    api.nvim_create_autocmd("VimEnter", {
        group = "Neominimap",
        callback = vim.schedule_wrap(function()
            local logger = require("neominimap.logger")
            local config = require("neominimap.config").get()
            logger.log("VimEnter event triggered. Checking if minimap should auto-enable.", vim.log.levels.TRACE)
            if config.auto_enable then
                M.on({}, {})
            end
        end),
    })
end

return M
