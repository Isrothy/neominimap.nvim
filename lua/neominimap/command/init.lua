---@class Neominimap.Subcommand
---@field impl fun(args:string[], opts: table) The command implementation
---@field complete? fun(subcmd_arg_lead: string): string[] (optional) Command completions callback, taking the lead of the subcommand's arguments

local M = {}

M.subcommand_tbl = vim.tbl_deep_extend(
    "error",
    require("neominimap.command.window").subcommand_tbl,
    require("neominimap.command.buffer").subcommand_tbl,
    require("neominimap.command.global").subcommand_tbl,
    require("neominimap.command.perf").subcommand_tbl,
    require("neominimap.command.focus").subcommand_tbl
)

return M
