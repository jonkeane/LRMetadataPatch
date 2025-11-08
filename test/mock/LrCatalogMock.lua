local LrCatalogMock = {
}

function LrCatalogMock:getActiveSources ()
    return self.activeSources
end

function LrCatalogMock:type()
    return 'LrCatalog'
end

function LrCatalogMock:make (activeSources) 
    local catalog = {}
    setmetatable (catalog, self)
    self.__index = self

    self.activeSources = activeSources
      
    return catalog
end

return {
    make = function (activeSources)
        return LrCatalogMock:make (activeSources)
    end
}