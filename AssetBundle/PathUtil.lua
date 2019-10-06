local m = {}

-- Returns the index of the last instance of 'char'.
local function findLastInstanceOf(path, char, start)
  return path:find(string.format("%s[^%s]*$", char, char), start or 1)
end

-- Removes any oddities from the path
-- which could cause other functions to
-- return incorrect results.
function m.cleanPath(path)
  -- Replaces backslashes and groups of
  -- slashes with single forward slashes.
  path = path:gsub("[/\\]+", "/")
  return path
end

-- Splits a path into two components.
-- The head being everything leading
-- up to and including the final
-- forward slash.
-- And the tail being everthing after
-- the final foward slash.
function m.split(path)
  local lastSlash = findLastInstanceOf(path, "/") or 0
  local head = path:sub(1, lastSlash)
  local tail = path:sub(lastSlash+1)
  return head, tail
end

-- Splits a path into two components.
-- The root being everything leading
-- up to the final fullstop.
-- And the ext being the final
-- fullstop and everthing after it.
-- NOTE: Final fullstop must be after
-- the final forward slash.
function m.splitExt(path)
  local lastSlash = findLastInstanceOf(path, "/") or 0
  local lastDot = findLastInstanceOf(path, "%.", lastSlash)
  if lastDot == nil then
    return path, nil
  end
  local root = path:sub(1, lastDot-1)
  local ext = path:sub(lastDot)
  return root, ext
end

-- Returns the first result
-- from split().
-- E.g. "/foo/bar"
-- would return "/foo/"
function m.dirName(path)
  local head, _ = m.split(path)
  return head
end

-- Returns the second result
-- from split().
-- E.g. "/foo/bar"
-- would return "bar"
function m.baseName(path)
  local _, tail = m.split(path)
  return tail
end

-- Joins two paths together into a single path.
-- Will return the second path in the case
-- it is absolute or if the first path
-- is nil or empty.
function m.join(path1, path2)
  -- If path2 begins with '/'
  -- it is treated as an absolute path.
  if path1 == nil or path1 == "" or path2:sub(1, 1) == "/" then
    return path2
  end
  -- Add a forward slash to the end of
  -- path1, if it doesnt already have.
  if path1:sub(-1) ~= "/" then
    path1 = path1 .. "/"
  end
  return path1 .. path2
end

return m