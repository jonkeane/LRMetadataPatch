require 'Use'

local FilmRoll = use 'analog.FilmRoll'

local function make (index, mode)    
    if mode == FilmRoll.Mode.ROLL then
        return tostring (index)
    end

    if mode == FilmRoll.Mode.SET then
        local holderIndex = math.floor ((index + 1) / 2)
        local even = (index % 2 == 0)

        return string.format ("%d%s", holderIndex, even and 'B' or 'A')
    end
end

return {
    make = make
}