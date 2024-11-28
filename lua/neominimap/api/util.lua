local M = {}

---Validate that tbl is a list of integers
---@param input any
---@return boolean is_valid
---@return string | nil error_message
M.validate_list_of_integers = function(input)
    if type(input) ~= "table" then
        return false, "Input is not a table"
    end

    for i, value in ipairs(input) do
        if type(value) ~= "number" then
            return false, string.format("Element at index %d is not a number", i)
        end
        if value % 1 ~= 0 then
            return false, string.format("Element at index %d is not an integer", i)
        end
    end
    return true
end

return M
