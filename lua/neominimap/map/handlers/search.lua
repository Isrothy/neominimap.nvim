local api = vim.api
local fn = vim.fn

local config = require("neominimap.config").get()

local M = {}

M.namespace = api.nvim_create_namespace("neominimap_search")

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

--- @param bufnr integer
---@return Neominimap.Handler.Mark[]
M.get_marks = function(bufnr)
    local marks = get_matches(bufnr)
    return vim.tbl_map(function(lnum)
        return {
            lnum = lnum + 1,
            end_lnum = lnum + 1,
            priority = config.search.priority,
            id = 1,
            line_highlight = "NeominimapSearchLine",
            sign_highlight = "NeominimapSearchSign",
        }
    end, marks)
end

return M
