local m = {}
local _local = {}

function m.unitTest(filePath)
    local records, err = m.importOBJRecords(filePath)
    if not records then
        return nil, string.format("Failed to import Records from OBJ file '%s' : %s", filePath, err)
    end

    for _, record in ipairs(records) do
        -- print(string.format("Type: '%s', Data: '%s'", record.type, record.values))
        -- if record.recordType == "f" then
        --     for k, indexGroup in ipairs(record.recordValues) do
        --         print(k, indexGroup.v, indexGroup.vt, indexGroup.vn)
        --     end
        -- end
    end
    
    return m.generateLove2dMeshData(records)
end

function m.generateLove2dMeshData(records)
    local vTable = {}
    local vtTable = {}

    local vertices = {}
    local indices = {}

    for _, record in ipairs(records) do
        local values = record.values

        if record.type == "v" then
            table.insert(vTable, values)
        elseif record.type == "vt" then
            table.insert(vtTable, values)
        elseif record.type == "f" then

            -- TODO: If the same values in an indexgroup are shared by another index group it is a shared vertex

            -- Iterate over all index groups in this face
            for _, indexGroup in ipairs(values) do
                local vData = vTable[indexGroup.v]
                local vtData = vtTable[indexGroup.vt]

                -- Insert a new vertex for every index group
                table.insert(vertices, {
                    -vData[1],   -- x
                    vData[2],   -- y
                    vData[3],   -- z
                    vtData[1],  -- u
                    1-vtData[2],  -- v
                    vData[4],   -- r
                    vData[5],   -- g
                    vData[6],   -- b
                    vData[7]    -- a
                })
                table.insert(indices, #vertices)
            end
        end
    end

    return {vertices=vertices, indices=indices}
end

--[[
    Returns a table containing Records in the same order as in the OBJ file.
    A Record is in the form { type(string) , values(table) }
        'type' is the character or characters at the beginning of each line
        e.g. "v" from "v 16.00 0.00 0.00"

        'values' is a table containing the evaluated values in a format determined by the Record Type.
        e.g. if 'type'=='v' then 'values'=={16.00, 0.00, 0.00}
    Incase of error returns nil and an error message
]]
function m.importOBJRecords(filePath)
    local objFile, err = love.filesystem.newFile(filePath)
    if objFile == nil then
        return nil, err
    end

    local success, err = objFile:open("r")
    if not success then
        return nil, err
    end

    -- Seperate each line into Records containing their type and trailing string
    local records = {}
    local lineNumber = 0
    for line in objFile:lines() do
        lineNumber = lineNumber + 1
        local recordType, recordString = line:match("^([^%s]+)%s+(.+)%s-$")
        if recordType then
            local recordValues, err = m.evaluateRecordString(recordType, recordString)
            if recordValues == nil then
                return nil, string.format("Could not evaluate record values ln#%s '%s' : %s", lineNumber, recordString, err)
            end
            table.insert(records, {type=recordType, values=recordValues})
        end
    end

    objFile:close()

    return records
end


_local.evalFuncs = {
    ["#"]=function(recordString) return true end,
    ["o"]=function(recordString) return true end,
    ["v"]=function(recordString)
        local values = {}
        for numStr in recordString:gmatch("[^%s]+") do
            local realNum = tonumber(numStr)
            if realNum == nil then
                return nil, string.format("Value is not a number '%s'.", numStr)
            end
            table.insert(values, realNum)
        end
        return values
    end,
    ["vt"]=function(recordString)
        local u, v, w

        -- Get the string values
        u, v, w = recordString:match("^([^%s]+)%s+([^%s]+)%s+([^%s]+)")
        if not u then u, v = recordString:match("^([^%s]+)%s+([^%s]+)") end
        if not u then u = u or recordString:match("^([^%s]+)") end

        if u == nil then
            return nil, "Atleast one value must be supplied!"
        end

        -- V and W are optional and default to 0
        v = v or 0
        w = w or 0

        -- Attempt to convert strings to numbers
        local realU = tonumber(u)
        if realU == nil then
            return nil, string.format("First value is not a number '%s'.", u)
        end
        local realV = tonumber(v)
        if realV == nil then
            return nil, string.format("Second value is not a number '%s'.", v)
        end
        local realW = tonumber(w)
        if realW == nil then
            return nil, string.format("Third value is not a number '%s'.", w)
        end

        return {u, v, w}
    end,
    ["vn"]=function(recordString) return true end,
    ["s"]=function(recordString) return true end,
    ["f"]=function(recordString)
        local values = {}
        -- Iterate over each index group
        for indexGroup in recordString:gmatch("[^%s]+") do

            -- Get the string values
            v, vt, vn = indexGroup:match("^([^/]+)/([^/]+)/([^/]+)$")
            if not v then v, vt = indexGroup:match("^([^/]+)/([^/]+)$") end
            if not v then v, vn = indexGroup:match("^([^/]+)//([^/]+)$") end
            if not v then v = indexGroup:match("^([^/]+)$") end

            -- Vertex Index must be specified
            if v == nil then
                return nil, string.format("A vertex index must be specified '%s'", indexGroup)
            end

            local realV, realVT, realVN
            -- Attempt to convert strings to numbers
            realV = tonumber(v)
            if realV == nil then
                return nil, string.format("Vertex index '%s' from indexgroup '%s' is not a number.", v, indexGroup)
            end
            -- Only convert Vertex Texture if it's not nil
            if vt ~= nil then
                realVT = tonumber(vt)
                if realVT == nil then
                    return nil, string.format("Vertex Texture index '%s' from indexgroup '%s' is not a number.", vt, indexGroup)
                end
            end
            -- Only convert Vertex Normal if it's not nil
            if vn ~= nil then
                realVN = tonumber(vn)
                if realVN == nil then
                    return nil, string.format("Vertex Normal index '%s' from indexgroup '%s' is not a number.", vn, indexGroup)
                end
            end

            -- Insert Index Group values
            table.insert(values, {v=realV, vt=realVT, vn=realVN})
        end
        
        return values
    end
}
function m.evaluateRecordString(recordType, recordString)
    local evalFunc = _local.evalFuncs[recordType]
    if not evalFunc then
        return nil, string.format("Unsupported Record Type '%s'.", recordType)
    end
    return evalFunc(recordString)
end

return m