return {
    --- Turns on Neominimap globally
    enable = function()
        require("neominimap.api.internal.global").enable()
    end,

    --- Turns off Neominimap globally
    disable = function()
        require("neominimap.api.internal.global").disable()
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
        enable = function(buf_list)
            require("neominimap.api.internal.buf").enable(buf_list)
        end,

        ---Turns off Neominimap for the given buffers. If no buffers are provided, it will be applied to the current buffer.
        ---@param buf_list integer|integer[]|nil
        disable = function(buf_list)
            require("neominimap.api.internal.buf").disable(buf_list)
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
        enable = function(win_list)
            require("neominimap.api.internal.win").enable(win_list)
        end,

        --- Turns off Neominimap for the given windows. If no windows are provided, it will be applied to the current window.
        ---@param win_list integer|integer[]|nil
        disable = function(win_list)
            require("neominimap.api.internal.win").disable(win_list)
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
        enable = function(tab_list)
            require("neominimap.api.internal.tab").enable(tab_list)
        end,

        --- Turns off Neominimap for the given tabs. If no tabs are provided, it will be applied to the current tab.
        ---@param tab_list integer|integer[]|nil
        disable = function(tab_list)
            require("neominimap.api.internal.tab").disable(tab_list)
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

    focus = {
        --- Focuses on the Neominimap window
        enable = function()
            require("neominimap.api.internal.focus").enable()
        end,

        --- Unfocuses the Neominimap window
        disable = function()
            require("neominimap.api.internal.focus").disable()
        end,

        --- Toggles focus on the Neominimap window
        toggle = function()
            require("neominimap.api.internal.focus").toggle()
        end,
    },
}
