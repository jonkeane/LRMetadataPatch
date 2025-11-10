require 'Use'

local LightroomMetadata = use 'analog.LightroomMetadata'

local function makeFrameMenuItems (roll)
    local items = {}

    if roll.frameCount > 0 then
        for index = 1,roll.frameCount do 
            local frame = roll.frames[index]
            if frame then      
                local title = string.format ("%s - %s (%s sec @ %.1f)",
                        frame.frameIndex,
                        frame.locality or "",
                        frame.shutterSpeed or "0/0",
                        frame.aperture or 0.0
                    )

                table.insert (items, {
                    title = title,
                    value = frame.frameIndex
                })        
            end
        end
    end

    return items
end

local function ForEach (array, initial, func)
    local result = initial
    for _, item in ipairs (array) do
        table.insert (result, func (item))
    end
    return result
end

local function build (args)
    local LrView = args.LrView
    local LrColor = args.LrColor
    local LrHttp = args.LrHttp

    local size = args.size    
    local updateInfo = args.updateInfo

    local roll = args.roll
    local bindings = args.bindings

    -- Pre-compute filenames for each binding
    local filenameCache = {}
    for i, binding in ipairs(bindings) do
        local filename = LightroomMetadata.make(binding.photo):fileName()
        filenameCache[binding] = filename
    end
    -- Sort bindings in place by pre-computed filename
    table.sort(bindings, function(a, b)
        local aName = filenameCache[a]
        local bName = filenameCache[b]
        return aName < bName
    end)
    
    local f = LrView.osFactory()    local update_snack = f:static_text {
        title = ""
    }

    if updateInfo then
        update_snack = f:row {
            f:static_text {
                title = "Analog Metadata Plugin update is available: " .. updateInfo.newVersion,
                text_color = LrColor ("red"),
                font = "<system/bold>",
            },
            f:push_button {
                title = "Download",
                font = "<system/bold>",
                action = function ()
                    LrHttp.openUrlInBrowser (updateInfo.downloadUrl)
                end
            }
        }
    end

    local filmFrameItems = makeFrameMenuItems (roll)

    -- Pre-populate each binding's filmFrameIndex with the corresponding frame index (right before UI is built)
    if roll.frames then
        for i, pair in ipairs(bindings) do
            -- Only set default if not already set
            if not pair.binding.filmFrameIndex then
                local frame = roll.frames[i]
                if frame and frame.frameIndex then
                    pair.binding.filmFrameIndex = frame.frameIndex
                end
            end
        end
    end

    return f:column {
        spacing = f:dialog_spacing(),
        update_snack,
        f:static_text {
            title = "Match Lightroom photos to reference images from metadata",
        },
        f:row {
            spacing = 16,
            f:column {
                width = 256,
                f:static_text {
                    title = "Scan from Lightroom",
                    font = "<system/bold>",
                }
            },
            f:column {
                f:static_text {
                    title = "Reference from Crown & Flint",
                    font = "<system/bold>",
                }
            }
        },
        f:scrolled_view {
            height = size.height * 0.75,
            width = 256 * 2.25,
                f:column (
                    ForEach (bindings, {
                            margin = 16,
                            spacing = f:dialog_spacing(),
                        },  
                        function (pair)
                            return f:row {
                                spacing = 16,
                                f:column {
                                    spacing = 0,
                                    f:catalog_photo {
                                        photo = pair.photo,
                                        width = 256,
                                        height = 256,
                                    },
                                    f:static_text {
                                        title = LightroomMetadata.make (pair.photo):fileName ()
                                    }
                                },
                                f:column {
                                    spacing = f:dialog_spacing(),
                                    f:picture {
                                        value = LrView.bind {
                                            key = 'filmFrameIndex',
                                            bind_to_object = pair.binding,
                                            transform = function (value, fromTable)
                                                if value and roll.frames[value] then
                                                    return roll.frames[value].referenceImagePath
                                                end
                                                return nil
                                            end
                                        },
                                        width = 256,
                                        height = 256,
                                    },
                                    f:popup_menu {
                                        value = LrView.bind {
                                            key = 'filmFrameIndex',
                                            bind_to_object = pair.binding,
                                        },
                                        items = filmFrameItems
                                    }
                                }
                            }
                        end
                    )
                )
        }
    }
end

return {
    build = build
}