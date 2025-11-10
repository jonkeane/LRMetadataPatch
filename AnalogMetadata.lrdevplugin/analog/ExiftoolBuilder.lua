local log = require 'Logger' ("ExiftoolBuilder")

local ExiftoolBuilder = {

}

function ExiftoolBuilder:buildCommand (photoPath, meta)
    local empty = true
    local command = self.exiftoolPath

    log ('Exiftool: Mapping: ', #self.metadataMap)

    for _, pair in ipairs (self.metadataMap) do
        log ("Pair: ", pair)
        if pair.key and pair.val then
            local getter = meta[pair.val]
            if getter then
                local val = getter (meta)
                if val then
                    log ('Val: ', val)
                    command = command .. " " .. string.format ("-%s=\"%s\"", pair.key, val)
                    empty = false
                end
            end
        end
    end

    if empty then
        return nil
    end

    command = command .. " -overwrite_original " .. "\"" .. photoPath .. "\""

    if WIN_ENV then
        command = "\"" .. command .. "\""
    end

    log (command)

    return command
end

function ExiftoolBuilder:make (metadataMap)
    local builder = {}
    setmetatable (builder, self)
    self.__index = self

    if MAC_ENV then
        builder.exiftoolPath = string.format ("\"%s/%s\"", _PLUGIN.path, "exiftool/macos/exiftool")
    elseif WIN_ENV then
        builder.exiftoolPath = string.format ("\"%s\\%s\"", _PLUGIN.path, "exiftool\\windows\\exiftool.exe")
    else
        builder.exiftoolPath = "exiftool"
    end

    log ('Exiftool: path: ', builder.exiftoolPath)

    builder.metadataMap = metadataMap
    return builder
end

return {
    make = function (metadataMap)
        return ExiftoolBuilder:make (metadataMap)
    end
}