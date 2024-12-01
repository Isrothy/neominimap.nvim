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
---@generic K
---@param iterator fun(var:V,state:S):K,V? The iterator function
---@param invarient V The initial control variable
---@param start_index S The initial state for the iterator
---@param batch_size integer The number of iterations before yielding
---@param func fun(key:K, value:V) The function to execute for each iteration
M.for_in_co = function(iterator, invarient, start_index, batch_size, func)
    local count = 0
    for key, value in iterator, invarient, start_index do
        func(key, value)

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
---@generic K
---@param iterator fun(var:V,state:S):K,V? The iterator function
---@param invariant V The initial control variable
---@param start_index S The initial state for the iterator
---@param batch_size integer The number of iterations before yielding
---@param func fun(key:K, value:V) The function to execute for each iteration
---@return fun()
M.for_in_co_wrapped = function(iterator, invariant, start_index, batch_size, func)
    return function()
        M.for_in_co(iterator, invariant, start_index, batch_size, func)
    end
end

--- A for-in loop that yields after a specified number of iterations to release CPU resources.
---@async
---@generic V
---@param arr V[] The table to iterate over
---@param batch_size integer The number of iterations before yielding
---@param func fun(index:integer, value:V) The function to execute for each iteration
M.for_ipairs_co = function(arr, batch_size, func)
    local count = 0
    for index, value in ipairs(arr) do
        func(index, value)

        count = count + 1
        if count == batch_size then
            coroutine.yield()
            count = 0
        end
    end
end

---A wrapper for `for_ipairs_co` that returns a coroutine.
---@async
---@generic V
---@param arr V[] The table to iterate over
---@param batch_size integer The number of iterations before yielding
---@param func fun(index:integer, value:V) The function to execute for each iteration
---@return fun()
M.for_ipairs_co_wrapped = function(arr, batch_size, func)
    return function()
        M.for_ipairs_co(arr, batch_size, func)
    end
end

--- A for-pairs loop that yields after a specified number of iterations to release CPU resources.
---@async
---@generic K
---@generic V
---@param arr table<K, V> The table to iterate over
---@param batch_size integer The number of iterations before yielding
---@param func fun(key:K, value:V) The function to execute for each iteration
M.for_pairs_co = function(arr, batch_size, func)
    local count = 0
    for key, value in pairs(arr) do
        func(key, value)

        count = count + 1
        if count == batch_size then
            coroutine.yield()
            count = 0
        end
    end
end

---A wrapper for `for_pairs_co` that returns a coroutine.
---@async
---@generic K
---@generic V
---@param arr table<K, V> The table to iterate over
---@param batch_size integer The number of iterations before yielding
---@param func fun(key:K, value:V) The function to execute for each iteration
---@return fun()
M.for_pairs_co_wrapped = function(arr, batch_size, func)
    return function()
        M.for_pairs_co(arr, batch_size, func)
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
