local lu = require "luaunit"

require 'Logger' ("TestFilmRoll")

local FilmRoll = require "analog.FilmRoll"

local LrFolderMock = require "mock.LrFolderMock"
local LrCatalogMock = require "mock.LrCatalogMock"
local LrPathUtilsMock = require "mock.LrPathUtilsMock"

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

function testReadFile()
    local roll = FilmRoll.fromFile("test/data/test-album/test-album.json")
    local expected = {
        boxIsoSpeed = 100,
        cameraName = "Rolleiflex T",
        defaultAperture = 8,
        defaultFocalLength = 75,
        defaultLensName = "Tessar 75mm F3.5",
        defaultShutterSpeed = "1/125",
        emulsionName = "Fujifilm Acros",
        formatName = "120/6x6",
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
                locality = "Mickleham",
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
                locality = "Mickleham",
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
                locality = "Mickleham",
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
                locality = "Mickleham",
                longitude = 0.22222,
                ratedIsoSpeed = 100,
                shutterSpeed = "1/60"
            }
        },
        mode = "R",
        name = "Box Hill",
        ratedIsoSpeed = 100,
        status = "P",
        timestamp = 1589026694008,
        uuid = "581c0629-3810-464d-9382-7f095f2e9e2d"
    }

    lu.assertEquals(roll, expected)
end

function testReadFile_Bad()
    local roll = FilmRoll.fromFile("test/data/dasdasdas.json")
    lu.assertNil(roll)
end

function testFromLrFolder_Nil()
   local roll, error = FilmRoll.fromLrFolder({}, nil)
       
   lu.assertNil (roll)
   lu.assertEquals (error, "<no path>")
end

function testFromLrFolder_Bad()
    local roll, error = FilmRoll.fromLrFolder({}, {})
       
    lu.assertNil (roll)
    lu.assertEquals (error, "<no path>")
end

function testFromLrFolder_Basic_BadPath ()
    local folder = LrFolderMock.make ("test-album1", "test/data/test-album1", {})
    local roll, path = FilmRoll.fromLrFolder(LrPathUtilsMock, folder)

    lu.assertEquals (path, "test/data/test-album1/test-album1.json")
    lu.assertNil (roll)
end

function testFromLrFolder_Basic ()
    local folder = LrFolderMock.make ("test-album", "test/data/test-album", {})
    local roll, path = FilmRoll.fromLrFolder(LrPathUtilsMock, folder)

    lu.assertEquals (path, "test/data/test-album/test-album.json")

    local expected = {
        boxIsoSpeed = 100,
        cameraName = "Rolleiflex T",
        defaultAperture = 8,
        defaultFocalLength = 75,
        defaultLensName = "Tessar 75mm F3.5",
        defaultShutterSpeed = "1/125",
        emulsionName = "Fujifilm Acros",
        formatName = "120/6x6",
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
                locality = "Mickleham",
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
                locality = "Mickleham",
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
                locality = "Mickleham",
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
                locality = "Mickleham",
                longitude = 0.22222,
                ratedIsoSpeed = 100,
                shutterSpeed = "1/60"
            }
        },
        mode = "R",
        name = "Box Hill",
        ratedIsoSpeed = 100,
        status = "P",
        timestamp = 1589026694008,
        uuid = "581c0629-3810-464d-9382-7f095f2e9e2d"
    }

    lu.assertEquals(roll, expected)
end

function testFromCatalog_Nil()
    local roll, error, folder = FilmRoll.fromCatalog({}, nil)
       
    lu.assertNil (roll)
    lu.assertNil (error)
    lu.assertNil (folder)
 end
 
 function testFromCatalog_Bad()
     local roll, error, folder = FilmRoll.fromCatalog({}, {})
        
     lu.assertNil (roll)
     lu.assertNil (error)
     lu.assertNil (folder)
end

function testFromCatalog_NoSources ()
    local catalog = LrCatalogMock.make ({})
    local roll, error, folder1 = FilmRoll.fromCatalog(LrPathUtilsMock, catalog)
    
    lu.assertNil (roll)
    lu.assertNil (error)
    lu.assertNil (folder)
end

function testFromCatalog_Basic ()
    local folder = LrFolderMock.make ("test-album", "test/data/test-album", {})
    local catalog = LrCatalogMock.make ({folder})
    local roll, path, folder1 = FilmRoll.fromCatalog(LrPathUtilsMock, catalog)

    lu.assertEquals (path, "test/data/test-album/test-album.json")
    lu.assertEquals (folder, folder1)

    local expected = {
        boxIsoSpeed = 100,
        cameraName = "Rolleiflex T",
        defaultAperture = 8,
        defaultFocalLength = 75,
        defaultLensName = "Tessar 75mm F3.5",
        defaultShutterSpeed = "1/125",
        emulsionName = "Fujifilm Acros",
        formatName = "120/6x6",
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
                locality = "Mickleham",
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
                locality = "Mickleham",
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
                locality = "Mickleham",
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
                locality = "Mickleham",
                longitude = 0.22222,
                ratedIsoSpeed = 100,
                shutterSpeed = "1/60"
            }
        },
        mode = "R",
        name = "Box Hill",
        ratedIsoSpeed = 100,
        status = "P",
        timestamp = 1589026694008,
        uuid = "581c0629-3810-464d-9382-7f095f2e9e2d"
    }

    lu.assertEquals(roll, expected)

end



os.exit(lu.LuaUnit.run())
