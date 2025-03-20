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

The color scheme used for these screenshots is [nord](https://github.com/gbprod/nord.nvim)

![screenshot](https://github.com/user-attachments/assets/029d61c7-94ac-4e68-9308-3c82a3c07fef)

<details>
 <summary>Show diagnostics:</summary>

![image](https://github.com/user-attachments/assets/0710873b-bfa8-4102-bd6f-dbd9dd5cb9fd)

</details>

<details>
 <summary>Show git signs:</summary>

![image](https://github.com/user-attachments/assets/383ab582-884d-4fd5-86ab-1324ebedd7c0)

</details>

<details>
 <summary>Show search results:</summary>

![image](https://github.com/user-attachments/assets/83a1a5a5-7bc7-48cc-9c01-39de75fada94)

</details>

<details>
 <summary>Show marks:</summary>
  
![image](https://github.com/user-attachments/assets/9a3260c3-7930-4f49-9b8d-888b15a760ad)

</details>

<details>
 <summary>Show minimaps in float windows:</summary>

![image](https://github.com/user-attachments/assets/71a14460-e8c0-468f-b7bc-6e991df1f042)

</details>

<details>
 <summary>Show minimaps in a split window:</summary>

![image](https://github.com/user-attachments/assets/8a4fc48b-4811-4cee-a964-eccc5fda9a57)

</details>

## Features

- 🖥️ LSP integration
- 🌳 TreeSitter integration
- ➖ Fold integration
- 🔀 Git integration
- 🔎 Search integration
- 🏷️ Support for marks
- 🖱️ Mouse click support
- 🖍️ Support for map annotations in the sign column and line highlight
- 📐 Support both split window and float window layouts
- 🌐 Respects UTF-8 encoding and tab width
- 🎯 Focus on the minimap, allowing interaction with it
- 🔧 Support for customized handlers
- 🔣 Statusline Components
- ⏳ Cooperative Scheduling

## Requirements and Dependencies

- Neovim version 0.10.0 or higher is required.
  Nightly versions might work, but **NOT** guaranteed or maintained.
- A font that supports dispalys **Braille Patterns** Unicode block
- Optional: [nvim-treesitter](https://github.com/nvim-treesitter/nvim-treesitter) for highlighting
- Optional: [gitsigns.nvim](https://github.com/lewis6991/gitsigns.nvim) for Git integration

## Installation

With Lazy:

```lua
---@module "neominimap.config.meta"
{
    "Isrothy/neominimap.nvim",
    version = "v3.*.*",
    enabled = true,
    lazy = false, -- NOTE: NO NEED to Lazy load
    -- Optional
    keys = {
        -- Global Minimap Controls
        { "<leader>nm", "<cmd>Neominimap toggle<cr>", desc = "Toggle global minimap" },
        { "<leader>no", "<cmd>Neominimap on<cr>", desc = "Enable global minimap" },
        { "<leader>nc", "<cmd>Neominimap off<cr>", desc = "Disable global minimap" },
        { "<leader>nr", "<cmd>Neominimap refresh<cr>", desc = "Refresh global minimap" },

        -- Window-Specific Minimap Controls
        { "<leader>nwt", "<cmd>Neominimap winToggle<cr>", desc = "Toggle minimap for current window" },
        { "<leader>nwr", "<cmd>Neominimap winRefresh<cr>", desc = "Refresh minimap for current window" },
        { "<leader>nwo", "<cmd>Neominimap winOn<cr>", desc = "Enable minimap for current window" },
        { "<leader>nwc", "<cmd>Neominimap winOff<cr>", desc = "Disable minimap for current window" },

        -- Tab-Specific Minimap Controls
        { "<leader>ntt", "<cmd>Neominimap tabToggle<cr>", desc = "Toggle minimap for current tab" },
        { "<leader>ntr", "<cmd>Neominimap tabRefresh<cr>", desc = "Refresh minimap for current tab" },
        { "<leader>nto", "<cmd>Neominimap tabOn<cr>", desc = "Enable minimap for current tab" },
        { "<leader>ntc", "<cmd>Neominimap tabOff<cr>", desc = "Disable minimap for current tab" },

        -- Buffer-Specific Minimap Controls
        { "<leader>nbt", "<cmd>Neominimap bufToggle<cr>", desc = "Toggle minimap for current buffer" },
        { "<leader>nbr", "<cmd>Neominimap bufRefresh<cr>", desc = "Refresh minimap for current buffer" },
        { "<leader>nbo", "<cmd>Neominimap bufOn<cr>", desc = "Enable minimap for current buffer" },
        { "<leader>nbc", "<cmd>Neominimap bufOff<cr>", desc = "Disable minimap for current buffer" },

        ---Focus Controls
        { "<leader>nf", "<cmd>Neominimap focus<cr>", desc = "Focus on minimap" },
        { "<leader>nu", "<cmd>Neominimap unfocus<cr>", desc = "Unfocus minimap" },
        { "<leader>ns", "<cmd>Neominimap toggleFocus<cr>", desc = "Switch focus on minimap" },
    },
    init = function()
        -- The following options are recommended when layout == "float"
        vim.opt.wrap = false
        vim.opt.sidescrolloff = 36 -- Set a large value

        --- Put your configuration here
        ---@type Neominimap.UserConfig
        vim.g.neominimap = {
            auto_enable = true,
        }
    end,
}
```

## Configuration

<details>
 <summary>Default configuration</summary>

```lua
---@enum Neominimap.Handler.Annotation
local AnnotationMode = {
    Sign = "sign", -- Show braille signs in the sign column
    Icon = "icon", -- Show icons in the sign column
    Line = "line", -- Highlight the background of the line on the minimap
}

vim.g.neominimap ={
    -- Enable the plugin by default
    auto_enable = true, ---@type boolean

    -- Log level
    log_level = vim.log.levels.OFF, ---@type Neominimap.Log.Levels

    -- Notification level
    notification_level = vim.log.levels.INFO, ---@type Neominimap.Log.Levels

    -- Path to the log file
    log_path = vim.fn.stdpath("data") .. "/neominimap.log", ---@type string

    -- Minimap will not be created for buffers of these types
    ---@type string[]
    exclude_filetypes = {
        "help",
        "bigfile", -- For Snacks.nvim
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

    -- When false is returned, the minimap will not be created for this tab
    ---@type fun(tabid: integer): boolean
    tab_filter = function()
        return true
    end,


    -- How many columns a dot should span
    x_multiplier = 4, ---@type integer

    -- How many rows a dot should span
    y_multiplier = 1, ---@type integer

    ---@alias Neominimap.Config.LayoutType "split" | "float"

    --- Either `split` or `float`
    --- When layout is set to `float`,
    --- the minimap will be created in floating windows attached to all suitable windows
    --- When layout is set to `split`,
    --- the minimap will be created in one split window
    layout = "float", ---@type Neominimap.Config.LayoutType

    --- Used when `layout` is set to `split`
    split = {
        minimap_width = 20, ---@type integer

        -- Always fix the width of the split window
        fix_width = false, ---@type boolean

        -- split mode:
        -- left is an alias for topleft   - leftmost vertical split, full height
        -- right is an alias for botright - rightmost vertical split, full height
        -- aboveleft -  left split in current window
        -- rightbelow - right split in current window
        ---@alias Neominimap.Config.SplitDirection "left" | "right" | 
        ---       "topleft" | "botright" | "aboveleft" | "rightbelow"
        direction = "right", ---@type Neominimap.Config.SplitDirection

        ---Automatically close the split window when it is the last window
        close_if_last_window = false, ---@type boolean
    },

    --- Used when `layout` is set to `float`
    float = {
        minimap_width = 20, ---@type integer

        --- If set to nil, there is no maximum height restriction
        --- @type integer
        max_minimap_height = nil,

        margin = {
            right = 0, ---@type integer
            top = 0, ---@type integer
            bottom = 0, ---@type integer
        },
        z_index = 1, ---@type integer

        --- Border style of the floating window.
        --- Accepts all usual border style options (e.g., "single", "double")
        --- @type string | string[] | [string, string][]
        window_border = "single",
    },

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
        severity = vim.diagnostic.severity.WARN, ---@type vim.diagnostic.SeverityInt
        mode = "line", ---@type Neominimap.Handler.Annotation.Mode
        priority = {
            ERROR = 100, ---@type integer
            WARN = 90, ---@type integer
            INFO = 80, ---@type integer
            HINT = 70, ---@type integer
        },
        icon = {
            ERROR = "󰅚 ", ---@type string
            WARN = "󰀪 ", ---@type string
            INFO = "󰌶 ", ---@type string
            HINT = " ", ---@type string
        },
    },

    git = {
        enabled = true, ---@type boolean
        mode = "sign", ---@type Neominimap.Handler.Annotation.Mode
        priority = 6, ---@type integer
        icon = {
            add = "+ ", ---@type string
            change = "~ ", ---@type string
            delete = "- ", ---@type string
        },
    },

    search = {
        enabled = false, ---@type boolean
        mode = "line", ---@type Neominimap.Handler.Annotation.Mode
        priority = 20, ---@type integer
        icon = "󰱽 ", ---@type string
    },

    treesitter = {
        enabled = true, ---@type boolean
        priority = 200, ---@type integer
    },

    mark = {
        enabled = false, ---@type boolean
        mode = "icon", ---@type Neominimap.Handler.Annotation.Mode
        priority = 10, ---@type integer
        key = "m", ---@type string
        show_builtins = false, ---@type boolean -- shows the builtin marks like [ ] < >
    },

    fold = {
        -- Considering fold when rendering minimap
        enabled = true, ---@type boolean
    },

    ---Overrite the default winopt
    ---@param opt vim.wo
    ---@param winid integer the window id of the source window, NOT minimap window
    winopt = function(opt, winid) end,

    ---Overrite the default bufopt
    ---@param opt vim.bo
    ---@param bufnr integer the buffer id of the source buffer, NOT minimap buffer
    bufopt = function(opt, bufnr) end,

    ---@type Neominimap.Map.Handler[]
    handlers = {},
}
```

</details>

<details>
 <summary>Default winopt</summary>

```lua
{
    winhighlight = table.concat({
        "Normal:NeominimapBackground",
        "FloatBorder:NeominimapBorder",
        "CursorLine:NeominimapCursorLine",
        "CursorLineNr:NeominimapCursorLineNr",
        "CursorLineSign:NeominimapCursorLineSign",
        "CursorLineFold:NeominimapCursorLineFold",
    }, ","),
    wrap = false,
    foldcolumn = "0",
    signcolumn = "auto",
    number = false,
    relativenumber = false,
    scrolloff = 99999, -- To center minimap
    sidescrolloff = 0,
    winblend = 0,
    cursorline = true,
    spell = false,
    list = false,
    fillchars = "eob: ",
    winfixwidth = true,
}
```

</details>

<details>
 <summary>Default bufopt</summary>

```lua
{
    buftype = "nofile",
    filetype = "neominimap",
    swapfile = false,
    bufhidden = "hide",
    undolevels = -1,
    modifiable = false,
}
```

</details>

## Commands

<details>
 <summary>Click to expand</summary>

| Command                               | Description                                                                                                     | Arguments                  |
| ------------------------------------- | --------------------------------------------------------------------------------------------------------------- | -------------------------- |
| `Neominimap on`                       | Turn on minimaps globally.                                                                                      | None                       |
| `Neominimap off`                      | Turn off minimaps globally.                                                                                     | None                       |
| `Neominimap toggle`                   | Toggle minimaps globally.                                                                                       | None                       |
| `Neominimap refresh`                  | Refresh minimaps globally.                                                                                      | None                       |
| `Neominimap bufOn [buffer_list]`      | Enable the minimap for specified buffers. If no buffers are specified, enable for the current buffer.           | Optional: List of buffers  |
| `Neominimap bufOff [buffer_list]`     | Disable the minimap for specified buffers. If no buffers are specified, disable for the current buffer.         | Optional: List of buffers  |
| `Neominimap bufToggle [buffer_list]`  | Toggle the minimap for specified buffers. If no buffers are specified, toggle for the current buffer.           | Optional: List of buffers  |
| `Neominimap bufRefresh [buffer_list]` | Refresh the minimap buffers for specified buffers. If no buffers are specified, refresh for the current buffer. | Optional: List of buffers  |
| `Neominimap TabOn [tab_list]`         | Enable the minimap for specified tabspage. If no tabpages are specified, enable for the current tab.            | Optional: List of tabpages |
| `Neominimap TabOff [tab_list]`        | Disable the minimap for specified tabpages. If no tabpages are specified, disable for the current tab.          | Optional: List of tabpages |
| `Neominimap TabToggle [tab_list]`     | Toggle the minimap for specified tabpages. If no tabpages are specified, toggle for the current tab.            | Optional: List of tabpages |
| `Neominimap TabRefresh [tab_list]`    | Refresh the minimap tabs for specified tabs. If no tabs are specified, refresh for the current tab.             | Optional: List of tabpages |
| `Neominimap winOn [window_list]`      | Enable the minimap for specified windows. If no windows are specified, enable for the current window.           | Optional: List of windows  |
| `Neominimap winOff [window_list]`     | Disable the minimap for specified windows. If no windows are specified, disable for the current window.         | Optional: List of windows  |
| `Neominimap winToggle [window_list]`  | Toggle the minimap for specified windows. If no windows are specified, toggle for the current window.           | Optional: List of windows  |
| `Neominimap winRefresh [window_list]` | Refresh the minimap windows for specified windows. If no windows are specified, refresh for the current window. | Optional: List of windows  |
| `Neominimap focus`                    | Focus on the minimap. Set cursor to the minimap window.                                                         | None                       |
| `Neominimap unfocus`                  | Unfocus the minimap. Set cursor back.                                                                           | None                       |
| `Neominimap toggleFocus`              | Toggle minimap focus                                                                                            | None                       |

`Neominimap bufRefresh` does the following:

- Creating or wiping out buffers as needed.
- Rendering minimap text and applying highlights.

`Neominimap tabRefresh` does the following:

- Creating or wiping out windows in tabpages as needed.

`Neominimap winRefresh` does the following:

- Opening or closing windows as needed.
- Updating window configurations, such as positions and sizes.
- Attaching windows to the correct buffers.

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

</details>

> [!NOTE]
> A minimap is shown if and only if
>
> - Neominimap is enabled globally,
> - Neominimap is enabled for the current buffer,
> - Neominimap is enabled for the current tabage, and
> - Neominimap is enabled for the current window.

## Lua API

<details>
 <summary>These are the corresponding commands in the Lua API.</summary>

| Function                                    | Description                                                  | Arguments                                                            |
| ------------------------------------------- | ------------------------------------------------------------ | -------------------------------------------------------------------- |
| `require('neominimap').on()`                | Enable the minimap globally across all buffers and windows.  | None                                                                 |
| `require('neominimap').off()`               | Disable the minimap globally.                                | None                                                                 |
| `require('neominimap').toggle()`            | Toggle the minimap on or off globally.                       | None                                                                 |
| `require('neominimap').refresh()`           | Refresh the minimap globally.                                | None                                                                 |
| `require('neominimap').bufOn(<bufnr>)`      | Enable the minimap for specified buffers.                    | List of buffer numbers (defaults to current buffer if list is empty) |
| `require('neominimap').bufOff(<bufnr>)`     | Disable the minimap for specified buffers.                   | List of buffer numbers (defaults to current buffer if list is empty) |
| `require('neominimap').bufToggle(<bufnr>)`  | Toggle the minimap for specified buffers.                    | List of buffer numbers (defaults to current buffer if list is empty) |
| `require('neominimap').bufRefresh(<bufnr>)` | Refresh the minimap buffers for specified buffers.           | List of buffer numbers (defaults to current buffer if list is empty) |
| `require('neominimap').tabOn(<tabid>)`      | Enable the minimap for specified tabpages.                   | List of tabage IDs (defaults to current tabage if list is empty)     |
| `require('neominimap').tabOff(<tabid>)`     | Disable the minimap for specified tabpages.                  | List of tabage IDs (defaults to current tabage if list is empty)     |
| `require('neominimap').tabToggle(<tabnr>)`  | Toggle the minimap for specified tabpages.                   | List of tabage IDs (defaults to current tabage if list is empty)     |
| `require('neominimap').tabRefresh(<tabnr>)` | Refresh the minimap tabs for specified tabpages.             | List of tabage IDs (defaults to current tabage if list is empty)     |
| `require('neominimap').winOn(<winid>)`      | Enable the minimap for specified windows.                    | List of window IDs (defaults to current window if list is empty)     |
| `require('neominimap').winOff(<winid>)`     | Disable the minimap for specified windows.                   | List of window IDs (defaults to current window if list is empty)     |
| `require('neominimap').winToggle(<winid>)`  | Toggle the minimap for specified windows.                    | List of window IDs (defaults to current window if list is empty)     |
| `require('neominimap').winRefresh(<winid>)` | Refresh the minimap windows for specified windows.           | List of window IDs (defaults to current window if list is empty)     |
| `require('neominimap').focus()`             | Focuse the minimap window, allowing interaction with it.     | None                                                                 |
| `require('neominimap').unfocus()`           | Unfocus the minimap window, returning focus to the editor.   | None                                                                 |
| `require('neominimap').toggleFocus()`       | Toggle focus between the minimap and the main editor window. | None                                                                 |

</details>

## Customized Handlers

See the [wiki page](https://github.com/Isrothy/neominimap.nvim/wiki/Custimized-Handlers)

## Statusline

This plugin provides statusline components that integrate with various
statusline plugins like Lualine.

<details>
 <summary>
 Click to expand
</summary>

### Customizable Statusline Components

The plugin offers the following customizable components for your statusline:

- plugin_name - Displays the plugin name, "Neominimap".
- fullname - Shows the full path of the current file.
- shortname - Displays only the filename (without the path).
- position - Indicates the current cursor position within the file.

#### Example: Customizing Lualine

Here's an example of how you can customize the Lualine statusline using
neominimap components:

```lua
local neominimap = require("neominimap.statusline")
local minimap_extension = {
    sections = {
        lualine_c = {
            neominimap.fullname,
        },
        lualine_z = {
            neominimap.position,
            "progress",
        },
    },
    filetypes = { "neominimap" },
}
require('lualine').setup { extensions = { minimap_extension } }
```

### Using the Default Lualine Extension

Alternatively, you can use the default settings provided by the plugin:

```lua
local minimap_extension = require("neominimap.statusline").lualine_default
require('lualine').setup { extensions = { minimap_extension } }
```

The default Lualine extension provided by the plugin is structured as follows:

```lua
{
  sections = {
      winbar = {},
      lualine_a = {
          M.plugin_name,
      },
      lualine_c = {
          M.shortname,
      },
      lualine_z = {
          M.position,
          "progress",
      },
  },
  filetypes = { "neominimap" },
}
```

</details>

## How it works

### Caching Minimap Buffers

For every file opened, the plugin generates a corresponding minimap buffer.

When a buffer is displayed in a window,
the minimap buffer is automatically opened side by side with the main window.

This approach minimizes unnecessary rendering when

- Multiple windows are open for same file
- Switching between buffers within a window

### TreeSitter Integration

First, the plugin retrieves all Treesitter nodes in the buffer.

For each codepoint in the minimap,
the plugin calculates which highlight occurs most frequently
and displays it.
If multiple highlights occur the same number of times,
all of them are displayed.

Note that the plugin considers which highlights are _applied_,
rather than which highlights are _shown_.
Specifically, when many highlights are applied to a codepoint,
it is possible that only some of them are visible.
However, all applied highlights are considered in the calculation.
As a result, unshown highlights may be displayed in the minimap,
leading to potential inconsistencies
between the highlights in the minimap and those in the buffer.

### Cooperative Scheduling

When a buffer is exceptionally large, calculating and setting up the minimap can
take a significant amount of time, potentially blocking the UI. To address this,
the plugin employs cooperative scheduling, as Lua operates in a single-threaded
environment.

Most CPU-intensive tasks are executed within coroutines, which periodically
yield control back to the Neovim event loop. This allows the event loop to
decide when to resume the coroutine. By releasing CPU resources intermittently,
the plugin ensures that the UI remains responsive and unblocked during these
operations.

## Tips

Checkout the wiki page for more details. [wiki](https://github.com/Isrothy/neominimap.nvim/wiki/Tips)

## Highlights

<details>
 <summary>Click to expand</summary>

### Highlight Groups of Neominimap Windows

| Highlight Group            | Description                                |
| -------------------------- | ------------------------------------------ |
| `NeominimapBackground`     | Background color for the minimap.          |
| `NeominimapBorder`         | Border highlight for the minimap window.   |
| `NeominimapCursorLine`     | Highlight for the cursor line in minimaps. |
| `NeominimapCursorLineNr`   | To replace `CursorLineNr` in minimaps.     |
| `NeominimapCursorLineSign` | To replace `CursorLineSign` in minimaps.   |
| `NeominimapCursorLineFold` | To replace `CursorLineFold` in minimaps.   |

### Highlight Groups of Diagnostic Annotations

| Highlight Group       | Description |
| --------------------- | ----------- |
| `NeominimapHintLine`  |             |
| `NeominimapInfoLine`  |             |
| `NeominimapWarnLine`  |             |
| `NeominimapErrorLine` |             |
| `NeominimapHintSign`  |             |
| `NeominimapInfoSign`  |             |
| `NeominimapWarnSign`  |             |
| `NeominimapErrorSign` |             |
| `NeominimapHintIcon`  |             |
| `NeominimapInfoIcon`  |             |
| `NeominimapWarnIcon`  |             |
| `NeominimapErrorIcon` |             |

### Highlight Groups of Git Annotations

| Highlight Group           | Description |
| ------------------------- | ----------- |
| `NeominimapGitAddLine`    |             |
| `NeominimapGitChangeLine` |             |
| `NeominimapGitDeleteLine` |             |
| `NeominimapGitAddSign`    |             |
| `NeominimapGitChangeSign` |             |
| `NeominimapGitDeleteSign` |             |
| `NeominimapGitAddIcon`    |             |
| `NeominimapGitChangeIcon` |             |
| `NeominimapGitDeleteIcon` |             |

### Highlight Groups of Search Annotations

| Highlight Group        | Description |
| ---------------------- | ----------- |
| `NeominimapSearchLine` |             |
| `NeominimapSearchSign` |             |
| `NeominimapSearchIcon` |             |

### Highlight Groups of Mark Annotations

| Highlight Group      | Description |
| -------------------- | ----------- |
| `NeominimapMarkLine` |             |
| `NeominimapMarkSign` |             |
| `NeominimapMarkIcon` |             |

</details>

## Namespaces

<details>
 <summary>Click to expand</summary>

| Namespace               | Description                      |
| ----------------------- | -------------------------------- |
| `neominimap_git`        | Git signs and highlights.        |
| `neominimap_diagnostic` | Diagnostic signs and highlights. |
| `neominimap_search`     | Search signs and highlights.     |
| `neominimap_mark`       | Mark signs and highlights.       |
| `neominimap_treesitter` | Treesitter highlights.           |

</details>

## TODO

- [x] LSP integration
- [x] TreeSitter integration
- [x] Git integration
- [x] Search integration
- [x] Support for window relative to editor
- [x] Validate user configuration
- [x] Documentation
- [x] Performance improvements
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
    the minimap, so it only renders when the text is changed. Therefore, this
    plugin should offer better performance when frequently switching windows or
    buffers.
  - Codewindow.nvim renders the minimap based on bytes, while this plugin
    renders based on codepoints, respecting UTF-8 encoding and tab width.
  - Codewindow.nvim does not consider folds, whereas this plugin does.
  - Codewindow.nvim shows the minimap in a floating window but does not support
    a split window. This plugin supports both.
  - Codewindow.nvim does not support customized handlers, which this plugin
    does.

- [mini.map](https://github.com/echasnovski/mini.map)

  - Mini.map allows for encoded symbol customization, while this plugin does not.
  - Mini.map includes a scrollbar, which this plugin does not.
  - Mini.map does not have Treesitter integration, whereas this plugin does.
  - Mini.map rescales the minimap so that its height matches the window height,
    while this plugin generates the minimap using a fixed compression rate.
  - Mini.map does not cache the minimap, but it is still performant.
  - Mini.map shows the minimap in a floating window but does not support a
    split window. This plugin supports both.
  - Mini.map does not support customized handlers, which this plugin does.

- [minimap.vim](https://github.com/wfxr/minimap.vim)
  - Like Mini.map, Minimap.vim scales the minimap.
  - Minimap.vim uses a Rust program to generate minimaps efficiently, while
    this plugin is written in Lua.
  - Minimap.vim does not have Treesitter or LSP integration, which this plugin
    does.
  - Minimap.vim shows the minimap in a split window but does not support a
    floating window. This plugin supports both.
  - Minimap.vim does not support customized handlers, which this plugin does.

## Acknowledgements

Thanks to [gorbit99](https://github.com/gorbit99) for
[codewindow.nvim](https://github.com/gorbit99/codewindow.nvim),
by which this plugin was inspired.
The map generation algorithm and TreeSitter integration algorithm are also
learned from that project.

Special thanks to [lewis6991](https://github.com/lewis6991) for creating the
excellent [gitsigns.nvim](https://github.com/lewis6991/gitsigns.nvim) and
[satellite.nvim](https://github.com/lewis6991/satellite.nvim) plugins. The Git
integration in Neominimap was made possible by gitsigns.nvim, and the search
and mark integrations are based on satellite.nvim's code.
