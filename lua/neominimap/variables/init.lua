-- A wrapper around vim.g, vim.b, vim.w and vim.t
-- Facilitates better integration with static analysis tools

local global = require("neominimap.variables.global")
local buffer = require("neominimap.variables.buffer")
local window = require("neominimap.variables.window")
local tabpage = require("neominimap.variables.tabpage")

return {
    g = global.g,
    b = buffer.b,
    w = window.w,
    t = tabpage.t,

    --- Set a global variable
    ---@type fun(name:string, value:any)
    set_var = global.set_var,

    --- Get a global variable
    ---@type fun(name:string):any
    get_var = global.get_var,

    --- Set a buffer-scoped variable
    ---@type fun(buffer:integer, name:string, value:any)
    buffer_set_var = buffer.buf_set_var,

    --- Get a buffer-scoped variable
    ---@type fun(buffer:integer, name:string):any
    buffer_get_var = buffer.buf_get_var,

    --- Set a window-scoped variable
    ---@type fun(window:integer, name:string, value:any)
    window_set_var = window.win_set_var,

    --- Get a window-scoped variable
    ---@type fun(window:integer, name:string):any
    window_get_var = window.win_get_var,

    --- Set a tab-scoped variable
    ---@type fun(tab:integer, name:string, value:any)
    tab_set_var = tabpage.tab_set_var,

    --- Get a tab-scoped variable
    ---@type fun(tab:integer, name:string):any
    tab_get_var = tabpage.tab_get_var,
}
