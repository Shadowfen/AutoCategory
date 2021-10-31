--
-- ref to ingame/crafting/gamepad/gamepadcraftinginventory.lua
local ZGCI = ZO_GamepadCraftingInventory

local CUSTOM_GAMEPAD_ITEM_SORT = {
  	sortPriorityName  = { tiebreaker = "bestItemTypeName" },
  	bestItemTypeName = { tiebreaker = "name" },
    name = { tiebreaker = "requiredLevel" },
    requiredLevel = { tiebreaker = "requiredChampionPoints", isNumeric = true },
    requiredChampionPoints = { tiebreaker = "iconFile", isNumeric = true },
    iconFile = { tiebreaker = "uniqueId" },
    uniqueId = { isId64 = true },
}

local function AutoCategory_ItemSortComparator(left, right)
    return ZO_TableOrderingFunction(left, right, "sortPriorityName", CUSTOM_GAMEPAD_ITEM_SORT, ZO_SORT_ORDER_UP)
end

local function ZO_GamepadInventoryList_AddSlotDataToTable(self, slotsTable, inventoryType, slotIndex)
    local itemFilterFunction = self.itemFilterFunction
    local categorizationFunction = self.categorizationFunction or ZO_InventoryUtils_Gamepad_GetBestItemCategoryDescription
    local slotData = SHARED_INVENTORY:GenerateSingleSlotData(inventoryType, slotIndex)
    if slotData then
        local itemData = slotData
        local matched, categoryName, categoryPriority = AutoCategory:MatchCategoryRules(itemData.bagId, itemData.slotIndex)
        if not matched then
            itemData.bestItemTypeName = AutoCategory.acctSaved.appearance["CATEGORY_OTHER_TEXT"]
            itemData.bestGamepadItemCategoryName = AutoCategory.acctSaved.appearance["CATEGORY_OTHER_TEXT"]
            itemData.sortPriorityName = string.format("%03d%s", 999 , categoryName) 
        else
            itemData.bestItemTypeName = categoryName
            itemData.bestGamepadItemCategoryName = categoryName
            itemData.sortPriorityName = string.format("%03d%s", 100 - categoryPriority , categoryName) 
        end
            
        table.insert(slotsTable, slotData)
    end
    
end

local function gci_AddSlotDataToTable1(self, slotsTable, inventoryType, slotIndex)
    local itemFilterFunction = self.itemFilterFunction
    local categorizationFunction = self.categorizationFunction or ZO_InventoryUtils_Gamepad_GetBestItemCategoryDescription
    local slotData = SHARED_INVENTORY:GenerateSingleSlotData(inventoryType, slotIndex)
    if slotData then
        if (not itemFilterFunction) or itemFilterFunction(slotData) then
            -- itemData is shared in several places and can write their own value of bestItemCategoryName.
            -- We'll use bestGamepadItemCategoryName instead so there are no conflicts.
            --slotData.bestGamepadItemCategoryName = categorizationFunction(slotData)
             
            local matched, categoryName, categoryPriority = AutoCategory:MatchCategoryRules(slotData.bagId, slotData.slotIndex)
            if not matched then
                slotData.bestItemTypeName = AutoCategory.acctSaved.appearance["CATEGORY_OTHER_TEXT"]
                slotData.bestGamepadItemCategoryName = AutoCategory.acctSaved.appearance["CATEGORY_OTHER_TEXT"]
                slotData.sortPriorityName = string.format("%03d%s", 999 , categoryName) 
            else
                slotData.bestItemTypeName = categoryName
                slotData.bestGamepadItemCategoryName = categoryName
                slotData.sortPriorityName = string.format("%03d%s", 100 - categoryPriority , categoryName) 
            end

            table.insert(slotsTable, slotData)
        end
    end
end


--[[ Original code; RockingDice, et.al.
function AutoCategory.HookGamepadInventory()	
	ZO_GamepadInventoryList.AddSlotDataToTable = ZO_GamepadInventoryList_AddSlotDataToTable
	ZO_GamepadInventoryList.sortFunction = AutoCategory_ItemSortComparator
end
--]]

-- New code; Friday-The13-rus
function AutoCategory.HookGamepadInventory()
	ZO_GamepadInventoryList.AddSlotDataToTable = ZO_GamepadInventoryList_AddSlotDataToTable
	ZO_GamepadInventoryList.sortFunction = AutoCategory_ItemSortComparator
	
	if AutoCategory.saved.general["ENABLE_GAMEPAD"] ~= true then return end

	-- Hide existing Quickslot, Crafting and Furnishing categories
	ZO_PreHook(GAMEPAD_INVENTORY, "AddFilteredBackpackCategoryIfPopulated", function (self, filterType, iconFile)
		if AutoCategory.saved.general["EXTENDED_GAMEPAD_SUPPLIES"] ~= true then return end
		if filterType == ITEMFILTERTYPE_CRAFTING or filterType == ITEMFILTERTYPE_FURNISHING or filterType == ITEMFILTERTYPE_QUICKSLOT then
			return true
		end
	end)

	local function IsSuppliesCategory(category)
		return category.filterType == nil and not category.isCurrencyEntry and not category.equipSlot
	end

	-- Update new items indicator for Supplies category (because of not it contains all inventory items)
	ZO_PostHook(GAMEPAD_INVENTORY, "RefreshCategoryList", function(self)
		if AutoCategory.saved.general["EXTENDED_GAMEPAD_SUPPLIES"] ~= true then return end
		for i = 1, self.categoryList:GetNumEntries() do
			local category = self.categoryList:GetEntryData(i)
			if IsSuppliesCategory(category) then
				local hasAnyNewItems = SHARED_INVENTORY:AreAnyItemsNew(nil, nil, BAG_BACKPACK)
				category:SetNew(hasAnyNewItems)
			end
		end
	end)

	local function GetItemDataFilterComparator(filteredEquipSlot, nonEquipableFilterType)
		return function(itemData)
			if filteredEquipSlot then
				return ZO_Character_DoesEquipSlotUseEquipType(filteredEquipSlot, itemData.equipType)
			end
	
			if nonEquipableFilterType then
				return ZO_InventoryUtils_DoesNewItemMatchFilterType(itemData, nonEquipableFilterType)
			end
			
			return ZO_InventoryUtils_DoesNewItemMatchSupplies(itemData)
		end
	end

	local function GetBestQuestItemCategoryDescription(questItemData)
		local questItemCategory = GAMEPAD_QUEST_ITEM_CATEGORY_NOT_SLOTTABLE
		if CanQuickslotQuestItemById(questItemData.questItemId) then
			questItemCategory = GAMEPAD_QUEST_ITEM_CATEGORY_SLOTTABLE
		end
	
		return GetString("SI_GAMEPADQUESTITEMCATEGORY", questItemCategory)
	end

	-- Replase content in Supplies category by all items from inventory (like in keyboard inventory)
	-- Supplies category is targetCategoryData.filterType == nil
	ZO_PreHook(GAMEPAD_INVENTORY, "RefreshItemList", function (self)
		self.itemList:Clear()
		if self.categoryList:IsEmpty() then return true end

		local targetCategoryData = self.categoryList:GetTargetData()
		local filteredEquipSlot = targetCategoryData.equipSlot
		local nonEquipableFilterType = targetCategoryData.filterType
		local filteredDataTable

		local isQuestItemFilter = nonEquipableFilterType == ITEMFILTERTYPE_QUEST
		--special case for quest items
		if isQuestItemFilter then
			filteredDataTable = {}
			local questCache = SHARED_INVENTORY:GenerateFullQuestCache()
			for _, questItems in pairs(questCache) do
				for _, questItem in pairs(questItems) do
					table.insert(filteredDataTable, questItem)
					questItem.bestItemCategoryName = zo_strformat(SI_INVENTORY_HEADER, GetBestQuestItemCategoryDescription(questItem))
				end
			end
			table.sort(filteredDataTable, ZO_GamepadInventory_QuestItemSortComparator)
		else
			if AutoCategory.saved.general["EXTENDED_GAMEPAD_SUPPLIES"] == true and IsSuppliesCategory(targetCategoryData) then
				filteredDataTable = SHARED_INVENTORY:GenerateFullSlotData(nil, BAG_BACKPACK)
			else
				local comparator = GetItemDataFilterComparator(filteredEquipSlot, nonEquipableFilterType)
				filteredDataTable = SHARED_INVENTORY:GenerateFullSlotData(comparator, BAG_BACKPACK, BAG_WORN)
			end
			for _, slotData in pairs(filteredDataTable) do
				local matched, categoryName, categoryPriority = AutoCategory:MatchCategoryRules(slotData.bagId, slotData.slotIndex)
				if not matched then
					slotData.bestItemTypeName = AutoCategory.acctSaved.appearance["CATEGORY_OTHER_TEXT"]
					slotData.bestItemCategoryName = AutoCategory.acctSaved.appearance["CATEGORY_OTHER_TEXT"]
					slotData.sortPriorityName = string.format("%03d%s", 999 , categoryName) 
				else
					slotData.bestItemTypeName = categoryName
					slotData.bestItemCategoryName = categoryName
					slotData.sortPriorityName = string.format("%03d%s", 100 - categoryPriority , categoryName)
				end
			end
			table.sort(filteredDataTable, AutoCategory_ItemSortComparator)
		end

		local lastBestItemCategoryName
		for i, itemData in ipairs(filteredDataTable) do
			local entryData = ZO_GamepadEntryData:New(itemData.name, itemData.iconFile)
			entryData:InitializeInventoryVisualData(itemData)

			if itemData.bagId == BAG_WORN then
				entryData.isEquippedInCurrentCategory = itemData.slotIndex == filteredEquipSlot
				entryData.isEquippedInAnotherCategory = itemData.slotIndex ~= filteredEquipSlot

				entryData.isHiddenByWardrobe = WouldEquipmentBeHidden(itemData.slotIndex or EQUIP_SLOT_NONE)
			elseif isQuestItemFilter then
				local slotIndex = FindActionSlotMatchingSimpleAction(ACTION_TYPE_QUEST_ITEM, itemData.questItemId)
				entryData.isEquippedInCurrentCategory = slotIndex ~= nil
			else
				local slotIndex = FindActionSlotMatchingItem(itemData.bagId, itemData.slotIndex)
				entryData.isEquippedInCurrentCategory = slotIndex ~= nil
			end

			local remaining, duration
			if isQuestItemFilter then
				if itemData.toolIndex then
					remaining, duration = GetQuestToolCooldownInfo(itemData.questIndex, itemData.toolIndex)
				elseif itemData.stepIndex and itemData.conditionIndex then
					remaining, duration = GetQuestItemCooldownInfo(itemData.questIndex, itemData.stepIndex, itemData.conditionIndex)
				end

				ZO_InventorySlot_SetType(entryData, SLOT_TYPE_QUEST_ITEM)
			else
				remaining, duration = GetItemCooldownInfo(itemData.bagId, itemData.slotIndex)

				ZO_InventorySlot_SetType(entryData, SLOT_TYPE_GAMEPAD_INVENTORY_ITEM)
			end
			if remaining > 0 and duration > 0 then
				entryData:SetCooldown(remaining, duration)
			end

			if AutoCategory.saved.general["EXTENDED_GAMEPAD_SUPPLIES"] ~= true or not IsSuppliesCategory(targetCategoryData) then
				entryData:SetIgnoreTraitInformation(true)
			end

			if itemData.bestItemCategoryName ~= lastBestItemCategoryName then
				lastBestItemCategoryName = itemData.bestItemCategoryName

				entryData:SetHeader(lastBestItemCategoryName)
				self.itemList:AddEntry("ZO_GamepadItemSubEntryTemplateWithHeader", entryData)
			else
				self.itemList:AddEntry("ZO_GamepadItemSubEntryTemplate", entryData)
			end
		end

		self.itemList:Commit()
		return true
	end)

	if AutoCategory.saved.general["EXTENDED_GAMEPAD_SUPPLIES"] ~= true then return end
	-- The following code related only to Extendes Supplies category

	-- Allow to equip items from Supplies category
	ZO_PreHook(GAMEPAD_INVENTORY, "TryEquipItem", function (self, inventorySlot)
		local sourceBag, sourceSlot = ZO_Inventory_GetBagAndIndex(inventorySlot)
		local function DoEquip()
			EquipItem(sourceBag, sourceSlot, self.selectedEquipSlot)
		end

		if ZO_InventorySlot_WillItemBecomeBoundOnEquip(sourceBag, sourceSlot) then
			local itemDisplayQuality = GetItemDisplayQuality(sourceBag, sourceSlot)
			local itemDisplayQualityColor = GetItemQualityColor(itemDisplayQuality)
			ZO_Dialogs_ShowPlatformDialog("CONFIRM_EQUIP_ITEM", { onAcceptCallback = DoEquip }, { mainTextParams = { itemDisplayQualityColor:Colorize(GetItemName(sourceBag, sourceSlot)) } })
		else
			DoEquip()
		end
		return true
	end)

	-- Show change compare mode and quickslot buttons in Supplies
	SecurePostHook(GAMEPAD_INVENTORY, "InitializeKeybindStrip", function (self)
		local function CanQuickSlotTargetItem()
			local targetData = self.itemList:GetTargetData()
			if targetData and ZO_InventorySlot_CanQuickslotItem(targetData) then
				return true
			end
		end

		local function IsQuickSlotEnabled()
			local targetCategoryData = self.categoryList:GetTargetData()
			if AutoCategory.saved.general["EXTENDED_GAMEPAD_SUPPLIES"] == true and IsSuppliesCategory(targetCategoryData) then
				return CanQuickSlotTargetItem()
			else
				return self.selectedItemFilterType == ITEMFILTERTYPE_QUICKSLOT or self.selectedItemFilterType == ITEMFILTERTYPE_QUEST
			end
		end
	
		local function CanCompareTargetItem()
			local targetData = self.itemList:GetTargetData()
			if targetData then
				local equipSlot = ZO_Character_GetEquipSlotForEquipType(targetData.equipType)
				if equipSlot then
					return true
				end
			end
		end

		local function IsCompareModeEnabled()
			local targetCategoryData = self.categoryList:GetTargetData()
			if AutoCategory.saved.general["EXTENDED_GAMEPAD_SUPPLIES"] == true and IsSuppliesCategory(targetCategoryData) then
				return CanCompareTargetItem()
			else
				return self.selectedItemFilterType == ITEMFILTERTYPE_JEWELRY or self.selectedItemFilterType == ITEMFILTERTYPE_ARMOR or self.selectedItemFilterType == ITEMFILTERTYPE_WEAPONS
			end
		end

		local multiactionKeybind = {
            alignment = function()
                if IsQuickSlotEnabled() then
                    return KEYBIND_STRIP_ALIGN_LEFT
                elseif IsCompareModeEnabled() then
                    return KEYBIND_STRIP_ALIGN_RIGHT
                end
            end,
            name = function()
                if IsQuickSlotEnabled() then
                    return GetString(SI_GAMEPAD_ITEM_ACTION_QUICKSLOT_ASSIGN)
                elseif IsCompareModeEnabled() then
                    return GetString(SI_GAMEPAD_INVENTORY_TOGGLE_ITEM_COMPARE_MODE)
                end
            end,
            keybind = "UI_SHORTCUT_SECONDARY",
            order = function()
                if IsQuickSlotEnabled() then
                    return -500
                end
            end,
            visible = function()
				local targetCategoryData = self.categoryList:GetTargetData()
				if AutoCategory.saved.general["EXTENDED_GAMEPAD_SUPPLIES"] == true and IsSuppliesCategory(targetCategoryData) then
					return CanQuickSlotTargetItem() or CanCompareTargetItem()
				else
					if IsQuickSlotEnabled() then
						return CanQuickSlotTargetItem()
					elseif IsCompareModeEnabled() then
						if targetCategoryData then
							local equipSlotHasItem = select(2, GetEquippedItemInfo(targetCategoryData.equipSlot))
							return equipSlotHasItem
						end
					end
				end
            end,
            callback = function()
                if IsQuickSlotEnabled() then
					self:ShowQuickslot()
                elseif IsCompareModeEnabled() then
                    self.savedVars.useStatComparisonTooltip = not self.savedVars.useStatComparisonTooltip
                    self:UpdateRightTooltip()
                end
            end,
        }

		self.itemFilterKeybindStripDescriptor[1] = multiactionKeybind
	end)

	local QUICKSLOT_ASSIGNMENT_TYPE_ITEM = 1
	local QUICKSLOT_ASSIGNMENT_TYPE_COLLECTIBLE = 2
	local QUICKSLOT_ASSIGNMENT_TYPE_QUEST_ITEM = 3

	ZO_PreHook(GAMEPAD_QUICKSLOT, "TryAssignItemToSlot", function (self)
		local selectedData = self.radialMenu.selectedEntry
		if selectedData then
			if self.assignmentType == QUICKSLOT_ASSIGNMENT_TYPE_COLLECTIBLE then
				if self.collectibleToSlotId then
					CallSecureProtected("SelectSlotSimpleAction", ACTION_TYPE_COLLECTIBLE, self.collectibleToSlotId, selectedData.data)
					self.collectibleToSlotId = nil
				end
			elseif self.assignmentType == QUICKSLOT_ASSIGNMENT_TYPE_ITEM then
				if self.itemToSlotId and self.itemToSlotIndex then
					CallSecureProtected("SelectSlotItem", self.itemToSlotId, self.itemToSlotIndex, selectedData.data)
					self.itemToSlotId = nil
					self.itemToSlotIndex = nil
				end
			elseif self.assignmentType == QUICKSLOT_ASSIGNMENT_TYPE_QUEST_ITEM then
				if self.questItemToSlotId then
					CallSecureProtected("SelectSlotSimpleAction", ACTION_TYPE_QUEST_ITEM, self.questItemToSlotId, selectedData.data)
					self.questItemToSlotId = nil
				end
			end

			self.radialMenu.activeIcon:SetHidden(true)
			self.activeIcon = nil
			self.slotIndexForAnim = selectedData.data
		end
		self.enteringMenuUnslottedItem = false  --in case the player tries to assign the slotted item that is currently being unassigned so that the scene will properly hide
		return true
	end)

	ZO_PreHook(GAMEPAD_QUICKSLOT, "ShowQuickslotMenu", function (self)
		self.radialMenu:Clear()
		self:PopulateMenu()
		self.radialMenu:Show()

		--special entrance case, unslot selected item
		local slotNum
		if self.assignmentType == QUICKSLOT_ASSIGNMENT_TYPE_ITEM then
			if self.itemToSlotId and self.itemToSlotIndex then
				slotNum = FindActionSlotMatchingItem(self.itemToSlotId, self.itemToSlotIndex)
			end
		elseif self.assignmentType == QUICKSLOT_ASSIGNMENT_TYPE_COLLECTIBLE then
			if self.collectibleToSlotId then
				slotNum = FindActionSlotMatchingSimpleAction(ACTION_TYPE_COLLECTIBLE, self.collectibleToSlotId)
			end
		elseif self.assignmentType == QUICKSLOT_ASSIGNMENT_TYPE_QUEST_ITEM then
			if self.questItemToSlotId then
				slotNum = FindActionSlotMatchingSimpleAction(ACTION_TYPE_QUEST_ITEM, self.questItemToSlotId)
			end
		end

		if slotNum then
			self.enteringMenuUnslottedItem = true
			CallSecureProtected("ClearSlot", slotNum)
			self.slotIndexForAnim = slotNum
			self.radialMenu.activeIcon:SetHidden(true)
		end
		return true
	end)

	-- Show right tooltip for equipable items in Supplies
	ZO_PreHook(GAMEPAD_INVENTORY, "UpdateRightTooltip", function (self)
		local targetCategoryData = self.categoryList:GetTargetData()
		if AutoCategory.saved.general["EXTENDED_GAMEPAD_SUPPLIES"] == true and IsSuppliesCategory(targetCategoryData) then
			local selectedItemData = self.currentlySelectedData
			local equipSlot = ZO_Character_GetEquipSlotForEquipType(selectedItemData.equipType)
			if not equipSlot then
				GAMEPAD_TOOLTIPS:Reset(GAMEPAD_RIGHT_TOOLTIP)
				return true
			end
			local equipSlotHasItem = select(2, GetEquippedItemInfo(equipSlot))
			if selectedItemData and (not equipSlotHasItem or self.savedVars.useStatComparisonTooltip) then
				GAMEPAD_TOOLTIPS:LayoutItemStatComparison(GAMEPAD_RIGHT_TOOLTIP, selectedItemData.bagId, selectedItemData.slotIndex, equipSlot)
				GAMEPAD_TOOLTIPS:SetStatusLabelText(GAMEPAD_RIGHT_TOOLTIP, GetString(SI_GAMEPAD_INVENTORY_ITEM_COMPARE_TOOLTIP_TITLE))
			elseif GAMEPAD_TOOLTIPS:LayoutBagItem(GAMEPAD_RIGHT_TOOLTIP, BAG_WORN, equipSlot) then
				self:UpdateTooltipEquippedIndicatorText(GAMEPAD_RIGHT_TOOLTIP, equipSlot)
			end
			return true
		end
		return false
	end)
end

local function gci_AddFilteredDataToList(self, filteredDataTable)
    table.sort(filteredDataTable, AutoCategory_ItemSortComparator) -- this is different

    local lastBestItemCategoryName
    for i, itemData in ipairs(filteredDataTable) do
        if itemData.bestItemCategoryName ~= lastBestItemCategoryName then
            lastBestItemCategoryName = itemData.bestItemCategoryName
            itemData:SetHeader(zo_strformat(SI_GAMEPAD_CRAFTING_INVENTORY_HEADER, lastBestItemCategoryName))
        end
        
        local template = self:GetListEntryTemplate(itemData)

        self.list:AddEntry(template, itemData)
    end
end
    
local function gci_GenerateCraftingInventoryEntryData(self, bagId, slotIndex, stackCount, slotData)
    local itemName = GetItemName(bagId, slotIndex)
    local icon = GetItemInfo(bagId, slotIndex)
    local name = zo_strformat(SI_TOOLTIP_ITEM_NAME, itemName)
    local customSortData = self.customDataSortFunction and self.customDataSortFunction(bagId, slotIndex) or 0

    local newData = ZO_GamepadEntryData:New(name)
    newData:InitializeCraftingInventoryVisualData(bagId, slotIndex, stackCount, customSortData, self.customBestItemCategoryNameFunction, slotData)
    --Auto Category Modify[
    if slotData then
        local matched, categoryName, categoryPriority = AutoCategory:MatchCategoryRules(slotData.bagId, slotData.slotIndex, AC_BAG_TYPE_CRAFTSTATION)
        if not matched then
            newData.bestItemTypeName = AutoCategory.acctSaved.appearance["CATEGORY_OTHER_TEXT"]
            newData.bestItemCategoryName = AutoCategory.acctSaved.appearance["CATEGORY_OTHER_TEXT"]
            newData.sortPriorityName = string.format("%03d%s", 999 , categoryName) 
        else
            newData.bestItemTypeName = categoryName
            newData.bestItemCategoryName = categoryName
            newData.sortPriorityName = string.format("%03d%s", 100 - categoryPriority , categoryName) 
        end
    end
    --Auto Category Modify]
    ZO_InventorySlot_SetType(newData, self.baseSlotType)

    if self.customExtraDataFunction then
        self.customExtraDataFunction(bagId, slotIndex, newData)
    end

    return newData
end

function AutoCategory.HookGamepadCraftStation()
--API 100021
	ZGCI.AddFilteredDataToList = gci_AddFilteredDataToList
	ZGCI.GenerateCraftingInventoryEntryData = gci_GenerateCraftingInventoryEntryData
--API 100021
end

function AutoCategory.HookGamepadTradeInventory() 
	local originalFunction = ZO_GamepadTradeWindow.InitializeInventoryList	
	
	ZO_GamepadTradeWindow.InitializeInventoryList = function(self) 
		originalFunction(self)
		self.inventoryList.AddSlotDataToTable = gci_AddSlotDataToTable1
		self.inventoryList.sortFunction = AutoCategory_ItemSortComparator
	end
	
end

function AutoCategory.HookGamepadStore(list)
	--change item 
	local originalUpdateFunc = list.updateFunc
	list.updateFunc = function( ... )
		local filteredDataTable = originalUpdateFunc(...)
		--add new fields to item data
		local tempDataTable = {}
		for i = 1, #filteredDataTable  do
			local itemData = filteredDataTable[i]
			--use custom categories

			local matched, categoryName, categoryPriority = AutoCategory:MatchCategoryRules(itemData.bagId, itemData.slotIndex)
			if not matched then
	            itemData.bestItemTypeName = AutoCategory.acctSaved.appearance["CATEGORY_OTHER_TEXT"]
	            itemData.bestGamepadItemCategoryName = AutoCategory.acctSaved.appearance["CATEGORY_OTHER_TEXT"]
	            itemData.sortPriorityName = string.format("%03d%s", 999 , categoryName) 
			else
				itemData.bestItemTypeName = categoryName
				itemData.bestGamepadItemCategoryName = categoryName
				itemData.sortPriorityName = string.format("%03d%s", 100 - categoryPriority , categoryName) 
			end

	        table.insert(tempDataTable, itemData)
		end
		filteredDataTable = tempDataTable
		return filteredDataTable
	end

	list.sortFunc = AutoCategory_ItemSortComparator
end

function AutoCategory.HookGamepadBanking()
	local oldSortParamsFunction = ZO_BankingCommon_Gamepad.GetCurrentSortParams
	ZO_BankingCommon_Gamepad.GetCurrentSortParams = function (...)
		local sortKey, sortOptions, sortOrder = oldSortParamsFunction(...)
		if sortKey == "bestGamepadItemCategoryName" then
			sortKey = "sortPriorityName"
		end
		return sortKey, CUSTOM_GAMEPAD_ITEM_SORT, sortOrder
	end
end

function AutoCategory.HookGamepadMode() 
  	AutoCategory.HookGamepadInventory()
  	AutoCategory.HookGamepadCraftStation()
  	AutoCategory.HookGamepadStore(STORE_WINDOW_GAMEPAD.components[ZO_MODE_STORE_SELL].list)
	AutoCategory.HookGamepadStore(STORE_WINDOW_GAMEPAD.components[ZO_MODE_STORE_SELL_STOLEN].list)
	AutoCategory.HookGamepadStore(STORE_WINDOW_GAMEPAD.components[ZO_MODE_STORE_LAUNDER].list)
  	AutoCategory.HookGamepadTradeInventory()
	AutoCategory.HookGamepadBanking()
end
