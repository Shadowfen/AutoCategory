local LMP = LibStub:GetLibrary("LibMediaProvider-1.0")

local CATEGORY_HEADER = 998

local CUSTOM_GAMEPAD_ITEM_SORT =
{
	sortPriorityName  = { tiebreaker = "bestItemTypeName" },
	bestItemTypeName = { tiebreaker = "name" },
    name = { tiebreaker = "requiredLevel" },
    requiredLevel = { tiebreaker = "requiredChampionPoints", isNumeric = true },
    requiredChampionPoints = { tiebreaker = "iconFile", isNumeric = true },
    iconFile = { tiebreaker = "uniqueId" },
    uniqueId = { isId64 = true },
}
 
local sortKeys =
{
    slotIndex = { isNumeric = true },
    stackCount = { tiebreaker = "slotIndex", isNumeric = true },
    name = { tiebreaker = "stackCount" },
    quality = { tiebreaker = "name", isNumeric = true },
    stackSellPrice = { tiebreaker = "name", tieBreakerSortOrder = ZO_SORT_ORDER_UP, isNumeric = true },
    statusSortOrder = { tiebreaker = "age", isNumeric = true},
    age = { tiebreaker = "name", tieBreakerSortOrder = ZO_SORT_ORDER_UP, isNumeric = true},
    statValue = { tiebreaker = "name", isNumeric = true, tieBreakerSortOrder = ZO_SORT_ORDER_UP },
    traitInformationSortOrder = { tiebreaker = "name", isNumeric = true, tieBreakerSortOrder = ZO_SORT_ORDER_UP },
    sellInformationSortOrder = { tiebreaker = "name", isNumeric = true, tieBreakerSortOrder = ZO_SORT_ORDER_UP },
}

local function AutoCategory_ItemSortComparator(left, right)
    return ZO_TableOrderingFunction(left, right, "sortPriorityName", CUSTOM_GAMEPAD_ITEM_SORT, ZO_SORT_ORDER_UP)
end

local function NilOrLessThan(value1, value2)
    if value1 == nil then
        return true
    elseif value2 == nil then
        return false
    else
        return value1 < value2
    end
end 

local backupListData
AutoCategory.dataCount = {}
function AutoCategory.HookKeyboardMode() 
	local function AC_Setup_InventoryRowWithHeader(rowControl, slot, overrideOptions)
		--set header
		local headerLabel = rowControl:GetNamedChild("HeaderName")
		if AutoCategory.acctSaved.general["SHOW_CATEGORY_ITEM_COUNT"] then
			headerLabel:SetText(string.format('%s |cFFE690[%d]|r', slot.bestItemTypeName, slot.dataEntry.num))
		else
			headerLabel:SetText(slot.bestItemTypeName)
		end
		local appearance = AutoCategory.acctSaved.appearance
		headerLabel:SetHorizontalAlignment(appearance["CATEGORY_FONT_ALIGNMENT"])
		headerLabel:SetFont(string.format('%s|%d|%s', LMP:Fetch('font', appearance["CATEGORY_FONT_NAME"]), appearance["CATEGORY_FONT_SIZE"], appearance["CATEGORY_FONT_STYLE"]))
		headerLabel:SetColor(appearance["CATEGORY_FONT_COLOR"][1], appearance["CATEGORY_FONT_COLOR"][2], appearance["CATEGORY_FONT_COLOR"][3], appearance["CATEGORY_FONT_COLOR"][4])

		local marker = rowControl:GetNamedChild("CollapseMarker")
		local cateName = slot.dataEntry.bestItemTypeName
		local bagTypeId = slot.dataEntry.bagTypeId 
		local collapsed = AutoCategory.IsCategoryCollapsed(bagTypeId, cateName) 
		if collapsed then
			marker:SetTexture("EsoUI/Art/Buttons/plus_up.dds")
		else
			marker:SetTexture("EsoUI/Art/Buttons/minus_up.dds")
		end
		
		rowControl:SetHeight(AutoCategory.acctSaved.appearance["CATEGORY_HEADER_HEIGHT"])
		rowControl.slot = slot
	end
    
	--Add a new data type: row with header
	local rowHeight = AutoCategory.acctSaved.appearance["CATEGORY_HEADER_HEIGHT"]
    local function AddTypeToList(datalist, inven_ndx) 
        local cb
        if inven_ndx then
            cb = PLAYER_INVENTORY.inventories[inven_ndx].listHiddenCallback
        else
            cb = nil
        end
        ZO_ScrollList_AddDataType(datalist, CATEGORY_HEADER, "AC_InventoryItemRowHeader", 
            rowHeight, AC_Setup_InventoryRowWithHeader, cb, nil, 
            ZO_InventorySlot_OnPoolReset)
    end
    
    AddTypeToList(ZO_PlayerInventoryList, INVENTORY_BACKPACK)
    AddTypeToList(ZO_CraftBagList, INVENTORY_BACKPACK)
    AddTypeToList(ZO_PlayerBankBackpack, INVENTORY_BACKPACK)
    AddTypeToList(ZO_GuildBankBackpack, INVENTORY_BACKPACK)
    AddTypeToList(ZO_HouseBankBackpack, INVENTORY_BACKPACK)
    AddTypeToList(ZO_PlayerInventoryQuest, INVENTORY_QUEST_ITEM)
    AddTypeToList(SMITHING.deconstructionPanel.inventory.list, nil)
	AddTypeToList(SMITHING.improvementPanel.inventory.list, nil)
	
	local function resetCount(bagTypeId, name)
		if AutoCategory.dataCount[bagTypeId] == nil then
			AutoCategory.dataCount[bagTypeId] = {}
		end
		AutoCategory.dataCount[bagTypeId][name] = 0 
	end
    
	local function addCount(bagTypeId, name)
		if AutoCategory.dataCount[bagTypeId] == nil then
			AutoCategory.dataCount[bagTypeId] = {}
		end
		if AutoCategory.dataCount[bagTypeId][name] == nil then
			AutoCategory.dataCount[bagTypeId][name] = 0
		end
		AutoCategory.dataCount[bagTypeId][name] = AutoCategory.dataCount[bagTypeId][name] + 1
	end
    
	local function getCount(bagTypeId, name)
		if AutoCategory.dataCount[bagTypeId] == nil then
			AutoCategory.dataCount[bagTypeId] = {}
		end
		if AutoCategory.dataCount[bagTypeId][name] == nil then
			AutoCategory.dataCount[bagTypeId][name] = 0
		end
		return AutoCategory.dataCount[bagTypeId][name]
	end
    
	local function prehookSort(self, inventoryType) 
		local inventory
	    if inventoryType == INVENTORY_BANK then
	        inventory = self.inventories[INVENTORY_BANK]
	    elseif inventoryType == INVENTORY_GUILD_BANK then
	        inventory = self.inventories[INVENTORY_GUILD_BANK]
	    elseif inventoryType == INVENTORY_CRAFT_BAG then
	        inventory = self.inventories[INVENTORY_CRAFT_BAG]
	    elseif inventoryType == INVENTORY_HOUSE_BANK then
	        inventory = self.inventories[INVENTORY_HOUSE_BANK]
	    else
	        -- Use normal inventory by default (instead of the quest item inventory for example)
	        inventory = self.inventories[self.selectedTabType]
	    end
		
		--change sort function
		inventory.sortFn =  function(left, right) 
			if AutoCategory.Enabled then
				if right.sortPriorityName ~= left.sortPriorityName then
					return NilOrLessThan(left.sortPriorityName, right.sortPriorityName)
				end
				if right.isHeader ~= left.isHeader then
					return NilOrLessThan(right.isHeader, left.isHeader)
				end
            end
            --compatible with quality sort
            if type(inventory.currentSortKey) == "function" then 
                if inventory.currentSortOrder == ZO_SORT_ORDER_UP then
                    return inventory.currentSortKey(left.data, right.data)
                else
                    return inventory.currentSortKey(right.data, left.data)
                end
            end
			return ZO_TableOrderingFunction(left.data, right.data, inventory.currentSortKey, sortKeys, inventory.currentSortOrder)
        end

	    local list = inventory.listView 
	    local scrollData = ZO_ScrollList_GetDataList(list) 
		
		for i, entry in ipairs(scrollData) do
			--only match items(not headers)
			if entry.typeId ~= 998 then
				local slotData = entry.data
				local matched, categoryName, categoryPriority, bagTypeId, isHidden = AutoCategory:MatchCategoryRules(slotData.bagId, slotData.slotIndex)
				if not matched or not AutoCategory.Enabled then
					entry.bestItemTypeName = AutoCategory.acctSaved.appearance["CATEGORY_OTHER_TEXT"] 
					entry.sortPriorityName = string.format("%03d%s", 999 , categoryName) 
					entry.bagTypeId = bagTypeId 
					if not AutoCategory.Enabled or bagTypeId == nil then
						entry.isHidden = false
					else
						entry.isHidden = AutoCategory.saved.bags[bagTypeId].isUngroupedHidden
					end
				else
					entry.bestItemTypeName = categoryName 
					entry.sortPriorityName = string.format("%03d%s", 100 - categoryPriority , categoryName) 
					entry.bagTypeId = bagTypeId
					entry.isHidden = isHidden 
				end
			end
		end
		
		--sort data to add header
        table.sort(scrollData, inventory.sortFn)  
		
		-- add header data	    
	    local lastBestItemCategoryName
        local newScrollData = {} 
		local hiddenItem = false
		local countItems = false
	    for i, entry in ipairs(scrollData) do 
			if AutoCategory.Enabled and entry.bagTypeId ~= nil then					
				if entry.bestItemTypeName ~= lastBestItemCategoryName then
					--new header
					hiddenItem = false
					
					lastBestItemCategoryName = entry.bestItemTypeName
					local headerEntry = ZO_ScrollList_CreateDataEntry(998, {bestItemTypeName = entry.bestItemTypeName, stackLaunderPrice = 0})
					headerEntry.sortPriorityName = entry.sortPriorityName
					headerEntry.isHeader = true
					headerEntry.bestItemTypeName = entry.bestItemTypeName
					headerEntry.bagTypeId = entry.bagTypeId
					local num = getCount(entry.bagTypeId, entry.bestItemTypeName) 
					headerEntry.num = num
					if entry.isHeader then
						countItems = false
					else 
						countItems = true
						resetCount(entry.bagTypeId, entry.bestItemTypeName)
					end
					if entry.isHidden then
						--don't add header
						hiddenItem = true
					else					
						table.insert(newScrollData, headerEntry)
						--check collapse
						if AutoCategory.IsCategoryCollapsed(entry.bagTypeId, entry.bestItemTypeName) then
							hiddenItem = true
						end
					end
					
				end
			end
	    	if entry.typeId ~= 998 then
				if not hiddenItem then
					table.insert(newScrollData, entry)
				end
				if countItems then
					addCount(entry.bagTypeId, entry.bestItemTypeName)
				end
	    	end
	    end
	    list.data = newScrollData 
	end
	
	ZO_PreHook(ZO_InventoryManager, "ApplySort", prehookSort)
    ZO_PreHook(PLAYER_INVENTORY, "ApplySort", prehookSort)
	
	local function prehookCraftSort(self)
		--change sort function
		self.sortFunction = function(left, right) 
			if AutoCategory.Enabled then
				if right.sortPriorityName ~= left.sortPriorityName then
					return NilOrLessThan(left.sortPriorityName, right.sortPriorityName)
				end
				if right.isHeader ~= left.isHeader then
					return NilOrLessThan(right.isHeader, left.isHeader)
				end
				--compatible with quality sort
				if type(self.sortKey) == "function" then 
					if self.sortOrder == ZO_SORT_ORDER_UP then
						return self.sortKey(left.data, right.data)
					else
						return self.sortKey(right.data, left.data)
					end
				end
			end
			return ZO_TableOrderingFunction(left.data, right.data, self.sortKey, sortKeys, self.sortOrder)
		end

		--add header data
	    local scrollData = ZO_ScrollList_GetDataList(self.list)
		for i, entry in ipairs(scrollData) do
			--only match items(not headers)
			if entry.typeId ~= 998 then
			local slotData = entry.data
			local matched, categoryName, categoryPriority, bagTypeId, isHidden = AutoCategory:MatchCategoryRules(slotData.bagId, slotData.slotIndex, AC_BAG_TYPE_CRAFTSTATION)
			if not matched or not AutoCategory.Enabled then
				entry.bestItemTypeName = AutoCategory.acctSaved.appearance["CATEGORY_OTHER_TEXT"] 
				entry.sortPriorityName = string.format("%03d%s", 999 , categoryName) 
				entry.bagTypeId = bagTypeId
				if not AutoCategory.Enabled then
					entry.isHidden = false
				else
					entry.isHidden = AutoCategory.saved.bags[bagTypeId].isUngroupedHidden
				end
			else
				entry.bestItemTypeName = categoryName 
				entry.sortPriorityName = string.format("%03d%s", 100 - categoryPriority , categoryName) 
				entry.bagTypeId = bagTypeId
				entry.isHidden = isHidden
				end
			end
		end
		
		--sort data to add header
        table.sort(scrollData, self.sortFunction)
		
				-- add header data	    
	    local lastBestItemCategoryName
        local newScrollData = {}
		local hiddenItem = false
		local countItems = true
		local lastHeaderEntry 
	    for i, entry in ipairs(scrollData) do 
			if AutoCategory.Enabled then					
				if entry.bestItemTypeName ~= lastBestItemCategoryName then
					--new header
					hiddenItem = false
					
					lastBestItemCategoryName = entry.bestItemTypeName
					local headerEntry = ZO_ScrollList_CreateDataEntry(998, {bestItemTypeName = entry.bestItemTypeName, stackLaunderPrice = 0})
					headerEntry.sortPriorityName = entry.sortPriorityName
					headerEntry.isHeader = true
					headerEntry.bestItemTypeName = entry.bestItemTypeName
					headerEntry.bagTypeId = entry.bagTypeId
					--local num = getCount(entry.bagTypeId, entry.bestItemTypeName)
					if lastHeaderEntry then 
						lastHeaderEntry.num = getCount(lastHeaderEntry.bagTypeId, lastHeaderEntry.bestItemTypeName)
					end
					lastHeaderEntry = headerEntry
					--headerEntry.num = num
					 
					if entry.isHeader then
						countItems = false
					else 
						countItems = true
						resetCount(entry.bagTypeId, entry.bestItemTypeName)
					end
					if entry.isHidden then
						--don't add header
						hiddenItem = true
					else					
						table.insert(newScrollData, headerEntry)
						--check collapse
						if AutoCategory.IsCategoryCollapsed(entry.bagTypeId, entry.bestItemTypeName) then
							hiddenItem = true
						end
					end
				end
			end
	    	if entry.typeId ~= 998 then
				if not hiddenItem then
					table.insert(newScrollData, entry)
				end
				if countItems then 
					addCount(entry.bagTypeId, entry.bestItemTypeName)
				end
	    	end
	    end
		if lastHeaderEntry then 
			lastHeaderEntry.num = getCount(lastHeaderEntry.bagTypeId, lastHeaderEntry.bestItemTypeName)
		end
	    self.list.data = newScrollData  
	end
    ZO_PreHook(SMITHING.deconstructionPanel.inventory, "SortData", prehookCraftSort)
    ZO_PreHook(SMITHING.improvementPanel.inventory, "SortData", prehookCraftSort)
end

function AutoCategory.HookGamepadInventory()
	function ZO_GamepadInventoryList_AddSlotDataToTable(self, slotsTable, inventoryType, slotIndex)
		local itemFilterFunction = self.itemFilterFunction
		local categorizationFunction = self.categorizationFunction or ZO_InventoryUtils_Gamepad_GetBestItemCategoryDescription
		local slotData = SHARED_INVENTORY:GenerateSingleSlotData(inventoryType, slotIndex)
		if slotData then
		--[[
			if (not itemFilterFunction) or itemFilterFunction(slotData) then
				-- itemData is shared in several places and can write their own value of bestItemCategoryName.
				-- We'll use bestGamepadItemCategoryName instead so there are no conflicts.
				slotData.bestGamepadItemCategoryName = categorizationFunction(slotData)

				table.insert(slotsTable, slotData)
			end
			]]
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
	ZO_GamepadInventoryList.AddSlotDataToTable = ZO_GamepadInventoryList_AddSlotDataToTable
	ZO_GamepadInventoryList.sortFunction = AutoCategory_ItemSortComparator
end
 
function AutoCategory.HookGamepadCraftStation()
--API 100021
	local function ZO_GamepadCraftingInventory_AddFilteredDataToList(self, filteredDataTable)
		table.sort(filteredDataTable, AutoCategory_ItemSortComparator)

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
	ZO_GamepadCraftingInventory.AddFilteredDataToList = ZO_GamepadCraftingInventory_AddFilteredDataToList
	
	function ZO_GamepadCraftingInventory_GenerateCraftingInventoryEntryData(self, bagId, slotIndex, stackCount, slotData)
		local itemName = GetItemName(bagId, slotIndex)
		local icon = GetItemInfo(bagId, slotIndex)
		local name = zo_strformat(SI_TOOLTIP_ITEM_NAME, itemName)
		local customSortData = self.customDataSortFunction and self.customDataSortFunction(bagId, slotIndex) or 0

		local newData = ZO_GamepadEntryData:New(name)
		newData:InitializeCraftingInventoryVisualData(bagId, slotIndex, stackCount, customSortData, self.customBestItemCategoryNameFunction, slotData)
		--Auto Category Modify
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
		--end
		ZO_InventorySlot_SetType(newData, self.baseSlotType)

		if self.customExtraDataFunction then
			self.customExtraDataFunction(bagId, slotIndex, newData)
		end

		return newData
	end
	ZO_GamepadCraftingInventory.GenerateCraftingInventoryEntryData = ZO_GamepadCraftingInventory_GenerateCraftingInventoryEntryData
--API 100021
end

function AutoCategory.HookGamepadTradeInventory() 
	local originalFunction = ZO_GamepadTradeWindow.InitializeInventoryList
	
	local function ZO_GamepadInventoryList_AddSlotDataToTable(self, slotsTable, inventoryType, slotIndex)
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
	
	
	ZO_GamepadTradeWindow.InitializeInventoryList = function(self) 
		originalFunction(self)
		self.inventoryList.AddSlotDataToTable = ZO_GamepadInventoryList_AddSlotDataToTable
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