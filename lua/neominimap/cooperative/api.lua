local M = {}

--- Cooperative version of nvim_buf_get_lines
---@async
---@param bufnr integer The buffer number
---@param start integer The start line (0-indexed)
---@param stop integer The end line (0-indexed, exclusive)
---@param chunk_size integer? The number of lines to fetch before yielding
---@return string[] lines A list of lines from the buffer
M.buf_get_lines_co = function(bufnr, start, stop, chunk_size)
    if stop == -1 then
        stop = vim.api.nvim_buf_line_count(bufnr)
    end
    chunk_size = chunk_size or 200
    local result = {}
    local coop = require("neominimap.cooperative")
    coop.for_co(start, stop, chunk_size, 1, function(i)
        local chunk_stop = math.min(i + chunk_size, stop)
        local lines = vim.api.nvim_buf_get_lines(bufnr, i, chunk_stop, false)
        vim.list_extend(result, lines) -- Append lines to result
    end)

    return result
end

--- Cooperative version of nvim_buf_set_lines
---@async
---@param bufnr integer The buffer number
---@param start integer The start line (0-indexed)
---@param end_ integer The end line (0-indexed, exclusive)
---@param replacement string[] The lines to set
---@param chunk_size integer? The number of lines to set before yielding
M.buf_set_lines_co = function(bufnr, start, end_, replacement, chunk_size)
    chunk_size = chunk_size or 200
    local replacement_line_count = #replacement
    local original_line_count = vim.api.nvim_buf_line_count(bufnr)
    local chunks = math.ceil(replacement_line_count / chunk_size)
    if start < 0 then
        start = original_line_count + start + 1
    end
    if end_ < 0 then
        end_ = original_line_count + end_ + 1
    end
    if start >= end_ then
        return
    end

    local coop = require("neominimap.cooperative")
    coop.for_co(1, chunks, 1, 1, function(i)
        local chunk_start = (i - 1) * chunk_size + 1
        local chunk_stop = math.min(i * chunk_size, replacement_line_count)
        local lines = vim.list_slice(replacement, chunk_start, chunk_stop)

        vim.api.nvim_buf_set_lines(bufnr, start, math.min(start + #lines, math.max(start, end_)), false, lines)
        start = start + #lines
    end)

    if start < end_ then
        vim.api.nvim_buf_set_lines(bufnr, start, end_, false, {})
    end
end

---@async
---@param parser vim.treesitter.LanguageTree
---@param range boolean|Range?
---@return table<integer, TSTree>
M.parse_language_tree_co = function(parser, range)
    local co = coroutine.running()
    local trees = parser:parse(range, function(err, trees)
        local logger = require("neominimap.logger")
        if err then
            logger.notify(err, vim.log.levels.ERROR)
            return
        end
        if coroutine.status(co) == "suspended" then
            require("neominimap.cooperative").resume(co, trees)
        end
    end)
    if trees then
        return trees
    else
        return coroutine.yield()
    end
end

return M
