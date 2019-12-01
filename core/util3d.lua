local m = {}

local _local = {}

_local.translationMatrix = {
    1, 0, 0, 0,
    0, 1, 0, 0,
    0, 0, 1, 0,
    0, 0, 0, 1
}
--[[
    Returns a translation matrix(row-major) from x, y and z
    without creating a new table.
]]
function m.getTranslationMatrix(x, y, z)
    local matrix = _local.translationMatrix
    matrix[4] = x
    matrix[8] = y
    matrix[12] = z
    return matrix
end

_local.transform = love.math.newTransform()
--[[
    Returns a translation Transform from x, y and z
    without creating a new Transform.
]]
function m.getTranslationTransform(x, y, z)
    local matrix = m.getTranslationMatrix(x, y, z)
    return _local.transform:setMatrix("row", matrix)
end

return m