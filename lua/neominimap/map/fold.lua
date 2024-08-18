local M = {}

---@class (exact) Neominimap.Fold
---@field start integer
---@field end_ integer

---@param bufnr integer
---@return Neominimap.Fold[]
M.get_all_folds = function(bufnr)
    local folds = {} ---@type Neominimap.Fold[]
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
---@param folds Neominimap.Fold[]
---@param lines T[]
M.filter_folds = function(folds, lines)
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

---@param folds Neominimap.Fold[]
---@param lineNr integer
---@return integer?
M.substract_fold_lines = function(folds, lineNr)
    local acc = 0
    for _, f in ipairs(folds) do
        if lineNr <= f.start then
            break
        elseif lineNr <= f.end_ then
            return nil
        else
            acc = acc + f.end_ - f.start
        end
    end
    return lineNr - acc
end

---@param folds Neominimap.Fold[]
---@param lineNr integer
M.add_fold_lines = function(folds, lineNr)
    for _, f in ipairs(folds) do
        if lineNr <= f.start then
            break
        else
            lineNr = lineNr + f.end_ - f.start
        end
    end
    return lineNr
end

---@param bufnr integer
---@return Neominimap.Fold[]
M.get_cached_folds = function(bufnr)
    local var = require("neominimap.variables")
    return var.b[bufnr].cached_folds
end

---@param bufnr integer
M.cache_folds = function(bufnr)
    local var = require("neominimap.variables")
    var.b[bufnr].cached_folds = M.get_all_folds(bufnr)
end

return M
