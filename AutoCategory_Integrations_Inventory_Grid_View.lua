--Integration with Inventory Grid View

-----------copied from original file------------

local IGV = InventoryGridView
local util
local settings
local adapter
local LEFT_PADDING = 25

local function UpdateScrollFade(useFadeGradient, scroll, slider, sliderValue)
    if(useFadeGradient) then
        local sliderMin, sliderMax = slider:GetMinMax()
        sliderValue = sliderValue or slider:GetValue()

        if(sliderValue > sliderMin) then
            scroll:SetFadeGradient(1, 0, 1, zo_min(sliderValue - sliderMin, 64))
        else
            scroll:SetFadeGradient(1, 0, 0, 0)
        end

        if(sliderValue < sliderMax) then
            scroll:SetFadeGradient(2, 0, -1, zo_min(sliderMax - sliderValue, 64))
        else
            scroll:SetFadeGradient(2, 0, 0, 0);
        end
    else
        scroll:SetFadeGradient(1, 0, 0, 0)
        scroll:SetFadeGradient(2, 0, 0, 0)
    end
end

local function AreSelectionsEnabled(self)
    return self.selectionTemplate or self.selectionCallback
end

local function RemoveAnimationOnControl(control, animationFieldName, animateInstantly)
    if control[animationFieldName] then
        if animateInstantly then
            control[animationFieldName]:PlayInstantlyToStart()
        else
            control[animationFieldName]:PlayBackward()
        end
    end
end

local function UnhighlightControl(self, control)
    RemoveAnimationOnControl(control, "HighlightAnimation")

    self.highlightedControl = nil

    if(self.highlightCallback) then
        self.highlightCallback(control, false)
    end
end

local function UnselectControl(self, control, animateInstantly)
    RemoveAnimationOnControl(control, "SelectionAnimation", animateInstantly)

    self.selectedControl = nil
end

local function AreDataEqualSelections(self, data1, data2)
    if(data1 == data2) then
        return true
    end

    if(data1 == nil or data2 == nil) then
        return false
    end

    local dataEntry1 = data1.dataEntry
    local dataEntry2 = data2.dataEntry
    if(dataEntry1.typeId == dataEntry2.typeId) then
        local equalityFunction = self.dataTypes[dataEntry1.typeId].equalityFunction
        if(equalityFunction) then
            return equalityFunction(data1, data2)
        end
    end

    return false
end

local function FreeActiveScrollListControl(self, i)
    local currentControl = self.activeControls[i]
    local currentDataEntry = currentControl.dataEntry
    local dataType = self.dataTypes[currentDataEntry.typeId]

    if(self.highlightTemplate and currentControl == self.highlightedControl) then
        UnhighlightControl(self, currentControl)
        if(self.highlightLocked) then
            self.highlightLocked = false
        end
    end

    if(currentControl == self.pendingHighlightControl) then
        self.pendingHighlightControl = nil
    end

    if AreSelectionsEnabled(self) and currentControl == self.selectedControl then
        UnselectControl(self, currentControl, ANIMATE_INSTANTLY)
    end

    if(dataType.hideCallback) then
        dataType.hideCallback(currentControl, currentControl.dataEntry.data)
    end

    dataType.pool:ReleaseObject(currentControl.key)
    currentControl.key = nil
    currentControl.dataEntry = nil
    self.activeControls[i] = self.activeControls[#self.activeControls]
    self.activeControls[#self.activeControls] = nil
end

local HIDE_SCROLLBAR = true
local function ResizeScrollBar(self, scrollableDistance)
    local scrollBarHeight = self.scrollbar:GetHeight()
    local scrollListHeight = ZO_ScrollList_GetHeight(self)
    if(scrollableDistance > 0) then
        self.scrollbar:SetEnabled(true)

        if self.ScrollBarHiddenCallback then
            self.ScrollBarHiddenCallback(self, not HIDE_SCROLLBAR)
        else
            self.scrollbar:SetHidden(false)
        end

        self.scrollbar:SetThumbTextureHeight(scrollBarHeight * scrollListHeight /(scrollableDistance + scrollListHeight))
        if(self.offset > scrollableDistance) then
            self.offset = scrollableDistance
        end
        self.scrollbar:SetMinMax(0, scrollableDistance)
    else
        self.offset = 0
        self.scrollbar:SetThumbTextureHeight(scrollBarHeight)
        self.scrollbar:SetMinMax(0, 0)
        self.scrollbar:SetEnabled(false)

        if(self.hideScrollBarOnDisabled) then
            if self.ScrollBarHiddenCallback then
                self.ScrollBarHiddenCallback(self, HIDE_SCROLLBAR)
            else
                self.scrollbar:SetHidden(true)
            end
        end
    end
end

local function CompareEntries(topEdge, compareData)
    return topEdge - compareData.bottom
end

local SCROLL_LIST_UNIFORM = 1
local function FindStartPoint(self, topEdge)
    if(self.mode == SCROLL_LIST_UNIFORM) then
        return zo_floor(topEdge / self.controlHeight)+1
    else
        local found, insertPoint = zo_binarysearch(topEdge, self.data, CompareEntries)
        return insertPoint
    end
end


local function freeActiveScrollListControls(scrollList)
    if not scrollList or not scrollList.activeControls then return end

    while #scrollList.activeControls > 0 do
        FreeActiveScrollListControl(scrollList, 1)
    end
end
------------------------copied end--------------------------


 
------------------------modified begin--------------------------

local consideredMap = {}
local function IGV_ScrollList_UpdateScroll_Grid(self) 
    local windowHeight = ZO_ScrollList_GetHeight(self)
   
    --Added------------------------------------------------------------------
    local scrollableDistance = 0
    local foundSelected = false
	local currentY = 0
	local lastIndex = 1
    local gridIconSize = settings.GetGridIconSize()
    local isGrid = settings.IsGrid(IGVId)
	if isGrid then
		self.controlHeight = gridIconSize
	else
		self.controlHeight = 52
	end
    local contentsWidth = self.contents:GetWidth()
    local contentsWidthMinusPadding = contentsWidth - LEFT_PADDING
    local itemsPerRow = zo_floor(contentsWidthMinusPadding / gridIconSize)
    local gridSpacing = .5
	local totalControlWidth = gridIconSize + gridSpacing
	local headerRowHeight = AutoCategory.acctSavedVariables.appearance["CATEGORY_HEADER_HEIGHT"]
	for i = 1,#self.data do
		local currentData = self.data[i]
		if currentData.isHeader then
			--Y add header's height
			if i ~= 1 then
				--next row
				currentY = currentY + totalControlWidth *  (zo_floor((i - 1 - lastIndex) / itemsPerRow)  + 1)
			end
			lastIndex = i + 1 
			currentData.top = currentY	
			currentData.bottom = currentY + headerRowHeight
			currentData.left = LEFT_PADDING
			currentY = currentY + headerRowHeight
		else 
			currentData.top = zo_floor((i - lastIndex) / itemsPerRow) * totalControlWidth + currentY
			--d(currentData.top)
			currentData.bottom = currentData.top + totalControlWidth
			currentData.left = (i - lastIndex) % itemsPerRow * totalControlWidth + LEFT_PADDING 
		end 
	end
	currentY = currentY + totalControlWidth *  (zo_floor((#self.data - lastIndex) / itemsPerRow)  + 1)
	scrollableDistance = currentY - windowHeight
 
    ResizeScrollBar(self, scrollableDistance)
    ----------------------------------------------------------------------------

    local controlHeight = self.controlHeight
    local activeControls = self.activeControls
    local offset = self.offset

    UpdateScrollFade(self.useFadeGradient, self.contents, self.scrollbar, offset)
	
    --remove active controls that are now hidden
    local i = 1
    local numActive = #activeControls
    while(i <= numActive) do
        local currentDataEntry = activeControls[i].dataEntry

        if(currentDataEntry.bottom < offset or currentDataEntry.top > offset + windowHeight) then
            FreeActiveScrollListControl(self, i)
            numActive = numActive - 1
        else
            i = i + 1
        end

        consideredMap[currentDataEntry] = true
    end

    --add revealed controls
    local firstInViewIndex = FindStartPoint(self, offset)

    local data = self.data
    local dataTypes = self.dataTypes
    local visibleData = self.visibleData
    local mode = self.mode

    local i = firstInViewIndex
    local visibleDataIndex = visibleData[i]
    local dataEntry = data[visibleDataIndex]
    local bottomEdge = offset + windowHeight

    --Modified------------------------------------------------------------------
    local controlTop, controlLeft

    if dataEntry then
        --removed isUniform check because we're assuming always uniform
        controlTop = dataEntry.top
		controlLeft = dataEntry.left
    end
    ----------------------------------------------------------------------------
    while(dataEntry and controlTop <= bottomEdge) do
        if(not consideredMap[dataEntry]) then
            local dataType = dataTypes[dataEntry.typeId]
            local controlPool = dataType.pool
            local control, key = controlPool:AcquireObject()

            control:SetHidden(false)
            control.dataEntry = dataEntry
            control.key = key
            control.index = visibleDataIndex
            --Added-------------------------------------------------------------
            control.isGrid = false
            --------------------------------------------------------------------
            if(dataType.setupCallback) then
                dataType.setupCallback(control, dataEntry.data, self)
            end
            table.insert(activeControls, control)
            consideredMap[dataEntry] = true

            if(AreDataEqualSelections(self, dataEntry.data, self.selectedData)) then
                SelectControl(self, control, ANIMATE_INSTANTLY)
            end

            --even uniform active controls need to know their position to determine if they are still active
			--Modified-------------------------------------------------------------- 
		 
			------------------------------------------------------------------------
        end
        i = i + 1
        visibleDataIndex = visibleData[i]
        dataEntry = data[visibleDataIndex]
        --Modified--------------------------------------------------------------
        if(dataEntry) then
            --removed isUniform check because we're assuming always uniform
            controlTop = dataEntry.top
			controlLeft = dataEntry.left
        end
        ------------------------------------------------------------------------
    end

    --update positions
    local contents = self.contents
    local numActive = #activeControls

    for i = 1, numActive do
        local currentControl = activeControls[i]
        local currentData = currentControl.dataEntry
        local controlOffset = currentData.top - offset
        --Added-----------------------------------------------------------------
        local controlOffsetX = currentData.left
        ------------------------------------------------------------------------
        currentControl:ClearAnchors()
        --Modified--------------------------------------------------------------
        currentControl:SetAnchor(TOPLEFT, contents, TOPLEFT, controlOffsetX, controlOffset)
        --removed other anchor because this will no longer stretch across the contents pane
        ------------------------------------------------------------------------
    end

    --reset considered
    for k,v in pairs(consideredMap) do
        consideredMap[k] = nil
    end
end
  

function adapter_ScrollController(self)
    if self == IGV.currentScrollList and settings.IsGrid(IGV.currentIGVId) then
        freeActiveScrollListControls(self)
        IGV_ScrollList_UpdateScroll_Grid(self)
        util.ReshapeSlots()

        return true
    else
        return false
    end
end


function adapter_ToggleGrid()
    local IGVId = IGV.currentIGVId
    local scrollList = IGV.currentScrollList

    if not scrollList then return end

    settings.ToggleGrid(IGVId)
    local isGrid = settings.IsGrid(IGVId)

	--change data.left 
    for i = 1, #scrollList.data do				
		local currentData = scrollList.data[i]
		currentData.left = 0
	end
	
    ZO_ScrollList_ResetToTop(scrollList)

    util.ReshapeSlots()
    freeActiveScrollListControls(scrollList)
	ZO_ScrollList_Commit(scrollList)
    ZO_ScrollList_UpdateScroll(scrollList)

    if isGrid then
        util.ReshapeSlots()
    else
        --ResizeScrollBar(scrollList, (#scrollList.data * scrollList.controlHeight) - ZO_ScrollList_GetHeight(scrollList))
    end

    ZO_ScrollList_RefreshVisible(scrollList)
    --util.ReshapeSlots()
end


-------------------------------------------------------------

local function AddColor(control)
    if not control.dataEntry then return end
    if control.dataEntry.data.slotIndex == nil then control.dataEntry.data.quality = 0 end

    local quality = control.dataEntry.data.quality
    local r, g, b = GetInterfaceColor(INTERFACE_COLOR_TYPE_ITEM_QUALITY_COLORS, quality)

    local alpha = 1
    if quality < IGV.settings.GetMinOutlineQuality() then
        alpha = 0
    end

    control:GetNamedChild("Bg"):SetColor(r, g, b, 1)
    control:GetNamedChild("Outline"):SetColor(r, g, b, alpha)
    control:GetNamedChild("Highlight"):SetColor(r, g, b, 0)
end

local oldSetHidden
local function ReshapeSlot(control, isGrid, width, height)
    if control == nil then return end
	if control.dataEntry == nil or control.dataEntry.isHeader then return end
	if height == nil then height = 52 end

    local ICON_MULT = 0.77
    local textureSet = IGV.settings.GetTextureSet()

    if control.isGrid ~= isGrid then
        control.isGrid = isGrid

        local bg = control:GetNamedChild("Bg")
        local highlight = control:GetNamedChild("Highlight")
        local outline = control:GetNamedChild("Outline")
        local new = control:GetNamedChild("Status")
        local button = control:GetNamedChild("Button")
        local name = control:GetNamedChild("Name")
        local sell = control:GetNamedChild("SellPrice")
        --local stat = control:GetNamedChild("StatValue")

        --make sure sell price label stays shown/hidden
        if sell then
            if not oldSetHidden then oldSetHidden = sell.SetHidden end

            sell.SetHidden = function(sell, shouldHide)
                if isGrid and shouldHide then
                    oldSetHidden(sell, shouldHide)
                elseif isGrid then
                    return
                else
                    oldSetHidden(sell, shouldHide)
                end
            end
            --show/hide sell price label
            sell:SetHidden(isGrid)
        end

        --create outline texture for control if missing
        if not outline then
            outline = WINDOW_MANAGER:CreateControl(control:GetName() .. "Outline", control, CT_TEXTURE)
            outline:SetAnchor(CENTER, control, CENTER)
        end
        outline:SetDimensions(height, height)

        if button then
            button:ClearAnchors()
            button:SetDimensions(height * ICON_MULT, height * ICON_MULT)
        end

        if new then new:ClearAnchors() end
		
		--disable status' mouse callback
		new:SetMouseEnabled(false)
		new:GetNamedChild("Texture"):SetMouseEnabled(false)

        control:SetDimensions(width, height)

        if isGrid == true and new ~= nil then
            button:SetAnchor(CENTER, control, CENTER)

            new:SetAnchor(TOPLEFT, button:GetNamedChild("Icon"), TOPLEFT, 0, 0)
            new:SetDrawTier(2)

            name:SetHidden(true)
            --stat:SetHidden(true)

            highlight:SetTexture(textureSet.HOVER)
            highlight:SetTextureCoords(0, 1, 0, 1)

            bg:SetTexture(textureSet.BACKGROUND)
            bg:SetTextureCoords(0, 1, 0, 1)

            if IGV.settings.ShowQualityOutline() then
                outline:SetTexture(textureSet.OUTLINE)
                outline:SetHidden(false)
            else
                outline:SetHidden(true)
            end

            AddColor(control)
        else
            local LIST_SLOT_BACKGROUND = "EsoUI/Art/Miscellaneous/listItem_backdrop.dds"
            local LIST_SLOT_HOVER = "EsoUI/Art/Miscellaneous/listitem_highlight.dds"

            if button then button:SetAnchor(CENTER, control, TOPLEFT, 47, 26) end

            if new then new:SetAnchor(CENTER, control, TOPLEFT, 20, 27) end

            if name then name:SetHidden(false) end
            --if stat then stat:SetHidden(false) end
            outline:SetHidden(true)

            if highlight then
                highlight:SetTexture(LIST_SLOT_HOVER)
                highlight:SetColor(1, 1, 1, 0)
                highlight:SetTextureCoords(0, 1, 0, .625)
            end

            if bg then
                bg:SetTexture(LIST_SLOT_BACKGROUND)
                bg:SetTextureCoords(0, 1, 0, .8125)
                bg:SetColor(1, 1, 1, 1)
            end
        end
    end
end

function util_ReshapeSlots()
    local scrollList = IGV.currentScrollList
    if not scrollList then return end
    local parent = scrollList.contents
    local numControls = parent:GetNumChildren()
    local gridIconSize = IGV.settings.GetGridIconSize()
    local IGVId = IGV.currentIGVId
    local isGrid = IGV.settings.IsGrid(IGVId)

    local width, height

    if isGrid then
        width = gridIconSize
        height = gridIconSize
    else
        width = scrollList:GetWidth()
        height = scrollList.controlHeight
    end

    --CRAFT_BAG, QUICKSLOT, and BUY_BACK don't have the same child element pattern, have to start at 1 instead of 2
    if IGVId == 4 or IGVId == 5 or IGVId == 7 then
        for i = 1, numControls do
            ReshapeSlot(parent:GetChild(i), isGrid, width, height)
        end

        for i = 1, numControls do
            parent:GetChild(i).isGrid = isGrid
        end

        if scrollList.dataTypes[1] then
            for _, v in pairs(scrollList.dataTypes[1].pool["m_Free"]) do
                ReshapeSlot(v, isGrid, width, height)
            end
        end

        if scrollList.dataTypes[2] then
            for _, v in pairs(scrollList.dataTypes[2].pool["m_Free"]) do
                ReshapeSlot(v, isGrid, width, height)
            end
        end
    else
        for i = 2, numControls do
            ReshapeSlot(parent:GetChild(i), isGrid, width, height)
        end

        for i = 2, numControls do
            parent:GetChild(i).isGrid = isGrid
        end

        for _, v in pairs(scrollList.dataTypes[1].pool["m_Free"]) do
            ReshapeSlot(v, isGrid, width, height)
        end
    end
end

---------------------------------------------------------------------------
local integrated = false
function IntegrateInventoryGridView() 
	zo_callLater(function() 
		if integrated == false and InventoryGridView ~= nil then		
			IGV = InventoryGridView
			util = IGV.util
			settings = IGV.settings
			adapter = IGV.adapter
			--integrate
			InventoryGridView.adapter.ScrollController = adapter_ScrollController
			
			InventoryGridView.adapter.ToggleGrid = adapter_ToggleGrid
			
			InventoryGridView.util.ReshapeSlots = util_ReshapeSlots 
			 
			integrated = true
			
			--fix prehook  	
			ZO_PreHook("ZO_ScrollList_UpdateScroll", adapter_ScrollController)
		end
	end, 10) 
end 

EVENT_MANAGER:RegisterForEvent(AutoCategory.name, EVENT_PLAYER_ACTIVATED, IntegrateInventoryGridView)

		
------------------------modified end--------------------------