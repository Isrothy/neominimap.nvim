local api, fn = vim.api, vim.fn
local config = require("neominimap.config")

local builtin_marks = {
    "'.",
    "'^",
    "''",
    "'\"",
    "'<",
    "'>",
    "'[",
    "']",
}

--- @param m string mark name
--- @return boolean
local function is_builtin(m)
    return vim.list_contains(builtin_marks, m)
end

api.nvim_set_hl(0, "NeominimapMarkSign", { link = "Normal", default = true })
api.nvim_set_hl(0, "NeominimapMarkIcon", { link = "Normal", default = true })
api.nvim_set_hl(0, "NeominimapMarkLine", { link = "CursorLine", default = true })

---@alias Neominimap.Handler.Mark {mark:string, pos:integer[], file:string}

---@param bufnr integer
---@return Neominimap.Handler.Mark[]
local get_marks = function(bufnr)
    ---@type Neominimap.Handler.Mark[]
    local marks = {}
    local current_file = api.nvim_buf_get_name(bufnr)
    for _, mark in ipairs(fn.getmarklist()) do
        ---@cast mark Neominimap.Handler.Mark
        local mark_file = fn.fnamemodify(mark.file, ":p:a")
        if mark_file == current_file and mark.mark:find("[a-zA-Z]") ~= nil then
            marks[#marks + 1] = mark
        end
    end
    for _, mark in ipairs(vim.fn.getmarklist(bufnr)) do
        marks[#marks + 1] = mark
    end
    return marks
end

local name = "Built-in Mark"

---@type Neominimap.Map.Handler
return {
    name = name,
    mode = config.mark.mode,
    init = function()
        require("neominimap.events.mark")(config.mark.key)
    end,
    namespace = api.nvim_create_namespace("neominimap_mark"),
    autocmds = {
        {
            event = "BufWinEnter",
            opts = {
                desc = "Update mark annotations when entering window",
                callback = function(apply)
                    local logger = require("neominimap.logger")
                    logger.log("BufWinEnter event triggered.", vim.log.levels.TRACE)
                    vim.schedule(function()
                        local bufnr = api.nvim_get_current_buf()
                        logger.log(string.format("Updating marks for buffer %d.", bufnr), vim.log.levels.TRACE)
                        apply(bufnr)
                        logger.log(string.format("Marks updated for buffer %d.", bufnr), vim.log.levels.TRACE)
                    end)
                end,
            },
        },
        {
            event = "TabEnter",
            opts = {
                desc = "Update marks annotations when entering tab",
                callback = function(apply)
                    local tid = api.nvim_get_current_tabpage()
                    local logger = require("neominimap.logger")
                    logger.log(string.format("TabEnter event triggered for tab %d.", tid), vim.log.levels.TRACE)
                    logger.log("Refreshing search status.", vim.log.levels.TRACE)
                    local visiable_buffers = require("neominimap.util").get_visible_buffers()
                    vim.schedule(function()
                        vim.tbl_map(function(bufnr)
                            logger.log(string.format("Updating marks for buffer %d.", bufnr), vim.log.levels.TRACE)
                            apply(bufnr)
                            logger.log(string.format("Marks updated for buffer %d.", bufnr), vim.log.levels.TRACE)
                        end, visiable_buffers)
                    end)
                    logger.log("Marks refreshed.", vim.log.levels.TRACE)
                end,
            },
        },
        {
            event = "User",
            opts = {
                pattern = "Mark",
                desc = "Update marks annotations when mark event is triggered",
                callback = function(apply)
                    local logger = require("neominimap.logger")
                    logger.log("Mark event triggered", vim.log.levels.TRACE)
                    vim.schedule(function()
                        local visible_buffers = require("neominimap.util").get_visible_buffers()
                        for _, bufnr in ipairs(visible_buffers) do
                            logger.log(string.format("Updating marks for buffer %d.", bufnr), vim.log.levels.TRACE)
                            apply(bufnr)
                            logger.log(string.format("Marks updated for buffer %d.", bufnr), vim.log.levels.TRACE)
                        end
                        logger.log("Marksrefreshed.", vim.log.levels.TRACE)
                    end)
                end,
            },
        },
    },
    get_annotations = function(bufnr)
        local marks = get_marks(bufnr)
        local util = require("neominimap.util")
        local annotation = {}
        for _, mark in ipairs(marks) do
            local lnum = mark.pos[2]
            if config.mark.show_builtins or not is_builtin(mark.mark) then
                annotation[#annotation + 1] = {
                    lnum = lnum,
                    end_lnum = lnum,
                    priority = config.mark.priority,
                    id = 1,
                    icon = string.sub(mark.mark, 2, 3),
                    highlight = "NeominimapMark" .. util.capitalize(config.mark.mode),
                }
            end
        end
        return annotation
    end,
}
