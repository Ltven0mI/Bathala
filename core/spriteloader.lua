local OBJParser = require "core.objparser"
local Sprite = require "classes.sprite"

local m = {}

local _local = {}
_local.vertexFormat = {
    {"VertexPosition", "float", 3}, -- The x, y, z position of each vertex.
    {"VertexTexCoord", "float", 2}, -- The u,v texture coordinates of each vertex.
    {"VertexColor", "byte", 4} -- The r,g,b,a color of each vertex.meshData.vertices, )
}

--[[
    loadFromOBJ(objPath [, path_or_texture, isTransparent] )
    objPath (string) : The path to an .obj file.
    > optional arguments >
    path_or_texture (string or texture) : Either a Texture or the path to an Image.
    isTransparent (bool) : Whether the Sprite has transparency or not.
]]
function m.loadFromOBJ(objPath, path_or_texture, isTransparent)
    local texture = path_or_texture
    if type(path_or_texture) == "string" then
        texture = love.graphics.newImage(path_or_texture)
    end

    local meshData, err = OBJParser.unitTest(objPath)
    if meshData == nil then error(err) end
    local mesh = love.graphics.newMesh(_local.vertexFormat, meshData.vertices, "triangles")
    mesh:setVertexMap(meshData.indices)
    mesh:setTexture(texture)

    if isTransparent == nil then isTransparent = false end
    return Sprite(mesh, isTransparent)
end

return m