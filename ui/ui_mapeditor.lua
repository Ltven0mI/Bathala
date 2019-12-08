local Lewd = require "core.lewd"
local UTF8 = require "utf8"

local _local = {}
function _local.new()
    local t = Lewd.element{x=0, y=0, w="100%", h="100%", parent=nil}
    
    t.selectionLayout = Lewd.layout{w=250, h=214, layoutType="vertical", padding={right=2, bottom=2}, horizontalAlignment="right", verticalAlignment="bottom", parent=t}

    -- [[ Selection Tabs ]] --
    t.selectionTabs = Lewd.tabgroup{w="100%", h=197, buttonWidth=30, buttonHeight=24, parent=t.selectionLayout}

    -- [[ Tile Selection Grid ]] --
    t.tileSelectionResultGrid = Lewd.gridlayout{w="100%", h=170, entryWidth=32, entryHeight=64, entryPadding={top=8, left=8, bottom=8}}
    t.tileSelectionResultGrid.draw = function(self, x, y)
        love.graphics.setColor(1, 1, 1, 1)
        local realW, realH = self:getRealSize()
        _local.drawBorder(x, y, realW, realH, true)
        return Lewd.gridlayout.draw(self, x, y)
    end
    t.tileSelectionResultGrid.drawEntry = function(self, entry, element, x, y, w, h)
        local offsetY = 0

        -- [[ Set color based on whether the tile is selected or not ]] --
        if entry == self.selectedEntry then
            love.graphics.setColor(1, 1, 1, 1)
        elseif element.isHovered then
            love.graphics.setColor(0.7, 0.7, 0.7, 1)
            offsetY = -2
        else
            love.graphics.setColor(0.5, 0.5, 0.5, 1)
        end
        _local.drawBorder(x, y + offsetY, w+2, h+2)
        
        if entry == self.selectedEntry then
            love.graphics.rectangle("fill", x-1, y+h+4 + offsetY, w+4, 2)
        end

        if entry.icon then
            love.graphics.setColor(1, 1, 1, 1)
            love.graphics.draw(entry.icon, x+1, y+1 + offsetY, 0, 2, 2)
        end
    end
    t.selectionTabs:newTab(t.tileSelectionResultGrid, love.graphics.newImage("assets/images/ui/mapeditor/tileselection_tab.png"))
    -- \\ End Tile Selection Grid // --

    -- [[ Entity Selection Grid ]] --
    t.entitySelectionResultGrid = Lewd.gridlayout{w="100%", h=170, entryWidth=32, entryHeight=64, entryPadding={top=8, left=8, bottom=8}}
    t.entitySelectionResultGrid.draw = function(self, x, y)
        love.graphics.setColor(1, 1, 1, 1)
        local realW, realH = self:getRealSize()
        _local.drawBorder(x, y, realW, realH, true)
        return Lewd.gridlayout.draw(self, x, y)
    end
    t.entitySelectionResultGrid.drawEntry = function(self, entry, element, x, y, w, h)
        local offsetY = 0

        -- [[ Set color based on whether the tile is selected or not ]] --
        if entry == self.selectedEntry then
            love.graphics.setColor(1, 1, 1, 1)
        elseif element.isHovered then
            love.graphics.setColor(0.7, 0.7, 0.7, 1)
            offsetY = -2
        else
            love.graphics.setColor(0.5, 0.5, 0.5, 1)
        end
        _local.drawBorder(x, y + offsetY, w+2, h+2)
        
        if entry == self.selectedEntry then
            love.graphics.rectangle("fill", x-1, y+h+4 + offsetY, w+4, 2)
        end

        if entry.icon then
            love.graphics.setColor(1, 1, 1, 1)
            love.graphics.draw(entry.icon, x+1, y+1 + offsetY, 0, 2, 2)
        end
    end
    t.selectionTabs:newTab(t.entitySelectionResultGrid, love.graphics.newImage("assets/images/ui/mapeditor/entityselection_tab.png"))
    -- \\ End Entity Selection Grid // --
    
    t.selectionTabs:setSelectedTab(1)
    -- \\ End Selection Tabs // --

    t.selectionSearchBar = Lewd.textbox{w="100%", h=17, cursorH=12, value="", placeholder="Search Tiles", parent=t.selectionLayout}

    return t
end


-- [[ Drawing Functions ]] --

function _local.drawBorder(x, y, w, h, ignoreTop, ignoreBottom, ignoreLeft, ignoreRight)
    if not ignoreTop then love.graphics.rectangle("fill", x, y, w, 1) end -- Top
    if not ignoreBottom then love.graphics.rectangle("fill", x, y+h-1, w, 1) end -- Bottom
    if not ignoreLeft then love.graphics.rectangle("fill", x, y, 1, h) end -- Left
    if not ignoreRight then love.graphics.rectangle("fill", x+w-1, y, 1, h) end -- Right
end
-- \\ End Drawing Functions // --


-- [[ Custom Lewd Elements ]] --

Lewd.core.newElementType("textbox", {
    __extends="layout",
    init = function(self, data)
        data = data or {}
        Lewd.layout.init(self, data)

        self.value = data.value or ""
        self.placeholder = data.placeholder or ""
        self.layoutType = "horizontal"

        self.label = Lewd.label{text=self.value, padding={left=4}, wrapContent=true, verticalAlignment="top", ignoresInput=true, parent=self}
        self.placeholderLabel = Lewd.label{text=self.placeholder, style={fg_color={0.5, 0.5, 0.5, 1}}, padding={left=4}, wrapContent=true, verticalAlignment="top", ignoresInput=true, isVisible=false, parent=self}
        self.cursor = Lewd.element{w=2, h=data.cursorH or "100%", padding={left=1}, verticalAlignment="centre", isVisible=false, ignoresInput=true, parent=self}
        self.cursor.draw = function(element, x, y)
            if math.floor(love.timer.getTime() * 3.5) % 2 ~= 1 then
                local realW, realH = element:getRealSize()
                love.graphics.rectangle("fill", x, y, realW, realH)
            end
            return Lewd.element.draw(element, x, y)
        end

        self:setValue(self.value, true)
    end,
    setValue = function(self, value, ignoreCallback)
        self.value = value
        self.label:setText(value)
        self:updateLabelVisibility()
        if not ignoreCallback and self.onValueChanged then
            self:onValueChanged(value)
        end
    end,
    getValue = function(self)
        return self.value
    end,
    updateLabelVisibility = function(self)
        local showPlaceholder = ((self.value == nil or self.value:len() == 0) and not self.isSelected)
        self.label:setIsVisible(not showPlaceholder)
        self.placeholderLabel:setIsVisible(showPlaceholder)
    end,
    draw = function(self, x, y)
        local realW, realH = self:getRealSize()
        love.graphics.setColor(1, 1, 1, 1)
        _local.drawBorder(x, y-1, realW, realH+1)
        return Lewd.layout.draw(self, x, y)
    end,
    onKeyPressed = function(self, key, scancode, isRepeat)
        if key == "backspace" then
            -- get the byte offset to the last UTF-8 character in the string.
            local byteoffset = UTF8.offset(self:getValue(), -1)
     
            if byteoffset then
                -- remove the last UTF-8 character.
                -- string.sub operates on bytes rather than UTF-8 characters, so we couldn't do string.sub(text, 1, -2).
                local newText = string.sub(self:getValue(), 1, byteoffset - 1)
                self:setValue(newText)
            end
        elseif key == "return" then
            Lewd.core.setSelectedElement(nil)
        end
    end,
    onTextInput = function(self, text)
        self:setValue(self:getValue() .. text)
    end,
    onFocused = function(self)
        self.cursor:setIsVisible(true)
        self:updateLabelVisibility()
    end,
    onLostFocus = function(self)
        self.cursor:setIsVisible(false)
        self:updateLabelVisibility()
    end
})

Lewd.core.newElementType("gridlayout", {
    __extends="element",
    init = function(self, data)
        data = data or {}
        Lewd.element.init(self, data)

        self.entryWidth = data.entryWidth or Lewd.style.unit
        self.entryHeight = data.entryHeight or Lewd.style.unit

        self.entryPadding = data.entryPadding or {}
        self.entryPadding.left = self.entryPadding.left or 0
        self.entryPadding.right = self.entryPadding.right or 0
        self.entryPadding.top = self.entryPadding.top or 0
        self.entryPadding.bottom = self.entryPadding.bottom or 0

        self.rows = data.rows
        self.columns = data.columns
        self:setEntries(data.entries or {}, true)
    end,
    setSelectedEntry = function(self, entry)
        self.selectedEntry = entry
        if self.onSelectedEntryChanged then
            self:onSelectedEntryChanged(entry)
        end
    end,
    setEntries = function(self, entries)
        self.entries = entries
        local childCount = #self.children
        local entryCount = #self.entries

        if childCount < entryCount then
            -- Need to add more elements
            for i=childCount+1, entryCount do
                local element = Lewd.element{w=self.entryWidth, h=self.entryHeight, padding=self.entryPadding, parent=self}
                element.entryID = i
                element.draw = function(element, x, y)
                    if element.parent.drawEntry then
                        local realW, realH = element:getRealSize()
                        element.parent:drawEntry(element.parent.entries[element.entryID], element, x, y, realW, realH)
                    end
                    return Lewd.element.draw(element, x, y)
                end
                element.onClick = function(element)
                    self:setSelectedEntry(element.parent.entries[element.entryID])
                end
            end
        else
            -- Need to remove elements
            while #self.children > entryCount do
                self:removeChild(self.children[entryCount + 1])
            end
        end
    end,
    draw = function(self, x, y)
        self:createZoneEntry()

        local realW, realH = self:getRealSize()
        local realPadding = self:getRealPadding()

        local childWidthSum, childHeightSum = 0, 0
        local rowWidth, columnHeight = 0, 0
        for i, child in ipairs(self.children) do
            if child.isVisible then
                local realChildPaddedW, realChildPaddedH = child:getRealPaddedSize()
                local realChildPadding = child:getRealPadding()

                local offsetX, offsetY = 0, 0
                if rowWidth + realChildPaddedW > realW then
                    -- This is when it moves to the next column
                    childWidthSum = math.max(childWidthSum, rowWidth)
                    childHeightSum = childHeightSum + columnHeight
                    rowWidth = 0
                    columnHeight = 0

                    if childHeightSum + realChildPaddedH > realH then
                        -- Hit the last row
                        break
                    end
                end

                offsetX = rowWidth + realChildPadding.left
                offsetY = childHeightSum + realChildPadding.top

                local offsetWidth, offsetHeight = child:draw(x + offsetX, y + offsetY)

                rowWidth = rowWidth + offsetWidth
                columnHeight = math.max(columnHeight, offsetHeight)
            end
        end
        childHeightSum = childHeightSum + columnHeight

        if self.wrapContent then
            realW = childWidthSum
            realH = childHeightSum
        end

        self:updateZoneEntry(x, y, realW, realH)

        return realW + realPadding.left + realPadding.right, realH + realPadding.top + realPadding.bottom
    end
})

Lewd.core.newElementType("tabbutton", {
    __extends="element",
    init = function(self, data)
        data = data or {}
        Lewd.element.init(self, data)

        self.icon = data.icon
        self.tabgroup = data.tabgroup
        self.tabId = data.tabId
    end,
    draw = function(self, x, y)
        local offsetY = (self.isHovered and self.tabId ~= self.tabgroup.selectedTabId) and -2 or 0
        local realW, realH = self:getRealSize()
        love.graphics.setColor(1, 1, 1, 1)
        if self.icon then
            love.graphics.draw(self.icon, x+1, y+1 + offsetY)
        end
        if self.tabId == self.tabgroup.selectedTabId then
            local parentW, parentH = self.parent:getRealSize()
            _local.drawBorder(x, y + offsetY, realW, parentH+3, false, true, false, false)
        else
            _local.drawBorder(x, y + offsetY, realW, realH)
        end
        return Lewd.element.draw(self, x, y)
    end
})

Lewd.core.newElementType("tabgroup", {
    __extends="layout",
    init = function(self, data)
        data = data or {}
        Lewd.layout.init(self, data)

        self.layoutType = "vertical"

        self.selectedTabId = 0
        self.selectedTabElement = nil

        self.buttonWidth = data.buttonWidth or self.style.unit * 2
        self.buttonHeight = data.buttonHeight or self.style.unit * 2

        self.tabButtonLayout = Lewd.layout{w="100%", h=self.buttonHeight, padding={bottom=3}, layoutType="horizontal", parent=self}

        self.tabElements = {}
    end,
    draw = function(self, x, y)
        local drawResultW, drawResultH = Lewd.layout.draw(self, x, y)

        local realW, realH = self:getRealSize()
        local selectedButton = self.tabButtonLayout.children[self.selectedTabId]
        if selectedButton then
            local tabZone = selectedButton:getZone()
            if tabZone then
                local realTabLayoutW, realTabLayoutH = self.tabButtonLayout:getRealSize()
                love.graphics.rectangle("fill", x, y+realTabLayoutH+3-1, tabZone.x - x, 1)
                love.graphics.rectangle("fill", tabZone.x+tabZone.w, y+realTabLayoutH+3-1, realW - ((tabZone.x + tabZone.w)-x), 1)
            end
        else
            _local.drawBorder(x, y, realW, realH, true, false, true, true)
        end
        return drawResultW, drawResultH
    end,
    setSelectedTab = function(self, tabId, ignoreCallback)
        local lastTabElement = self.tabElements[self.selectedTabId]
        local tabElement = self.tabElements[tabId]

        if lastTabElement ~= tabElement then
            if lastTabElement then
                lastTabElement:setIsVisible(false)
            end
            if tabElement then
                tabElement:setIsVisible(true)
            end
        end
        self.selectedTabId = tabId
        self.selectedTabElement = tabElement
        if not ignoreCallback and self.onSelectedTabChanged then
            self:onSelectedTabChanged(self.selectedTabElement)
        end
    end,
    newTab = function(self, element, icon)
        local tabId = #self.tabElements+1
        local tabButton = Lewd.tabbutton{w=self.buttonWidth, h=self.buttonHeight, tabgroup=self, tabId=tabId, padding={right=4}, icon=icon, parent=self.tabButtonLayout}
        tabButton.onClick = function(tabbutton)
            self:setSelectedTab(tabbutton.tabId)
        end

        self:addChild(element)
        table.insert(self.tabElements, element)

        element:setIsVisible(false)
    end
})

Lewd.core.registerNewElementTypes()
-- \\ End Custom Lewd Elements // --

return setmetatable({}, {__call = function(_, ...) return _local.new(...) end})