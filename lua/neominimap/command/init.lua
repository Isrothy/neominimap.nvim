---@class (exact) Neominimap.Subcommand
---@field impl fun(args:string[], opts: table) The command implementation
---@field complete? fun(subcmd_arg_lead: string): string[] (optional) Command completions callback, taking the lead of the subcommand's arguments

local M = {}

---@type boolean
local subcommand_loaded = false
local subcommand_tbl_cache = {}
local get_subcommand_tbl = function()
    if subcommand_loaded then
        return subcommand_tbl_cache
    end
    subcommand_loaded = true
    subcommand_tbl_cache = vim.tbl_deep_extend(
        "error",
        require("neominimap.command.window").subcommand_tbl,
        require("neominimap.command.buffer").subcommand_tbl,
        require("neominimap.command.global").subcommand_tbl,
        require("neominimap.command.perf").subcommand_tbl,
        require("neominimap.command.focus").subcommand_tbl
    )
    return subcommand_tbl_cache
end

---@param opts table
M.commands = function(opts)
    local fargs = opts.fargs
    local subcommand_key = fargs[1]
    local args = #fargs > 1 and vim.list_slice(fargs, 2, #fargs) or {}
    local subcommand = get_subcommand_tbl()[subcommand_key]
    if not subcommand then
        local logger = require("neominimap.logger")
        logger.notify("Neominimap: Unknown command: " .. subcommand_key, vim.log.levels.ERROR)
        return
    end
    subcommand.impl(args, opts)
end

M.complete = function(arg_lead, cmdline, _)
    local subcmd_key, subcmd_arg_lead = cmdline:match("^['<,'>]*Neominimap[!]*%s(%S+)%s(.*)$")
    local subcommand_tbl = get_subcommand_tbl()
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
end

return M
