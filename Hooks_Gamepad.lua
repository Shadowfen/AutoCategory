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
		if filterType == ITEMFILTERTYPE_CRAFTING or filterType == ITEMFILTERTYPE_FURNISHING or filterType == ITEMFILTERTYPE_QUICKSLOT then
			return true
		end
	end)

	-- Update new items indicator for Supplies category (because of not it contains all inventory items)
	ZO_PostHook(GAMEPAD_INVENTORY, "RefreshCategoryList", function(self)
		for i = 1, self.categoryList:GetNumEntries() do
			local category = self.categoryList:GetEntryData(i)
			if category.filterType == nil and not category.isCurrencyEntry then
				local hasAnyNewItems = SHARED_INVENTORY:AreAnyItemsNew(nil, nil, BAG_BACKPACK)
				category:SetNew(hasAnyNewItems)
			end
		end
	end)

	-- Replase content in Supplies category by all items from inventory (like in keyboard inventory)
	-- Supplies category is targetCategoryData.filterType == nil
	ZO_PreHook(GAMEPAD_INVENTORY, "RefreshItemList", function (self)
		local targetCategoryData = self.categoryList:GetTargetData()
		if targetCategoryData.filterType == nil then
			self.itemList:Clear()
			if self.categoryList:IsEmpty() then return true end

			local filteredDataTable = SHARED_INVENTORY:GenerateFullSlotData(nil, BAG_BACKPACK)
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

			local lastBestItemCategoryName
			for i, itemData in ipairs(filteredDataTable) do
				local entryData = ZO_GamepadEntryData:New(itemData.name, itemData.iconFile)
				entryData:InitializeInventoryVisualData(itemData)

				ZO_InventorySlot_SetType(entryData, SLOT_TYPE_GAMEPAD_INVENTORY_ITEM)

				local remaining, duration = GetItemCooldownInfo(itemData.bagId, itemData.slotIndex)
				if remaining > 0 and duration > 0 then
					entryData:SetCooldown(remaining, duration)
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
		end
		return false
	end)

	-- Allow to equip items from Supplies category
	SecurePostHook(GAMEPAD_INVENTORY, "TryEquipItem", function (self, inventorySlot)
		if not self.selectedEquipSlot then
			local sourceBag, sourceSlot = ZO_Inventory_GetBagAndIndex(inventorySlot)
			local function DoEquip()
				EquipItem(sourceBag, sourceSlot)
			end

			if ZO_InventorySlot_WillItemBecomeBoundOnEquip(sourceBag, sourceSlot) then
				local itemDisplayQuality = GetItemDisplayQuality(sourceBag, sourceSlot)
				local itemDisplayQualityColor = GetItemQualityColor(itemDisplayQuality)
				ZO_Dialogs_ShowPlatformDialog("CONFIRM_EQUIP_ITEM", { onAcceptCallback = DoEquip }, { mainTextParams = { itemDisplayQualityColor:Colorize(GetItemName(sourceBag, sourceSlot)) } })
			else
				DoEquip()
			end
		end
	end)

	-- Allow to quickslot items from Supplies category
	ZO_PostHook(GAMEPAD_INVENTORY, "SwitchActiveList", function (self, listDescriptor)
		if listDescriptor == "itemList" and self.selectedItemFilterType == nil then
			KEYBIND_STRIP:AddKeybindButton(self.quickslotAssignKeybindStripDescriptor)
			self:RefreshItemActions()
			self:RefreshActiveKeybinds()
		end
	end)

	-- Fix an issue, when set to quickslot action does not hide after selecting item that cannot be quickslotted
	ZO_PostHook(GAMEPAD_INVENTORY, "RefreshActiveKeybinds", function (self)
		KEYBIND_STRIP:UpdateKeybindButton(self.quickslotAssignKeybindStripDescriptor)
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

function AutoCategory.HookGamepadMode() 
  	AutoCategory.HookGamepadInventory()
  	AutoCategory.HookGamepadCraftStation()
  	AutoCategory.HookGamepadStore(STORE_WINDOW_GAMEPAD.components[ZO_MODE_STORE_SELL].list)
  	AutoCategory.HookGamepadStore(STORE_WINDOW_GAMEPAD.components[ZO_MODE_STORE_BUY_BACK].list)
  	AutoCategory.HookGamepadTradeInventory() 
end
