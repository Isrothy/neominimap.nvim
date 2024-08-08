local M = {}

---@class Fold
---@field start integer
---@field end_ integer

---@param bufnr integer
---@return Fold[]
M.get_all_folds = function(bufnr)
    local folds = {}
    local line_count = vim.api.nvim_buf_line_count(bufnr)
    vim.api.nvim_buf_call(bufnr, function()
        local line = 1
        while line <= line_count and vim.fn.foldlevel(line) do
            local foldend = vim.fn.foldclosedend(line)
            if foldend ~= -1 then
                folds[#folds + 1] = { start = line, end_ = foldend }
                line = foldend + 1
            else
                line = line + 1
            end
        end
    end)

    return folds
end

---@param bufnr integer
---@param line integer
M.is_line_folded = function(bufnr, line)
    local folded = false

    -- Run the function in the context of the buffer with bufnr
    vim.api.nvim_buf_call(bufnr, function()
        folded = vim.fn.foldclosed(line) ~= -1
    end)

    return folded
end

---@generic T
---@param bufnr integer
---@param lines T[]
M.filter_folds = function(bufnr, lines)
    local folds = M.get_all_folds(bufnr)
    local filtered_lines = {}
    local index = 1
    for line_num, line in ipairs(lines) do
        while index <= #folds and folds[index].end_ < line_num do
            index = index + 1
        end
        if index > #folds or folds[index].start >= line_num then
            filtered_lines[#filtered_lines + 1] = line
        end
    end
    return filtered_lines
end

return M
