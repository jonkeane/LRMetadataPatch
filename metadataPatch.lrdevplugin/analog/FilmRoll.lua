local log = require 'Logger' ("FilmRoll")

require 'Use'

local json = use 'lib.dkjson'

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

local function fromJson (jsonString)
    log ("fromJson: ", jsonString:len())
    if jsonString then
        local filmShotsMetadata, pos, error = json.decode (jsonString)

        if filmShotsMetadata and #filmShotsMetadata == 1 then
            local filmFrames = {}
            local maxIndex = 0

            log ("Frames: ", #filmShotsMetadata[1].frames)

            for _, frame in ipairs (filmShotsMetadata[1].frames) do
                log ("Frame: ", frame.frameIndex)
                filmFrames[frame.frameIndex] = frame

                if frame.frameIndex > maxIndex then
                    maxIndex = frame.frameIndex
                end
            end

            log ("Frames: ", maxIndex)

            filmShotsMetadata[1].frameCount = maxIndex
            filmShotsMetadata[1].frames = filmFrames
            return filmShotsMetadata[1]
        else
            log ("JSON Error: ", pos, error)
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

local function fromFile (path)
    log ("JSON: ", path)

    local jsonString = readFile (path)

    if jsonString then
        return fromJson (jsonString)
    end

    log ("JSON: missing")

    return nil
end

local function fromLrFolder (LrPathUtils, folder)
    if folder and folder.getPath and folder.getName then
        local jsonPath = LrPathUtils.addExtension (LrPathUtils.child (folder:getPath(), folder:getName()), "json")
        return fromFile (jsonPath), jsonPath, folder
    end
    return nil, "<no path>", folder
end

local function fromCatalog (LrPathUtils, catalog)
    if catalog then
        local folder = getCurrentFolder (catalog)

        if not folder then 
            log ("Current folder nil")
            return nil
        end

        log ("Current folder: ", folder:getPath())
        return fromLrFolder (LrPathUtils, folder)
    end

    return nil
end

return {
    Mode = {
        ROLL = 'R',
        SET = 'HS'
    },

    fromJson = fromJson,
    fromFile = fromFile,
    fromLrFolder = fromLrFolder,
    fromCatalog = fromCatalog
}