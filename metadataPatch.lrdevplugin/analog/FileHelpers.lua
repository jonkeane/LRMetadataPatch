local log = require 'Logger' ("FileHelpers")

require 'Use'

-- Helpers to normalize and transform metadata into the expected FilmRoll shape
local function shutterToString (t)
    if not t then return nil end
    local denominators = {4000,2000,1000,500,250,125,100,60,30,15,8,4,2,1}
    for _, d in ipairs (denominators) do
        local expected = 1 / d
        if math.abs (t - expected) < 0.00005 then
            if d >= 1 then
                return "1/" .. d
            end
        end
    end
    if t >= 1 then
        return string.format ("%gs", t)
    end
    return string.format ("1/%.0f", 1 / t)
end

local function normalizeDateTime (dt)
    if not dt then return nil end
    return dt:gsub(" ", "T")
end

local function intIfWhole(n)
    if type(n) == 'number' then
        local f = math.floor(n)
        if f == n then return f end
    end
    return n
end

local function getCurrentFolder (catalog) 
    if catalog.getActiveSources then
        log ("getCurrentFolder")
        local sources = catalog:getActiveSources()
        for _, s in ipairs (sources) do            
            if s.type then
                log (s:type())
                if s:type() == 'LrFolder' then
                    return s
                end
            end
        end
    end

    return nil
end

local function readFile (path)
    local str = nil

    local file = io.open (path)
    if file then
        str = file:read("*all")
        file:close ()
    end

    return str
end

local function createTempDir ()
    local LrPathUtils = import 'LrPathUtils'
    local LrFileUtils = import 'LrFileUtils'
    local LrDate = import 'LrDate'
    local LrMD5 = import 'LrMD5'

    local tempRoot = LrPathUtils.getStandardFilePath('temp')
    local uniqueName = string.format(
        'lrplugin_%d_%s',
        LrDate.currentTime(),
        LrMD5.digest(tostring(math.random()))
    )
    local child = LrPathUtils.child or function(a,b) return a .. '/' .. b end
    local tempFolder = child(tempRoot, uniqueName)
    local ok = LrFileUtils.createDirectory(tempFolder)
    if ok then
        return tempFolder
    end
    return nil
end

local function findFirstZip (folderPath)
    local LrFileUtils = import 'LrFileUtils'
    local LrPathUtils = import 'LrPathUtils'

    -- Try non-recursive listing first
    if LrFileUtils.children then
        local children = LrFileUtils.children(folderPath) or {}
        for _, p in ipairs(children) do
            if p:lower():match('%.zip$') then
                return p
            end
        end
    else
        log('findFirstZip: LrFileUtils.children unavailable')
    end

    -- Fallback to any iterator provided by SDK
    local iter = (LrFileUtils.files and LrFileUtils.files(folderPath)) or
                 (LrFileUtils.recursiveFiles and LrFileUtils.recursiveFiles(folderPath))
    if type(iter) == 'function' then
        for p in iter do
            if type(p) == 'string' and p:lower():match('%.zip$') then
                return p
            end
        end
    elseif type(iter) == 'table' then
        for _, p in ipairs(iter) do
            if type(p) == 'string' and p:lower():match('%.zip$') then
                return p
            end
        end
    end
    log('findFirstZip: none found in', folderPath)
    return nil
end

local function unzipToTemp (zipPath)
    local tempDir = createTempDir()
    if not tempDir then
        log('Temp dir creation failed')
        return nil
    end

    local LrTasks = import 'LrTasks'

    -- Helper: escape single quotes for PowerShell literal single-quoted string
    local function pwshQuote(p)
        return (p or ''):gsub("'", "''")
    end

    local cmd
    if WIN_ENV then
        cmd = string.format(
            "powershell -NoLogo -NonInteractive -Command \"Expand-Archive -LiteralPath '%s' -DestinationPath '%s' -Force\"",
            pwshQuote(zipPath), pwshQuote(tempDir)
        )
    else
        cmd = string.format('/usr/bin/unzip -qq -o "%s" -d "%s"', zipPath, tempDir)
    end

    log('unzipToTemp: cmd:', cmd)
    local exitCode = LrTasks.execute(cmd)
    log('unzipToTemp: exit code:', tostring(exitCode))

    return tempDir
end

-- Clean up a temporary directory created by createTempDir
local function cleanupTempDir (tempDir)
    if not tempDir then return end
    
    local LrFileUtils = import 'LrFileUtils'
    
    log('Cleaning up temp dir: ', tempDir)
    
    -- Recursively delete the temp directory
    local success = LrFileUtils.delete(tempDir)
end

-- Recursively locate the first *.json file using Lightroom SDK file utilities instead of shell find.
local function findFirstJson (dir)
    local LrFileUtils = import 'LrFileUtils'
    local LrPathUtils = import 'LrPathUtils'

    -- Helper to normalize child paths: Lightroom may return names, not full paths
    local function toFullPath(base, p)
        if type(p) ~= 'string' then return nil end
        if p:match('^/') or p:match('^%a:[/\\]') then
            return p
        end
        local child = (LrPathUtils.child and LrPathUtils.child(base, p)) or (base .. '/' .. p)
        return child
    end

    -- recurse through files and find json files
    local iter = (LrFileUtils.recursiveFiles and LrFileUtils.recursiveFiles(dir)) or nil
    if iter then
        if type(iter) == 'function' then
            for p in iter do
                local full = toFullPath(dir, p)
                if type(full) == 'string' and full:lower():match('%.json$') then
                    return full
                end
            end
        elseif type(iter) == 'table' then
            for _, p in ipairs(iter) do
                local full = toFullPath(dir, p)
                if type(full) == 'string' and full:lower():match('%.json$') then
                    return full
                end
            end
        end
    end

    return nil
end


return {
    findFirstZip = findFirstZip,
    unzipToTemp = unzipToTemp,
    findFirstJson = findFirstJson,
    cleanupTempDir = cleanupTempDir,
    getCurrentFolder = getCurrentFolder,
    readFile = readFile,
}
