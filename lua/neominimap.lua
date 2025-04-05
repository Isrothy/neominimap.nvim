local M = {}

local function deprecated_warning(old_name, new_name)
    local logger = require("neominimap.logger")
    logger.notify(string.format("'%s' is deprecated. Use '%s' instead.", old_name, new_name), vim.log.levels.WARN)
end

---@deprecated
---@type Neominimap.Command.Impl
M.refresh = function(args, opts)
    deprecated_warning("require('neominimap').refresh", "require('neominimap.api').refresh")
    require("neominimap.command.global").subcommand_tbl.refresh.impl(args, opts)
end

---@deprecated
---@type Neominimap.Command.Impl
M.on = function(args, opts)
    deprecated_warning("require('neominimap').on", "require('neominimap.api').enable")
    require("neominimap.command.global").subcommand_tbl.on.impl(args, opts)
end

---@deprecated
---@type Neominimap.Command.Impl
M.off = function(args, opts)
    deprecated_warning("require('neominimap').off", "require('neominimap.api').disable")
    require("neominimap.command.global").subcommand_tbl.off.impl(args, opts)
end

---@deprecated
---@type Neominimap.Command.Impl
M.toggle = function(args, opts)
    deprecated_warning("require('neominimap').toggle", "require('neominimap.api').toggle")
    require("neominimap.command.global").subcommand_tbl.toggle.impl(args, opts)
end

---@deprecated
--- Minimap is enabled globally
---@return boolean
M.enabled = function()
    deprecated_warning("require('neominimap').enabled", "require('neominimap.api').enabled")
    return require("neominimap.variables").g.enabled
end

---@deprecated
---@type Neominimap.Command.Impl
M.bufOn = function(args, opts)
    deprecated_warning("require('neominimap').bufOn", "require('neominimap.api').buf.enable")
    require("neominimap.command.buf").subcommand_tbl.bufOn.impl(args, opts)
end

---@deprecated
---@type Neominimap.Command.Impl
M.bufOff = function(args, opts)
    deprecated_warning("require('neominimap').bufOff", "require('neominimap.api').buf.disable")
    require("neominimap.command.buf").subcommand_tbl.bufOff.impl(args, opts)
end

---@deprecated
---@type Neominimap.Command.Impl
M.bufToggle = function(args, opts)
    deprecated_warning("require('neominimap').bufToggle", "require('neominimap.api').buf.toggle")
    require("neominimap.command.buf").subcommand_tbl.bufToggle.impl(args, opts)
end

---@deprecated
---@type Neominimap.Command.Impl
M.bufRefresh = function(args, opts)
    deprecated_warning("require('neominimap').bufRefresh", "require('neominimap.api').buf.refresh")
    require("neominimap.command.buf").subcommand_tbl.bufRefresh.impl(args, opts)
end

---@deprecated
--- Minimap is enabled for the given buffer
---@param bufnr integer? If nil, check for the current buffer
---@return boolean
M.bufEnabled = function(bufnr)
    deprecated_warning("require('neominimap').bufEnabled", "require('neominimap.api').buf.enabled")
    if bufnr == nil then
        bufnr = 0
    end
    return require("neominimap.variables").b[bufnr].enabled
end

---@deprecated
---@type Neominimap.Command.Impl
M.winOn = function(args, opts)
    deprecated_warning("require('neominimap').winOn", "require('neominimap.api').win.enable")
    require("neominimap.command.win").subcommand_tbl.winOn.impl(args, opts)
end

---@deprecated
---@type Neominimap.Command.Impl
M.winOff = function(args, opts)
    deprecated_warning("require('neominimap').winOff", "require('neominimap.api').win.disable")
    require("neominimap.command.win").subcommand_tbl.winOff.impl(args, opts)
end

---@deprecated
---@type Neominimap.Command.Impl
M.winToggle = function(args, opts)
    deprecated_warning("require('neominimap').winToggle", "require('neominimap.api').win.toggle")
    require("neominimap.command.win").subcommand_tbl.winToggle.impl(args, opts)
end

---@deprecated
---@type Neominimap.Command.Impl
M.winRefresh = function(args, opts)
    deprecated_warning("require('neominimap').winRefresh", "require('neominimap.api').win.refresh")
    require("neominimap.command.win").subcommand_tbl.winRefresh.impl(args, opts)
end

---@deprecated
---@type Neominimap.Command.Impl
M.tabOn = function(args, opts)
    deprecated_warning("require('neominimap').tabOn", "require('neominimap.api').tab.enable")
    require("neominimap.command.tab").subcommand_tbl.tabOn.impl(args, opts)
end

---@deprecated
---@type Neominimap.Command.Impl
M.tabOff = function(args, opts)
    deprecated_warning("require('neominimap').tabOff", "require('neominimap.api').tab.disable")
    require("neominimap.command.tab").subcommand_tbl.tabOff.impl(args, opts)
end

---@deprecated
--- Minimap is enabled for the given window
---@param winid integer? If nil, check for the current window
---@return boolean
M.winEnabled = function(winid)
    deprecated_warning("require('neominimap').winEnabled", "require('neominimap.api').win.wnabled")
    if winid == nil then
        winid = 0
    end
    return require("neominimap.variables").w[winid].enabled
end

---@deprecated
---@type Neominimap.Command.Impl
M.tabToggle = function(args, opts)
    deprecated_warning("require('neominimap').tabToggle", "require('neominimap.api').tab.toggle")
    require("neominimap.command.tab").subcommand_tbl.tabToggle.impl(args, opts)
end

---@deprecated
---@type Neominimap.Command.Impl
M.tabRefresh = function(args, opts)
    deprecated_warning("require('neominimap').tabRefresh", "require('neominimap.api').tab.refresh")
    require("neominimap.command.tab").subcommand_tbl.tabRefresh.impl(args, opts)
end

---@deprecated
--- Minimap is enabled for the given tab page
---@param tabid integer? If nil, check for the current tab page
---@return boolean
M.tabEnabled = function(tabid)
    deprecated_warning("require('neominimap').tabEnabled", "require('neominimap.api').tab.enabled")
    if tabid == nil then
        tabid = 0
    end
    return require("neominimap.variables").t[tabid].enabled
end

---@deprecated
---@type Neominimap.Command.Impl
M.focus = function(args, opts)
    deprecated_warning("require('neominimap').focus", "require('neominimap.api').focus.on")
    require("neominimap.command.focus").subcommand_tbl.focus.impl(args, opts)
end

---@deprecated
---@type Neominimap.Command.Impl
M.unfocus = function(args, opts)
    deprecated_warning("require('neominimap').unfocus", "require('neominimap.api').focus.off")
    require("neominimap.command.focus").subcommand_tbl.unfocus.impl(args, opts)
end

---@deprecated
---@type Neominimap.Command.Impl
M.toggleFocus = function(args, opts)
    deprecated_warning("require('neominimap').toggleFocus", "require('neominimap.api').focus.toggle")
    require("neominimap.command.focus").subcommand_tbl.toggleFocus.impl(args, opts)
end

return M
