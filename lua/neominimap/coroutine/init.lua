local M = {}

--- A for-loop that yields after a specified number of iterations to release CPU resources.
---@async
---@param start number The starting value of the loop
---@param stop number The ending value of the loop
---@param step number The step size for the loop
---@param batch_size number The number of iterations before yielding
---@param func fun(i: number) The function to execute for each iteration
M.for_co = function(start, stop, step, batch_size, func)
    for i = start, stop, step do
        func(i) -- Execute the provided function

        -- Yield after every `batch_size` iterations
        if (i - start) % batch_size == 0 then
            coroutine.yield()
        end
    end
end

---A wrapper for `for_co` that returns a coroutine.
---@async
---@param start number The starting value of the loop
---@param stop number The ending value of the loop
---@param step number The step size for the loop
---@param batch_size number The number of iterations before yielding
---@param func fun(i: number) The function to execute for each iteration
---@return fun()
M.for_co_wrapped = function(start, stop, step, batch_size, func)
    return function()
        M.for_co(start, stop, step, batch_size, func)
    end
end

--- A for-in loop that yields after a specified number of iterations to release CPU resources.
---@async
---@generic S
---@generic V
---@param iterator fun(state:S, var:V):V? The iterator function
---@param state S The initial state for the iterator
---@param var V The initial control variable
---@param batch_size integer The number of iterations before yielding
---@param func fun(var: V) The function to execute for each iteration
M.for_in_co = function(iterator, state, var, batch_size, func)
    local count = 0
    while true do
        var = iterator(state, var)
        if var == nil then
            break
        end

        func(var)

        count = count + 1
        if count == batch_size then
            coroutine.yield()
            count = 0
        end
    end
end

---A wrapper for `for_in_co` that returns a coroutine.
---@async
---@generic S
---@generic V
---@param iterator fun(state:S, var:V):V? The iterator function
---@param state S The initial state for the iterator
---@param var V The initial control variable
---@param batch_size integer The number of iterations before yielding
---@param func fun(var: V) The function to execute for each iteration
---@return fun()
M.for_in_co_wrapped = function(iterator, state, var, batch_size, func)
    return function()
        M.for_in_co(iterator, state, var, batch_size, func)
    end
end

--- Implements a while-loop that yields after a specified number of iterations.
---@async
---@param condition fun(): boolean The condition function that determines whether the loop continues
---@param batch_size integer The number of iterations before yielding
---@param func fun() The function to execute in each iteration
M.while_co = function(condition, batch_size, func)
    local count = 0
    while condition() do
        func() -- Execute the loop body

        count = count + 1
        if count == batch_size then
            coroutine.yield() -- Yield to release CPU resources
            count = 0 -- Reset the batch counter
        end
    end
end

--- A wrapper for `while_co` that returns a coroutine.
---@async
---@param condition fun(): boolean The condition function that determines whether the loop continues
---@param batch_size integer The number of iterations before yielding
---@param func fun() The function to execute in each iteration
---@return fun() A coroutine function
M.while_co_wrapped = function(condition, batch_size, func)
    return function()
        M.while_co(condition, batch_size, func)
    end
end

return M
