local api = vim.api
local fn = vim.fn

local config = require("neominimap.config")

local M = {}

---@param name string
---@return string
local get_hl_bg = function(name)
    local hl = vim.api.nvim_get_hl(0, { name = name, link = false })
    if hl.fg then
        return string.format("#%06x", hl.fg)
    elseif hl.bg then
        return string.format("#%06x", hl.bg)
    else
        return "#00ffff"
    end
end

api.nvim_set_hl(0, "NeominimapSearchSign", { fg = get_hl_bg("Search"), default = true })
api.nvim_set_hl(0, "NeominimapSearchIcon", { fg = get_hl_bg("Search"), default = true })
api.nvim_set_hl(0, "NeominimapSearchLine", { bg = get_hl_bg("Search"), default = true })

--- @param pattern string
--- @return string
local function smartcaseify(pattern)
    local smartcase = pattern:find("[A-Z]") ~= nil
    if smartcase and not vim.startswith(pattern, "\\C") then
        return "\\C" .. pattern
    else
        return pattern
    end
end

--- @return string
local function get_pattern()
    if require("neominimap.util").is_search_mode() then
        return vim.fn.getcmdline()
    end
    return vim.v.hlsearch == 1 and fn.getreg("/") --[[@as string]]
        or ""
end

--- @class Neominimap.Handlers.Search.CacheElem
--- @field changedtick integer
--- @field pattern string
--- @field matches integer[]

--- @type table<integer, Neominimap.Handlers.Search.CacheElem>
local cache = {}

--- @param bufnr integer
--- @return integer[]
local get_matches = function(bufnr)
    local pattern = get_pattern()
    if pattern and vim.o.ignorecase and vim.o.smartcase then
        pattern = smartcaseify(pattern)
    end

    if
        cache[bufnr]
        and cache[bufnr].changedtick == vim.b[bufnr].changedtick
        and (not pattern or cache[bufnr].pattern == pattern)
    then
        return cache[bufnr].matches
    end

    ---@type integer[]
    local matches = {}

    if pattern and pattern ~= "" then
        local lines = api.nvim_buf_get_lines(bufnr, 0, -1, true)

        for lnum, line in ipairs(lines) do
            local ok, col = pcall(fn.match, line, pattern, 0)
            if ok and col ~= -1 then
                matches[#matches + 1] = lnum
            end
        end
    end

    cache[bufnr] = {
        pattern = pattern,
        changedtick = vim.b[bufnr].changedtick,
        matches = matches,
    }

    return matches
end

---@type Neominimap.Map.Handler.Autocmd.Callback
M.on_buf_win_enter = function(apply, args)
    local logger = require("neominimap.logger")
    logger.log("BufWinEnter event triggered.", vim.log.levels.TRACE)
    vim.schedule(function()
        local bufnr = api.nvim_get_current_buf()
        logger.log(string.format("Updating search status for buffer %d.", bufnr), vim.log.levels.TRACE)
        apply(bufnr)
        logger.log(string.format("Search status updated for buffer %d.", bufnr), vim.log.levels.TRACE)
    end)
end

---@type Neominimap.Map.Handler.Autocmd.Callback
M.on_tab_enter = function(apply, args)
    local tid = api.nvim_get_current_tabpage()
    local logger = require("neominimap.logger")
    logger.log(string.format("TabEnter event triggered for tab %d.", tid), vim.log.levels.TRACE)
    logger.log("Refreshing search status.", vim.log.levels.TRACE)
    local visiable_buffers = require("neominimap.util").get_visible_buffers()
    vim.schedule(function()
        vim.tbl_map(function(bufnr)
            logger.log(string.format("Updating search status for buffer %d.", bufnr), vim.log.levels.TRACE)
            apply(bufnr)
            logger.log(string.format("Search status updated for buffer %d.", bufnr), vim.log.levels.TRACE)
        end, visiable_buffers)
        logger.log("Search status refreshed.", vim.log.levels.TRACE)
    end)
end

---@type Neominimap.Map.Handler.Autocmd.Callback
M.on_search = function(apply, args)
    local logger = require("neominimap.logger")
    logger.log("Search event triggered", vim.log.levels.TRACE)
    vim.schedule(function()
        local visible_buffers = require("neominimap.util").get_visible_buffers()
        vim.tbl_map(function(bufnr)
            logger.log(string.format("Updating search status for buffer %d.", bufnr), vim.log.levels.TRACE)
            apply(bufnr)
            logger.log(string.format("Search status updated for buffer %d.", bufnr), vim.log.levels.TRACE)
        end, visible_buffers)
        logger.log("Search status refreshed.", vim.log.levels.TRACE)
    end)
end

---@param bufnr integer
---@return Neominimap.Map.Handler.Annotation[]
M.get_annotations = function(bufnr)
    local matches = get_matches(bufnr)
    local util = require("neominimap.util")
    return vim.tbl_map(function(lnum)
        ---@type Neominimap.Map.Handler.Annotation[]
        return {
            lnum = lnum + 1,
            end_lnum = lnum + 1,
            priority = config.search.priority,
            id = 1,
            icon = config.search.icon,
            highlight = "NeominimapSearch" .. util.capitalize(config.search.mode),
        }
    end, matches)
end

return M
