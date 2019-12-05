--[[

    Lewd

    Luv2d
    Ewements
    Wenderwing
    Dynamicawwy

]]

local lewd = {}
local _local = {}

lewd.style = {
    font = love.graphics.getFont(),
    bg_color = {30/256, 30/256, 30/256, 1},
    border_color = {52/256, 52/256, 52/256, 1},
    fg_color = {1, 1, 1, 1},
    text_placeholder_color = {0.5, 0.5, 0.5, 1},
    unit = 18,
    halfunit = 9
}

lewd.const = {
    minDragDistance = 10
}

function lewd.mousepressed(x, y, btn, isTouch, presses)
    -- First update hovered element
    local nextHoveredElement = lewd.core.getZoneDataAt(x, y)
    local lastHoveredElement = lewd.core.hoveredElement
    lewd.core.hoveredElement = nextHoveredElement

    if nextHoveredElement ~= lastHoveredElement then
        if lastHoveredElement then
            lastHoveredElement.isHovered = false
            if lastHoveredElement.onMouseLeave then lastHoveredElement:onMouseLeave() end
        end
        if nextHoveredElement then
            nextHoveredElement.isHovered = true
            if nextHoveredElement.onMouseEnter then nextHoveredElement:onMouseEnter(x, y) end
        end
    end

    local nextSelectedElement = lewd.core.hoveredElement
    lewd.core.setSelectedElement(nextSelectedElement)
    
    if nextSelectedElement ~= nil then
        if nextSelectedElement.onMousePressed then nextSelectedElement:onMousePressed(x, y, btn) end
    end
        
    if btn == 1 then
        lewd.core.dragStartX = x
        lewd.core.dragStartY = y
        lewd.core.isDragging = true
    end
end

function lewd.mousemoved(x, y, dx, dy, isTouch)
    local nextHoveredElement = lewd.core.getZoneDataAt(x, y)
    local lastHoveredElement = lewd.core.hoveredElement
    lewd.core.hoveredElement = nextHoveredElement

    if nextHoveredElement ~= lastHoveredElement then
        if lastHoveredElement then
            lastHoveredElement.isHovered = false
            if lastHoveredElement.onMouseLeave then lastHoveredElement:onMouseLeave() end
        end
        if nextHoveredElement then
            nextHoveredElement.isHovered = true
            if nextHoveredElement.onMouseEnter then nextHoveredElement:onMouseEnter(x, y) end
        end
    end

    if nextHoveredElement ~= nil then
        if nextHoveredElement.onMouseMoved then
            nextHoveredElement:onMouseMoved(x, y, dx, dy)
        end
    end

    local selectedElement = lewd.core.selectedElement
    if lewd.core.draggedElement == nil and selectedElement ~= nil and lewd.core.isDragging then
        local draggedDistance = lewd.util.dist(lewd.core.dragStartX, lewd.core.dragStartY, x, y)
        if draggedDistance >= lewd.const.minDragDistance then
            lewd.core.draggedElement = selectedElement
        end
    end

    local draggedElement = lewd.core.draggedElement
    if draggedElement then
        if selectedElement.onDragged then selectedElement:onDragged(x, y, dx, dy) end
    end
end

function lewd.mousereleased(x, y, btn, isTouch, presses)
    local selectedElement = lewd.core.selectedElement
    if selectedElement and selectedElement.onMouseReleased then
        selectedElement:onMouseReleased(x, y, btn)
    end

    if btn == 1 then
        local draggedElement = lewd.core.draggedElement
        if draggedElement and draggedElement.onDropped then draggedElement:onDropped(x, y) end
        lewd.core.draggedElement = nil

        lewd.core.dragStartX = nil
        lewd.core.dragStartY = nil
        lewd.core.isDragging = false
    end
    -- if btn == 1 then
    --     local nextElement = lewd.core.getZoneDataAt(x, y)
    --     local selectedElement = lewd.core.selectedElement
    --     print(selectedElement, nextElement)
    --     if selectedElement == nextElement and nextElement ~= nil then
    --         if selectedElement.onClick then selectedElement:onClick() end
    --     end
    --     -- ! Need to be able to check if mouse is still inside elements drawn rect
    -- end
end

function lewd.keypressed(key, scancode, isRepeat)
    local selectedElement = lewd.core.selectedElement
    if selectedElement and selectedElement.onKeyPressed then
        selectedElement:onKeyPressed(key, scancode, isRepeat)
    end
end

function lewd.textinput(text)
    local selectedElement = lewd.core.selectedElement
    if selectedElement and selectedElement.onTextInput then
        selectedElement:onTextInput(text)
    end
end

lewd.util = {
    clamp = function(num, min, max)
        if min > max then
            error(string.format("Invalid min and max values to 'clamp()' max=%s, min=%s. max must be greater than min.", min, max))
        end
        if num < min then num = min end
        if num > max then num = max end
        return num
    end,

    angleBetween = function(x1, y1, x2, y2)
        return math.atan2(y2-y1, x2-x1)
    end,

    dist = function(x1,y1, x2,y2) return ((x2-x1)^2+(y2-y1)^2)^0.5 end,

    round = function(x, decimals)
        -- This should be less naive about multiplication and division if you are 
        -- care about accuracy around edges like: numbers close to the higher
        -- values of a float or if you are rounding to large numbers of decimals.
        local n = 10^(decimals or 0)
        x = x * n
        if x >= 0 then x = math.floor(x + 0.5) else x = math.ceil(x - 0.5) end
        return x / n
    end,

    checkArgument = function(value, argNum, funcName, allowedTypes)
        local valueType = type(value)
        for _, typeToCheck in ipairs(allowedTypes) do
            if valueType == typeToCheck then
                return -- Since value is allowed just return
            end
        end

        local allowedText = ""
        if #allowedTypes == 1 then
            allowedText = allowedTypes[1]
        elseif #allowedTypes > 1 then
            for k, allowedType in ipairs(allowedTypes) do
                local seperator = ""
                if k > 1 and k < #allowedTypes then
                    seperator = ", "
                elseif k >= #allowedTypes then
                    seperator = " or "
                end
                allowedText = allowedText .. seperator .. allowedType
            end
        end

        local pattern = "bad argument #%s to '%s' ( got %s, expected %s )"
        local msg = string.format(pattern, argNum, funcName, valueType, allowedText)
        error(msg, 2)
    end,

    splitModifiedNumber = function(modifiedNumber)
        if type(modifiedNumber) == "number" then
            return modifiedNumber -- Number is regular number so just return
        end

        local numStr, modifier = modifiedNumber:match("^(.-)([%%]?)$")
        local rawNumber = tonumber(numStr)
        if rawNumber == nil then
            error(string.format("Unable to split modified-number '%s' not a valid number!", modifiedNumber))
        end

        return numStr, modifier
    end,

    modifyNumber = function(rawNumber, modifier, specialNumber)
        if modifier == nil or modifier == "" then
            return rawNumber
        elseif modifier == "%" then
            return specialNumber * (rawNumber / 100)
        else
            error(string.format("Unknown number modifier '%'", modifier))
        end
    end
}

lewd.core = {
    unregisteredElementTypes = {},

    newElementType = function(elementType, t)
        lewd.util.checkArgument(elementType, 1, "newElementType", {"string"})
        lewd.util.checkArgument(t, 2, "newElementType", {"table"})

        if lewd[elementType] or lewd.core.unregisteredElementTypes[elementType] then
            error(string.format("Lewd Element of type '%s' already exists!", elementType), 2)
        end

        if type(t.init) ~= "function" then
            error(string.format("Lewd Elements must have an 'init()' function!"), 2)
        end

        print("newElement", elementType)

        lewd.core.unregisteredElementTypes[elementType] = t
    end,

    registerNewElementTypes = function()
        for elementType, t in pairs(lewd.core.unregisteredElementTypes) do
            local baseElement = nil
            if t.__extends then
                -- No self extension thanks
                if t.__extends == elementType then
                    error(string.format("Lewd Element '%s' tried to extend from itself...", elementType))
                end

                -- Get the base element that 't' should extend from
                baseElement = lewd[t.__extends] or lewd.core.unregisteredElementTypes[t.__extends]
                if baseElement == nil then
                    error(string.format(
                        "Lewd Element '%s' tried to extend unknown Element '%s'",
                        elementType, t.__extends))
                end
            end

            print(elementType, baseElement)
            t.__base = baseElement

            -- Insert the 't' into lewd ;)
            lewd[elementType] = setmetatable(t, {
                __call = function(element, ...)
                    local instance = setmetatable({}, {__index=element})
                    element.init(instance, ...)
                    if instance.postInit then instance:postInit() end
                    return instance
                end,
                __index = baseElement
            })
        end

        -- Clear unregisteredElementTypes table
        lewd.core.unregisteredElementTypes = {}
    end,

    zones = {},
    createZoneEntry = function(data)
        table.insert(lewd.core.zones, {x=0, y=0, w=0, h=0, data=data})
        return #lewd.core.zones
    end,
    updateZoneEntry = function(zoneId, x, y, w, h)
        local zone = lewd.core.zones[zoneId]
        if zone == nil then
            error(string.format("Tried to update zone with out of range zoneId '%s'", zoneId))
        end
        zone.x = x
        zone.y = y
        zone.w = w
        zone.h = h
    end,
    -- setZoneData = function(x, y, w, h, data)
    --     table.insert(lewd.core.zones, {x=x, y=y, w=w, h=h, data=data})
    --     -- ! CALL THIS FROM INSIDE ELEMENT DRAW CALLS
    -- end,
    getZoneDataAt = function(x, y)
        for i=#lewd.core.zones, 1, -1 do
            local zone = lewd.core.zones[i]
            if x >= zone.x and x < zone.x + zone.w and
            y >= zone.y and y < zone.y + zone.h then
                return zone.data
            end
            -- ! USE THIS FOR CLICKING ON ELEMENTS
        end
    end,
    clearZones = function()
        lewd.core.zones = {}
    end,
    drawZoneMap = function()
        for i=1, #lewd.core.zones do
            local zone = lewd.core.zones[i]
            love.graphics.setColor(0.1, 0.1, 0.1 + 0.9 * ((i / #lewd.core.zones)), 0.5)
            love.graphics.rectangle("fill", zone.x, zone.y, zone.w, zone.h)
        end
    end,

    setSelectedElement = function(element)
        local nextSelectedElement = element
        local lastSelectedElement = lewd.core.selectedElement
        lewd.core.selectedElement = nextSelectedElement

        if nextSelectedElement ~= lastSelectedElement then
            if lastSelectedElement ~= nil then
                lastSelectedElement.isSelected = false
                if lastSelectedElement.onLostFocus then lastSelectedElement:onLostFocus() end
            end
            if nextSelectedElement ~= nil then
                nextSelectedElement.isSelected = true
                if nextSelectedElement.onFocused then nextSelectedElement:onFocused() end
            end
        end
    end
}

lewd.core.newElementType("element", {
    __extends = nil,
    init = function(self, data)
        data = data or {}
        self.x = data.x or 0
        self.y = data.y or 0
        self.w = data.w or lewd.style.unit
        self.h = data.h or lewd.style.unit
        self.zoneId = nil
        -- isVisible defaults to true and so it must be handled slightly differently
        self.isVisible = data.isVisible
        if self.isVisible == nil then self.isVisible = true end

        self.ignoresInput = data.ignoresInput or false
        self.wrapContent = data.wrapContent or false
        self.horizontalAlignment = data.horizontalAlignment or "none"
        self.verticalAlignment = data.verticalAlignment or "none"
        self.padding = {
            top=data.padding and (data.padding.top or 0) or 0,
            bottom=data.padding and (data.padding.bottom or 0) or 0,
            left=data.padding and (data.padding.left or 0) or 0,
            right=data.padding and (data.padding.right or 0) or 0
        }
        if data.parent then
            data.parent:addChild(self)
        end
        self.children = {}
        self.style = setmetatable((data.style or {}), {__index=lewd.style})
    end,
    draw = function(self, x, y)
        local realW, realH = self:getRealSize()
        local realPadding = self:getRealPadding()

        -- love.graphics.setColor(1, 1, 1, 1)
        -- love.graphics.rectangle("line", x, y, realW, realH)

        self:createZoneEntry()

        for _, child in ipairs(self.children) do
            if child.isVisible then
                local childX, childY = child:getRealPos()
                local offsetWidth, offsetHeight = child:draw(x + childX, y + childY)
            end
        end

        self:updateZoneEntry(x, y, realW, realH)

        return realW + realPadding.left + realPadding.right, realH + realPadding.top + realPadding.bottom
    end,
    onMouseReleased = function(self, x, y, btn)
        if btn == 1 and self.isHovered then
            if self.onClick then self:onClick() end
        end
    end,
    createZoneEntry = function(self)
        if self.ignoresInput then return end
        self.zoneId = lewd.core.createZoneEntry(self)
    end,
    updateZoneEntry = function(self, x, y, w, h)
        if self.ignoresInput then return end
        lewd.core.updateZoneEntry(self.zoneId, x, y, w, h)
    end,
    getZone = function(self)
        if self.zoneId == nil then return nil end
        return lewd.core.zones[self.zoneId]
    end,
    setIsVisible = function(self, isVisible)
        self.isVisible = isVisible
    end,
    getRealPos = function(self)
        local parentW, parentH
        if self.parent then
            parentW, parentH = self.parent:getRealSize()
        else
            parentW, parentH = love.graphics.getDimensions()
        end

        local realX, realY
        local rawX, modifierX = lewd.util.splitModifiedNumber(self.x)
        realX = lewd.util.modifyNumber(rawX, modifierX, parentW)

        local rawY, modifierY = lewd.util.splitModifiedNumber(self.y)
        realY = lewd.util.modifyNumber(rawY, modifierY, parentH)

        -- Get Padding
        local rawPaddingLeft, modifierLeft = lewd.util.splitModifiedNumber(self.padding.left)
        local realPaddingLeft = lewd.util.modifyNumber(rawPaddingLeft, modifierLeft, parentW)
        local rawPaddingRight, modifierRight = lewd.util.splitModifiedNumber(self.padding.right)
        local realPaddingRight = lewd.util.modifyNumber(rawPaddingRight, modifierRight, parentW)
        
        local rawPaddingTop, modifierTop = lewd.util.splitModifiedNumber(self.padding.top)
        local realPaddingTop = lewd.util.modifyNumber(rawPaddingTop, modifierTop, parentH)
        local rawPaddingBottom, modifierBottom = lewd.util.splitModifiedNumber(self.padding.bottom)
        local realPaddingBottom = lewd.util.modifyNumber(rawPaddingBottom, modifierBottom, parentH)
        
        -- Add left padding to realX
        realX = realX + realPaddingLeft

        -- Add top padding to realY
        realY = realY + realPaddingTop

        if self.horizontalAlignment ~= "none" then
            local realW, realH = self:getRealSize()
            if self.horizontalAlignment == "left" then
                realX = realPaddingLeft
            elseif self.horizontalAlignment == "centre" then
                realX = math.floor(parentW / 2) - math.floor(realW / 2)
                --! May need to make this take into account padding...
            elseif self.horizontalAlignment == "right" then
                realX = parentW - realW - realPaddingRight
            end
        end

        if self.verticalAlignment ~= "none" then
            local realW, realH = self:getRealSize()
            if self.verticalAlignment == "top" then
                realY = realPaddingTop
            elseif self.verticalAlignment == "centre" then
                realY = math.floor(parentH / 2) - math.floor(realH / 2)
                --! May need to make this take into account padding...
            elseif self.verticalAlignment == "bottom" then
                realY = parentH - realH - realPaddingBottom
            end
        end

        return realX, realY
    end,
    getRealSize = function(self)
        local parentW, parentH
        if self.parent then
            parentW, parentH = self.parent:getRealSize()
        else
            parentW, parentH = love.graphics.getDimensions()
        end

        local realW, realH
        local rawW, modifierW = lewd.util.splitModifiedNumber(self.w)
        realW = lewd.util.modifyNumber(rawW, modifierW, parentW)

        local rawH, modifierH = lewd.util.splitModifiedNumber(self.h)
        realH = lewd.util.modifyNumber(rawH, modifierH, parentH)

        return realW, realH
    end,
    getRealPadding = function(self)
        local parentW, parentH
        if self.parent then
            parentW, parentH = self.parent:getRealSize()
        else
            parentW, parentH = love.graphics.getDimensions()
        end

        local rawPaddingLeft, modifierLeft = lewd.util.splitModifiedNumber(self.padding.left)
        realPaddingLeft = lewd.util.modifyNumber(rawPaddingLeft, modifierLeft, parentW)

        local rawPaddingRight, modifierRight = lewd.util.splitModifiedNumber(self.padding.right)
        realPaddingRight = lewd.util.modifyNumber(rawPaddingRight, modifierRight, parentW)

        local rawPaddingTop, modifierTop = lewd.util.splitModifiedNumber(self.padding.top)
        realPaddingTop = lewd.util.modifyNumber(rawPaddingTop, modifierTop, parentH)

        local rawPaddingBottom, modifierBottom = lewd.util.splitModifiedNumber(self.padding.bottom)
        realPaddingBottom = lewd.util.modifyNumber(rawPaddingBottom, modifierBottom, parentH)

        return {
            top = realPaddingTop,
            bottom = realPaddingBottom,
            left = realPaddingLeft,
            right = realPaddingRight
        }
    end,
    getRealPaddedSize = function(self)
        local parentW, parentH
        if self.parent then
            parentW, parentH = self.parent:getRealSize()
        else
            parentW, parentH = love.graphics.getDimensions()
        end

        local realW, realH
        local rawW, modifierW = lewd.util.splitModifiedNumber(self.w)
        realW = lewd.util.modifyNumber(rawW, modifierW, parentW)

        local rawH, modifierH = lewd.util.splitModifiedNumber(self.h)
        realH = lewd.util.modifyNumber(rawH, modifierH, parentH)

        -- Add horizontal padding to the total real width
        local rawPaddingLeft, modifierLeft = lewd.util.splitModifiedNumber(self.padding.left)
        realW = realW + lewd.util.modifyNumber(rawPaddingLeft, modifierLeft, parentW)

        local rawPaddingRight, modifierRight = lewd.util.splitModifiedNumber(self.padding.right)
        realW = realW + lewd.util.modifyNumber(rawPaddingRight, modifierRight, parentW)

        -- Add vertical padding to the total real height
        local rawPaddingTop, modifierTop = lewd.util.splitModifiedNumber(self.padding.top)
        realH = realH + lewd.util.modifyNumber(rawPaddingTop, modifierTop, parentH)

        local rawPaddingBottom, modifierBottom = lewd.util.splitModifiedNumber(self.padding.bottom)
        realH = realH + lewd.util.modifyNumber(rawPaddingBottom, modifierBottom, parentH)

        return realW, realH
    end,
    addChild = function(self, childElement)
        table.insert(self.children, childElement)
        childElement.parent = self
    end,
    removeChild = function(self, childElement)
        for k, child in ipairs(self.children) do
            if child == childElement then
                table.remove(self.children, k)
                return
            end
        end
        error(string.format("Tried to remove a non existing child '%s'", childElement))
    end
    -- containsPoint = function(self, x, y)
    --     return (x >= self.drawnX and x < self.drawnX + self.drawnW and
    --     y >= self.drawnY and y < self.drawnY + self.drawnH)
    -- end
    -- * Commented out function as it is believed to be obsolete
})

lewd.core.newElementType("layout", {
    __extends = "element",
    init = function(self, data)
        data = data or {}
        lewd.element.init(self, data)
        self.layoutType = data.layoutType or "none"
    end,
    draw = function(self, x, y)
        self:createZoneEntry()

        local realW, realH = self:getRealSize()
        local realPadding = self:getRealPadding()

        -- love.graphics.setColor(1, 1, 0, 1)
        -- love.graphics.rectangle("line", x, y, realW, realH)

        local childWidthSum, childHeightSum = 0, 0
        for _, child in ipairs(self.children) do
            if child.isVisible then
                local childX, childY = child:getRealPos()
                local childPadding = child:getRealPadding()

                local offsetX, offsetY = 0, 0
                if self.layoutType == "vertical" then
                    childY = childPadding.top
                    offsetY = childHeightSum
                elseif self.layoutType == "horizontal" then
                    childX = childPadding.left
                    offsetX = childWidthSum
                end

                local offsetWidth, offsetHeight = child:draw(x + offsetX + childX, y + offsetY + childY)

                if self.layoutType == "vertical" then
                    childWidthSum = math.max(childWidthSum, offsetWidth)
                    childHeightSum = childHeightSum + offsetHeight
                elseif self.layoutType == "horizontal" then
                    childWidthSum = childWidthSum + offsetWidth
                    childHeightSum = math.max(childHeightSum, offsetHeight)
                end
            end
        end

        if self.wrapContent then
            realW = childWidthSum
            realH = childHeightSum
        end

        -- TODO: Need to change realW or realH to fit child elements

        self:updateZoneEntry(x, y, realW, realH)

        return realW + realPadding.left + realPadding.right, realH + realPadding.top + realPadding.bottom
    end,
})

lewd.core.newElementType("button", {
    __extends = "element",
    init = function(self, data)
        data = data or {}
        lewd.element.init(self, data)

        self.label = lewd.label{w="100%", h="100%", textAlignment="centre", text=data.text or "", ignoresInput=true, parent=self}
    end,
    draw = function(self, x, y)
        self:createZoneEntry()

        local realW, realH = self:getRealSize()
        local realPaddedW, realPaddedH = self:getRealPaddedSize()

        for _, child in ipairs(self.children) do
            local childX, childY = child:getRealPos()
            local offsetWidth, offsetHeight = child:draw(x + childX, y + childY)
        end

        love.graphics.setColor(lewd.style.border_color)
        love.graphics.rectangle("fill", x, y, realW, 1) -- Top Border
        love.graphics.rectangle("fill", x, y+realH-1, realW, 1) -- Bottom Border
        love.graphics.rectangle("fill", x, y, 1, realH) -- Left Border
        love.graphics.rectangle("fill", x+realW-1, y, 1, realH) -- Right Border

        self:updateZoneEntry(x, y, realW, realH)
        
        return realPaddedW, realPaddedH
    end,
    setText = function(self, text)
        self.label.text = text
    end
})

lewd.core.newElementType("group", {
    __extends = "element",
    init = function(self, data)
        data = data or {}
        lewd.element.init(self, data)

        self.isCollapsed = data.isCollapsed
        if self.isCollapsed == nil then self.isCollapsed = true end

        self.headerLayout = lewd.layout{w="100%", layoutType="horizontal", wrapContent=true, parent=self}
        self.headerLayout.onClick = function(layout)
            self:setIsCollapsed(not self.isCollapsed)
        end

        self.collapseButton = lewd.button{text="v", ignoresInput=true, parent=self.headerLayout}

        self.headerLabel = lewd.label{text=data.title or "", ignoresInput=true, wrapContent=true, padding={left=lewd.style.halfunit}, parent=self.headerLayout}
    end,
    postInit = function(self)
        self:setIsCollapsed(self.isCollapsed)
    end,
    draw = function(self, x, y)
        self:createZoneEntry()

        local realW, realH = self:getRealSize()
        local realPadding = self:getRealPadding()

        local childHeightSum = 0
        for _, child in ipairs(self.children) do
            if child.isVisible then
                -- Even if isCollapsed then still draw headerLayout.
                if child == self.headerLayout or not self.isCollapsed then
                    local realChildX, realChildY = child:getRealPos()
                    local offsetWidth, offsetHeight = child:draw(x + realChildX, y + childHeightSum)
                    childHeightSum = childHeightSum + offsetHeight
                end
            end
        end

        self:updateZoneEntry(x, y, realW, childHeightSum)

        return realW + realPadding.left + realPadding.right, childHeightSum + realPadding.top + realPadding.bottom
    end,
    setIsCollapsed = function(self, isCollapsed)
        self.isCollapsed = isCollapsed
        if self.isCollapsed then
            self.collapseButton:setText(">")
        else
            self.collapseButton:setText("v")
        end
        if self.onIsCollapsedChanged then self:onIsCollapsedChanged(isCollapsed) end
    end,
    setTitle = function(self, title)
        self.headerLabel.text = title
    end,
    onIsCollapsedChanged = function(self, isCollapsed) end
})

lewd.core.newElementType("label", {
    __extends = "element",
    init = function(self, data)
        data = data or {}
        lewd.element.init(self, data)

        self.text = data.text or ""
        self.textAlignment = data.textAlignment or "left"
        self.wrapContent = data.wrapContent or false
    end,
    draw = function(self, x, y)
        self:createZoneEntry()
        
        local realW, realH = self:getRealSize()
        local realPadding = self:getRealPadding()

        local textW = lewd.style.font:getWidth(self.text)
        local textH = lewd.style.font:getHeight()

        if self.wrapContent then
            realW = textW
            realH = textH
        end

        local textX
        if self.textAlignment == "left" then
            textX = x
        elseif self.textAlignment == "centre" then
            textX = x + math.floor(realW / 2) - math.floor(textW / 2)
        elseif self.textAlignment == "right" then
            textX = x + realW - textW
        else
            error(string.format("Unknown textAlignment value '%s'"))
        end

        love.graphics.setColor(self.style.fg_color)
        love.graphics.print(self.text, textX, y)

        self:updateZoneEntry(textX, y, realW, realH)
        return realW + realPadding.left + realPadding.right, realH + realPadding.top + realPadding.bottom
    end,
    setText = function(self, text)
        self.text = text
    end
})

lewd.core.newElementType("numberinput", {
    __extends = "element",
    init = function(self, data)
        data = data or {}
        lewd.element.init(self, data)

        self.value = data.value or (data.range and data.range.min) or 0
        self.scale = data.scale or 1
        self.decimalPlaces = data.decimalPlaces or 0
        if data.range then
            self.range = {
                min = data.range.min or -math.huge,
                max = data.range.max or math.huge
            }
            print(self.range.min, self.range.max)
        end
    end,
    draw = function(self, x, y)
        self:createZoneEntry()

        local realW, realH = self:getRealSize()
        local realPadding = self:getRealPadding()

        love.graphics.setColor(lewd.style.border_color)
        love.graphics.rectangle("fill", x, y, realW, 1) -- Top Border
        love.graphics.rectangle("fill", x, y+realH-1, realW, 1) -- Bottom Border
        love.graphics.rectangle("fill", x, y, 1, realH) -- Left Border
        love.graphics.rectangle("fill", x+realW-1, y, 1, realH) -- Right Border

        love.graphics.setColor(lewd.style.fg_color)
        love.graphics.print(tostring(self:getValue()), x, y)

        self:updateZoneEntry(x, y, realW, realH)
        return realW + realPadding.left + realPadding.right, realH + realPadding.top + realPadding.bottom
    end,
    onMousePressed = function(self)
        love.mouse.setRelativeMode(true)
    end,
    onMouseReleased = function(self)
        love.mouse.setRelativeMode(false)
    end,
    onDragged = function(self, x, y, dx, dy)
        local shiftScale = love.keyboard.isDown("lshift", "rshift") and 0.1 or 1
        self:setValue(self.value + dx * self.scale * shiftScale)
    end,
    setValue = function(self, value, ignoreCallback)
        local lastValue = self.value
        self.value = value
        if self.range then
            self.value = lewd.util.clamp(value, self.range.min, self.range.max)
        end
        if self.value ~= lastValue and not ignoreCallback then
            if self.onValueChanged then self:onValueChanged(self.value) end
        end
    end,
    getValue = function(self)
        return lewd.util.round(self.value, self.decimalPlaces)
    end
})

lewd.core.registerNewElementTypes()

return lewd