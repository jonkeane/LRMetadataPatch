local lu = require "luaunit"

local FilmFramesImportDialog = require "analog.FilmFramesImportDialog"
local FilmRoll = require "analog.FilmRoll"
local LrViewMock = require 'mock.LrViewMock' 

local LrHttpMock = {
    openUrlInBrowser = function(utl)
        return {
            type = "url",
            url = url
        }
    end
}

local function LrColorMock(color)
    return {
        type = "color",
        color = color
    }
end

function testEmpty()
    lu.assertTrue(true)
end

function testBasic()
    local content =
        FilmFramesImportDialog.build {
        LrView = LrViewMock,
        LrHttp = LrHttpMock,
        LrColor = LrColorMock,
        size = {width = 1024, height = 768},
        updateInfo = nil,
        roll = {
            frameCount = 0,
            frames = {}
        },
        bindings = {}
    }

    lu.assertEquals(
        content,
        {
            type = "column",
            args = {
                spacing = 0,
                {
                    type = "static_text",
                    args = {
                        title = ""
                    }
                },
                {
                    type = "static_text",
                    args = {
                        title = "Match Lightroom photos to reference images from metadata"
                    }
                },
                {
                    type = "row",
                    args = {
                        spacing = 16,
                        {
                            type = "column",
                            args = {
                                width = 256,
                                {
                                    type = "static_text",
                                    args = {
                                        title = "Scan from Lightroom",
                                        font = "<system/bold>"
                                    }
                                }
                            }
                        },
                        {
                            type = "column",
                            args = {
                                {
                                    type = "static_text",
                                    args = {
                                        title = "Reference from Crown + Flint",
                                        font = "<system/bold>"
                                    }
                                }
                            }
                        }
                    }
                },
                {
                    type = "scrolled_view",
                    args = {
                        height = 576.0,
                        width = 576.0,
                        {
                            args = {
                                margin = 16,
                                spacing = 0
                            },
                            type = "column"
                        }
                    }
                }
            }
        }
    )
end

function testWithFrames()
    local content =
        FilmFramesImportDialog.build {
        LrView = LrViewMock,
        LrHttp = LrHttpMock,
        LrColor = LrColorMock,
        size = {width = 1024, height = 768},
        updateInfo = nil,
        roll = {
            mode = FilmRoll.Mode.ROLL,
            frameCount = 3,
            frames = {
                {
                    frameIndex = 1
                },
                {
                    frameIndex = 2
                },
                {
                    frameIndex = 3
                }
            }
        },
        bindings = {
            {
                photo = {
                    type = "photo",
                    fileName = "Photo1.arw"
                },
                binding = {
                    filmFrameIndex = 1
                }
            },
            {
                photo = {
                    type = "photo",
                    fileName = "Photo2.arw"
                },
                binding = {
                    filmFrameIndex = 3
                }
            }
        }
    }

    lu.assertEquals(
        content,
        {
            args = {
                {
                    args = {
                        title = ""
                    },
                    type = "static_text"
                },
                {
                    args = {
                        title = "Match Lightroom photos to reference images from metadata"
                    },
                    type = "static_text"
                },
                {
                    type = "row",
                    args = {
                        spacing = 16,
                        {
                            type = "column",
                            args = {
                                width = 256,
                                {
                                    type = "static_text",
                                    args = {
                                        title = "Scan from Lightroom",
                                        font = "<system/bold>"
                                    }
                                }
                            }
                        },
                        {
                            type = "column",
                            args = {
                                {
                                    type = "static_text",
                                    args = {
                                        title = "Reference from Crown + Flint",
                                        font = "<system/bold>"
                                    }
                                }
                            }
                        }
                    }
                },
                {
                    args = {
                        {
                            args = {
                                {
                                    args = {
                                        spacing = 16,
                                        {
                                            args = {
                                                spacing = 0,
                                                {
                                                    args = {
                                                        height = 256,
                                                        photo = {
                                                            type = "photo",
                                                            fileName = "Photo1.arw"
                                                        },
                                                        width = 256
                                                    },
                                                    type = "catalog_photo"
                                                },
                                                {
                                                    args = {
                                                        title = "Photo1.arw"
                                                    },
                                                    type = "static_text"
                                                }
                                            },
                                            type = "column"
                                        },
                                        {
                                            args = {
                                                spacing = 0,
                                                {
                                                    args = {
                                                        height = 256,
                                                        width = 256,
                                                        value = {
                                                            key = {
                                                                bind_to_object = {filmFrameIndex = 1},
                                                                key = "filmFrameIndex",
                                                                transform = nil
                                                            },
                                                            type = "binding"
                                                        }
                                                    },
                                                    type = "picture"
                                                },
                                                {
                                                    args = {
                                                        items = {
                                                            {
                                                                title = "1 -  (0/0 sec @ 0.0)",
                                                                value = 1
                                                            },
                                                            {
                                                                title = "2 -  (0/0 sec @ 0.0)",
                                                                value = 2
                                                            },
                                                            {
                                                                title = "3 -  (0/0 sec @ 0.0)",
                                                                value = 3
                                                            }
                                                        },
                                                        value = {
                                                            key = {
                                                                bind_to_object = {filmFrameIndex = 1},
                                                                key = "filmFrameIndex"
                                                            },
                                                            type = "binding"
                                                        }
                                                    },
                                                    type = "popup_menu"
                                                }
                                            },
                                            type = "column"
                                        }
                                    },
                                    type = "row"
                                },
                                {
                                    args = {
                                        spacing = 16,
                                        {
                                            args = {
                                                spacing = 0,
                                                {
                                                    args = {
                                                        height = 256,
                                                        photo = {
                                                            type = "photo",
                                                            fileName = "Photo2.arw"
                                                        },
                                                        width = 256
                                                    },
                                                    type = "catalog_photo"
                                                },
                                                {
                                                    args = {
                                                        title = "Photo2.arw"
                                                    },
                                                    type = "static_text"
                                                }
                                            },
                                            type = "column"
                                        },
                                        {
                                            args = {
                                                spacing = 0,
                                                {
                                                    args = {
                                                        height = 256,
                                                        width = 256,
                                                        value = {
                                                            key = {
                                                                bind_to_object = {filmFrameIndex = 3},
                                                                key = "filmFrameIndex",
                                                                transform = nil
                                                            },
                                                            type = "binding"
                                                        }
                                                    },
                                                    type = "picture"
                                                },
                                                {
                                                    args = {
                                                        items = {
                                                            {
                                                                title = "1 -  (0/0 sec @ 0.0)",
                                                                value = 1
                                                            },
                                                            {
                                                                title = "2 -  (0/0 sec @ 0.0)",
                                                                value = 2
                                                            },
                                                            {
                                                                title = "3 -  (0/0 sec @ 0.0)",
                                                                value = 3
                                                            }
                                                        },
                                                        value = {
                                                            key = {
                                                                bind_to_object = {filmFrameIndex = 3},
                                                                key = "filmFrameIndex"
                                                            },
                                                            type = "binding"
                                                        }
                                                    },
                                                    type = "popup_menu"
                                                }
                                            },
                                            type = "column"
                                        }
                                    },
                                    type = "row"
                                },
                                margin = 16,
                                spacing = 0
                            },
                            type = "column"
                        },
                        height = 576.0,
                        width = 576.0
                    },
                    type = "scrolled_view"
                },
                spacing = 0
            },
            type = "column"
        }
    )
end

function testWithFrames_Holders()
    local content =
        FilmFramesImportDialog.build {
        LrView = LrViewMock,
        LrHttp = LrHttpMock,
        LrColor = LrColorMock,
        size = {width = 1024, height = 768},
        updateInfo = nil,
        roll = {
            mode = FilmRoll.Mode.SET,
            frameCount = 3,
            frames = {
                {
                    frameIndex = 1
                },
                {
                    frameIndex = 2
                },
                {
                    frameIndex = 3
                }
            }
        },
        bindings = {
            {
                photo = {
                    type = "photo",
                    fileName = "Photo1.arw"
                },
                binding = {
                    filmFrameIndex = 1
                }
            },
            {
                photo = {
                    type = "photo",
                    fileName = "Photo2.arw"
                },
                binding = {
                    filmFrameIndex = 3
                }
            }
        }
    }

    lu.assertEquals(
        content,
        {
            args = {
                {
                    args = {
                        title = ""
                    },
                    type = "static_text"
                },
                {
                    args = {
                        title = "Match Lightroom photos to reference images from metadata"
                    },
                    type = "static_text"
                },
                {
                    type = "row",
                    args = {
                        spacing = 16,
                        {
                            type = "column",
                            args = {
                                width = 256,
                                {
                                    type = "static_text",
                                    args = {
                                        title = "Scan from Lightroom",
                                        font = "<system/bold>"
                                    }
                                }
                            }
                        },
                        {
                            type = "column",
                            args = {
                                {
                                    type = "static_text",
                                    args = {
                                        title = "Reference from Crown + Flint",
                                        font = "<system/bold>"
                                    }
                                }
                            }
                        }
                    }
                },
                {
                    args = {
                        {
                            args = {
                                {
                                    args = {
                                        spacing = 16,
                                        {
                                            args = {
                                                spacing = 0,
                                                {
                                                    args = {
                                                        height = 256,
                                                        photo = {
                                                            type = "photo",
                                                            fileName = "Photo1.arw"
                                                        },
                                                        width = 256
                                                    },
                                                    type = "catalog_photo"
                                                },
                                                {
                                                    args = {
                                                        title = "Photo1.arw"
                                                    },
                                                    type = "static_text"
                                                }
                                            },
                                            type = "column"
                                        },
                                        {
                                            args = {
                                                spacing = 0,
                                                {
                                                    args = {
                                                        height = 256,
                                                        width = 256,
                                                        value = {
                                                            key = {
                                                                bind_to_object = {filmFrameIndex = 1},
                                                                key = "filmFrameIndex",
                                                                transform = nil
                                                            },
                                                            type = "binding"
                                                        }
                                                    },
                                                    type = "picture"
                                                },
                                                {
                                                    args = {
                                                        items = {
                                                            {
                                                                title = "1 -  (0/0 sec @ 0.0)",
                                                                value = 1
                                                            },
                                                            {
                                                                title = "2 -  (0/0 sec @ 0.0)",
                                                                value = 2
                                                            },
                                                            {
                                                                title = "3 -  (0/0 sec @ 0.0)",
                                                                value = 3
                                                            }
                                                        },
                                                        value = {
                                                            key = {
                                                                bind_to_object = {filmFrameIndex = 1},
                                                                key = "filmFrameIndex"
                                                            },
                                                            type = "binding"
                                                        }
                                                    },
                                                    type = "popup_menu"
                                                }
                                            },
                                            type = "column"
                                        }
                                    },
                                    type = "row"
                                },
                                {
                                    args = {
                                        spacing = 16,
                                        {
                                            args = {
                                                spacing = 0,
                                                {
                                                    args = {
                                                        height = 256,
                                                        photo = {
                                                            type = "photo",
                                                            fileName = "Photo2.arw"
                                                        },
                                                        width = 256
                                                    },
                                                    type = "catalog_photo"
                                                },
                                                {
                                                    args = {
                                                        title = "Photo2.arw"
                                                    },
                                                    type = "static_text"
                                                }
                                            },
                                            type = "column"
                                        },
                                        {
                                            args = {
                                                spacing = 0,
                                                {
                                                    args = {
                                                        height = 256,
                                                        width = 256,
                                                        value = {
                                                            key = {
                                                                bind_to_object = {filmFrameIndex = 3},
                                                                key = "filmFrameIndex",
                                                                transform = nil
                                                            },
                                                            type = "binding"
                                                        }
                                                    },
                                                    type = "picture"
                                                },
                                                {
                                                    args = {
                                                        items = {
                                                            {
                                                                title = "1 -  (0/0 sec @ 0.0)",
                                                                value = 1
                                                            },
                                                            {
                                                                title = "2 -  (0/0 sec @ 0.0)",
                                                                value = 2
                                                            },
                                                            {
                                                                title = "3 -  (0/0 sec @ 0.0)",
                                                                value = 3
                                                            }
                                                        },
                                                        value = {
                                                            key = {
                                                                bind_to_object = {filmFrameIndex = 3},
                                                                key = "filmFrameIndex"
                                                            },
                                                            type = "binding"
                                                        }
                                                    },
                                                    type = "popup_menu"
                                                }
                                            },
                                            type = "column"
                                        }
                                    },
                                    type = "row"
                                },
                                margin = 16,
                                spacing = 0
                            },
                            type = "column"
                        },
                        height = 576.0,
                        width = 576.0
                    },
                    type = "scrolled_view"
                },
                spacing = 0
            },
            type = "column"
        }
    )
end

os.exit(lu.LuaUnit.run())
