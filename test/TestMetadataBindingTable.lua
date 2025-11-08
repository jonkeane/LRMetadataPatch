local lu = require 'luaunit'
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
    local roll = FilmRoll.fromFile ('test/data/test-album/test-album.json')
    roll.frames = nil
    MetadataBindingTable.apply (roll, {})
end

function testApplyEmptyBindings ()
    local roll = FilmRoll.fromFile ('test/data/test-album/test-album.json')
    
    MetadataBindingTable.apply (roll, {})
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

    local roll = FilmRoll.fromFile ('test/data/test-album/test-album.json')
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

    local roll = FilmRoll.fromFile ('test/data/test-album/test-album.json')
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
        Roll_CreationTimeUnix="1589026694008",
        Roll_FormatName="120/6x6",
        Roll_Mode="R",
        Roll_Name="Box Hill",
        Roll_Status="P",
        Roll_UID="581c0629-3810-464d-9382-7f095f2e9e2d",       

        Frame_Index="1",
        Frame_Designator="1",
        Frame_BoxISO="100",
        Frame_EmulsionName="Fujifilm Acros",
        Frame_FStop="8",
        Frame_FocalLength="75",
        Frame_Latitude="51.2684547",
        Frame_LensName="Tessar 75mm F3.5",
        Frame_LocalTimeIso8601="2020-05-09T13:21:34",
        Frame_Locality="Mickleham",
        Frame_Longitude="-0.3264871",
        Frame_RatedISO="100",
        Frame_Shutter="1/125",       
    })

    lu.assertEquals (folder.photos[2], {
        fileName="file2.jpeg",
        stackPositionInFolder=1,

        Roll_CameraName="Rolleiflex T",
        Roll_CreationTimeUnix="1589026694008",
        Roll_FormatName="120/6x6",
        Roll_Mode="R",
        Roll_Name="Box Hill",
        Roll_Status="P",
        Roll_UID="581c0629-3810-464d-9382-7f095f2e9e2d",

        Frame_Index="2",
        Frame_Designator="2",
        Frame_BoxISO="100",
        Frame_EmulsionName="Fujifilm Acros",
        Frame_FStop="16",
        Frame_FocalLength="75",
        Frame_Latitude="52.444444",
        Frame_LensName="Tessar 75mm F3.5",
        Frame_LocalTimeIso8601="2020-05-09T15:44:11",
        Frame_Locality="Mickleham",
        Frame_Longitude="1.2222",
        Frame_RatedISO="100",
        Frame_Shutter="1/500",
    })

    lu.assertEquals (folder.photos[3], {
        fileName="file3.jpeg",
        stackPositionInFolder=1,
        
        Roll_CameraName="Rolleiflex T",
        Roll_CreationTimeUnix="1589026694008",
        Roll_FormatName="120/6x6",
        Roll_Mode="R",
        Roll_Name="Box Hill",
        Roll_Status="P",
        Roll_UID="581c0629-3810-464d-9382-7f095f2e9e2d",
        
        Frame_Index="3",
        Frame_Designator="3",
        Frame_BoxISO="100",
        Frame_EmulsionName="Fujifilm Acros",
        Frame_FStop="5.6",
        Frame_FocalLength="75",
        Frame_Latitude="54.33333",
        Frame_LensName="Tessar 75mm F3.5",
        Frame_LocalTimeIso8601="2020-05-09T13:21:35",
        Frame_Locality="Mickleham",
        Frame_Longitude="-1.444555",
        Frame_RatedISO="100",
        Frame_Shutter="1/250",
    })

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

    local roll = FilmRoll.fromFile ('test/data/test-album/test-album.json')
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
        Roll_CreationTimeUnix="1589026694008",
        Roll_FormatName="120/6x6",
        Roll_Mode="HS",
        Roll_Name="Box Hill",
        Roll_Status="P",
        Roll_UID="581c0629-3810-464d-9382-7f095f2e9e2d",       

        Frame_Index="1",
        Frame_Designator="1A",
        Frame_BoxISO="100",
        Frame_EmulsionName="Fujifilm Acros",
        Frame_FStop="8",
        Frame_FocalLength="75",
        Frame_Latitude="51.2684547",
        Frame_LensName="Tessar 75mm F3.5",
        Frame_LocalTimeIso8601="2020-05-09T13:21:34",
        Frame_Locality="Mickleham",
        Frame_Longitude="-0.3264871",
        Frame_RatedISO="100",
        Frame_Shutter="1/125",       
    })

    lu.assertEquals (folder.photos[2], {
        fileName="file2.jpeg",
        stackPositionInFolder=1,

        Roll_CameraName="Rolleiflex T",
        Roll_CreationTimeUnix="1589026694008",
        Roll_FormatName="120/6x6",
        Roll_Mode="HS",
        Roll_Name="Box Hill",
        Roll_Status="P",
        Roll_UID="581c0629-3810-464d-9382-7f095f2e9e2d",

        Frame_Index="2",
        Frame_Designator="1B",
        Frame_BoxISO="100",
        Frame_EmulsionName="Fujifilm Acros",
        Frame_FStop="16",
        Frame_FocalLength="75",
        Frame_Latitude="52.444444",
        Frame_LensName="Tessar 75mm F3.5",
        Frame_LocalTimeIso8601="2020-05-09T15:44:11",
        Frame_Locality="Mickleham",
        Frame_Longitude="1.2222",
        Frame_RatedISO="100",
        Frame_Shutter="1/500",
    })

    lu.assertEquals (folder.photos[3], {
        fileName="file3.jpeg",
        stackPositionInFolder=1,
        
        Roll_CameraName="Rolleiflex T",
        Roll_CreationTimeUnix="1589026694008",
        Roll_FormatName="120/6x6",
        Roll_Mode="HS",
        Roll_Name="Box Hill",
        Roll_Status="P",
        Roll_UID="581c0629-3810-464d-9382-7f095f2e9e2d",
        
        Frame_Index="3",
        Frame_Designator="2A",
        Frame_BoxISO="100",
        Frame_EmulsionName="Fujifilm Acros",
        Frame_FStop="5.6",
        Frame_FocalLength="75",
        Frame_Latitude="54.33333",
        Frame_LensName="Tessar 75mm F3.5",
        Frame_LocalTimeIso8601="2020-05-09T13:21:35",
        Frame_Locality="Mickleham",
        Frame_Longitude="-1.444555",
        Frame_RatedISO="100",
        Frame_Shutter="1/250",
    })

end

os.exit( lu.LuaUnit.run() )