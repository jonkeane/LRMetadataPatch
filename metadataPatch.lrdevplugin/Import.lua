local LrFunctionContext = import 'LrFunctionContext'
local LrDialogs = import 'LrDialogs'
local LrView = import 'LrView'
local LrColor = import 'LrColor'
local LrApplication = import 'LrApplication'
local LrPathUtils = import 'LrPathUtils'
local LrSystemInfo = import 'LrSystemInfo'
local LrHttp = import 'LrHttp'
local LrBinding = import 'LrBinding'

local log = require 'Logger' ("import")
require 'Use'

local AnalogMetadata = use 'analog.AnalogMetadata'
local FilmRoll = use 'analog.FilmRoll'
local FilmFramesImportDialog = use 'analog.FilmFramesImportDialog'
local UpdateChecker = use 'analog.UpdateChecker'
local MetadataBindingTable = use 'analog.MetadataBindingTable'

local function showAnalogImportDialog (roll, bindings, updateInfo)  
    log ("showAnalogImportDialog")
    
    local f = LrView.osFactory()
    local width, height = LrSystemInfo.appWindowSize()

    log ("Window size ", width, "x", height)

    local content = FilmFramesImportDialog.build {
        LrView = LrView,
        LrHttp = LrHttp,
        LrColor = LrColor,

        size = {width = width, height=height},
        updateInfo = updateInfo,
        
        roll = roll,
        bindings = bindings
    }

    log ("Content ready")

    return LrDialogs.presentModalDialog {
        title = "Import Film Shots Data",
        contents = content,
        resizable = false
    }
end

local function main (context)
    log ("main")

    local catalog = LrApplication.activeCatalog ()

    local updateInfo = UpdateChecker.check (LrHttp, nil)
    log ("updateInfo: ", updateInfo)
    
    local roll, jsonPath, folder, tempDir = FilmRoll.fromCatalog (LrPathUtils, catalog)    
    log ("roll: ", roll, ": ", jsonPath)

    if roll == nil and jsonPath then
        LrDialogs.message ("Couldn't load Film Shots JSON file\n"  .. jsonPath)
        FilmRoll.cleanupTempDir(tempDir)
        return
    elseif roll == nil and jsonPath == nil then
        LrDialogs.message ("Please select a folder first")
        FilmRoll.cleanupTempDir(tempDir)
        return
    end

    local bindings = MetadataBindingTable.make (context, LrBinding, folder)    
    local result = showAnalogImportDialog (roll, bindings, updateInfo)
    
    if result == "ok" then
        log ("apply")
        catalog:withPrivateWriteAccessDo (function (context)            
            MetadataBindingTable.apply (roll, bindings)
        end)
        log ("apply: OK")
    end

    -- Clean up temp directory after dialog closes
    FilmRoll.cleanupTempDir(tempDir)

    log ("DONE")
end

LrFunctionContext.postAsyncTaskWithContext ("showAnalogImportDialog", function (context)
    main (context)
end)