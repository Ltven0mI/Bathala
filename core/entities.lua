local PathUtil = require "AssetBundle.PathUtil"

local m = {}
local _local = {}

local _defaultPath = "assets/entities/"
_local.path = _defaultPath

_local.loadedEntities = {}


-- [[ Debug Functions ]] --

local function printInfo(str, ...)
    print("[info] "..tostring(str), ...)
end
local function printWarn(str, ...)
    print("[warn] "..tostring(str), ...)
end
-- \\ End Debug Functions // --


-- [[ Exposed Functions ]] --

function m.loadEntities()
    printInfo(string.format("Loading Entities from '%s'...", _local.path))
    _local.loadEntitiesFrom(_local.path)
    printInfo("Finished loading Entities!")
end

function m.new(entityName, ...)
    local entity = _local.loadedEntities[entityName]
    if entity == nil then
        error(string.format("Failed to create instance of entity: No entity with name '%s'", entityName), 2)
    end
    return entity(...)
end

function m.get(entityName)
    local entity = _local.loadedEntities[entityName]
    if entity == nil then
        error(string.format("Failed to get entity: No entity with name '%s'", entityName), 2)
    end
    return entity
end

--[[
    Returns a table containing all entities thats name matches the pattern.
]]
function m.getEntitiesMatchingPattern(pattern)
    if pattern == nil or pattern:len() == 0 then
        pattern = ".*"
    end
    local matchedEntities = {}
    for name, entity in pairs(_local.loadedEntities) do
        if name:match(pattern) then
            table.insert(matchedEntities, entity)
        end
    end
    return matchedEntities
end

function m.setDefaultPath(path)
    if type(path) ~= "string" then
        error(string.format("setDefaultPath() accepts type 'string' not '%s'", type(path)), 2)
    end
    _local.path = PathUtil.cleanPath(path)
end
-- \\ End Exposed Functions // --


-- [[ Local Functions ]] --

function _local.loadEntityFromFile(path, name)
    local chunk, err = love.filesystem.load(path)
    if chunk == nil then
        return false, err
    end

    local success, result_or_err = pcall(chunk)
    if not success then
        return false, result_or_err
    end

    if type(result_or_err) ~= "table" then
        return false, string.format("File returned type '%s' instead of 'table'", type(result_or_err))
    end

    local root, baseName = PathUtil.split(path)
    local fileName, ext = PathUtil.splitExt(baseName)

    local entityName = result_or_err.__name or fileName

    if _local.loadedEntities[entityName] ~= nil then
        return false, string.format("Entity already exists with the name '%s'", entityName)
    end
    
    result_or_err.__name = entityName
    _local.loadedEntities[entityName] = result_or_err

    if result_or_err.onLoaded then
        result_or_err:onLoaded()
    end
    
    return true, entityName
end

function _local.loadEntitiesFrom(dirPath)
    local directoryItems = love.filesystem.getDirectoryItems(_local.path)
    for _, item in ipairs(directoryItems) do
        local fullPath = PathUtil.join(dirPath, item)
        local info = love.filesystem.getInfo(fullPath)
        if info.type == "directory" then
            _local.loadEntitiesFrom(fullPath)
        elseif info.type == "file" then
            local success, name_or_err = _local.loadEntityFromFile(fullPath)
            if not success then
                printWarn(string.format("Failed to load entity '%s' : %s", fullPath, name_or_err))
            end
            printInfo(string.format("Successfully loaded entity '%s' from '%s'", name_or_err, fullPath))
        else
            printInfo(string.format("Ignoring unknown directory item '%s'", fullPath))
        end
    end
end
-- \\ End Local Functions // --

return m