
STRING_LIMIT = 2048

local loggers = {
    entry = nil,
    map = {
    }
}

local function serializeKeyval (file, key, value, indent, serialize)
    file:write(string.format(indent.."[%q] = ", key))
    serialize(file, value, indent)
end

local function serialize (file, o, indent)
    if o then
        local t = type (o)
        if t == 'number' then
            file:write(o)
        elseif t == 'string' then
            if o:len () > STRING_LIMIT then
                file:write (o:sub (1, STRING_LIMIT), "<...>")
            else
                file:write(o)
            end
        elseif t == 'table' then
            file:write('{\n')
            local newIndent = indent..'\t'
            for k,v in pairs(o) do
                serializeKeyval (file, k, v, newIndent, serialize)
                file:write ('\n')
            end
            file:write(indent..'}')
        elseif t == 'boolean' then
            file:write (o and 'true' or 'false')
        else
            file:write ('<<', t, '>>')
        end
    else
        file:write ('nil')
    end
end

local function getLogSuffix ()
    local pu = import 'LrPathUtils'
    local configPath = pu.child (_PLUGIN.path, 'Config.txt')

    local config = {}
    local configChunk = loadfile (configPath)
    if configChunk then
        config = configChunk ()
    end
    return config.LogFile
end

local function writeLog (logPath, prefix, ...)
    local args = {...}
    if #args > 0 and logPath then
        local f = io.open (logPath, 'a')
        if f then
            f:write ('<', prefix, '>: ')
            for _, arg in ipairs (args) do
                serialize (f, arg, '')
                f:write (' ')
            end
            f:write ('\n')
            f:close ()
        end
    end
end

local function getLogger (prefix)
    if not prefix then
        return function (...) end
    end

    local logger = loggers [prefix]
    local isEntry = false

    if not logger then
        logger = function (...) end
        if loggers.entry == nil then
            loggers.entry = prefix
            isEntry = true
        end

        if _G.print and not _PLUGIN then
            if os and os.getenv and os.getenv ('ENABLE_LOGGING') then
                logger = function (...)
                    print ('<', prefix, '>: ', ...)
                end
            end
        elseif _PLUGIN and _PLUGIN.path then
            local suffix = getLogSuffix ()
            if suffix then
                local pu = import 'LrPathUtils'
                local fu = import 'LrFileUtils'

                local logDir = pu.child (_PLUGIN.path, "log")
                if not fu.exists (logDir) then
                    fu.createDirectory (logDir)
                end

                local logPath = pu.addExtension (pu.child (logDir, loggers.entry .. "_" .. suffix), "txt")
                logger = function (...)
                    writeLog (logPath, prefix, ...)
                end
            end
        end

        loggers[prefix] = logger
    end

    return logger, isEntry
end

local function startLog (prefix)
    local log, entry = getLogger (prefix)
    if entry then
        log ("================== <BEGIN> ==================")
    end
    return log
end

return startLog
