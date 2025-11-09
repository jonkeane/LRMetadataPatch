local M = {}

-- Execute a shell command synchronously and return an exit code like LrTasks.execute.
-- In Lightroom, LrTasks.execute returns the program exit code. We mirror that.
function M.execute(cmd)
    -- Use os.execute; normalize return to a number when possible.
    local ok, why, code = os.execute(cmd)
    if type(ok) == 'number' then
        -- Lua 5.1 on some systems returns numeric exit status directly
        return ok
    end
    if ok == true then
        return 0
    end
    if type(code) == 'number' then
        return code
    end
    return 1
end

-- startAsyncTask: immediately run the function for tests; no real threading.
function M.startAsyncTask(fn)
    if type(fn) == 'function' then
        local co = coroutine.create(function()
            fn()
        end)
        coroutine.resume(co)
    end
    return true
end

-- Optional sleep/yield no-ops to satisfy accidental calls.
function M.sleep(millis)
    -- No-op in tests
end

function M.yield()
    -- No-op in tests
end

return M
