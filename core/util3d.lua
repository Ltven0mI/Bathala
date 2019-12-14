local m = {}

local _local = {}

_local.vertexFormat = {
    {"VertexPosition", "float", 3}, -- The x, y, z position of each vertex.
    {"VertexTexCoord", "float", 2}, -- The u,v texture coordinates of each vertex.
    {"VertexColor", "byte", 4} -- The r,g,b,a color of each vertex.meshData.vertices, )
}

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

function m.generateMesh(width, height, depth)
    local halfWidth = width / 2
    local halfHeight = height / 2
    local halfDepth = depth / 2
    local vertices = {
        {-halfWidth, -halfHeight, -halfDepth, 0, 1, 1, 1, 1, 1}, -- Bottom Front Left
        {halfWidth, -halfHeight, -halfDepth, 1, 1, 1, 1, 1, 1}, -- Bottom Front Right
        {-halfWidth, halfHeight, halfDepth, 0, 0, 1, 1, 1, 1}, -- Top Back Left
        {halfWidth, halfHeight, halfDepth, 1, 0, 1, 1, 1, 1} -- Top Back Right
    }
    local indices = {1, 2, 4, 4, 3, 1}
    local mesh = love.graphics.newMesh(_local.vertexFormat, vertices, "triangles")
    mesh:setVertexMap(indices)
    return mesh
end

return m