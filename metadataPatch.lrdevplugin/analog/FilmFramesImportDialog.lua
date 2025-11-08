require 'Use'

local LightroomMetadata = use 'analog.LightroomMetadata'
local FrameDesignator = use 'analog.FrameDesignator'

local function makeFrameMenuItems (roll)
    local items = {}

    if roll.frameCount > 0 then
        for index = 1,roll.frameCount do 
            local frame = roll.frames[index]
            if frame then      
                local title = string.format ("%s - %s (%s sec @ %.1f)",
                        FrameDesignator.make (frame.frameIndex, roll.mode),
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

    local f = LrView.osFactory()  

    local update_snack = f:static_text {
        title = ""
    }

    if updateInfo then
        update_snack = f:row {
            f:static_text {
                title = "Film Shots Plugin update is available: " .. updateInfo.newVersion,
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

    return f:column {
        spacing = f:dialog_spacing(),
        update_snack,
        f:static_text {
            title = "Pick a Film Shots frame for each Photo"
        },
        f:scrolled_view {
            height = size.height * 0.75,
            f:column (
                ForEach (bindings, {
                        margin = 16,
                        spacing = f:dialog_spacing(),
                    },  
                    function (pair)
                        return f:column {
                            spacing = 0,
                            f:catalog_photo {
                                photo = pair.photo,
                                width = 256,
                                height = 256,
                            },
                            f:static_text {
                                title = LightroomMetadata.make (pair.photo):fileName ()
                            },
                            f:row {
                                f:static_text {
                                    title = "Film frame: "
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