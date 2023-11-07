--[[
CHANGE DETECTION STRATEGY
This file uses hooks on API functions: 
	PLAYER_INVENTORY:ApplySort, SMITHING.deconstructionPanel.inventory:SortData, and SMITHING.improvementPanel.inventory:SortData 
to order items in categories, in all inventories (including crafting station)
This process involves executing all active rules for each items, and can be 
triggered multiple times in a row, notably for bank transfers (more than ten calls)
In order to reduce the impact of the add-on:
	1 - The results of rules' execution are stored in 'itemEntry.data'.
 		As 'itemEntry.data' is persistent, results can be reused directly without having to re-execute all the rules every time.
		However, 'itemEntry.data' will not persist forever and will be reset at some point, and rules will need to be re-executed, but this is not much of an issue.
		
	2 - A change detection strategy is used to re-execute rules when necessary.
		A hash for each item is used to trigger re-execution of rules for a single item based on:
			- Time, as a safety net, in case a change were missed for any reason: test if the results stored are older than 2 seconds
			- Base game data: test various variables like isPlayerLocked, brandNew, isInArmory etc.
			- FCOIS data: test if item's marks have changed
			
		Some API events are monitored:
			- A hook on PLAYER_INVENTORY:OnInventorySlotUpdated triggers re-execution of rules for a single item
			- A callback on LAM-PanelClosed triggers re-execution of rules
			- The event EVENT_STACKED_ALL_ITEMS_IN_BAG is used so re-execution of rules with inventory refresh can be triggered manually by stacking all items.
]]


local LMP = LibMediaProvider
local SF = LibSFUtils
local AC = AutoCategory

-- uniqueIDs of items that have been updated (need rule re-execution), 
-- based on PLAYER_INVENTORY:OnInventorySlotUpdated hook
local forceRuleReloadByUniqueIDs = {} 

AutoCategory.dataCount = {}

local sortKeys = {
    slotIndex = { isNumeric = true },
    stackCount = { 
		tiebreaker = "slotIndex", 
		isNumeric = true 
	},
    name = { tiebreaker = "stackCount" },
    quality = { 
		tiebreaker = "name", 
		isNumeric = true 
	},
    stackSellPrice = { 
		tiebreaker = "name", 
		tieBreakerSortOrder = ZO_SORT_ORDER_UP, 
		isNumeric = true 
	},
    statusSortOrder = { tiebreaker = "age", isNumeric = true},
    age = { 
		tiebreaker = "name", 
		tieBreakerSortOrder = ZO_SORT_ORDER_UP, 
		isNumeric = true
	},
    statValue = { 
		tiebreaker = "name", 
		isNumeric = true, 
		tieBreakerSortOrder = ZO_SORT_ORDER_UP 
	},
    traitInformationSortOrder = { 
		tiebreaker = "name", 
		isNumeric = true, 
		tieBreakerSortOrder = ZO_SORT_ORDER_UP 
	},
    sellInformationSortOrder = { 
		tiebreaker = "name", 
		isNumeric = true, 
		tieBreakerSortOrder = ZO_SORT_ORDER_UP 
	},
	ptValue = { 
		tiebreaker = "name", 
		isNumeric = true 
	},
}

local CATEGORY_HEADER = 998

-- convenience function
local function NilOrLessThan(value1, value2)
    if value1 == nil then
        return true
		
    elseif value2 == nil then
        return false
		
	elseif type(value1) == "boolean" then
		if value1 == false then 
			return true 
		end
		return false
		
    else 
        return value1 < value2
    end
end 

local function buildHashString(...)
	return SF.dstr(":",...)
end

-- ---------------------------------------------------
-- Category Header functions

-- setup function for category header type to be added to the scroll list
local function setup_InventoryItemRowHeader(rowControl, slot, overrideOptions)
	--set header
	local appearance = AutoCategory.acctSaved.appearance
	local headerLabel = rowControl:GetNamedChild("HeaderName")	
	headerLabel:SetHorizontalAlignment(appearance["CATEGORY_FONT_ALIGNMENT"])
	headerLabel:SetFont(string.format('%s|%d|%s', 
			LMP:Fetch('font', 
				appearance["CATEGORY_FONT_NAME"]), 
				appearance["CATEGORY_FONT_SIZE"], 
				appearance["CATEGORY_FONT_STYLE"]))
	local data = SF.safeTable(slot.dataEntry.data)
	local cateName = SF.nilDefault(data.AC_categoryName, "Unknown")
	local bagTypeId = SF.nilDefault(data.AC_bagTypeId, 0)
	local num = SF.nilDefault(data.AC_catCount,0)
	
	local cache = AutoCategory.cache
	local headerColor = "CATEGORY_FONT_COLOR"
	if cache.entriesByName[bagTypeId][cateName] then
		if cache.entriesByName[bagTypeId][cateName].isHidden then
			headerColor = "HIDDEN_CATEGORY_FONT_COLOR"
		end
		
	elseif AC.saved.bags[bagTypeId].isUngroupedHidden and
			cateName == AutoCategory.saved.appearance["CATEGORY_OTHER_TEXT"] then
		headerColor = "HIDDEN_CATEGORY_FONT_COLOR"
	end
	headerLabel:SetColor(appearance[headerColor][1], 
						 appearance[headerColor][2], 
						 appearance[headerColor][3], 
						 appearance[headerColor][4])
	
	-- Add count to category name if selected in options
    if AutoCategory.acctSaved.general["SHOW_CATEGORY_ITEM_COUNT"] then
        headerLabel:SetText(string.format('%s |[%d]|r', cateName, num))
        headerLabel:SetColor(
			appearance[headerColor][1], 
			appearance[headerColor][2],
			appearance[headerColor][3], 
			appearance[headerColor][4])
			
    else
        headerLabel:SetText(cateName)
    end	
		
	-- set the collapse marker
	local marker = rowControl:GetNamedChild("CollapseMarker")
	local collapsed = AutoCategory.IsCategoryCollapsed(bagTypeId, cateName) 
	if AutoCategory.acctSaved.general["SHOW_CATEGORY_COLLAPSE_ICON"] then
		marker:SetHidden(false)
		if collapsed then
			-- is collapsed, so (+)
			marker:SetTexture("EsoUI/Art/Buttons/plus_up.dds")
			
		else
			-- is not collapsed so (-)
			marker:SetTexture("EsoUI/Art/Buttons/minus_up.dds")
		end
		AutoCategory.SetCategoryCollapsed(bagTypeId, cateName, collapsed)
		
	else
		marker:SetHidden(true)
	end
	
	rowControl:SetHeight(
		AutoCategory.acctSaved.appearance["CATEGORY_HEADER_HEIGHT"])
	rowControl.slot = slot
end

-- create the row header type and add to the inventory scroll list
local function AddTypeToList(rowHeight, datalist, inven_ndx) 
	if datalist == nil then return end
	
	local templateName = "AC_InventoryItemRowHeader"
	local setupFunc = setup_InventoryItemRowHeader
	local resetCB = ZO_InventorySlot_OnPoolReset
	local hiddenCB = nil
	if inven_ndx then
		hiddenCB = PLAYER_INVENTORY.inventories[inven_ndx].listHiddenCallback
	end
	ZO_ScrollList_AddDataType(datalist, CATEGORY_HEADER, templateName, 
	    rowHeight, setupFunc, hiddenCB, nil, resetCB)
end

local function createHeaderEntry(catInfo)
	local headerEntry = ZO_ScrollList_CreateDataEntry(CATEGORY_HEADER, { 
			AC_categoryName = catInfo.AC_categoryName,
			AC_sortPriorityName = catInfo.AC_sortPriorityName,
			AC_bagTypeId = catInfo.AC_bagTypeId,
			AC_isHeader = true,
			AC_catCount = catInfo.AC_catCount,
			stackLaunderPrice = 0})
	return headerEntry
end

-- ---------------------------------------------------

local function isUngroupedHidden(bagTypeId)
	return bagTypeId == nil or AutoCategory.saved.bags[bagTypeId].isUngroupedHidden
end

local function isHiddenEntry(itemEntry)
	if not itemEntry or not itemEntry.data then return false end
	
	local data = itemEntry.data
	if data.AC_isHidden or data.AC_bagTypeId == nil then return true end
	if not data.AC_matched and isUngroupedHidden(data.AC_bagTypeId) then 
		return true 
	end
	
	return false --AutoCategory.IsCategoryCollapsed(data.AC_bagTypeId, data.AC_categoryName)
end

local function isCollapsed(itemEntry)
	if not itemEntry or not itemEntry.data then return false end
	
	local data = itemEntry.data
	if data.AC_bagTypeId == nil then return true end
	
	return AutoCategory.IsCategoryCollapsed(data.AC_bagTypeId, data.AC_categoryName)
end

local function runRulesOnEntry(itemEntry, specialType)
	--only match on items(not headers)
	if itemEntry.typeId == CATEGORY_HEADER then return end
	
	local data = itemEntry.data
	local bagId = data.bagId
	local slotIndex = data.slotIndex
	
	local matched, categoryName, categoryPriority, bagTypeId, isHidden 
				= AutoCategory:MatchCategoryRules(bagId, slotIndex, specialType)
	data.AC_matched = matched
	if matched then
		data.AC_categoryName = categoryName
		data.AC_sortPriorityName = string.format("%04d%s", 1000 - categoryPriority , categoryName)
		data.AC_isHidden = isHidden
		
	else
		data.AC_categoryName = AutoCategory.acctSaved.appearance["CATEGORY_OTHER_TEXT"]
		data.AC_sortPriorityName = string.format("%04d%s", 
			9999 , data.AC_categoryName)
		-- if was not matched, then the isHidden value that was returned is not valid
		data.AC_isHidden = isUngroupedHidden(bagTypeId)
	end
	data.AC_bagTypeId = bagTypeId
	data.AC_isHeader = false
		
end

local function sortInventoryFn(inven, left, right, key, order) 
	if left == nil or left.data == nil then
		return true
	end
	if right == nil or right.data == nil then
		return false
	end
	if AutoCategory.BulkMode then
		-- revert to default
		return ZO_TableOrderingFunction(left.data, right.data, 
			inven.currentSortKey, sortKeys, inven.currentSortOrder)
	end
	
	local ldata = left.data
	local rdata = right.data
	
	if AutoCategory.Enabled then
		if rdata.AC_sortPriorityName ~= ldata.AC_sortPriorityName then
			return NilOrLessThan(ldata.AC_sortPriorityName, rdata.AC_sortPriorityName)
		end
		if rdata.AC_isHeader ~= ldata.AC_isHeader then
			return NilOrLessThan(rdata.AC_isHeader, ldata.AC_isHeader)
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
	
	if key == nil or sortKeys[key] == nil then
		-- possible fix for Arkadius' Trading Tools sort bug
		key =  "statValue"
	end

	return ZO_TableOrderingFunction(left.data, right.data, 
			key, sortKeys, order)
end

local function constructEntryHash(itemEntry)
	local data = itemEntry.data
	--- Hash construction
	local hashFCOIS = "" -- retrieve FCOIS mark data for change detection with itemEntry hash
	if FCOIS and data.bagId and data.bagId > 0 and data.slotIndex and data.slotIndex > 0 then
		local _, markedIconsArray = FCOIS.IsMarked(data.bagId, data.slotIndex, -1)
		if markedIconsArray then
			for _, value in ipairs(markedIconsArray) do
				hashFCOIS = hashFCOIS .. tostring(value)
			end
		end
	end
	local newEntryHash = buildHashString(
					data.isPlayerLocked, data.isGemmable, data.stolen, data.isBoPTradeable, data.isInArmory, data.brandNew, data.bagId, data.stackCount, data.uniqueId, data.slotIndex,
					data.meetsUsageRequirement, data.locked, data.isJunk, hashFCOIS)
	return newEntryHash
end

local function detectItemChanges(itemEntry, newEntryHash, needReload)
	local data = itemEntry.data
	local changeDetected = false
	local currentTime = os.clock()
	
	local function setChange(val)
		if val == false then return false end
		
		data.AC_lastUpdateTime = currentTime
		changeDetected = true
		return true
	end
	
	if needReload == true then
		return setChange(true)
	end

	--- Update hash and test if changed
	if data.AC_hash == nil or data.AC_hash ~= newEntryHash then
		data.AC_hash = newEntryHash
		return setChange(true)
	end

	--- Test last update time, triggers update if more than 2s
	if data.AC_lastUpdateTime == nil then
		return setChange(true)
		
	elseif currentTime - tonumber(data.AC_lastUpdateTime) > 2 then
		return setChange(true)
	end

	--- Test if uniqueID tagged for update
	for _, uniqueID in ipairs(forceRuleReloadByUniqueIDs) do 
		-- look for items with changes detected
		if data.uniqueID == uniqueID then
			return setChange(true)
		end
	end

	return changeDetected
end

-- Execute rules and store results in itemEntry.data, if needed. 
-- Return the number of items updated with rule re-execution.
--
-- The needsReload parameter allows the caller to force a re-evaluation
-- of rule on all of the (non-header) contents of the scrollData.
-- Defaults to false.
local function handleRules(scrollData, needsReload, specialType)
	-- keep track of if any changes to rule results occurred
	local updateCount = 0 
	
	-- at craft stations scrollData seems to be reset every time, 
	-- so need to always reload
	local reloadAll = needsReload or false 
	
	for _, itemEntry in ipairs(scrollData) do
		if itemEntry.typeId ~= CATEGORY_HEADER then 
			local newHash = constructEntryHash(itemEntry)
			if detectItemChanges(itemEntry, newHash, reloadAll) then 
				-- reload rules if full reload triggered, or changes detected
				updateCount = updateCount + 1
				runRulesOnEntry(itemEntry, specialType)
			end
		end
	end
	forceRuleReloadByUniqueIDs = {} --- reset update buffer
	return updateCount
end

-- look for the bag ID associated with the scrollData list
--
-- may return nil if there is no (non-header) data in the scrollData list
local function getListBagID(scrollData)
	local bagId = nil
	for i, entry in ipairs(scrollData) do
		if entry.typeId ~= CATEGORY_HEADER then
			local slotData = entry.data
			bagId = slotData.bagId
			break
		end
	end
	return bagId
end

--- Create list with visible items and headers (performs category count).
local function createNewScrollData(scrollData)
	local newScrollData = {} --- output, entries sorted with category headers
	local bagTypeId = getListBagID(scrollData)
	
	-- --------------------
	-- The categoryList info is collected and then each entry is passed
	-- to createHeaderEntry() to make a header row
	local categoryList = {} -- [name] {AC_catCount, AC_sortPriorityName,
							--         AC_categoryName, AC_bagTypeId }
							
	local function addCount(name)
		categoryList[name] = SF.safeTable(categoryList[name])
		if categoryList[name].AC_catCount == nil then
			categoryList[name].AC_catCount = 0
		end
		categoryList[name].AC_catCount = categoryList[name].AC_catCount + 1
	end

	local function getCount(name)
		categoryList[name] = SF.safeTable(categoryList[name])
		if categoryList[name].AC_catCount == nil then
			categoryList[name].AC_catCount = 0
		end
		return categoryList[name].AC_catCount
	end

	local function setCount(bagTypeId, name, count)
		categoryList[name] = SF.safeTable(categoryList[name])
		categoryList[name].AC_catCount = count
	end
	-- --------------------
	-- create newScrollData with headers and only non hidden items. No sorting here!
	for _, itemEntry in ipairs(scrollData) do 
		-- add visible non-header rows to the new scrollData table
		if not isHiddenEntry(itemEntry) then
			if itemEntry.typeId ~= CATEGORY_HEADER and not isCollapsed(itemEntry) then 
				-- add item if visible
				table.insert(newScrollData, itemEntry)
			end
		end

		-- look up the owning category in our list, update entry count
		-- or else create an entry with count = 1
		local data = itemEntry.data
		local AC_categoryName = data.AC_categoryName
		if not categoryList[AC_categoryName] then 
		
			-- keep track of categories and required data
			categoryList[AC_categoryName] =  {
				AC_sortPriorityName = data.AC_sortPriorityName,
				AC_categoryName = AC_categoryName, 
				AC_bagTypeId = data.AC_bagTypeId, 
				AC_catCount = 0, 
			} 
		end
		local catInfo = categoryList[AC_categoryName]
		
		if itemEntry.typeId ~= CATEGORY_HEADER then 
			-- this is an item, start new count
			addCount(AC_categoryName)
			
		elseif itemEntry.typeId == CATEGORY_HEADER 
			and AutoCategory.IsCategoryCollapsed(data.AC_bagTypeId, AC_categoryName) then 
			-- this is a collapsed category --> reuse previous count, since
			--   the content is not available in scrollData
			setCount(data.AC_bagTypeId, AC_categoryName, data.AC_catCount)
		end	
	end
	
	-- Create headers and append to newScrollData
	for _, catInfo in pairs(categoryList) do ---> add tracked categories
		if catInfo.AC_catCount ~= nil then --and catInfo.AC_catCount ~= 0 then
			local headerEntry = createHeaderEntry(catInfo)
			table.insert(newScrollData, headerEntry)
		end
	end
	return newScrollData
end

local function prehookSort(self, inventoryType) 
	-- revert to default behaviour if safety conditions not met
	if not AutoCategory.Enabled then return false end
	if inventoryType == INVENTORY_QUEST_ITEM then return false end

	-- inventory info from esoui/ingame/inventory/inventory.lua
	local zo_inventory = self.inventories[inventoryType]
					or self.inventories[self.selectedTabType]
	
	--change sort function
	zo_inventory.sortFn =  function(left, right) 
			return sortInventoryFn(zo_inventory, left, right,
									zo_inventory.currentSortKey, 
									zo_inventory.currentSortOrder)
		end

	-- from nogetrandom
	local scene
	if SCENE_MANAGER and SCENE_MANAGER:GetCurrentScene() then
		scene = SCENE_MANAGER:GetCurrentScene():GetName()
	end
	if scene then
		if AutoCategory.BulkMode and AutoCategory.BulkMode == true then
			if scene == "guildBank" or (XLGearBanker and scene == "bank") then
				return false	-- skip out early
			end
		end
	end	
	-- end nogetrandom recommend 

	local list = zo_inventory.listView 
	local scrollData = ZO_ScrollList_GetDataList(list) 
	local bagId = getListBagID(scrollData)
	
	local needsReload = true
	if scene == "bank" or scene == "guildBank" then
		needsReload = false
	end
	handleRules(scrollData, needsReload) --> update rules' results if necessary

	
	-- add header rows	   
	--> rebuild scrollData with headers and visible items
	list.data = createNewScrollData(scrollData) 
	table.sort(list.data, zo_inventory.sortFn)  
	ZO_ScrollList_Commit(list)
	return false
end

local function prehookCraftSort(self)
	-- revert to default behaviour if safety conditions not met
	if not AutoCategory.Enabled then return false end

	--change sort function
	self.sortFunction = function(left, right) 
			return sortInventoryFn(self, left, right, self.sortKey, self.sortOrder)
		end

	local scrollData = ZO_ScrollList_GetDataList(self.list)
	if #scrollData > 0 then
		-- rerun rules for all items (always for craftstations)
		handleRules(scrollData, true, AC_BAG_TYPE_CRAFTSTATION)

		-- add header rows	    
		self.list.data = createNewScrollData(scrollData)
		table.sort(self.list.data, self.sortFunction)
		ZO_ScrollList_Commit(self.list)
	end
	-- continue on to run follow-on hooks
	return false
end

-- perform refresh of list
local function refresh(forceRuleReload)
	AutoCategory.RefreshCurrentList(forceRuleReload)
end

-- event handlers
local function onInventorySlotUpdated(self, bagId, slotIndex)
	-- mark the slot as needing rule re-evaluation
	table.insert(forceRuleReloadByUniqueIDs, GetItemUniqueId(bagId, slotIndex))
end

local function onStackItems(evtid, bagId)
	local invType = PLAYER_INVENTORY.bagToInventoryType[bagId]
	AutoCategory.RefreshList(invType)
end


function AutoCategory.HookKeyboardMode()
	--Add a new header row data type
	local rowHeight = AutoCategory.acctSaved.appearance["CATEGORY_HEADER_HEIGHT"]
	
    AddTypeToList(rowHeight, ZO_PlayerInventoryList,  INVENTORY_BACKPACK)
    AddTypeToList(rowHeight, ZO_CraftBagList,         INVENTORY_BACKPACK)
    AddTypeToList(rowHeight, ZO_PlayerBankBackpack,   INVENTORY_BACKPACK)
    AddTypeToList(rowHeight, ZO_GuildBankBackpack,    INVENTORY_BACKPACK)
    AddTypeToList(rowHeight, ZO_HouseBankBackpack,    INVENTORY_BACKPACK)
    AddTypeToList(rowHeight, ZO_PlayerInventoryQuest, INVENTORY_QUEST_ITEM)
	
    AddTypeToList(rowHeight, SMITHING.deconstructionPanel.inventory.list, nil)
    AddTypeToList(rowHeight, SMITHING.improvementPanel.inventory.list,    nil)
	
    AddTypeToList(rowHeight,
		ZO_UniversalDeconstructionTopLevel_KeyboardPanelInventoryBackpack, nil )
	
	--- sort hooks
	ZO_PreHook(PLAYER_INVENTORY,                       "ApplySort", prehookSort)
    ZO_PreHook(SMITHING.deconstructionPanel.inventory, "SortData",  prehookCraftSort)
    ZO_PreHook(SMITHING.improvementPanel.inventory,    "SortData",  prehookCraftSort)
    ZO_PreHook(UNIVERSAL_DECONSTRUCTION.deconstructionPanel.inventory, 
													   "SortData",  prehookCraftSort)
	
	--- changes detection events/hooks (anticipate if rules results may have changed)
	ZO_PreHook(PLAYER_INVENTORY, "OnInventorySlotUpdated", onInventorySlotUpdated) -- item has changed
	
	-- Other events that cause a full refresh
	CALLBACK_MANAGER:RegisterCallback("LAM-PanelClosed", 
		refresh, true)
			
	EVENT_MANAGER:RegisterForEvent(AutoCategory.name, 
			EVENT_STACKED_ALL_ITEMS_IN_BAG, onStackItems )

end


--[[
-------- HINTS FOR REFERENCE -----------

In sharedInventory.lua we can see a breakdown of how slotData is build, under is a truncated summary:

slot.rawName = GetItemName(bagId, slotIndex)
slot.name = zo_strformat(SI_TOOLTIP_ITEM_NAME, slot.rawName)
slot.requiredLevel = GetItemRequiredLevel(bagId, slotIndex)
slot.requiredChampionPoints = GetItemRequiredChampionPoints(bagId, slotIndex)
slot.itemType, slot.specializedItemType = GetItemType(bagId, slotIndex)
slot.uniqueId = GetItemUniqueId(bagId, slotIndex)
slot.iconFile = icon
slot.stackCount = stackCount
slot.sellPrice = sellPrice
slot.launderPrice = launderPrice
slot.stackSellPrice = stackCount * sellPrice
slot.stackLaunderPrice = stackCount * launderPrice
slot.bagId = bagId
slot.slotIndex = slotIndex
slot.meetsUsageRequirement = meetsUsageRequirement or (bagId == BAG_WORN)
slot.locked = locked
slot.functionalQuality = functionalQuality
slot.displayQuality = displayQuality
-- slot.quality is deprecated, included here for addon backwards compatibility
slot.quality = displayQuality
slot.equipType = equipType
slot.isPlayerLocked = IsItemPlayerLocked(bagId, slotIndex)
slot.isBoPTradeable = IsItemBoPAndTradeable(bagId, slotIndex)
slot.isJunk = IsItemJunk(bagId, slotIndex)
slot.statValue = GetItemStatValue(bagId, slotIndex) or 0
slot.itemInstanceId = GetItemInstanceId(bagId, slotIndex) or nil
slot.brandNew = isNewItem
slot.stolen = IsItemStolen(bagId, slotIndex)
slot.filterData = { GetItemFilterTypeInfo(bagId, slotIndex) }
slot.condition = GetItemCondition(bagId, slotIndex)
slot.isPlaceableFurniture = IsItemPlaceableFurniture(bagId, slotIndex)
slot.traitInformation = GetItemTraitInformation(bagId, slotIndex)
slot.traitInformationSortOrder = ZO_GetItemTraitInformation_SortOrder(slot.traitInformation)
slot.sellInformation = GetItemSellInformation(bagId, slotIndex)
slot.sellInformationSortOrder = ZO_GetItemSellInformationCustomSortOrder(slot.sellInformation)
slot.actorCategory = GetItemActorCategory(bagId, slotIndex)
slot.isInArmory = IsItemInArmory(bagId, slotIndex)
slot.isGemmable = false
slot.requiredPerGemConversion = nil
slot.gemsAwardedPerConversion = nil
slot.isFromCrownStore = IsItemFromCrownStore(bagId, slotIndex)
slot.age = GetFrameTimeSeconds()

slotData.statusSortOrder = self:ComputeDynamicStatusMask(slotData.isPlayerLocked, slotData.isGemmable, slotData.stolen, slotData.isBoPTradeable, slotData.isInArmory, slotData.brandNew, slotData.bagId == BAG_WORN)

]]
