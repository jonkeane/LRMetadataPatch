
local function child (path, name)
    return path .. "/" .. name
end

local function addExtension (path, ext)
    return path .. "." .. ext
end

return {
    -- Return a pseudo-standard temp directory used in tests
    getStandardFilePath = function(kind)
        if kind == 'temp' then
            return 'test/tmp'
        end
        return 'test/tmp'
    end,
    child = child,
    addExtension = addExtension
}