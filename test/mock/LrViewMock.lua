local FactoryMock = require 'mock.LrViewFactoryMock' 

local LrViewMock = {
    osFactory = function ()
        return FactoryMock
    end,

    bind = function (key)
        -- Create a shallow copy of key, excluding function values
        local filteredKey = {}
        for k, v in pairs(key) do
            if type(v) ~= 'function' then
                filteredKey[k] = v
            end
        end
        
        return {
            type = 'binding',
            key = filteredKey
        }
    end
}

return LrViewMock