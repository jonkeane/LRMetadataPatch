local M = {}

function M.createDirectory(path)
    -- Simulate success always; tests do not require failure modes yet
    -- Return (ok, detail) per Lightroom SDK semantics
    local ok = true
    local detail = nil
    -- Actually create dir on real FS so subsequent logic (find, unzip) can work
    local sep = package.config:sub(1,1) == '\\' and '\\' or '/'
    local cmd
    if package.config:sub(1,1) == '\\' then
        cmd = string.format('mkdir "%s" >NUL 2>&1', path)
    else
        cmd = string.format('mkdir -p "%s" 2>/dev/null', path)
    end
    os.execute(cmd)
    return ok, detail
end

-- Return a recursive iterator over files under 'path'. Returns relative paths
-- from the provided root, matching how FilmRoll's findFirstJson expects to
-- join via LrPathUtils.child when entries are not absolute.
function M.recursiveFiles(root)
    -- Collect list using POSIX find; tests run on *nix.
    local cmd = string.format('find "%s" -type f -print 2>/dev/null', root)
    local h = io.popen(cmd)
    local files = {}
    if h then
        for line in h:lines() do
            -- Normalize to relative path if possible
            local rel = line
            if line:sub(1, #root + 1) == (root .. '/') then
                rel = line:sub(#root + 2)
            end
            table.insert(files, rel)
        end
        h:close()
    end
    local i = 0
    return function()
        i = i + 1
        return files[i]
    end
end

-- Return list of child paths (files + directories) for simple recursive traversal in tests
function M.children(path)
    local results = {}
    -- Use ls to enumerate; tests run on *nix in CI context
    local h = io.popen(string.format('ls -1 "%s" 2>/dev/null', path))
    if h then
        for line in h:lines() do
            table.insert(results, path .. '/' .. line)
        end
        h:close()
    end
    return results
end


-- Check if a file or directory exists
function M.exists(path)
    if not path then return false end
    local f = io.open(path, "r")
    if f then f:close(); return true end
    return false
end

function M.delete(path)
    if not path then return false end
    local cmd = string.format('rm -rf "%s" 2>/dev/null', path)
    local result = os.execute(cmd)
    -- os.execute returns true on success in Lua 5.2+, or 0 in Lua 5.1
    return result == true or result == 0
end

return M
