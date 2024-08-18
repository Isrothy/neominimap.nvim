local global = require("neominimap.variables.global")
local buffer = require("neominimap.variables.buffer")
local window = require("neominimap.variables.window")
local tab = require("neominimap.variables.tab")

return {
    g = global.g,
    b = buffer.b,
    w = window.w,
    t = tab.t,

    ---@type fun(name:string, value:any)
    set_var = global.set_var,
    ---@type fun(name:string):any
    get_var = global.get_var,

    ---@type fun(buffer:integer, name:string, value:any)
    buffer_set_var = buffer.buf_set_var,
    ---@type fun(buffer:integer, name:string):any
    buffer_get_var = buffer.buf_get_var,

    ---@type fun(window:integer, name:string, value:any)
    window_set_var = window.win_set_var,
    ---@type fun(window:integer, name:string):any
    window_get_var = window.win_get_var,

    ---@type fun(tab:integer, name:string, value:any)
    tab_set_var = tab.tab_set_var,
    ---@type fun(tab:integer, name:string):any
    tab_get_var = tab.tab_get_var,
}
