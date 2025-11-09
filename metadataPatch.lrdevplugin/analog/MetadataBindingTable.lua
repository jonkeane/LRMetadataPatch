local log = require 'Logger' ("MetadataBindingTable")

require 'Use'

local AnalogMetadata = use 'analog.AnalogMetadata'
local LightroomMetadata = use 'analog.LightroomMetadata'

local function saveMetadata (photo, rollData, frameData)
    local meta = AnalogMetadata.make (photo)

    meta:setRoll_UID (rollData.uuid)
    meta:setRoll_Name (rollData.name)
    meta:setRoll_Status (rollData.status)
    meta:setRoll_Comment (rollData.comment)
    meta:setRoll_Thumbnail (nil)
    meta:setRoll_CreationTimeUnix (rollData.timestamp)
    meta:setRoll_CameraName (rollData.cameraName)
    meta:setRoll_FormatName (rollData.formatName)

    meta:setFrame_Index (frameData.frameIndex)
    meta:setFrame_LocalTimeIso8601 (frameData.localTime)
    meta:setFrame_Thumbnail (nil)
    meta:setFrame_Latitude (frameData.latitude)
    meta:setFrame_Longitude (frameData.longitude)
    meta:setFrame_Locality (frameData.locality)
    meta:setFrame_Comment (frameData.comment)
    meta:setFrame_EmulsionName (frameData.emulsionName)
    meta:setFrame_BoxISO (frameData.boxIsoSpeed)
    meta:setFrame_RatedISO (frameData.ratedIsoSpeed)
    meta:setFrame_LensName (frameData.lensName)
    meta:setFrame_FocalLength (frameData.focalLength)
    meta:setFrame_FStop (frameData.aperture)
    meta:setFrame_Shutter (frameData.shutterSpeed)

end

local function make (context, LrBinding, folder)
    local bindings = {}

    for i, photo in ipairs (folder:getPhotos (false)) do 
        log ("Bind: ", photo.localIdentifier)
        local lrMeta = LightroomMetadata.make (photo)
        if lrMeta:stackPositionInFolder () == 1 then
            local pluginMeta = AnalogMetadata.make (photo)
            log ("pluginMeta: ", pluginMeta)

            local binding = LrBinding.makePropertyTable (context)
            log ("binding: ", binding)

            local frameIndex = pluginMeta:Frame_Index ()
            log ("frameIndex: ", binding)
            if frameIndex then
                binding.filmFrameIndex = frameIndex
            end

            table.insert (bindings, {
                photo = photo,
                binding = binding                
            })
        end
    end

    return bindings
end

local function apply (roll, bindings)
    if roll.frames then        
        for _, pair in ipairs (bindings) do                    
            if pair.binding.filmFrameIndex then 
                local frame = roll.frames[pair.binding.filmFrameIndex]
                if frame then
                    saveMetadata (pair.photo, roll, frame)
                end
            end
        end    
    end
end

return {
    make = make,
    apply = apply
}