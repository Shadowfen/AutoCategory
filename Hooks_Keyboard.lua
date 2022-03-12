
local LMP = LibMediaProvider
local SF = LibSFUtils

AutoCategory.dataCount = {}

local sortKeys = {
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
	ptValue = { tiebreaker = "name", isNumeric = true },
}

local CATEGORY_HEADER = 998

-- convenience function
-- given a (supposed) table variable
-- either return the table variable
-- or return an empty table if the table variable was nil
local function validTable(tbl)
    if tbl == nil then
        tbl = {}
    end
    return tbl
end

-- convenience function
local function NilOrLessThan(value1, value2)
    if value1 == nil then
        return true
    elseif value2 == nil then
        return false
    else
        return value1 < value2
    end
end 

local function setup_InventoryItemRowHeader(rowControl, slot, overrideOptions)
	--set header
	local headerLabel = rowControl:GetNamedChild("HeaderName")
	-- Add count to category name if selected in options
	if AutoCategory.acctSaved.general["SHOW_CATEGORY_ITEM_COUNT"] then
		headerLabel:SetText(string.format('%s |cFFE690[%d]|r', slot.bestItemTypeName, slot.dataEntry.num))
	else
		headerLabel:SetText(slot.bestItemTypeName)
	end
	
	local appearance = AutoCategory.acctSaved.appearance
	headerLabel:SetHorizontalAlignment(appearance["CATEGORY_FONT_ALIGNMENT"])
	headerLabel:SetFont(string.format('%s|%d|%s', 
			LMP:Fetch('font', appearance["CATEGORY_FONT_NAME"]), 
			appearance["CATEGORY_FONT_SIZE"], appearance["CATEGORY_FONT_STYLE"]))
	headerLabel:SetColor(appearance["CATEGORY_FONT_COLOR"][1], appearance["CATEGORY_FONT_COLOR"][2], 
						 appearance["CATEGORY_FONT_COLOR"][3], appearance["CATEGORY_FONT_COLOR"][4])

	local marker = rowControl:GetNamedChild("CollapseMarker")
	local cateName = slot.dataEntry.bestItemTypeName
	local bagTypeId = slot.dataEntry.bagTypeId 
	
	-- set the collapse marker
	local collapsed = AutoCategory.IsCategoryCollapsed(bagTypeId, cateName) 
	if AutoCategory.acctSaved.general["SHOW_CATEGORY_COLLAPSE_ICON"] then
		marker:SetHidden(false)
		if collapsed then
			marker:SetTexture("EsoUI/Art/Buttons/plus_up.dds")
		else
			marker:SetTexture("EsoUI/Art/Buttons/minus_up.dds")
		end
	else
		marker:SetHidden(true)
	end
	
	rowControl:SetHeight(AutoCategory.acctSaved.appearance["CATEGORY_HEADER_HEIGHT"])
	rowControl.slot = slot
end

local function AddTypeToList(rowHeight, datalist, inven_ndx) 
	if datalist == nil then return end
	
	local templateName = "AC_InventoryItemRowHeader"
	local setupFunc = setup_InventoryItemRowHeader
	local resetCB = ZO_InventorySlot_OnPoolReset
	local hiddenCB
	if inven_ndx then
		hiddenCB = PLAYER_INVENTORY.inventories[inven_ndx].listHiddenCallback
	else
		hiddenCB = nil
	end
	ZO_ScrollList_AddDataType(datalist, CATEGORY_HEADER, templateName, 
	    rowHeight, setupFunc, hiddenCB, nil, resetCB)
end
  
local function resetCount(bagTypeId, name)
	AutoCategory.dataCount[bagTypeId] = validTable(AutoCategory.dataCount[bagTypeId])
	AutoCategory.dataCount[bagTypeId][name] = 0 
end

local function addCount(bagTypeId, name)
	AutoCategory.dataCount[bagTypeId] = validTable(AutoCategory.dataCount[bagTypeId])
	if AutoCategory.dataCount[bagTypeId][name] == nil then
		AutoCategory.dataCount[bagTypeId][name] = 0
	end
	AutoCategory.dataCount[bagTypeId][name] = AutoCategory.dataCount[bagTypeId][name] + 1
end

local function getCount(bagTypeId, name)
	AutoCategory.dataCount[bagTypeId] = validTable(AutoCategory.dataCount[bagTypeId])
	if AutoCategory.dataCount[bagTypeId][name] == nil then
		AutoCategory.dataCount[bagTypeId][name] = 0
	end
	return AutoCategory.dataCount[bagTypeId][name]
end

local function createHeaderEntry(entry, num)
	local headerEntry = ZO_ScrollList_CreateDataEntry(CATEGORY_HEADER, 
			{bestItemTypeName = entry.bestItemTypeName, 
			 stackLaunderPrice = 0})
	headerEntry.sortPriorityName = entry.sortPriorityName
	headerEntry.isHeader = true
	headerEntry.bestItemTypeName = entry.bestItemTypeName
	headerEntry.bagTypeId = entry.bagTypeId
	local num = getCount(entry.bagTypeId, entry.bestItemTypeName) 
	headerEntry.num = num
	return headerEntry
end

local function sortInventoryFn(inven, left, right) 
	if AutoCategory.Enabled then
		if right.sortPriorityName ~= left.sortPriorityName then
			return NilOrLessThan(left.sortPriorityName, right.sortPriorityName)
		end
		if right.isHeader ~= left.isHeader then
			return NilOrLessThan(right.isHeader, left.isHeader)
		end
	end
	--compatible with quality sort
	if type(inven.sortKey) == "function" then 
		if inven.sortOrder == ZO_SORT_ORDER_UP then
			return inven.sortKey(left.data, right.data)
		else
			return inven.sortKey(right.data, left.data)
		end
	end
	return ZO_TableOrderingFunction(left.data, right.data, 
			inven.currentSortKey, sortKeys, inven.currentSortOrder)
end
    
local function prehookSort(self, inventoryType) 
	local inventory = self.inventories[inventoryType]
	if inventory == nil then
		-- Use normal inventory by default (instead of the quest item inventory for example)
		inventory = self.inventories[self.selectedTabType]
	end
	
	--change sort function
	inventory.sortFn =  function(left, right) 
		if AutoCategory and AutoCategory.Enabled then
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

	-- from nogetrandom
	if SCENE_MANAGER and SCENE_MANAGER:GetCurrentScene() then
	  if AutoCategory.BulkMode and AutoCategory.BulkMode == true then
		local scene = SCENE_MANAGER:GetCurrentScene():GetName()
		if scene == "guildBank" or (XLGearBanker and scene == "bank") then
		  return false	-- skip out early
		end
	  end
	end	
	-- end nogetrandom recommend
	--[[
    if SCENE_MANAGER and SCENE_MANAGER:GetCurrentScene() then
        if AutoCategory.BulkMode and AutoCategory.BulkMode == true and SCENE_MANAGER:GetCurrentScene():GetName() == "guildBank" then
            return false	-- skip out early
        end
    end
	--]]

	local list = inventory.listView 
	local scrollData = ZO_ScrollList_GetDataList(list) 
	
	for i, entry in ipairs(scrollData) do
		--only match items(not headers)
		if entry.typeId ~= CATEGORY_HEADER then
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
				local headerEntry = createHeaderEntry(entry, num)
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
		if entry.typeId ~= CATEGORY_HEADER then
			if not hiddenItem then
				table.insert(newScrollData, entry)
			end
			if countItems then
				addCount(entry.bagTypeId, entry.bestItemTypeName)
			end
		end
	end
	list.data = newScrollData 
	ZO_ScrollList_Commit(list)

end

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
		if entry.typeId ~= CATEGORY_HEADER then
		local slotData = entry.data
		local matched, categoryName, categoryPriority, bagTypeId, isHidden = 
			AutoCategory:MatchCategoryRules(slotData.bagId, slotData.slotIndex, AC_BAG_TYPE_CRAFTSTATION)
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
				local headerEntry = ZO_ScrollList_CreateDataEntry(CATEGORY_HEADER, {bestItemTypeName = entry.bestItemTypeName, stackLaunderPrice = 0})
				headerEntry.sortPriorityName = entry.sortPriorityName
				headerEntry.isHeader = true
				headerEntry.bestItemTypeName = entry.bestItemTypeName
				headerEntry.bagTypeId = entry.bagTypeId
				--local num = getCount(entry.bagTypeId, entry.bestItemTypeName)
				if lastHeaderEntry then 
					lastHeaderEntry.num = getCount(lastHeaderEntry.bagTypeId, lastHeaderEntry.bestItemTypeName)
				end
				lastHeaderEntry = headerEntry
				 
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
		if entry.typeId ~= CATEGORY_HEADER then
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

function AutoCategory.HookKeyboardMode() 
    
	--Add a new data type: row with header
	local rowHeight = AutoCategory.acctSaved.appearance["CATEGORY_HEADER_HEIGHT"]
	
    AddTypeToList(rowHeight, ZO_PlayerInventoryList, INVENTORY_BACKPACK)
    AddTypeToList(rowHeight, ZO_CraftBagList, INVENTORY_BACKPACK)
    AddTypeToList(rowHeight, ZO_PlayerBankBackpack, INVENTORY_BACKPACK)
    AddTypeToList(rowHeight, ZO_GuildBankBackpack, INVENTORY_BACKPACK)
    AddTypeToList(rowHeight, ZO_HouseBankBackpack, INVENTORY_BACKPACK)
    AddTypeToList(rowHeight, ZO_PlayerInventoryQuest, INVENTORY_QUEST_ITEM)
    AddTypeToList(rowHeight, SMITHING.deconstructionPanel.inventory.list, nil)
    AddTypeToList(rowHeight, SMITHING.improvementPanel.inventory.list, nil)
	
	--ZO_PreHook(ZO_InventoryManager, "ApplySort", prehookSort)
	ZO_PreHook(PLAYER_INVENTORY, "ApplySort", prehookSort)
	
    ZO_PreHook(SMITHING.deconstructionPanel.inventory, "SortData", prehookCraftSort)
    ZO_PreHook(SMITHING.improvementPanel.inventory, "SortData", prehookCraftSort)
end

