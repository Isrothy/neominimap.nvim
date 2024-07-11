# Neominimap

## Overview

This plugin provides a visual representation of your code structure on the side
of your windows, similar to the minimap found in many modern editors.

## Screenshots

## Features

- LSP Integration

## Installation

With Lazy:

```lua
{
  "Isrothy/neominimap.nvim",
  enabled = true,
  lazy = false, -- WARN: NO NEED to Lazy load
  init = function()
    vim.opt.wrap = false -- Recommended
    vim.opt.sidescrolloff = 36 -- It's recommended to set a large value
    vim.g.neominimap = {
      auto_enable = true,
    }
  end,
},

```

## Configuration

The following is the default configuration.

```lua
vim.g.neominimap = {
    -- Enable the plugin by default
    auto_enable = true,

    -- Log level
    log_level = vim.log.levels.OFF,

    -- Notification level
    notification_level = vim.log.levels.INFO,

    -- Path to the log file
    log_path = vim.fn.stdpath("data") .. "/neominimap.log",

    -- Minimap will not be created for buffers of these types
    exclude_filetypes = { "help" },

    -- Minimap will not be created for buffers of these types
    exclude_buftypes = {
        "nofile",
        "nowrite",
        "quickfix",
        "terminal",
        "prompt",
    },
    
    -- When false is returned, the minimap will not be created for this buffer
    buf_filter = function(bufnr)
        return true
    end

    -- When false is returned, the minimap will not be created for this window
    win_filter = function(winid)
        return true
    end

    -- Maximum height for the minimap
    -- If set to nil, there is no maximum height restriction
    max_minimap_height = nil,

    -- Width of the minimap window
    minimap_width = 20,

    -- How many columns a dot should span
    x_multiplier = 4,

    -- How many rows a dot should span
    y_multiplier = 1,

    -- Sets the delay before the minimap is refreshed
    delay = 200,

    -- Z-index for the floating window
    z_index = 1,

    -- Diagnostic integration
    diagnostic = {
        enabled = true,
        severity = vim.diagnostic.severity.WARN,
        priority = {
            ERROR = 100,
            WARN = 90,
            INFO = 80,
            HINT = 70,
        },
    },

    treesitter = {
        enabled = true,
        priority = 200,
    },

    -- Border style of the floating window
    -- Accepts all usual border style options (e.g., "single", "double")
    window_border = "single",
}
```

## Commands

- MinimapToggle - Toggle the minimap on and off.
- MinimapOpen - Open the minimap.
- MinimapClose - Close the minimap.

## How it works

For every file opened, the plugin generates a corresponding minimap buffer.

When a buffer is displayed in a window,
the minimap buffer is automatically opened side by side with the main window.

This approach minimizes unnecessary rendering when
- Multiple windows are open for same file
- Switching between buffers within a window

### TreeSitter integration

First, the plugin retrieves all Treesitter nodes in the buffer.

For each codepoint in the minimap,
the plugin calculates which highlight occurs most frequently
and displays it.
If multiple highlights occur the same number of times,
all of them are displayed.

Note that the plugin considers which highlights are *applied*,
rather than which highlights are *shown*.
Specifically, when many highlights are applied to a codepoint,
it is possible that only some of them are visible.
However, all applied highlights are considered in the calculation.
As a result, unshown highlights may be displayed in the minimap,
leading to potential inconsistencies
between the highlights in the minimap and those in the buffer.

## Tips

### Disable minimap for large file

```lua
buf_filter = function(bufnr)
  local line_count = vim.api.nvim_buf_line_count(bufnr)
  return line_count < 4096
end,
```

## TODO

- [x] LSP integration
- [ ] Git integration
- [ ] Search integration
- [x] TreeSitter integration
- [ ] Performance improvements
- [ ] Documentation
- [ ] More test cases

## Non-Goals

- Scrollbar.
  Use [satellite.nvim](https://github.com/lewis6991/satellite.nvim),
      [nvim-scrollview](https://github.com/dstein64/nvim-scrollview)
  or other plugins.
- Display screen bounds like
  [codewindow.nvim](https://github.com/gorbit99/codewindow.nvim).
  For performance, this plugin creates a minimap buffer for each buffer.
  Since a screen bound is a windowwise thing,
  it's not impossible to display them by highlights.
- Focus on minimap.
  Future updates may break this.

## Similar projects

- [codewindow.nvim](https://github.com/gorbit99/codewindow.nvim)
- [minimap.vim](https://github.com/wfxr/minimap.vim)
- [mini.map](https://github.com/echasnovski/mini.map)

## Acknowledgements

Thanks to [gorbit99](https://github.com/gorbit99) for
[codewindow.nvim](https://github.com/gorbit99/codewindow.nvim),
by which this plugin was inspired.
The map generation algorithm is also learned from that project.


