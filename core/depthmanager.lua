local m = {}

local _local = {}

--[[
    Create the shader, canvas and depthbuffer.
]]
function m.init()
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
            if (texcolor.a <= 0) discard;
            return texcolor * color;
        }
        
        #endif
    ]])
    local screenW, screenH = love.graphics.getDimensions()
    _local.depthBuffer = love.graphics.newCanvas(screenW, screenH, { type = "2d", format = "depth16", readable = true })
    _local.renderTarget = love.graphics.newCanvas(screenW, screenH, { type = "2d", format = "normal", readable = true })
end

--[[
    Cleans up all objects that were created in init()
]]
function m.cleanup()
    _local.shader = nil
    _local.depthBuffer = nil
    _local.renderTarget = nil
end

--[[
    Draws the depthbuffer to the screen. Useful for debugging.
]]
function m.drawDepthTexture(x, y)
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.draw(_local.depthBuffer, x, y)
end

function m.sampleDepthAt(x, y)
    local canvas = love.graphics.newCanvas(_local.depthBuffer:getDimensions())
    canvas:renderTo(function()
        love.graphics.clear()
        love.graphics.setColor(1, 1, 1, 1)
        love.graphics.draw(_local.depthBuffer, 0, 0)
    end)
    return canvas:newImageData():getPixel(x, y)
end

--[[
    Determines whether to write to the depthbuffer or not.
    isAlpha == true then don't write,
    isAlpha == false then write.
]]
function m.setIsAlpha(isAlpha)
    love.graphics.setDepthMode("less", not isAlpha)
end

m.depthCorrectionTransform = love.math.newTransform():setMatrix("row", {
    1, 0, 0, 0,
    0, 1, 0, 0,
    0, 0, 1/32, 0,
    0, 0, 0, 1
})

--[[
    Enable the shader and the canvas.
]]
function m.enable()
	love.graphics.setCanvas({ _local.renderTarget, depthstencil = _local.depthBuffer })
    love.graphics.clear(0, 0, 0, 0)
    
    love.graphics.setShader(_local.shader)
    m.setIsAlpha(false)
end

--[[
    Disables the shader, canvas and draws the rendertarget to the screen.
]]
function m.disable()
    love.graphics.setShader()
    love.graphics.setCanvas()
    
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.draw(_local.renderTarget)
end

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
    matrix[12] = -z
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