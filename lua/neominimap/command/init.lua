---@alias Neominimap.Command.Impl fun(args:string[], opts: table)

---@class (exact) Neominimap.Subcommand
---@field impl Neominimap.Command.Impl  The command implementation
---@field complete? fun(subcmd_arg_lead: string): string[] (optional) Command completions callback, taking the lead of the subcommand's arguments

---@type table<string, Neominimap.Subcommand>
local subcommand_tbl = vim.tbl_deep_extend(
    "error",
    require("neominimap.command.global").subcommand_tbl,
    require("neominimap.command.buf").subcommand_tbl,
    require("neominimap.command.tab").subcommand_tbl,
    require("neominimap.command.win").subcommand_tbl,
    require("neominimap.command.focus").subcommand_tbl
    -- require("neominimap.command.perf").subcommand_tbl,
)

return {
    subcommand_tbl = subcommand_tbl
}
