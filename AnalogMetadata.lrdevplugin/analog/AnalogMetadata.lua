local log = require 'Logger' ("AnalogMetadata")

local Metadata = {
}

local function toExifDate (iso8601)
    if iso8601 then
        local t = {
            ["T"] = '',
            ["-"] = ':'
        }
        return string.gsub (iso8601, '[T,-]', t)
    end

    return nil
end

local function nillOrString (value)
    if value then
        return tostring (value)
    end
    return nil
end


local function setValue (photo, key, value)
    log (photo.localIdentifier, 'set:', key, '=', value)
    if photo["setPropertyForPlugin"] then
        photo:setPropertyForPlugin (_PLUGIN, key, nillOrString (value))
    else
        photo[key] = nillOrString (value)
    end
end

local function getValue (photo, key)
    local value = nil
    if photo["getPropertyForPlugin"] then
        value = photo:getPropertyForPlugin (_PLUGIN, key)
    else
        value = photo[key]
    end

    log (photo.localIdentifier, 'get:', key, '=', value)

    return value
end

function Metadata:Frame_Index ()
    return tonumber (getValue (self.photo, "Frame_Index"))
end
function Metadata:setFrame_Index (value)
    setValue (self.photo, "Frame_Index", value)
end

function Metadata:Roll_UID ()
    return getValue (self.photo, "Roll_UID")
end
function Metadata:setRoll_UID (value)
    setValue (self.photo, "Roll_UID", value)
end

function Metadata:Roll_Name ()
    return getValue (self.photo, "Roll_Name")
end
function Metadata:setRoll_Name (value)
    setValue (self.photo, "Roll_Name", value)
end

function Metadata:Roll_Status ()
    return getValue (self.photo, "Roll_Status")
end
function Metadata:setRoll_Status (value)
    setValue (self.photo, "Roll_Status", value)
end

function Metadata:Roll_Comment ()
    return getValue (self.photo, "Roll_Comment")
end
function Metadata:setRoll_Comment (value)
    setValue (self.photo, "Roll_Comment", value)
end

function Metadata:Roll_Thumbnail ()
    return getValue (self.photo, "Roll_Thumbnail")
end
function Metadata:setRoll_Thumbnail (value)
    setValue (self.photo, "Roll_Thumbnail", value)
end

function Metadata:Roll_CreationTimeUnix ()
    return getValue (self.photo, "Roll_CreationTimeUnix")
end
function Metadata:setRoll_CreationTimeUnix (value)
    setValue (self.photo, "Roll_CreationTimeUnix", value)
end

function Metadata:Roll_CameraName ()
    return getValue (self.photo, "Roll_CameraName")
end
function Metadata:setRoll_CameraName (value)
    setValue (self.photo, "Roll_CameraName", value)
end

function Metadata:Roll_FormatName ()
    return getValue (self.photo, "Roll_FormatName")
end
function Metadata:setRoll_FormatName (value)
    setValue (self.photo, "Roll_FormatName", value)
end

function Metadata:Frame_LocalTimeIso8601 ()
    return getValue (self.photo, "Frame_LocalTimeIso8601")
end
function Metadata:setFrame_LocalTimeIso8601 (value)
    setValue (self.photo, "Frame_LocalTimeIso8601", value)
end

function Metadata:Frame_LocalTime ()
    return toExifDate (self:Frame_LocalTimeIso8601())
end

function Metadata:Frame_Thumbnail ()
    return getValue (self.photo, "Frame_Thumbnail")
end
function Metadata:setFrame_Thumbnail (value)
    setValue (self.photo, "Frame_Thumbnail", value)
end

function Metadata:Frame_Latitude ()
    return getValue (self.photo, "Frame_Latitude")
end
function Metadata:Frame_LatitudeRef ()
    local latitude = tonumber (self:Frame_Latitude ())

    if latitude == nil then
        return nil
    elseif latitude < 0 then
        return "S"
    else
        return "N"
    end
end
function Metadata:setFrame_Latitude (value)
    setValue (self.photo, "Frame_Latitude", value)
end

function Metadata:Frame_Longitude ()
    return getValue (self.photo, "Frame_Longitude")
end
function Metadata:Frame_LongitudeRef ()
    local longitude = tonumber (self:Frame_Longitude ())

    if longitude == nil then
        return nil
    elseif longitude < 0 then
        return "W"
    else
        return "E"
    end
end
function Metadata:setFrame_Longitude (value)
    setValue (self.photo, "Frame_Longitude", value)
end

function Metadata:Frame_Locality ()
    return getValue (self.photo, "Frame_Locality")
end
function Metadata:setFrame_Locality (value)
    setValue (self.photo, "Frame_Locality", value)
end

function Metadata:Frame_Comment ()
    return getValue (self.photo, "Frame_Comment")
end
function Metadata:setFrame_Comment (value)
    setValue (self.photo, "Frame_Comment", value)
end

function Metadata:Frame_EmulsionName ()
    return getValue (self.photo, "Frame_EmulsionName")
end
function Metadata:setFrame_EmulsionName (value)
    setValue (self.photo, "Frame_EmulsionName", value)
end

function Metadata:Frame_BoxISO ()
    return getValue (self.photo, "Frame_BoxISO")
end
function Metadata:setFrame_BoxISO (value)
    setValue (self.photo, "Frame_BoxISO", value)
end

function Metadata:Frame_RatedISO ()
    return getValue (self.photo, "Frame_RatedISO")
end
function Metadata:setFrame_RatedISO (value)
    setValue (self.photo, "Frame_RatedISO", value)
end

function Metadata:Frame_EffectiveISO ()
    if self:Frame_RatedISO() then
        return self:Frame_RatedISO()
    end

    return self:Frame_BoxISO ()
end

function Metadata:Frame_LensName ()
    return getValue (self.photo, "Frame_LensName")
end
function Metadata:setFrame_LensName (value)
    setValue (self.photo, "Frame_LensName", value)
end

function Metadata:Frame_FocalLength ()
    return getValue (self.photo, "Frame_FocalLength")
end
function Metadata:setFrame_FocalLength (value)
    setValue (self.photo, "Frame_FocalLength", value)
end

function Metadata:Frame_FStop ()
    return getValue (self.photo, "Frame_FStop")
end
function Metadata:setFrame_FStop (value)
    setValue (self.photo, "Frame_FStop", value)
end

function Metadata:Frame_Shutter ()
    return getValue (self.photo, "Frame_Shutter")
end
function Metadata:setFrame_Shutter (value)
    setValue (self.photo, "Frame_Shutter", value)
end


function Metadata:make (photo)
    local metadata = {}
    setmetatable (metadata, self)
    self.__index = self

    metadata.photo = photo

    log ("make OK")

    return metadata
end

return {
    make = function (photo)
        return Metadata:make (photo)
    end
}