local M = {}

---@deprecated
---@type Neominimap.Command.Impl
M.refresh = function(args, opts)
    vim.deprecate("require('neominimap').refresh", "require('neominimap.api').refresh", "v4", "neominimap.nvim")
    require("neominimap.command.global").subcommand_tbl.refresh.impl(args, opts)
end

---@deprecated
---@type Neominimap.Command.Impl
M.on = function(args, opts)
    vim.deprecate("require('neominimap').on", "require('neominimap.api').enable", "v4", "neominimap.nvim")
    require("neominimap.command.global").subcommand_tbl.on.impl(args, opts)
end

---@deprecated
---@type Neominimap.Command.Impl
M.off = function(args, opts)
    vim.deprecate("require('neominimap').off", "require('neominimap.api').disable", "v4", "neominimap.nvim")
    require("neominimap.command.global").subcommand_tbl.off.impl(args, opts)
end

---@deprecated
---@type Neominimap.Command.Impl
M.toggle = function(args, opts)
    vim.deprecate("require('neominimap').toggle", "require('neominimap.api').toggle", "v4", "neominimap.nvim")
    require("neominimap.command.global").subcommand_tbl.toggle.impl(args, opts)
end

---@deprecated
--- Minimap is enabled globally
---@return boolean
M.enabled = function()
    vim.deprecate("require('neominimap').enabled", "require('neominimap.api').enabled", "v4", "neominimap.nvim")
    return require("neominimap.variables").g.enabled
end

---@deprecated
---@type Neominimap.Command.Impl
M.bufOn = function(args, opts)
    vim.deprecate("require('neominimap').bufOn", "require('neominimap.api').buf.enable", "v4", "neominimap.nvim")
    require("neominimap.command.buf").subcommand_tbl.bufOn.impl(args, opts)
end

---@deprecated
---@type Neominimap.Command.Impl
M.bufOff = function(args, opts)
    vim.deprecate("require('neominimap').bufOff", "require('neominimap.api').buf.disable", "v4", "neominimap.nvim")
    require("neominimap.command.buf").subcommand_tbl.bufOff.impl(args, opts)
end

---@deprecated
---@type Neominimap.Command.Impl
M.bufToggle = function(args, opts)
    vim.deprecate("require('neominimap').bufToggle", "require('neominimap.api').buf.toggle", "v4", "neominimap.nvim")
    require("neominimap.command.buf").subcommand_tbl.bufToggle.impl(args, opts)
end

---@deprecated
---@type Neominimap.Command.Impl
M.bufRefresh = function(args, opts)
    vim.deprecate("require('neominimap').bufRefresh", "require('neominimap.api').buf.refresh", "v4", "neominimap.nvim")
    require("neominimap.command.buf").subcommand_tbl.bufRefresh.impl(args, opts)
end

---@deprecated
--- Minimap is enabled for the given buffer
---@param bufnr integer? If nil, check for the current buffer
---@return boolean
M.bufEnabled = function(bufnr)
    vim.deprecate("require('neominimap').bufEnabled", "require('neominimap.api').buf.enabled", "v4", "neominimap.nvim")
    if bufnr == nil then
        bufnr = 0
    end
    return require("neominimap.variables").b[bufnr].enabled
end

---@deprecated
---@type Neominimap.Command.Impl
M.winOn = function(args, opts)
    vim.deprecate("require('neominimap').winOn", "require('neominimap.api').win.enable", "v4", "neominimap.nvim")
    require("neominimap.command.win").subcommand_tbl.winOn.impl(args, opts)
end

---@deprecated
---@type Neominimap.Command.Impl
M.winOff = function(args, opts)
    vim.deprecate("require('neominimap').winOff", "require('neominimap.api').win.disable", "v4", "neominimap.nvim")
    require("neominimap.command.win").subcommand_tbl.winOff.impl(args, opts)
end

---@deprecated
---@type Neominimap.Command.Impl
M.winToggle = function(args, opts)
    vim.deprecate("require('neominimap').winToggle", "require('neominimap.api').win.toggle", "v4", "neominimap.nvim")
    require("neominimap.command.win").subcommand_tbl.winToggle.impl(args, opts)
end

---@deprecated
---@type Neominimap.Command.Impl
M.winRefresh = function(args, opts)
    vim.deprecate("require('neominimap').winRefresh", "require('neominimap.api').win.refresh", "v4", "neominimap.nvim")
    require("neominimap.command.win").subcommand_tbl.winRefresh.impl(args, opts)
end

---@deprecated
---@type Neominimap.Command.Impl
M.tabOn = function(args, opts)
    vim.deprecate("require('neominimap').tabOn", "require('neominimap.api').tab.enable", "v4", "neominimap.nvim")
    require("neominimap.command.tab").subcommand_tbl.tabOn.impl(args, opts)
end

---@deprecated
---@type Neominimap.Command.Impl
M.tabOff = function(args, opts)
    vim.deprecate("require('neominimap').tabOff", "require('neominimap.api').tab.disable", "v4", "neominimap.nvim")
    require("neominimap.command.tab").subcommand_tbl.tabOff.impl(args, opts)
end

---@deprecated
--- Minimap is enabled for the given window
---@param winid integer? If nil, check for the current window
---@return boolean
M.winEnabled = function(winid)
    vim.deprecate("require('neominimap').winEnabled", "require('neominimap.api').win.wnabled", "v4", "neominimap.nvim")
    if winid == nil then
        winid = 0
    end
    return require("neominimap.variables").w[winid].enabled
end

---@deprecated
---@type Neominimap.Command.Impl
M.tabToggle = function(args, opts)
    vim.deprecate("require('neominimap').tabToggle", "require('neominimap.api').tab.toggle", "v4", "neominimap.nvim")
    require("neominimap.command.tab").subcommand_tbl.tabToggle.impl(args, opts)
end

---@deprecated
---@type Neominimap.Command.Impl
M.tabRefresh = function(args, opts)
    vim.deprecate("require('neominimap').tabRefresh", "require('neominimap.api').tab.refresh", "v4", "neominimap.nvim")
    require("neominimap.command.tab").subcommand_tbl.tabRefresh.impl(args, opts)
end

---@deprecated
--- Minimap is enabled for the given tab page
---@param tabid integer? If nil, check for the current tab page
---@return boolean
M.tabEnabled = function(tabid)
    vim.deprecate("require('neominimap').tabEnabled", "require('neominimap.api').tab.enabled", "v4", "neominimap.nvim")
    if tabid == nil then
        tabid = 0
    end
    return require("neominimap.variables").t[tabid].enabled
end

---@deprecated
---@type Neominimap.Command.Impl
M.focus = function(args, opts)
    vim.deprecate("require('neominimap').focus", "require('neominimap.api').focus.on", "v4", "neominimap.nvim")
    require("neominimap.command.focus").subcommand_tbl.focus.impl(args, opts)
end

---@deprecated
---@type Neominimap.Command.Impl
M.unfocus = function(args, opts)
    vim.deprecate("require('neominimap').unfocus", "require('neominimap.api').focus.off", "v4", "neominimap.nvim")
    require("neominimap.command.focus").subcommand_tbl.unfocus.impl(args, opts)
end

---@deprecated
---@type Neominimap.Command.Impl
M.toggleFocus = function(args, opts)
    vim.deprecate(
        "require('neominimap').toggleFocus",
        "require('neominimap.api').focus.toggle",
        "v4",
        "neominimap.nvim"
    )
    require("neominimap.command.focus").subcommand_tbl.toggleFocus.impl(args, opts)
end

return M
