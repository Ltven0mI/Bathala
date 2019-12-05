local Matrix = require "core.matrix"

local camera = {}

local _const = {}
local _local = {}

_local.shader = love.graphics.newShader([[
    #ifdef VERTEX
    vec4 position(mat4 transform_projection, vec4 vertex_position)
    {
        return transform_projection * vertex_position;
    }
    #endif
    #ifdef PIXEL

    vec4 effect( vec4 color, Image tex, vec2 texture_coords, vec2 screen_coords )
    {
        vec4 texcolor = Texel(tex, texture_coords);
        //if (texcolor.a <= 0) discard;
        return texcolor * color;
    }
    
    #endif
]])

_local.zNormalizeTransform = love.math.newTransform():setMatrix("row", Matrix.newScaler(1, 1, 10))

function _local.new(x, y, z, w, h, zNear, zFar, zoom, rot)
    x, y, z = x or 0, y or 0, z or 0
    w, h = w or love.graphics.getWidth(), h or love.graphics.getHeight()
    zNear = zNear or -1
    zFar = zFar or 1
    zoom = zoom or 1
    rot = rot or 0

    local t = {
        x=x, y=y, z=z,
        w=w, h=h,
        zNear=zNear,
        zFar=zFar,
        scale=zoom,
        rot=rot
    }

    t.depthBuffer = love.graphics.newCanvas(w, h, { type = "2d", format = "depth16", readable = true })
    t.renderTarget = love.graphics.newCanvas(w, h, { type = "2d", format = "normal", readable = true })

    t.viewportMatrix = Matrix:new{
        {1, 0, 0, 0},
        {0, 1, 0, 0},
        {0, 0, (-2/((zFar-zNear)*zoom)) * 10, ((zFar+zNear) / (zFar-zNear)) * 10},
        {0, 0, 0, 1}
    }
    
    -- Converts from viewport space to screen space
    t.projectionMatrix = Matrix:new{
        {1, 0, 0, w/2},
        {0, -1, -1, h/2},
        {0, 0, 1, 0},
        {0, 0, 0, 1}
    }

    t.translationMatrix = Matrix.newTranslation(-x, -y, -z)
    t.scaleMatrix = Matrix.newScaler(zoom, zoom, zoom)

    -- Converts from world space to viewport space
    t.viewMatrix = t.scaleMatrix * t.translationMatrix

    
    return setmetatable(t, {__index=camera})
end

--[[
    Draws the depthbuffer to the screen. Useful for debugging.
]]
function camera:drawDepthBuffer()
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.draw(self.depthBuffer)
end

--[[
    Determines whether to write to the depthbuffer or not.
    isAlpha == true then don't write,
    isAlpha == false then write.
]]
function camera:setIsAlpha(isAlpha)
    love.graphics.setDepthMode("lequal", not isAlpha)
end

local cameraCoordsVector = Matrix:new({0, 0, 0})
local cameraCoordsMatrix = Matrix.newIdentity()
function camera:cameraCoords(x, y, z)
    cameraCoordsVector[1][1] = x
    cameraCoordsVector[2][1] = y
    cameraCoordsVector[3][1] = z
    Matrix.mul(Matrix.mul(self.projectionMatrix, self.viewMatrix, cameraCoordsMatrix), cameraCoordsVector, cameraCoordsVector)
    return cameraCoordsVector[1][1], cameraCoordsVector[2][1]--(self.h / 2 - cameraCoordsVector[2][1]) + self.y * self.scale
end

local worldCoordsVector = Matrix:new({0, 0, 0})
local worldCoordsMatrix = Matrix.newIdentity()
function camera:worldCoords(x, y)
    y = (self.h / 2 - y) + self.y * self.scale
    worldCoordsVector[1][1] = x
    worldCoordsVector[2][1] = 0
    worldCoordsVector[3][1] = y
    Matrix.mul(Matrix.mul(self.projectionMatrix,  self.viewMatrix, worldCoordsMatrix):invert(), worldCoordsVector, worldCoordsVector)
    return worldCoordsVector[1][1], 0, worldCoordsVector[3][1]
end

function camera:move(dx, dy, dz)
    dx = dx or 0
    dy = dy or 0
    dz = dz or 0

    self.x = self.x + dx
    self.y = self.y + dy
    self.z = self.z + dz

    self.translationMatrix[1][4] = -self.x
    self.translationMatrix[2][4] = -self.y
    self.translationMatrix[3][4] = -self.z

    self.viewMatrix = self.scaleMatrix * self.translationMatrix
end

function camera:lockPosition(x, y, z)
    self:move(x - self.x, y - self.y, z - self.z)
end

function camera:attach()
    love.graphics.push("all")

	love.graphics.setCanvas({ self.renderTarget, depthstencil = self.depthBuffer })
    love.graphics.clear(0, 0, 0, 0)

    love.graphics.setFrontFaceWinding("ccw")
    love.graphics.setMeshCullMode("back")
    
    love.graphics.setShader(_local.shader)
    self:setIsAlpha(false)

    local projectionTransform = love.math.newTransform():setMatrix("row", self.viewportMatrix * self.projectionMatrix)
    local viewTransform = love.math.newTransform():setMatrix("row", self.viewMatrix)
    
    love.graphics.applyTransform(projectionTransform)
    love.graphics.applyTransform(viewTransform)
end

function camera:detach()
    love.graphics.pop()

    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.draw(self.renderTarget)
end

return setmetatable({new=_local.new}, {
    __call=function(_, ...) return _local.new(...) end
})