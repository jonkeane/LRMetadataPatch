local lu = require 'luaunit'
require 'mock.ImportMock'
local MetadataBindingTable = require 'analog.MetadataBindingTable'
local FilmRoll = require 'analog.FilmRoll'

local LrFolderMock = require 'mock.LrFolderMock'

function testEmpty()
    lu.assertTrue(true)
end

local LrBindingMock = {
    makePropertyTable = function (context)
        return {
            type = 'binding',
            context = context
        }
    end
}

-- Helper: unzip fixture and return roll built from frames-only JSON inside zip
local function unzipFixtureRoll(zipPath)
    local tempDir = FilmRoll.unzipToTemp(zipPath)
    if not tempDir then return nil, nil end
    local jsonPath = FilmRoll.findFirstJson(tempDir)
    if not jsonPath then return nil, tempDir end

    return FilmRoll.fromFile(jsonPath), tempDir
end

function testBasic ()
    local context = {
        type = "context"
    }

    local folder = LrFolderMock:make ()
    folder.photos = {
        {
            fileName = 'file1.jpeg',
            stackPositionInFolder = 1,
        },

        {
            fileName = 'file2.jpeg',
            stackPositionInFolder = 1,
        },

        {
            fileName = 'file3.jpeg',
            stackPositionInFolder = 1,
        },
    }

    local bindingTable = MetadataBindingTable.make (context, LrBindingMock, folder)

    lu.assertEquals (bindingTable, {
            {
                photo = {
                    fileName = 'file1.jpeg',
                    stackPositionInFolder = 1,
                },
                binding = {
                    type = 'binding',
                    context = {
                        type = 'context'
                    },
                    filmFrameIndex = nil
                }
            },

            {
                photo = {
                    fileName = 'file2.jpeg',
                    stackPositionInFolder = 1,
                },
                binding = {
                    type = 'binding',
                    context = {
                        type = 'context'
                    },
                    filmFrameIndex = nil
                }
            },

            {
                photo = {
                    fileName = 'file3.jpeg',
                    stackPositionInFolder = 1,
                },
                binding = {
                    type = 'binding',
                    context = {
                        type = 'context'
                    },
                    filmFrameIndex = nil
                }
            }
    })

end

function testSomeFramesAssigned ()
    local context = {
        type = "context"
    }

    local folder = LrFolderMock:make ()
    folder.photos = {
        {
            fileName = 'file1.jpeg',
            stackPositionInFolder = 1,
            Frame_Index = 2,
        },

        {
            fileName = 'file2.jpeg',
            stackPositionInFolder = 1,
        },

        {
            fileName = 'file3.jpeg',
            stackPositionInFolder = 1,
            Frame_Index = 4,
        },
    }

    local bindingTable = MetadataBindingTable.make (context, LrBindingMock, folder)

    lu.assertEquals (bindingTable, {
            {
                photo = {
                    fileName = 'file1.jpeg',
                    stackPositionInFolder = 1,
                    Frame_Index = 2,
                },
                binding = {
                    type = 'binding',
                    context = {
                        type = 'context'
                    },
                    filmFrameIndex = 2
                }
            },

            {
                photo = {
                    fileName = 'file2.jpeg',
                    stackPositionInFolder = 1,
                },
                binding = {
                    type = 'binding',
                    context = {
                        type = 'context'
                    },
                    filmFrameIndex = nil
                }
            },

            {
                photo = {
                    fileName = 'file3.jpeg',
                    stackPositionInFolder = 1,
                    Frame_Index = 4,
                },
                binding = {
                    type = 'binding',
                    context = {
                        type = 'context'
                    },
                    filmFrameIndex = 4
                }
            }
    })

end

function testSomeFramesAssigned_Stacked ()
    local context = {
        type = "context"
    }

    local folder = LrFolderMock:make ()
    folder.photos = {
        {
            fileName = 'file1.jpeg',
            stackPositionInFolder = 1,
            Frame_Index = 2,
        },

        {
            fileName = 'file2.jpeg',
            stackPositionInFolder = 1,
        },

        {
            fileName = 'file3.jpeg',
            stackPositionInFolder = 1,
            Frame_Index = 4,
        },

        {
            fileName = 'file4.jpeg',
            stackPositionInFolder = 2,
            Frame_Index = 5,
        },

        {
            fileName = 'file5.jpeg',
            stackPositionInFolder = 1,
            Frame_Index = 1,
        },
    }

    local bindingTable = MetadataBindingTable.make (context, LrBindingMock, folder)

    lu.assertEquals (bindingTable, {
            {
                photo = {
                    fileName = 'file1.jpeg',
                    stackPositionInFolder = 1,
                    Frame_Index = 2,
                },
                binding = {
                    type = 'binding',
                    context = {
                        type = 'context'
                    },
                    filmFrameIndex = 2
                }
            },

            {
                photo = {
                    fileName = 'file2.jpeg',
                    stackPositionInFolder = 1,
                },
                binding = {
                    type = 'binding',
                    context = {
                        type = 'context'
                    },
                    filmFrameIndex = nil
                }
            },

            {
                photo = {
                    fileName = 'file3.jpeg',
                    stackPositionInFolder = 1,
                    Frame_Index = 4,
                },
                binding = {
                    type = 'binding',
                    context = {
                        type = 'context'
                    },
                    filmFrameIndex = 4
                }
            },

            {
                photo = {
                    fileName = 'file5.jpeg',
                    stackPositionInFolder = 1,
                    Frame_Index = 1,
                },
                binding = {
                    type = 'binding',
                    context = {
                        type = 'context'
                    },
                    filmFrameIndex = 1
                }
            }
    })
end

function testApplyNilFrames ()
    local roll, tempDir = unzipFixtureRoll('test/data/Ektar101.zip')
    roll.frames = nil
    MetadataBindingTable.apply (roll, {})
    FilmRoll.cleanupTempDir(tempDir)
end

function testApplyEmptyBindings ()
    local roll, tempDir = unzipFixtureRoll('test/data/Ektar101.zip')
    
    MetadataBindingTable.apply (roll, {})
    FilmRoll.cleanupTempDir(tempDir)
end


function testApplyNoBindings ()
    local context = {
        type = "context"
    }

    local folder = LrFolderMock:make ()
    folder.photos = {
        {
            fileName = 'file1.jpeg',
            stackPositionInFolder = 1,
        },

        {
            fileName = 'file2.jpeg',
            stackPositionInFolder = 1,
        },

        {
            fileName = 'file3.jpeg',
            stackPositionInFolder = 1,
        },
    }

    local roll, tempDir = unzipFixtureRoll('test/data/Ektar101.zip')
    lu.assertNotNil (roll)

    local bindingTable = MetadataBindingTable.make (context, LrBindingMock, folder)

    MetadataBindingTable.apply (roll, bindingTable)

    lu.assertEquals (folder.photos[1], {
        fileName="file1.jpeg",
        stackPositionInFolder=1      
    })

    lu.assertEquals (folder.photos[2], {
        fileName="file2.jpeg",
        stackPositionInFolder=1
    })

    lu.assertEquals (folder.photos[3], {
        fileName="file3.jpeg",
        stackPositionInFolder=1
    })
    
    FilmRoll.cleanupTempDir(tempDir)
end

function testApplyBasic ()
    local context = {
        type = "context"
    }

    local folder = LrFolderMock:make ()
    folder.photos = {
        {
            fileName = 'file1.jpeg',
            stackPositionInFolder = 1,
        },

        {
            fileName = 'file2.jpeg',
            stackPositionInFolder = 1,
        },

        {
            fileName = 'file3.jpeg',
            stackPositionInFolder = 1,
        },
    }

    local roll, tempDir = unzipFixtureRoll('test/data/Ektar101.zip')
    lu.assertNotNil (roll)

    local bindingTable = MetadataBindingTable.make (context, LrBindingMock, folder)

    bindingTable[1].binding.filmFrameIndex = 1
    bindingTable[2].binding.filmFrameIndex = 2
    bindingTable[3].binding.filmFrameIndex = 3

    MetadataBindingTable.apply (roll, bindingTable)

    lu.assertEquals (folder.photos[1], {
        fileName="file1.jpeg",
        stackPositionInFolder=1,

        Roll_CameraName="Rolleiflex T",

        Frame_Index="1",
        Frame_BoxISO="100",
        Frame_EmulsionName="Fujifilm Acros",
        Frame_FStop="8",
        Frame_FocalLength="75",
        Frame_Latitude="51.2684547",
        Frame_LensName="Tessar 75mm F3.5",
        Frame_LocalTimeIso8601="2020-05-09T13:21:34",
        Frame_Longitude="-0.3264871",
        Frame_RatedISO="100",
        Frame_Shutter="1/125",
    })

    lu.assertEquals (folder.photos[2], {
        fileName="file2.jpeg",
        stackPositionInFolder=1,

        Roll_CameraName="Rolleiflex T",

        Frame_Index="2",
        Frame_BoxISO="100",
        Frame_EmulsionName="Fujifilm Acros",
        Frame_FStop="16",
        Frame_FocalLength="75",
        Frame_Latitude="52.444444",
        Frame_LensName="Tessar 75mm F3.5",
        Frame_LocalTimeIso8601="2020-05-09T15:44:11",
        Frame_Longitude="1.2222",
        Frame_RatedISO="100",
        Frame_Shutter="1/500",
    })

    lu.assertEquals (folder.photos[3], {
        fileName="file3.jpeg",
        stackPositionInFolder=1,

        Roll_CameraName="Rolleiflex T",

        Frame_Index="3",
        Frame_BoxISO="100",
        Frame_EmulsionName="Fujifilm Acros",
        Frame_FStop="5.6",
        Frame_FocalLength="75",
        Frame_Latitude="54.33333",
        Frame_LensName="Tessar 75mm F3.5",
        Frame_LocalTimeIso8601="2020-05-09T13:21:35",
        Frame_Longitude="-1.444555",
        Frame_RatedISO="100",
        Frame_Shutter="1/250",
    })

    FilmRoll.cleanupTempDir(tempDir)
end

function testApplyBasic_Holders ()
    local context = {
        type = "context"
    }

    local folder = LrFolderMock:make ()
    folder.photos = {
        {
            fileName = 'file1.jpeg',
            stackPositionInFolder = 1,
        },

        {
            fileName = 'file2.jpeg',
            stackPositionInFolder = 1,
        },

        {
            fileName = 'file3.jpeg',
            stackPositionInFolder = 1,
        },
    }

    local roll, tempDir = unzipFixtureRoll('test/data/Ektar101.zip')
    lu.assertNotNil (roll)

    --  Switch to Holder mode
    roll.mode = FilmRoll.Mode.SET

    local bindingTable = MetadataBindingTable.make (context, LrBindingMock, folder)

    bindingTable[1].binding.filmFrameIndex = 1
    bindingTable[2].binding.filmFrameIndex = 2
    bindingTable[3].binding.filmFrameIndex = 3

    MetadataBindingTable.apply (roll, bindingTable)

    lu.assertEquals (folder.photos[1], {
        fileName="file1.jpeg",
        stackPositionInFolder=1,

        Roll_CameraName="Rolleiflex T",

        Frame_Index="1",
        Frame_BoxISO="100",
        Frame_EmulsionName="Fujifilm Acros",
        Frame_FStop="8",
        Frame_FocalLength="75",
        Frame_Latitude="51.2684547",
        Frame_LensName="Tessar 75mm F3.5",
        Frame_LocalTimeIso8601="2020-05-09T13:21:34",
        Frame_Longitude="-0.3264871",
        Frame_RatedISO="100",
        Frame_Shutter="1/125",
    })

    lu.assertEquals (folder.photos[2], {
        fileName="file2.jpeg",
        stackPositionInFolder=1,

        Roll_CameraName="Rolleiflex T",

        Frame_Index="2",
        Frame_BoxISO="100",
        Frame_EmulsionName="Fujifilm Acros",
        Frame_FStop="16",
        Frame_FocalLength="75",
        Frame_Latitude="52.444444",
        Frame_LensName="Tessar 75mm F3.5",
        Frame_LocalTimeIso8601="2020-05-09T15:44:11",
        Frame_Longitude="1.2222",
        Frame_RatedISO="100",
        Frame_Shutter="1/500",
    })

    lu.assertEquals (folder.photos[3], {
        fileName="file3.jpeg",
        stackPositionInFolder=1,

        Roll_CameraName="Rolleiflex T",

        Frame_Index="3",
        Frame_BoxISO="100",
        Frame_EmulsionName="Fujifilm Acros",
        Frame_FStop="5.6",
        Frame_FocalLength="75",
        Frame_Latitude="54.33333",
        Frame_LensName="Tessar 75mm F3.5",
        Frame_LocalTimeIso8601="2020-05-09T13:21:35",
        Frame_Longitude="-1.444555",
        Frame_RatedISO="100",
        Frame_Shutter="1/250",
    })

    FilmRoll.cleanupTempDir(tempDir)
end

os.exit(lu.LuaUnit.run())