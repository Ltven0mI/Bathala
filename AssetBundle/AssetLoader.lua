local PathUtil = require "AssetBundle.PathUtil"

local m = {}

m.loaders = {
    [".png"] = love.graphics.newImage
}

function m.loadFromFile(path)
    local dir, basename = PathUtil.split(path)
    local filename, ext = PathUtil.splitExt(basename)

    local loader = m.loaders[ext]
    if loader == nil then
        return nil, string.format("No loader found for '%s' files.", ext)
    end

    return loader(path)
end

return m