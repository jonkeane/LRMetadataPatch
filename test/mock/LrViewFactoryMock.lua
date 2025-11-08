local FactoryMock = {
    dialog_spacing = function (self)        
        return 0
    end,

    control_spacing = function (self)        
        return 0
    end,

    static_text = function (self, args)
        return {
            type = 'static_text',
            args = args
        }
    end,

    push_button = function (self, args) 
        return {
            type = 'push_button',
            args = args
        }
    end,

    scrolled_view = function (self, args) 
        return {
            type = 'scrolled_view',
            args = args
        }
    end,

    column = function (self, args) 
        return {
            type = 'column',
            args = args
        }
    end,

    row = function (self, args) 
        return {
            type = 'row',
            args = args
        }
    end,

    catalog_photo = function (self, args) 
        return {
            type = 'catalog_photo',
            args = args
        }
    end,

    popup_menu = function (self, args) 
        return {
            type = 'popup_menu',
            args = args
        }
    end,
}

return FactoryMock