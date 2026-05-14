local M = {}
local api = vim.api
local config = require("neominimap.config")
local coord = require("neominimap.map.coord")
local fold = require("neominimap.map.fold")
local logger = require("neominimap.logger")

---@class Neominimap.Viewport.Cache
---@field w0 integer
---@field w_dollar integer
---@field sbufnr integer
---@field mbufnr integer
---@field line_count integer

---@type table<integer, Neominimap.Viewport.Cache>
local cache = {}

---@type table<integer, integer>
local match_id_map = {}

---@param swinid integer
---@param mwinid integer
M.refresh = function(swinid, mwinid)
    if not config.viewport.enabled then
        return
    end
    if not api.nvim_win_is_valid(swinid) or not api.nvim_win_is_valid(mwinid) then
        return
    end

    local mbufnr = api.nvim_win_get_buf(mwinid)
    if not mbufnr or not api.nvim_buf_is_valid(mbufnr) then
        return
    end

    local sbufnr = api.nvim_win_get_buf(swinid)
    if not sbufnr or not api.nvim_buf_is_valid(sbufnr) then
        return
    end

    local w0 = vim.fn.line("w0", swinid)
    local w_dollar = vim.fn.line("w$", swinid)
    if w0 == 0 or w_dollar == 0 then
        return
    end

    local cached_folds = fold.get_cached_folds(sbufnr) or {}
    local start_row, end_row = fold.get_visible_range(cached_folds, w0, w_dollar)
    local m_start_row = coord.codepoint_to_mcodepoint(start_row, 1)
    local m_end_row = coord.codepoint_to_mcodepoint(end_row, 1)
    local line_count = api.nvim_buf_line_count(mbufnr)

    local cached = cache[mwinid]
    if
        cached
        and cached.w0 == w0
        and cached.w_dollar == w_dollar
        and cached.sbufnr == sbufnr
        and cached.mbufnr == mbufnr
        and cached.line_count == line_count
    then
        return
    end

    logger.log.trace("Refreshing viewport overlay for minimap window %d", mwinid)

    local old_match_id = match_id_map[mwinid]
    if old_match_id then
        pcall(vim.fn.matchdelete, old_match_id, mwinid)
    end

    if m_start_row > line_count then
        cache[mwinid] = { w0 = w0, w_dollar = w_dollar, sbufnr = sbufnr, mbufnr = mbufnr, line_count = line_count }
        logger.log.trace("Viewport overlay cleared (out of range) for minimap window %d", mwinid)
        return
    end

    local end_line = math.min(m_end_row, line_count)
    local pattern = string.format([[\m\%%>%dl\%%<%dl.*]], m_start_row - 1, end_line + 1)
    local ok, match_id =
        pcall(vim.fn.matchadd, config.viewport.hl_group, pattern, config.viewport.priority, -1, { window = mwinid })
    if ok and match_id ~= -1 then
        match_id_map[mwinid] = match_id
    else
        logger.log.warn("Failed to add viewport match for window %d: %s", mwinid, tostring(match_id))
    end

    cache[mwinid] = { w0 = w0, w_dollar = w_dollar, sbufnr = sbufnr, mbufnr = mbufnr, line_count = line_count }
    logger.log.trace("Viewport overlay refreshed for minimap window %d", mwinid)
end

---@param mwinid integer
M.clear = function(mwinid)
    local match_id = match_id_map[mwinid]
    if match_id then
        pcall(vim.fn.matchdelete, match_id, mwinid)
    end
    match_id_map[mwinid] = nil
    cache[mwinid] = nil
end

return M
