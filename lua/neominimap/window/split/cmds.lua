local M = {}

---@type Neominimap.Command.Global.Handler
M.global_cmds = {
    ["on"] = function() end,
    ["off"] = function() end,
    ["refresh"] = function() end,
}

---@type Neominimap.Command.Win.Handler
M.win_cmds = {
    ["winRefresh"] = function() end,
    ["winOn"] = function() end,
    ["winOff"] = function() end,
}

---@type Neominimap.Command.Focus.Handler
M.focus_cmds = {
    ["focus"] = function() end,
    ["unfocus"] = function() end,
    ["toggleFocus"] = function() end,
}
return M
