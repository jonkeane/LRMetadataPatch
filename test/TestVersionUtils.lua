local lu = require 'luaunit'
local VersionUtils = require 'analog.VersionUtils'

function testEmpty()
    lu.assertTrue(true)
end

function testMajorGreater ()
    lu.assertTrue (VersionUtils.newer (
        { major=0, minor=5, revision=0, build = 0},
        { major=1, minor=0, revision=0, build = 0}
    ))
end

function testMajorSame_MinorGreater ()
    lu.assertTrue (VersionUtils.newer (
        { major=1, minor=5, revision=0, build = 0},
        { major=1, minor=6, revision=0, build = 0}
    ))
end

function testMajorSame_MinorSame_RevGreater ()
    lu.assertTrue (VersionUtils.newer (
        { major=1, minor=5, revision=1, build = 0},
        { major=1, minor=5, revision=2, build = 0}
    ))
end

function testMajorSame_MinorSame_RevSame_BuildGreater ()
    lu.assertTrue (VersionUtils.newer (
        { major=1, minor=5, revision=2, build=112},
        { major=1, minor=5, revision=2, build=113}
    ))
end

function testMajorSame_MinorSame_RevSame_BuildSame ()
    lu.assertFalse (VersionUtils.newer (
        { major=1, minor=5, revision=2, build=112},
        { major=1, minor=5, revision=2, build=112}
    ))
end

os.exit( lu.LuaUnit.run() )