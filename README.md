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

Show diagnostics:
![image](https://github.com/user-attachments/assets/0710873b-bfa8-4102-bd6f-dbd9dd5cb9fd)

Show git signs:
![image](https://github.com/user-attachments/assets/383ab582-884d-4fd5-86ab-1324ebedd7c0)

Show search results:
![image](https://github.com/user-attachments/assets/83a1a5a5-7bc7-48cc-9c01-39de75fada94)

## Features

- LSP integration
- TreeSitter integration
- Fold integration
- Git integration
- Search integration
- Mouse click support
- Support for marks in the sign column and line highlight
- Respects UTF-8 encoding and tab width
- Focus on the minimap, allowing interaction with it

## Dependencies

- Optional: [nvim-treesitter](https://github.com/nvim-treesitter/nvim-treesitter) for highlighting
- Optional: [gitsigns.nvim](https://github.com/lewis6991/gitsigns.nvim) for Git integration

## Installation

With Lazy:

```lua
---@module "neominimap.config.meta"
{
    "Isrothy/neominimap.nvim",
    enabled = true,
    lazy = false, -- NOTE: NO NEED to Lazy load
    -- Optional
    keys = {
        { "<leader>nt", "<cmd>Neominimap toggle<cr>", desc = "Toggle minimap" },
        { "<leader>no", "<cmd>Neominimap on<cr>", desc = "Enable minimap" },
        { "<leader>nc", "<cmd>Neominimap off<cr>", desc = "Disable minimap" },
        { "<leader>nf", "<cmd>Neominimap focus<cr>", desc = "Focus on minimap" },
        { "<leader>nu", "<cmd>Neominimap unfocus<cr>", desc = "Unfocus minimap" },
        { "<leader>ns", "<cmd>Neominimap toggleFocus<cr>", desc = "Toggle focus on minimap" },
        { "<leader>nwt", "<cmd>Neominimap winToggle<cr>", desc = "Toggle minimap for current window" },
        { "<leader>nwr", "<cmd>Neominimap winRefresh<cr>", desc = "Refresh minimap for current window" },
        { "<leader>nwo", "<cmd>Neominimap winOn<cr>", desc = "Enable minimap for current window" },
        { "<leader>nwc", "<cmd>Neominimap winOff<cr>", desc = "Disable minimap for current window" },
        { "<leader>nbt", "<cmd>Neominimap bufToggle<cr>", desc = "Toggle minimap for current buffer" },
        { "<leader>nbr", "<cmd>Neominimap bufRefresh<cr>", desc = "Refresh minimap for current buffer" },
        { "<leader>nbo", "<cmd>Neominimap bufOn<cr>", desc = "Enable minimap for current buffer" },
        { "<leader>nbc", "<cmd>Neominimap bufOff<cr>", desc = "Disable minimap for current buffer" },
    },
    init = function()
        vim.opt.wrap = false -- Recommended
        vim.opt.sidescrolloff = 36 -- It's recommended to set a large value
        ---@type Neominimap.UserConfig
        vim.g.neominimap = {
            auto_enable = true,
        }
    end,
},
```

## Configuration

The following is the default configuration.

```lua
{
    -- Enable the plugin by default
    auto_enable = true, ---@type boolean

    -- Log level
    log_level = vim.log.levels.OFF, ---@type integer

    -- Notification level
    notification_level = vim.log.levels.INFO, ---@type integer

    -- Path to the log file
    log_path = vim.fn.stdpath("data") .. "/neominimap.log", ---@type string

    -- Minimap will not be created for buffers of these types
    ---@type string[]
    exclude_filetypes = {
        "help",
    },

    -- Minimap will not be created for buffers of these types
    ---@type string[]
    exclude_buftypes = {
        "nofile",
        "nowrite",
        "quickfix",
        "terminal",
        "prompt",
    },

    -- When false is returned, the minimap will not be created for this buffer
    ---@type fun(bufnr: integer): boolean
    buf_filter = function()
        return true
    end,

    -- When false is returned, the minimap will not be created for this window
    ---@type fun(winid: integer): boolean
    win_filter = function()
        return true
    end,

    -- Maximum height for the minimap
    -- If set to nil, there is no maximum height restriction
    max_minimap_height = nil, ---@type integer?

    -- Width of the minimap window
    minimap_width = 20, ---@type integer

    -- How many columns a dot should span
    x_multiplier = 4, ---@type integer

    -- How many rows a dot should span
    y_multiplier = 1, ---@type integer

    -- For performance issue, when text changed,
    -- minimap is refreshed after a certain delay
    -- Set the delay in milliseconds
    delay = 200, ---@type integer

    -- Sync the cursor position with the minimap
    sync_cursor = true, ---@type boolean

    click = {
        -- Enable mouse click on minimap
        enabled = false, ---@type boolean
        -- Automatically switch focus to minimap when clicked
        auto_switch_focus = true, ---@type boolean
    },

    diagnostic = {
        enabled = true, ---@type boolean
        severity = vim.diagnostic.severity.WARN, ---@type integer
        mode = "line", ---@type Neominimap.Handler.MarkMode
        priority = {
            ERROR = 100, ---@type integer
            WARN = 90, ---@type integer
            INFO = 80, ---@type integer
            HINT = 70, ---@type integer
        },
    },

    git = {
        enabled = true, ---@type boolean
        mode = "sign", ---@type Neominimap.Handler.MarkMode
        priority = 6, ---@type integer
    },

    search = {
        enabled = false, ---@type boolean
        mode = "line", ---@type Neominimap.Handler.MarkMode
        priority = 20, ---@type integer
    },

    treesitter = {
        enabled = true, ---@type boolean
        priority = 200, ---@type integer
    },

    margin = {
        right = 0, ---@type integer
        top = 0, ---@type integer
        bottom = 0, ---@type integer
    },

    fold = {
        -- Considering fold when rendering minimap
        enabled = true, ---@type boolean
    },

    -- Z-index of the floating window
    z_index = 1, ---@type integer

    -- Border style of the floating window
    -- Accepts all usual border style options (e.g., "single", "double")
    window_border = "single", ---@type string | string[] | [string, string][]

    ---Overrite the default winopt
    ---@param opt table
    ---@param winid integer the window id of the source window, NOT minimap window
    winopt = function(opt, winid) end,

    ---Overrite the default bufopt
    ---@param opt table
    ---@param bufnr integer the buffer id of the source buffer, NOT minimap buffer
    bufopt = function(opt, bufnr) end,
}
```

The default `winopt` is:

```lua
{
    winhighlight = "Normal:NeominimapBackground,FloatBorder:NeominimapBorder,CursorLine:NeominimapCursorLine",
    wrap = false,
    foldcolumn = "0",
    signcolumn = "auto",
    number = false,
    relativenumber = false,
    scrolloff = 99999,
    sidescrolloff = 0,
    winblend = 0,
    cursorline = true,
    spell = false,
    list = false,
}
```

The default `bufopt` is:

```lua
{
    buftype = "nofile",
    filetype = "neominimap",
    swapfile = false,
    bufhidden = "hide",
    undolevels = -1,
}
```

## Commands

| Command                               | Description                                                                                                             | Arguments                 |
|---------------------------------------|-----------------------------------------------------------------------------------------------------------------|---------------------------|
| `Neominimap on`                       | Turn on minimaps globally.                                                                                      | None                      |
| `Neominimap off`                      | Turn off minimaps globally.                                                                                     | None                      |
| `Neominimap toggle`                   | Toggle minimaps globally.                                                                                       | None                      |
| `Neominimap refresh`                  | Refresh minimaps globally.                                                                                      | None                      |
| `Neominimap bufOn [buffer_list]`      | Enable the minimap for specified buffers. If no buffers are specified, enable for the current buffer.           | Optional: List of buffers |
| `Neominimap bufOff [buffer_list]`     | Disable the minimap for specified buffers. If no buffers are specified, disable for the current buffer.         | Optional: List of buffers |
| `Neominimap bufToggle [buffer_list]`  | Toggle the minimap for specified buffers. If no buffers are specified, toggle for the current buffer.           | Optional: List of buffers |
| `Neominimap bufRefresh [buffer_list]` | Refresh the minimap buffers for specified buffers. If no buffers are specified, refresh for the current buffer. | Optional: List of buffers |
| `Neominimap winOn [window_list]`      | Enable the minimap for specified windows. If no windows are specified, enable for the current window.           | Optional: List of windows |
| `Neominimap winOff [window_list]`     | Disable the minimap for specified windows. If no windows are specified, disable for the current window.         | Optional: List of windows |
| `Neominimap winToggle [window_list]`  | Toggle the minimap for specified windows. If no windows are specified, toggle for the current window.           | Optional: List of windows |
| `Neominimap winRefresh [window_list]` | Refresh the minimap windows for specified windows. If no windows are specified, refresh for the current window. | Optional: List of windows |
| `Neominimap focus`                    | Focus on the minimap. Set cursor to the minimap window.                                                         | None                      |
| `Neominimap unfocus`                  | Unfocus the minimap. Set cursor back.                                                                           | None                      |
| `Neominimap toggleFocus`              | Toggle minimap focus                                                                                            | None                      |

> [!NOTE]
> A minimap is shown if and only if
>
> - Neominimap is enabled globally,
> - Neominimap is enabled for the current buffer, and
> - Neominimap is enabled for the current window.

> [!NOTE]
>
> `Neominimap bufRefresh` only refreshes minimap buffers, which includes:
>
> - Creating or wiping out buffers as needed.
> - Rendering minimap text and applying highlights.
>
> `Neominimap winRefresh` only refreshes minimap windows, which includes:
>
> - Opening or closing windows as needed.
> - Updating window configurations, such as positions and sizes.
> - Attaching windows to the correct buffers.

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

| Function                                    | Description                                                  | Arguments                                                            |
|---------------------------------------------|--------------------------------------------------------------|----------------------------------------------------------------------|
| `require('neominimap').on()`                | Enable the minimap globally across all buffers and windows.  | None                                                                 |
| `require('neominimap').off()`               | Disable the minimap globally.                                | None                                                                 |
| `require('neominimap').toggle()`            | Toggle the minimap on or off globally.                       | None                                                                 |
| `require('neominimap').refresh()`           | Refresh the minimap globally.                                | None                                                                 |
| `require('neominimap').bufOn(<bufnr>)`      | Enable the minimap for specified buffers.                    | List of buffer numbers (defaults to current buffer if list is empty) |
| `require('neominimap').bufOff(<bufnr>)`     | Disable the minimap for specified buffers.                   | List of buffer numbers (defaults to current buffer if list is empty) |
| `require('neominimap').bufToggle(<bufnr>)`  | Toggle the minimap for specified buffers.                    | List of buffer numbers (defaults to current buffer if list is empty) |
| `require('neominimap').bufRefresh(<bufnr>)` | Refresh the minimap buffers for specified buffers.           | List of buffer numbers (defaults to current buffer if list is empty) |
| `require('neominimap').winOn(<winid>)`      | Enable the minimap for specified windows.                    | List of window IDs (defaults to current window if list is empty)     |
| `require('neominimap').winOff(<winid>)`     | Disable the minimap for specified windows.                   | List of window IDs (defaults to current window if list is empty)     |
| `require('neominimap').winToggle(<winid>)`  | Toggle the minimap for specified windows.                    | List of window IDs (defaults to current window if list is empty)     |
| `require('neominimap').winRefresh(<winid>)` | Refresh the minimap windows for specified windows.           | List of window IDs (defaults to current window if list is empty)     |
| `require('neominimap').focus()`             | Focuse the minimap window, allowing interaction with it.     | None                                                                 |
| `require('neominimap').unfocus()`           | Unfocus the minimap window, returning focus to the editor.   | None                                                                 |
| `require('neominimap').toggleFocus()`       | Toggle focus between the minimap and the main editor window. | None                                                                 |

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

Checkout the wiki page for more details. [wiki](https://github.com/Isrothy/neominimap.nvim/wiki/Tips)

## Highlights

| Highlight Group           | Description                                   |
|---------------------------|-----------------------------------------------|
| `NeominimapBackground`    | Background color for the minimap.             |
| `NeominimapBorder`        | Border highlight for the minimap window.      |
| `NeominimapCursorLine`    | Highlight for the cursor line in the minimap. |
| `NeominimapHintLine`      |                                               |
| `NeominimapInfoLine`      |                                               |
| `NeominimapWarnLine`      |                                               |
| `NeominimapErrorLine`     |                                               |
| `NeominimapHintSign`      |                                               |
| `NeominimapInfoSign`      |                                               |
| `NeominimapWarnSign`      |                                               |
| `NeominimapErrorSign`     |                                               |
| `NeominimapGitAddLine`    |                                               |
| `NeominimapGitChangeLine` |                                               |
| `NeominimapGitDeleteLine` |                                               |
| `NeominimapGitAddSign`    |                                               |
| `NeominimapGitChangeSign` |                                               |
| `NeominimapGitDeleteSign` |                                               |

## Namespaces

| Namespace               | Description                      |
|-------------------------|----------------------------------|
| `neominimap_git`        | Git signs and highlights.        |
| `neominimap_diagnostic` | Diagnostic signs and highlights. |
| `neominimap_search`     | Search signs and highlights.     |
| `neominimap_treesitter` | Treesitter highlights.           |

## TODO

- [x] LSP integration
- [x] TreeSitter integration
- [x] Git integration
- [x] Search integration
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
