local M = {}

local function simpleHash(s)
    -- Very small non-cryptographic hash for test uniqueness
    local h = 0
    for i = 1, #s do
        h = (h * 31 + s:byte(i)) % 2^32
    end
    return string.format("%08x", h)
end

function M.digest(s)
    return simpleHash(s or '')
end

return M
