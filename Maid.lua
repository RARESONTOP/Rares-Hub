-- Maid.lua
-- Manages the cleaning of events and other things.
-- Useful for encapsulating state and make deconstructors easy

local Maid = {}
Maid.__index = Maid
Maid.ClassName = "Maid"

-- Create a new Maid object
-- @constructor Maid.new()
-- @treturn Maid
function Maid.new()
    return setmetatable({
        _tasks = {}
    }, Maid)
end

-- Check if a value is a Maid
-- @param value The value to check
-- @treturn boolean
function Maid.isMaid(value)
    return type(value) == "table" and value.ClassName == "Maid"
end

-- Returns Maid[key] if not part of Maid metatable
-- @param index The index to get
-- @treturn any
function Maid:__index(index)
    if Maid[index] then
        return Maid[index]
    else
        return self._tasks[index]
    end
end

-- Add a task to clean up. Tasks given to a maid will be cleaned when
-- maid[index] is set to a different value.
-- @param index The index to set
-- @param newTask The task to set
function Maid:__newindex(index, newTask)
    if Maid[index] ~= nil then
        error(("'%s' is reserved"):format(tostring(index)), 2)
    end

    local tasks = self._tasks
    local oldTask = tasks[index]

    if oldTask == newTask then
        return
    end

    tasks[index] = newTask

    if oldTask then
        if type(oldTask) == "function" then
            oldTask()
        elseif typeof(oldTask) == "RBXScriptConnection" then
            oldTask:Disconnect()
        elseif Maid.isMaid(oldTask) then
            oldTask:Destroy()
        elseif type(oldTask) == "thread" then
            task.cancel(oldTask)
        elseif oldTask.Destroy then
            oldTask:Destroy()
        end
    end
end

-- Same as indexing, but uses an incremented number as a key.
-- @param task An item to clean
-- @treturn number taskId
function Maid:GiveTask(task)
    if not task then
        error("Task cannot be false or nil", 2)
    end

    local taskId = #self._tasks + 1
    self[taskId] = task

    return taskId
end

-- Cleans up all tasks.
function Maid:DoCleaning()
    local tasks = self._tasks

    -- Disconnect all events first as we know this is safe
    for index, task in pairs(tasks) do
        if typeof(task) == "RBXScriptConnection" then
            tasks[index] = nil
            task:Disconnect()
        end
    end

    -- Clear out tasks table completely, even if clean up tasks add more tasks to the maid
    local index, taskData = next(tasks)
    while taskData ~= nil do
        tasks[index] = nil
        if type(taskData) == "function" then
            taskData()
        elseif typeof(taskData) == "RBXScriptConnection" then
            taskData:Disconnect()
        elseif Maid.isMaid(taskData) then
            taskData:Destroy()
        elseif type(taskData) == "thread" then
            task.cancel(taskData)
        elseif taskData.Destroy then
            taskData:Destroy()
        end
        index, taskData = next(tasks)
    end
end

-- Alias for DoCleaning()
Maid.Destroy = Maid.DoCleaning

return Maid
