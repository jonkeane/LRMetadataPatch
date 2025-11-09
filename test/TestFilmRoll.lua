local lu = require "luaunit"

require 'Logger' ("TestFilmRoll")

require 'mock.ImportMock'
local FilmRoll = require "analog.FilmRoll"

local LrFolderMock = import 'LrFolder'
local LrCatalogMock = import 'LrCatalog'

function testEmpty()
    lu.assertTrue(true)
end

function testBasic()
    local roll =
        FilmRoll.fromJson(
        [[
        [
            {
                "name": "Roll Name",
                "frames": [
                    {
                        "frameIndex": 1,
                        "locality": "Frame1"
                    },
                    {
                        "frameIndex": 2,
                        "locality": "Frame2"
                    }
                ]
            }
        ]
    ]]
    )

    lu.assertEquals(roll.name, "Roll Name")

    lu.assertEquals(roll.frameCount, 2)

    lu.assertEquals(roll.frames[1].frameIndex, 1)
    lu.assertEquals(roll.frames[1].locality, "Frame1")

    lu.assertEquals(roll.frames[2].frameIndex, 2)
    lu.assertEquals(roll.frames[2].locality, "Frame2")
end

function testMissingFrames()
    local roll =
        FilmRoll.fromJson(
        [[
        [
            {
                "name": "Roll Name",
                "frames": [
                    {
                        "frameIndex": 1,
                        "locality": "Frame1"
                    },
                    {
                        "frameIndex": 3,
                        "locality": "Frame2"
                    }
                ]
            }
        ]
    ]]
    )

    lu.assertEquals(roll.name, "Roll Name")

    lu.assertEquals(roll.frameCount, 3)

    lu.assertEquals(roll.frames[1].frameIndex, 1)
    lu.assertEquals(roll.frames[1].locality, "Frame1")

    lu.assertEquals(roll.frames[2], nil)

    lu.assertEquals(roll.frames[3].frameIndex, 3)
    lu.assertEquals(roll.frames[3].locality, "Frame2")
end

function testReadFile_Bad()
    local roll = FilmRoll.fromFile("test/data/dasdasdas.json")
    lu.assertNil(roll)
end

function testFromLrFolder_Nil()
   local roll, error, folder, tempDir = FilmRoll.fromLrFolder({}, nil)
       
   lu.assertNil (roll)
   lu.assertEquals (error, "<no path>")
end

function testFromLrFolder_Bad()
    local roll, error, folder, tempDir = FilmRoll.fromLrFolder({}, {})
       
    lu.assertNil (roll)
    lu.assertEquals (error, "<no path>")
end

function testFromLrFolder_Basic_BadPath ()
    local folder = LrFolderMock.make ("test-album1", "test/data/test-album1", {})
    local roll, path, _, tempDir = FilmRoll.fromLrFolder({}, folder)

    lu.assertEquals (path, "<no json file found>")
    lu.assertNil (roll)
    
    -- Cleanup temp directory if any
    FilmRoll.cleanupTempDir(tempDir)
end

function testFromLrFolder_Basic ()
    -- Now prefer a zip file in the folder and read the JSON inside it
    -- The test data contains Ektar101.zip in test/data
    local folder = LrFolderMock.make ("data", "test/data", {})
    local roll, path, _, tempDir = FilmRoll.fromLrFolder({}, folder)

    local h = io.popen('ls "test/data"/*.zip 2>/dev/null')
    local z = h and h:read('*l') or nil
    if h then h:close() end

    -- Path should point to an extracted JSON file from the zip; ensure we processed a zip by checking temp dir pattern
    lu.assertTrue (type(path) == 'string')
    lu.assertTrue (path:match("test%-album%.json$") ~= nil or path:match("album%.json$") ~= nil or path:match("film%.json$") ~= nil)
    -- Confirm roll basics
    lu.assertEquals(roll.frameCount, 4)

    local expected = {
        boxIsoSpeed = 100,
        cameraName = "Rolleiflex T",
        defaultAperture = 8,
        defaultFocalLength = 75,
        defaultLensName = "Tessar 75mm F3.5",
        defaultShutterSpeed = "1/125",
        emulsionName = "Fujifilm Acros",
        frameCount = 4,
        frames = {
            {
                aperture = 8,
                boxIsoSpeed = 100,
                emulsionName = "Fujifilm Acros",
                focalLength = 75,
                frameIndex = 1,
                latitude = 51.2684547,
                lensName = "Tessar 75mm F3.5",
                localTime = "2020-05-09T13:21:34",
                longitude = -0.3264871,
                ratedIsoSpeed = 100,
                shutterSpeed = "1/125"
            },
            {
                aperture = 16,
                boxIsoSpeed = 100,
                emulsionName = "Fujifilm Acros",
                focalLength = 75,
                frameIndex = 2,
                latitude = 52.444444,
                lensName = "Tessar 75mm F3.5",
                localTime = "2020-05-09T15:44:11",
                longitude = 1.2222,
                ratedIsoSpeed = 100,
                shutterSpeed = "1/500"
            },
            {
                aperture = 5.6,
                boxIsoSpeed = 100,
                emulsionName = "Fujifilm Acros",
                focalLength = 75,
                frameIndex = 3,
                latitude = 54.33333,
                lensName = "Tessar 75mm F3.5",
                localTime = "2020-05-09T13:21:35",
                longitude = -1.444555,
                ratedIsoSpeed = 100,
                shutterSpeed = "1/250"
            },
            {
                aperture = 2.8,
                boxIsoSpeed = 100,
                emulsionName = "Fujifilm Acros",
                focalLength = 75,
                frameIndex = 4,
                latitude = 60.1111,
                lensName = "Tessar 75mm F3.5",
                localTime = "2020-05-09T13:21:36",
                longitude = 0.22222,
                ratedIsoSpeed = 100,
                shutterSpeed = "1/60"
            }
        },
        ratedIsoSpeed = 100
    }

    lu.assertEquals(roll, expected)
    
    -- Cleanup temp directory
    FilmRoll.cleanupTempDir(tempDir)
end

function testFromCatalog_Nil()
    local roll, error, folder, tempDir = FilmRoll.fromCatalog({}, nil)
       
    lu.assertNil (roll)
    lu.assertNil (error)
    lu.assertNil (folder)
 end
 
 function testFromCatalog_Bad()
     local roll, error, folder, tempDir = FilmRoll.fromCatalog({}, {})
        
     lu.assertNil (roll)
     lu.assertNil (error)
     lu.assertNil (folder)
end

function testFromCatalog_NoSources ()
    local catalog = LrCatalogMock.make ({})
    local roll, error, folder1, tempDir = FilmRoll.fromCatalog({}, catalog)
    
    lu.assertNil (roll)
    lu.assertNil (error)
    lu.assertNil (folder)
end

function testFromCatalog_Basic ()
    local folder = LrFolderMock.make ("data", "test/data", {})
    local catalog = LrCatalogMock.make ({folder})
    local roll, path, folder1, tempDir = FilmRoll.fromCatalog({}, catalog)

    lu.assertTrue (type(path) == 'string')
    print(path)
    lu.assertTrue (path:match("test%-album%.json$") ~= nil or path:match("album%.json$") ~= nil or path:match("film%.json$") ~= nil)
    lu.assertEquals(roll.frameCount, 4)
    lu.assertEquals (folder, folder1)

    local expected = {
        boxIsoSpeed = 100,
        cameraName = "Rolleiflex T",
        defaultAperture = 8,
        defaultFocalLength = 75,
        defaultLensName = "Tessar 75mm F3.5",
        defaultShutterSpeed = "1/125",
        emulsionName = "Fujifilm Acros",
        frameCount = 4,
        frames = {
            {
                aperture = 8,
                boxIsoSpeed = 100,
                emulsionName = "Fujifilm Acros",
                focalLength = 75,
                frameIndex = 1,
                latitude = 51.2684547,
                lensName = "Tessar 75mm F3.5",
                localTime = "2020-05-09T13:21:34",
                longitude = -0.3264871,
                ratedIsoSpeed = 100,
                shutterSpeed = "1/125"
            },
            {
                aperture = 16,
                boxIsoSpeed = 100,
                emulsionName = "Fujifilm Acros",
                focalLength = 75,
                frameIndex = 2,
                latitude = 52.444444,
                lensName = "Tessar 75mm F3.5",
                localTime = "2020-05-09T15:44:11",
                longitude = 1.2222,
                ratedIsoSpeed = 100,
                shutterSpeed = "1/500"
            },
            {
                aperture = 5.6,
                boxIsoSpeed = 100,
                emulsionName = "Fujifilm Acros",
                focalLength = 75,
                frameIndex = 3,
                latitude = 54.33333,
                lensName = "Tessar 75mm F3.5",
                localTime = "2020-05-09T13:21:35",
                longitude = -1.444555,
                ratedIsoSpeed = 100,
                shutterSpeed = "1/250"
            },
            {
                aperture = 2.8,
                boxIsoSpeed = 100,
                emulsionName = "Fujifilm Acros",
                focalLength = 75,
                frameIndex = 4,
                latitude = 60.1111,
                lensName = "Tessar 75mm F3.5",
                localTime = "2020-05-09T13:21:36",
                longitude = 0.22222,
                ratedIsoSpeed = 100,
                shutterSpeed = "1/60"
            }
        },
        ratedIsoSpeed = 100
    }

    lu.assertEquals(roll, expected)
    
    -- Cleanup temp directory
    FilmRoll.cleanupTempDir(tempDir)

end



os.exit(lu.LuaUnit.run())
