local FactoryMock = require 'mock.LrViewFactoryMock' 

local LrViewMock = {
    osFactory = function ()
        return FactoryMock
    end,

    bind = function (key)
        return {
            type = 'binding',
            key = key
        }
    end
}

return LrViewMock