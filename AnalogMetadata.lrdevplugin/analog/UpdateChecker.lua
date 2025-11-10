require 'Use'

local VersionUtils = use 'analog.VersionUtils'
local PluginInfo = use 'Info'

-- TODO: change to github
local VERSION_URL = "https://raw.githubusercontent.com/jonkeane/AnalogMetadata/refs/heads/main/AnalogMetadata.lrdevplugin/Info.lua"
local DOWNLOAD_URL = "https://github.com/jonkeane/AnalogMetadata/releases"

local function loadstring (str)
    if _G.loadstring then
        return _G.loadstring (str)
    end
    return load (str)
end

local function check (LrHttp, INFO)
    local result, headers = LrHttp.get (VERSION_URL, nil, 1)

    if INFO == nil then
        INFO = PluginInfo
    end

    if result and string.find (result, "<Error>") == nil then
        local chunk, error = loadstring (result)

        if chunk then
            local NEW_INFO = chunk ()
            if NEW_INFO and VersionUtils.newer (INFO.VERSION, NEW_INFO.VERSION)
            then
                return {
                    newVersion = string.format ("%d.%d.%d.%d", 
                                NEW_INFO.VERSION.major or 0,
                                NEW_INFO.VERSION.minor or 0,
                                NEW_INFO.VERSION.revision or 0,
                                NEW_INFO.VERSION.build or 0
                            ),
                    downloadUrl = DOWNLOAD_URL
                }
            end
        else
            --print (error)
        end
    end

    return nil
end


return {
    check = check
}