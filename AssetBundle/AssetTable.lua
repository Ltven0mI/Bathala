local PathUtil = require "AssetBundle.PathUtil"

local m = {}

local function _splitFilepath(path)
  local assetTable = {}
  local t = assetTable
  
  local root, basename = PathUtil.split(path)
  
  if root == nil or root == "" then
    return basename
  end
  
  --error(string.format("%s, %s", tostring(root), basename))
  
  for dir in root:gmatch("[^/]+") do
    t[dir] = {}
    t = t[dir]
  end
  
  t[1] = basename
  
  return assetTable
end

-- Adds an empty table to the table passed
-- in the first argument, using the key
-- passed in the second argument.
-- But only if it does not already exist.
local function _addDirectory(cleanTable, k)
  local entry = cleanTable[k]
  
  if entry and type(entry) ~= "table" then
    return nil, "Asset already exists with that key."
  end
  
  cleanTable[k] = entry or {}
  return true
end

-- Adds the string passed in the
-- third argument to the table
-- passed in the first argument,
-- using the key passed in the
-- second argument.
local function _addString(cleanTable, k, str)
  local entry = cleanTable[k]
  
  if entry == nil then
    cleanTable[k] = str
    return true
  end
  
  if type(entry) == "table" then
    return nil, "Directory table already exists with this key."
  else
    return nil, "Value already exists with this key."
  end
end

-- Creates a nested table structure in
-- the table passed in the first argument,
-- using the directories from the path
-- passed in the third argument, but only
-- if the key passed in the second
-- argument is not a string, otherwise
-- just adds the path to the table
-- using the key passed.
local function _addFilepath(cleanTable, k, path)
  local path = PathUtil.cleanPath(path)
  
  -- If the key was a string it is assumed
  -- the specific key is desired and so
  -- add the full path to the AssetTable.
  if type(k) == "string" then
    local success, err = _addString(cleanTable, k, path)
    if not success then
      return nil, string.format("Failed to add string '%s' to AssetTable: %s", basename, err)
    end
    return true
  end
  
  local root, basename = PathUtil.split(path)
  local t = cleanTable
  
  -- Create the table structure based
  -- on the directories in path.
  for dir in root:gmatch("[^/]+") do
    -- Attempt to add the directory to the current table.
    local success, err = _addDirectory(t, dir)
    if not success then
      return nil, string.format("Failed to add directory '%s' to AssetTable: %s", dir, err)
    end
    -- Set the current table to the nested table.
    t = t[dir]
  end
  
  -- After creating the table structure
  -- it's now time to add the filename
  -- to the last table.
  local filename, ext = PathUtil.splitExt(basename)
  local success, err = _addString(t, filename, basename)
  if not success then
    return nil, string.format("Failed to add string '%s' to AssetTable: %s", basename, err)
  end
  
  return true
end

-- Recursivly loops through all values
-- in the table passed in the first argument
-- and creates a matching table structure
-- in the table passed in the second argument.
-- Any string encounted will be treated
-- as a relative filepath and a corresponding
-- table structure will be added.
local function _cleanTable(dirtyTable, cleanTable)
  for k, v in pairs(dirtyTable) do
    local vType = type(v)
    
    if vType == "table" then
      -- Attempts to add a new table to the AssetTable.
      local success, err = _addDirectory(cleanTable, k)
      if not success then
        return nil, string.format("Failed to add directory '%s' to AssetTable: %s", k, err)
      end
      
      -- Process the nested table and add to the AssetTable.
      local success, err = _cleanTable(v, cleanTable[k])
      if not success then
        return nil, err
      end
    elseif vType == "string" then
      -- Attempt to add the filepath to the AssetTable.
      local success, err = _addFilepath(cleanTable, k, v)
      if not success then
        return nil, string.format("Failed to add filepath '%s' to AssetTable: %s", v, err)
      end
    else
      return nil, string.format("Invalid type of value '%s'", vType)
    end
  end
  
  return true
end

function m.clean(dirtyTable)
  local cleanTable = {}
  local success, err = _cleanTable(dirtyTable, cleanTable)
  if not success then
    error(err)
  end
  return cleanTable
end

return m