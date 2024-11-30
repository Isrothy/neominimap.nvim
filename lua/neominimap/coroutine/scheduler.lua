--- Manages coroutine tasks in Neovim, ensuring non-blocking execution, particularly for CPU-intensive tasks.
--- Implements cooperative multitasking, requiring coroutines to **explicitly** yield and resume execution.
--- When a coroutine yields, the scheduler schedules its resumption in the event loop, maintaining non-blocking behavior.
---
--- This scheduler allows only **one** coroutine to run at a time.
--- If multiple coroutines are added, **the previous ones will be discarded.**
---@class Neominimap.Coroutine.Scheduler
---@field current_task table|nil Holds the current coroutine task
local Scheduler = {}
Scheduler.__index = Scheduler

-- Constructor
---@return Neominimap.Coroutine.Scheduler
function Scheduler:new()
    local instance = {
        current_task = nil, -- Holds the current coroutine task
    }
    setmetatable(instance, Scheduler)
    return instance
end

-- Run the coroutine task
function Scheduler:run_coroutine()
    if not self.current_task or not self.current_task.co then
        return
    end

    local status, value = coroutine.resume(self.current_task.co)
    if not status then
        if self.current_task.handlers.on_error then
            self.current_task.handlers.on_error(value)
        else
            local logger = require("neominimap.logger")
            logger.notify("Error in coroutine: " .. value, vim.log.levels.ERROR)
        end
        self.current_task = nil
        return
    end

    if coroutine.status(self.current_task.co) == "dead" then
        if self.current_task.handlers.on_complete then
            self.current_task.handlers.on_complete(value)
        end
        self.current_task = nil
    else
        if self.current_task.handlers.on_yield then
            self.current_task.handlers.on_yield(value)
        end

        vim.defer_fn(function()
            self:run_coroutine()
        end, 0)
    end
end

---@class Neominimap.Coroutine.Scheduler.TaskHandlers
---@field on_yield fun(value: any)? Called when the coroutine yields
---@field on_complete fun(result: any)? Called when the coroutine completes
---@field on_error fun(error: any)? Called when the coroutine encounters an error

--- Add a new coroutine task
--- If currently running a task, it will be cleared
---@param worker fun(): thread The function that creates the coroutine
---@param handlers Neominimap.Coroutine.Scheduler.TaskHandlers? Optional handlers for the task
function Scheduler:add_coroutine(worker, handlers)
    if self.current_task then
        self.current_task = nil -- Clear the current task
    end

    self.current_task = {
        co = worker(),
        handlers = handlers or {}, -- Expect a table containing on_yield, on_complete, on_error
    }
end

return Scheduler
