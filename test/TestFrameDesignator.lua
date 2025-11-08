local lu = require 'luaunit'
local FrameDesignator = require 'analog.FrameDesignator'
local FilmRoll = require 'analog.FilmRoll'

function testEmpty()
    lu.assertTrue(true)
end

function testRollMode ()
    lu.assertEquals (FrameDesignator.make (1, FilmRoll.Mode.ROLL), "1")
    lu.assertEquals (FrameDesignator.make (2, FilmRoll.Mode.ROLL), "2")
    lu.assertEquals (FrameDesignator.make (3, FilmRoll.Mode.ROLL), "3")
    lu.assertEquals (FrameDesignator.make (4, FilmRoll.Mode.ROLL), "4")
end

function testSetMode ()
    lu.assertEquals (FrameDesignator.make (1, FilmRoll.Mode.SET), "1A")
    lu.assertEquals (FrameDesignator.make (2, FilmRoll.Mode.SET), "1B")
    lu.assertEquals (FrameDesignator.make (3, FilmRoll.Mode.SET), "2A")
    lu.assertEquals (FrameDesignator.make (4, FilmRoll.Mode.SET), "2B")

    lu.assertEquals (FrameDesignator.make (5, FilmRoll.Mode.SET), "3A")
    lu.assertEquals (FrameDesignator.make (6, FilmRoll.Mode.SET), "3B")
    lu.assertEquals (FrameDesignator.make (7, FilmRoll.Mode.SET), "4A")
    lu.assertEquals (FrameDesignator.make (8, FilmRoll.Mode.SET), "4B")
end

os.exit( lu.LuaUnit.run() )