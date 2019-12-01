local m = {}
local _local = {}

local _pt = {}
function _pt.draw(self, transform)
    love.graphics.draw(self.mesh, transform)
end

function m.new(path_or_texture, data)
    local image = path_or_texture
    if type(path_or_texture) == "string" then
        image = love.graphics.newImage(path_or_texture)
    end

    data = data or {}

    local sprite = {
        image=image,
        mesh=_local.newMesh(image, data.isGround)
    }

    return setmetatable(sprite, {__index=_pt})
end

function _local.newMesh(image, isGround)
    local imgW, imgH = image:getDimensions()
    local topDepth = isGround and -imgH or imgH
    local meshInstance = love.graphics.newMesh(
    {
        {"VertexPosition", "float", 3}, -- The x,y position of each vertex.
        {"VertexTexCoord", "float", 2}, -- The u,v texture coordinates of each vertex.
        {"VertexColor", "byte", 4} -- The r,g,b,a color of each vertex.
    },
    {
        {0, 0, topDepth, 0, 0, 1, 1, 1, 1}, -- Top Left
        {imgW, 0, topDepth, 1, 0, 1, 1, 1, 1}, -- Top Right
        {imgW, imgH, 0, 1, 1, 1, 1, 1, 1}, -- Bottom Right
        {0, imgH, 0, 0, 1, 1, 1, 1, 1} -- Bottom Left
    })

    meshInstance:setTexture(image)
    return meshInstance
end

return m