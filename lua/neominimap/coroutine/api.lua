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

    for i = start, stop, chunk_size do
        local chunk_stop = math.min(i + chunk_size, stop)
        local lines = vim.api.nvim_buf_get_lines(bufnr, i, chunk_stop, false)
        vim.list_extend(result, lines) -- Append lines to result
        coroutine.yield() -- Yield after processing a chunk
    end

    return result
end

--- Cooperative version of nvim_buf_set_lines
---@async
---@param bufnr integer The buffer number
---@param start integer The start line (0-indexed)
---@param stop integer The end line (0-indexed, exclusive)
---@param replacement string[] The lines to set
---@param chunk_size integer? The number of lines to set before yielding
M.buf_set_lines_co = function(bufnr, start, stop, replacement, chunk_size)
    chunk_size = chunk_size or 200
    local total_lines = #replacement
    local chunks = math.ceil(total_lines / chunk_size)
    vim.api.nvim_buf_set_lines(bufnr, start, stop, false, {})

    for i = 1, chunks do
        local chunk_start = (i - 1) * chunk_size + 1
        local chunk_stop = math.min(i * chunk_size, total_lines)
        local lines = vim.list_slice(replacement, chunk_start, chunk_stop)

        -- Set the chunk of lines
        vim.api.nvim_buf_set_lines(bufnr, start, start, false, lines)
        start = start + #lines -- Update start for the next chunk

        coroutine.yield() -- Yield after setting a chunk
    end
end

return M
