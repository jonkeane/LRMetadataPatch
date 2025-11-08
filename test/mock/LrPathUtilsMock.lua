
local function child (path, name)
    return path .. "/" .. name
end

local function addExtension (path, ext)
    return path .. "." .. ext
end

return {
    child = child,
    addExtension = addExtension
}