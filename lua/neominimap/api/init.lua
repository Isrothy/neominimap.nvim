return {
    --- Turns on Neominimap globally
    on = function()
        require("neominimap.api.internal.global").on()
    end,

    --- Turns off Neominimap globally
    off = function()
        require("neominimap.api.internal.global").off()
    end,

    --- Toggles Neominimap globally
    toggle = function()
        require("neominimap.api.internal.global").toggle()
    end,

    --- Refreshes Neominimap globally
    refresh = function()
        require("neominimap.api.internal.global").refresh()
    end,

    buf = {
        ---Turns on Neominimap for the given buffers. If no buffers are provided, it will be applied to the current buffer.
        ---@param buf_list integer|integer[]|nil
        on = function(buf_list)
            require("neominimap.api.internal.buf").on(buf_list)
        end,

        ---Turns off Neominimap for the given buffers. If no buffers are provided, it will be applied to the current buffer.
        ---@param buf_list integer|integer[]|nil
        off = function(buf_list)
            require("neominimap.api.internal.buf").off(buf_list)
        end,

        ---Toggles Neominimap for the given buffers. If no buffers are provided, it will be applied to the current buffer.
        ---@param buf_list integer|integer[]|nil
        toggle = function(buf_list)
            require("neominimap.api.internal.buf").toggle(buf_list)
        end,

        ---Refreshes Neominimap for the given buffers. If no buffers are provided, it will be applied to the current buffer.
        ---@param buf_list integer|integer[]|nil
        refresh = function(buf_list)
            require("neominimap.api.internal.buf").refresh(buf_list)
        end,
    },

    win = {
        --- Turns on Neominimap for the given windows. If no windows are provided, it will be applied to the current window.
        ---@param win_list integer|integer[]|nil
        on = function(win_list)
            require("neominimap.api.internal.win").on(win_list)
        end,

        --- Turns off Neominimap for the given windows. If no windows are provided, it will be applied to the current window.
        ---@param win_list integer|integer[]|nil
        off = function(win_list)
            require("neominimap.api.internal.win").off(win_list)
        end,

        --- Toggles Neominimap for the given windows. If no windows are provided, it will be applied to the current window.
        ---@param win_list integer|integer[]|nil
        toggle = function(win_list)
            require("neominimap.api.internal.win").toggle(win_list)
        end,

        --- Refreshes Neominimap for the given windows. If no windows are provided, it will be applied to the current window.
        ---@param win_list integer|integer[]|nil
        refresh = function(win_list)
            require("neominimap.api.internal.win").refresh(win_list)
        end,
    },

    tab = {
        --- Turns on Neominimap for the given tabs. If no tabs are provided, it will be applied to the current tab.
        ---@param tab_list integer|integer[]|nil
        on = function(tab_list)
            require("neominimap.api.internal.tab").on(tab_list)
        end,

        --- Turns off Neominimap for the given tabs. If no tabs are provided, it will be applied to the current tab.
        ---@param tab_list integer|integer[]|nil
        off = function(tab_list)
            require("neominimap.api.internal.tab").off(tab_list)
        end,

        --- Toggles Neominimap for the given tabs. If no tabs are provided, it will be applied to the current tab.
        ---@param tab_list integer|integer[]|nil
        toggle = function(tab_list)
            require("neominimap.api.internal.tab").toggle(tab_list)
        end,

        --- Refreshes Neominimap for the given tabs. If no tabs are provided, it will be applied to the current tab.
        ---@param tab_list integer|integer[]|nil
        refresh = function(tab_list)
            require("neominimap.api.internal.tab").refresh(tab_list)
        end,
    },

    --- Focuses on the Neominimap window
    focus = function()
        require("neominimap.api.internal.focus").focus()
    end,

    --- Unfocuses the Neominimap window
    unfocus = function()
        require("neominimap.api.internal.focus").unfocus()
    end,

    --- Toggles focus on the Neominimap window
    toggle_focus = function()
        require("neominimap.api.internal.focus").toggle_focus()
    end,
}
