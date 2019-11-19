local PathUtil = require "AssetBundle.PathUtil"

local Class = require "hump.class"
local Animation = require "classes.animation"
local JSON = require "peachy.lib.json"

local m = {}
local _local = {}

local _defaultPath = "assets/animations/"
_local.path = _defaultPath

_local.loadedAnimations = {}


-- [[ Debug Functions ]] --

local function printInfo(str, ...)
    print("[info] "..tostring(str), ...)
end
local function printWarn(str, ...)
    print("[warn] "..tostring(str), ...)
end
-- \\ End Debug Functions // --


-- [[ Exposed Functions ]] --

function m.loadAnimations()
    printInfo(string.format("Loading Animations from '%s'...", _local.path))
    _local.loadAnimationsFrom(_local.path)
    printInfo("Finished loading Animations!")
end

function m.new(animationName, ...)
    local animationType = _local.loadedAnimations[animationName]
    if animationType == nil then
        error(string.format("Failed to create instance of Animation: No Animation with name '%s'", animationName), 2)
    end
    return animationType(...)
end

function m.get(animationName)
    local animationType = _local.loadedAnimations[animationName]
    if animationType == nil then
        error(string.format("Failed to get Animation: No Animation with name '%s'", animationName), 2)
    end
    return animationType
end

function m.setDefaultPath(path)
    if type(path) ~= "string" then
        error(string.format("setDefaultPath() accepts type 'string' not '%s'", type(path)), 2)
    end
    _local.path = PathUtil.cleanPath(path)
end
-- \\ End Exposed Functions // --


-- [[ Local Functions ]] --

function _local.loadAnimationFromFile(path)
    -- Bit of path stuff
    local root, baseName = PathUtil.split(path)
    local fileName, _ = PathUtil.splitExt(baseName)

    -- Check Animation doesn't already exist
    if _local.loadedAnimations[fileName] ~= nil then
        return false, string.format("Animation already exists with the name '%s'", fileName)
    end

    -- Load JSON data
    local jsonRaw, err = love.filesystem.read(path)
    if jsonRaw == nil then
        return false, string.format("Failed to load json-data : %s", err)
    end
    local jsonData = JSON.decode(jsonRaw)

    -- Loading image with same path except '.png' instead of '.json'
    local imagePath = PathUtil.join(root, fileName .. ".png")
    local success, image_or_err = pcall(love.graphics.newImage, imagePath)
    if not success then
        return false, image_or_err
    end

    -- Create and store the new Animation class
    _local.loadedAnimations[fileName] = Class{
        init = function(self, initialTag)
            Animation.init(self, initialTag)
        end,
        __includes = {
            Animation
        },
        __name = fileName,
        jsonData = jsonData,
        spriteSheet = image_or_err
    }
    return true, fileName
end

function _local.loadAnimationsFrom(dirPath)
    local directoryItems = love.filesystem.getDirectoryItems(_local.path)
    for _, item in ipairs(directoryItems) do
        local fullPath = PathUtil.join(dirPath, item)
        local info = love.filesystem.getInfo(fullPath)
        if info.type == "directory" then
            _local.loadAnimationsFrom(fullPath)
        elseif info.type == "file" then
            local fileName, ext = PathUtil.splitExt(item)
            if ext == ".json" then
                -- * Only process '.json' files. Ignore any other extension
                local success, name_or_err = _local.loadAnimationFromFile(fullPath)
                if not success then
                    printWarn(string.format("Failed to load Animation '%s' : %s", fullPath, name_or_err))
                else
                    printInfo(string.format("Successfully loaded Animation '%s' from '%s'", name_or_err, fullPath))
                end
            end
        else
            printInfo(string.format("Ignoring unknown directory item '%s'", fullPath))
        end
    end
end
-- \\ End Local Functions // --

return m