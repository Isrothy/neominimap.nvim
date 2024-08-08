# Neominimap

![GitHub License](https://img.shields.io/github/license/Isrothy/neominimap.nvim)

![GitHub Repo stars](https://img.shields.io/github/stars/Isrothy/neominimap.nvim)
![GitHub forks](https://img.shields.io/github/forks/Isrothy/neominimap.nvim)
![GitHub watchers](https://img.shields.io/github/watchers/Isrothy/neominimap.nvim)
![GitHub contributors](https://img.shields.io/github/contributors/Isrothy/neominimap.nvim)
<a href="https://dotfyle.com/plugins/Isrothy/neominimap.nvim">
  <img src="https://dotfyle.com/plugins/Isrothy/neominimap.nvim/shield" />
</a>

![GitHub Issues or Pull Requests](https://img.shields.io/github/issues/Isrothy/neominimap.nvim)
![GitHub Issues or Pull Requests](https://img.shields.io/github/issues-pr/Isrothy/neominimap.nvim)

![GitHub Created At](https://img.shields.io/github/created-at/Isrothy/neominimap.nvim)
![GitHub commit activity](https://img.shields.io/github/commit-activity/m/Isrothy/neominimap.nvim)
![GitHub last commit](https://img.shields.io/github/last-commit/Isrothy/neominimap.nvim)
![GitHub Release](https://img.shields.io/github/v/release/Isrothy/neominimap.nvim)

![GitHub top language](https://img.shields.io/github/languages/top/Isrothy/neominimap.nvim)
![GitHub language count](https://img.shields.io/github/languages/count/Isrothy/neominimap.nvim)
![GitHub code size in bytes](https://img.shields.io/github/languages/code-size/Isrothy/neominimap.nvim)

## Overview

This plugin provides a visual representation of your code structure on the side
of your windows, similar to the minimap found in many modern editors.

Criticisms are welcome.

## Screenshots

![screenshot](https://github.com/user-attachments/assets/029d61c7-94ac-4e68-9308-3c82a3c07fef)

## Features

- LSP Integration
- TreeSitter Integration
- Fold Integration
- Respects UTF-8 encoding and tab width

## Dependencies

- Optional: [nvim-treesitter](https://github.com/nvim-treesitter/nvim-treesitter) for highlighting

## Installation

With Lazy:

```lua
{
    "Isrothy/neominimap.nvim",
    dependencies = {
        "nvim-treesitter/nvim-treesitter", --- Recommended
    },
    enabled = true,
    lazy = false, -- NOTE: NO NEED to Lazy load
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
---@module "neominimap.config.meta"

---@type Neominimap.UserConfig
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
    ---@type fun(bufnr: number): boolean
    buf_filter = function(bufnr)
        return true
    end

    -- When false is returned, the minimap will not be created for this window
    ---@type fun(bufnr: number): boolean
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

    -- For performance issue, when text changed,
    -- minimap is refreshed after a certain delay
    -- Set the delay in milliseconds
    delay = 200,
  
    -- Sync the cursor position with the minimap
    sync_cursor = true,

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
    
    -- Considering fold when rendering minimap
    fold = {
        enabled = true,
    },

    -- Border style of the floating window
    -- Accepts all usual border style options (e.g., "single", "double")
    window_border = "single",

    -- Margin of the floating window
    margin = {
        top = 0,
        bottom = 0,
        right = 0,
    },

    --- Override default window options.
    --- Can be either a table or a function that takes the winid of
    --- the window to which a minimap is attached and returns a table.
    ---@type table | fun(winid: integer) : table
    winopt = {},

    --- Override default buffer options.
    --- Can be either a table or a function that takes the bufnr of
    --- the buffer from which a minimap is generated and returns a table.
    ---@type table | fun(bufnr: integer) : table
    bufopt = {}
}
```

The default `winopt` is:

```lua
{
    winhighlight = "Normal:NeominimapBackground,FloatBorder:NeominimapBorder,CursorLine:NeominimapCursorLine",
    wrap = false,
    foldcolumn = "0",
    signcolumn = "no",
    statuscolumn = "",
    number = false,
    relativenumber = false,
    scrolloff = 99999,
    sidescrolloff = 0,
    winblend = 0,
    cursorline = true,
    spell = false,
}
```

The default `bufopt` is:

```lua
{
    buftype = "nofile",
    swapfile = false,
    bufhidden = "hide",
    undolevels = -1,
}
```

## Commands

Notice that a minimap is shown if and only if

- Neominimap is enabled globally,
- Neominimap is enabled for the current buffer, and
- Neominimap is enabled for the current window.

| Command                               | Description                                                                                             | Arguments                 |
|---------------------------------------|---------------------------------------------------------------------------------------------------------|---------------------------|
| `Neominimap on`                       | Turn on minimaps globally.                                                                              | None                      |
| `Neominimap off`                      | Turn off minimaps globally.                                                                             | None                      |
| `Neominimap toggle`                   | Toggle minimaps globally.                                                                               | None                      |
| `Neominimap refresh`                  | Refresh minimaps globally.                                                                              | None                      |
| `Neominimap bufOn [buffer_list]`      | Enable the minimap for specified buffers. If no buffers are specified, enable for the current buffer.   | Optional: List of buffers |
| `Neominimap bufOff [buffer_list]`     | Disable the minimap for specified buffers. If no buffers are specified, disable for the current buffer. | Optional: List of buffers |
| `Neominimap bufToggle [buffer_list]`  | Toggle the minimap for specified buffers. If no buffers are specified, toggle for the current buffer.   | Optional: List of buffers |
| `Neominimap bufRefresh [buffer_list]` | Refresh the minimap for specified buffers. If no buffers are specified, refresh for the current buffer. | Optional: List of buffers |
| `Neominimap winOn [window_list]`      | Enable the minimap for specified windows. If no windows are specified, enable for the current window.   | Optional: List of windows |
| `Neominimap winOff [window_list]`     | Disable the minimap for specified windows. If no windows are specified, disable for the current window. | Optional: List of windows |
| `Neominimap winToggle [window_list]`  | Toggle the minimap for specified windows. If no windows are specified, toggle for the current window.   | Optional: List of windows |
| `Neominimap winRefresh [window_list]` | Refresh the minimap for specified windows. If no windows are specified, refresh for the current window. | Optional: List of windows |
| `Neominimap focus`                    | Focus on the minimap. Set cursor to the minimap window.                                                 | None                      |
| `Neominimap blur`                     | Unfocus the minimap. Set cursor back.                                                                   | None                      |

### Usage Examples

To turn on the minimap globally:

```vim
:Neominimap on
```

To disable the minimap for the current buffer:

```vim
:Neominimap bufOff
```

To refresh the minimap for windows 3 and 4:

```vim
:Neominimap winRefresh 3 4
```

### Lua API

These are the corresponding commands in the Lua API.

| Command                        | Description                                  | Usage                                          |
|--------------------------------|----------------------------------------------|------------------------------------------------|
| `Neominimap on`                | Turns on the minimap globally.               | `require('neominimap').on()`                   |
| `Neominimap off`               | Turns off the minimap globally.              | `require('neominimap').off()`                  |
| `Neominimap toggle`            | Toggles the minimap globally.                | `require('neominimap').toggle()`               |
| `Neominimap refresh`           | Refreshes the minimap globally.              | `require('neominimap').refresh()`              |
| `Neominimap bufOn [args]`      | Turns on the minimap for specified buffers.  | `require('neominimap').bufOn({"1", "2"})`      |
| `Neominimap bufOff [args]`     | Turns off the minimap for specified buffers. | `require('neominimap').bufOff({"1", "2"})`     |
| `Neominimap bufToggle [args ]` | Toggles the minimap for specified buffers.   | `require('neominimap').bufToggle({"1", "2"})`  |
| `Neominimap bufRefresh [args]` | Refreshes the minimap for specified buffers. | `require('neominimap').bufRefresh({"1", "2"})` |
| `Neominimap winOn [args]`      | Turns on the minimap for specified windows.  | `require('neominimap').winOn({"3", "4"})`      |
| `Neominimap winOff [args]`     | Turns off the minimap for specified windows. | `require('neominimap').winOff({"3", "4"})`     |
| `Neominimap winToggle [args]`  | Toggles the minimap for specified windows.   | `require('neominimap').winToggle({"3", "4"})`  |
| `Neominimap winRefresh [args]` | Refreshes the minimap for specified windows. | `require('neominimap').winRefresh({"3", "4"})` |
| `Neominimap focus`             | Focuses the minimap.                         | `require('neominimap').focus()`                |
| `Neominimap unfocus`           | Unfocuses the minimap.                       | `require('neominimap').unfocus()`              |`

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

## Highlights

| Highlight Group      | Description                               |
|----------------------|-------------------------------------------|
| NeominimapBackground | Background color for the minimap.         |
| NeominimapBorder     | Border color for the minimap window.      |
| NeominimapCursorLine | Color for the cursor line in the minimap. |
| NeominimapHintLine   |                                           |
| NeominimapInfoLine   |                                           |
| NeominimapWarnLine   |                                           |
| NeominimapErrorLine  |                                           |

## TODO

- [x] LSP integration
- [x] TreeSitter integration
- [ ] Git integration
- [ ] Search integration
- [ ] Support for window relative to editor
- [x] Validate user configuration
- [x] Documentation
- [ ] Performance improvements
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

## Limitations

- Updating Folds Immediately.
  Neovim does not provide a fold event. Therefore, this plugin cannot update
  immediately whenever fold changes in a buffer.
  

## Similar projects

- [codewindow.nvim](https://github.com/gorbit99/codewindow.nvim)
  - Codewindow.nvim renders the minimap whenever focus is switched to a
    different window or the buffer is switched. In contrast, this plugin caches
    the minimap, so it only renders the minimap when the text is changed. Thus,
    this plugin should have better performance when you frequently switch
    windows or buffers.
  - Codewindow.nvim renders the minimap based on bytes, while this plugin
    renders based on codepoints. Specifically, it respects UTF-8 encoding and
    tab width.
  - Codewindow.nvim currently has more features like git integration and focus
    on the minimap, which this plugin does not.
  - Codewindow.nvim does not consider folds while this plugin does.

- [mini.map](https://github.com/echasnovski/mini.map)
  - Mini.map allows for encode symbol customization, while this plugin does not.
  - Mini.map includes a scrollbar, which this plugin does not.
  - Mini.map does not have Treesitter integration, which this plugin does.
  - Mini.map rescales the minimap so that the height is equal to the window
    height, while this plugin generates the minimap by a fixed compression
    rate.
  - Mini.map does not cache the minimap neither, but it is still performant.

- [minimap.vim](https://github.com/wfxr/minimap.vim)
  - Just like Mini.map, Minimap.vim scales minimap.
  - Minimap.vim uses a Rust program to generate minimaps efficiently, while
    this plugin is written in Lua.
  - Minimap.vim does not have Treesitter or LSP integration, which this plugin
    does.

## Acknowledgements

Thanks to [gorbit99](https://github.com/gorbit99) for
[codewindow.nvim](https://github.com/gorbit99/codewindow.nvim),
by which this plugin was inspired.
The map generation algorithm and TreeSitter integration algorithm are also
learned from that project.
