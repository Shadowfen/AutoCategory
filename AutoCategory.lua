----------------------
--INITIATE VARIABLES--
---------------------- 

local L = GetString

AutoCategory.compiledRules = {}

AC_EMPTY_TAG_NAME = L(SI_AC_DEFAULT_NAME_EMPTY_TAG)

function AutoCategory.RecompileRules(ruleset)
  local compiled = {}
  for j = 1, #ruleset do
    local n = ruleset[j].name
    compiled[n],err = zo_loadstring("return("..ruleset[j].rule..")")
    if not compiled[n] then
      d("Error1: " .. err)
      ruleset[j].damaged = true 
    end
  end
  AutoCategory.compiledRules = compiled
end

function AutoCategory.UpdateCurrentSavedVars()
	AutoCategory.curSavedVars= {}
	if not AutoCategory.charSavedVariables.accountWideSetting  then
		AutoCategory.curSavedVars.rules = AutoCategory.acctSavedVariables.rules
		AutoCategory.RecompileRules(AutoCategory.curSavedVars.rules)
		AutoCategory.curSavedVars.bags = AutoCategory.charSavedVariables.bags 
		AutoCategory.curSavedVars.collapses = AutoCategory.charSavedVariables.collapses 
	else 
		AutoCategory.curSavedVars.rules = AutoCategory.acctSavedVariables.rules
        AutoCategory.RecompileRules(AutoCategory.curSavedVars.rules)
		AutoCategory.curSavedVars.bags = AutoCategory.acctSavedVariables.bags  
		AutoCategory.curSavedVars.collapses = AutoCategory.acctSavedVariables.collapses 
	end
end 

function AutoCategory.LoadCollapse()
	if AutoCategory.acctSavedVariables.general["SAVE_CATEGORY_COLLAPSE_STATUS"] then
		--loaded from saved vars 
	else
		--init
		AutoCategory.ResetCollapse()
	end
end

function AutoCategory.ResetCollapse()
	AutoCategory.curSavedVars.collapses = {
		[AC_BAG_TYPE_BACKPACK] = {},
		[AC_BAG_TYPE_BANK] = {},
		[AC_BAG_TYPE_GUILDBANK] = {},
		[AC_BAG_TYPE_CRAFTBAG] = {},
		[AC_BAG_TYPE_CRAFTSTATION] = {},
		[AC_BAG_TYPE_HOUSEBANK] = {},
	}
end

function AutoCategory.ResetToDefaults()
	AutoCategory.acctSavedVariables.rules = AutoCategory.defaultAcctSettings.rules
	AutoCategory.acctSavedVariables.bags = AutoCategory.defaultAcctSettings.bags
	AutoCategory.acctSavedVariables.appearance = AutoCategory.defaultAcctSettings.appearance
    
	AutoCategory.charSavedVariables.rules = AutoCategory.defaultSettings.rules
	AutoCategory.charSavedVariables.bags = AutoCategory.defaultSettings.bags
	AutoCategory.charSavedVariables.accountWideSetting = AutoCategory.defaultSettings.accountWideSetting
    
	AutoCategory.ResetCollapse()
end

local function CheckVersionCompatible()
	--v1.06
	if AutoCategory.acctSavedVariables.appearance == nil then
		AutoCategory.acctSavedVariables.appearance = AutoCategory.defaultAcctSettings.appearance 
	end
	--v1.06
	
	--v1.12, added bag setting for guildbank/craftbag/craftstation
	local function RebuildBagSettingIfNeeded(setting, defaultSetting, bagId)
		if not setting.bags[bagId] then
			setting.bags[bagId] = defaultSetting.bags[bagId]
		end
	end
	RebuildBagSettingIfNeeded(AutoCategory.charSavedVariables, AutoCategory.defaultSettings, AC_BAG_TYPE_GUILDBANK)
	RebuildBagSettingIfNeeded(AutoCategory.charSavedVariables, AutoCategory.defaultSettings, AC_BAG_TYPE_CRAFTBAG)
	RebuildBagSettingIfNeeded(AutoCategory.charSavedVariables, AutoCategory.defaultSettings, AC_BAG_TYPE_CRAFTSTATION)
	
	RebuildBagSettingIfNeeded(AutoCategory.acctSavedVariables, AutoCategory.defaultAcctSettings, AC_BAG_TYPE_GUILDBANK)
	RebuildBagSettingIfNeeded(AutoCategory.acctSavedVariables, AutoCategory.defaultAcctSettings, AC_BAG_TYPE_CRAFTBAG)
	RebuildBagSettingIfNeeded(AutoCategory.acctSavedVariables, AutoCategory.defaultAcctSettings, AC_BAG_TYPE_CRAFTSTATION)
	--v1.12
	
	
	--v1.15, added some options to modify headers appearance, and general settings
	if not AutoCategory.acctSavedVariables.appearance["CATEGORY_OTHER_TEXT"] then
		AutoCategory.acctSavedVariables.appearance["CATEGORY_OTHER_TEXT"] = L(SI_AC_DEFAULT_NAME_CATEGORY_OTHER)
		AutoCategory.acctSavedVariables.appearance["CATEGORY_HEADER_HEIGHT"] = 52 
	end
	if not AutoCategory.acctSavedVariables.general then
		AutoCategory.acctSavedVariables.general = {}
		AutoCategory.acctSavedVariables.general["SHOW_MESSAGE_WHEN_TOGGLE"] = false
	end
	--v1.15
	
	--v1.16 
	--modify the account setting flag, move it to character
	if AutoCategory.charSavedVariables.accountWideSetting == nil then
		AutoCategory.charSavedVariables.accountWideSetting = true
	end
	
	--remove duplicated categories in bag
	local function removeDuplicatedCategories(setting)
		for i = 1, #setting.bags do
			local bag = setting.bags[i]
			local keys = {}
			--traverse from back to front to remove elements while iteration
			for j = #bag.rules, 1, -1 do
				local data = bag.rules[j]
				if keys[data.name] ~= nil then
					--remove duplicated category
					table.remove(bag.rules, j)
				else
					--flag this category
					keys[data.name] = true
				end
			end
		end
	end
	
	removeDuplicatedCategories(AutoCategory.charSavedVariables)
	removeDuplicatedCategories(AutoCategory.acctSavedVariables)
	
	--added hidden category flag to all bags
	local function addHiddenFlagIfPossible(setting)
		for i = 1, #setting.bags do
			local bag = setting.bags[i]
			if bag.isUngroupedHidden == nil then
				bag.isUngroupedHidden = false
			end
			
			for j = 1, #bag.rules do
				local data = bag.rules[j]
				if data.isHidden == nil then
					data.isHidden = false
				end
			end
		end
	end
	addHiddenFlagIfPossible(AutoCategory.charSavedVariables)
	addHiddenFlagIfPossible(AutoCategory.acctSavedVariables)
	
	--added setting
	if AutoCategory.acctSavedVariables.general["SHOW_CATEGORY_ITEM_COUNT"] == nil then 
		AutoCategory.acctSavedVariables.general["SHOW_CATEGORY_ITEM_COUNT"] = true
	end
	--v1.16
	
	--v1.19
	if AutoCategory.acctSavedVariables.general["SAVE_CATEGORY_COLLAPSE_STATUS"] == nil then 
		AutoCategory.acctSavedVariables.general["SAVE_CATEGORY_COLLAPSE_STATUS"] = false
	end
	
	local function addCollapseIfPossible(setting)
		if setting.collapses == nil then
			setting.collapses = {
				[AC_BAG_TYPE_BACKPACK] = {},
				[AC_BAG_TYPE_BANK] = {},
				[AC_BAG_TYPE_GUILDBANK] = {},
				[AC_BAG_TYPE_CRAFTBAG] = {},
				[AC_BAG_TYPE_CRAFTSTATION] = {},
				[AC_BAG_TYPE_HOUSEBANK] = {},
			}
		end
	end
	addCollapseIfPossible(AutoCategory.charSavedVariables)
	addCollapseIfPossible(AutoCategory.acctSavedVariables)
	--v1.19
	
	--v1.22
	--add variables for home storage chests	
	if not AutoCategory.charSavedVariables.bags[AC_BAG_TYPE_HOUSEBANK] then
		AutoCategory.charSavedVariables.bags[AC_BAG_TYPE_HOUSEBANK] = AutoCategory.charSavedVariables.bags[AC_BAG_TYPE_BANK]
	end	
	
	if not AutoCategory.acctSavedVariables.bags[AC_BAG_TYPE_HOUSEBANK] then
		AutoCategory.acctSavedVariables.bags[AC_BAG_TYPE_HOUSEBANK] = AutoCategory.acctSavedVariables.bags[AC_BAG_TYPE_BANK]
	end
	
	if AutoCategory.charSavedVariables.collapses[AC_BAG_TYPE_HOUSEBANK] == nil then 
		AutoCategory.charSavedVariables.collapses[AC_BAG_TYPE_HOUSEBANK] = {}
	end
	
	if AutoCategory.acctSavedVariables.collapses[AC_BAG_TYPE_HOUSEBANK] == nil then 
		AutoCategory.acctSavedVariables.collapses[AC_BAG_TYPE_HOUSEBANK] = {}
	end
	--v1.22
end

function AutoCategory.LazyInit()
	if not AutoCategory.Inited then
		-- load our saved variables
		AutoCategory.charSavedVariables = ZO_SavedVars:New('AutoCategorySavedVars', 1.1, nil, nil)
		AutoCategory.acctSavedVariables = ZO_SavedVars:NewAccountWide('AutoCategorySavedVars', 1.1, nil, nil)
		 
		--capabilities with other add-ons
        for name, initfunc in pairs(AutoCategory.Plugins) do
            if initfunc then
                initfunc()
            end
        end

		local function isTableEmpty(table)
			if next(table) == nil then
				return true
			end
			if table.bags == nil then 
				return true
			end
			return false
		end
		if isTableEmpty(AutoCategory.charSavedVariables) then
			AutoCategory.charSavedVariables.rules = AutoCategory.defaultSettings.rules
			AutoCategory.charSavedVariables.bags = AutoCategory.defaultSettings.bags
			AutoCategory.charSavedVariables.accountWideSetting = AutoCategory.defaultSettings.accountWideSetting
		end
		if isTableEmpty(AutoCategory.acctSavedVariables) then 
			AutoCategory.acctSavedVariables.rules = AutoCategory.defaultAcctSettings.rules
			AutoCategory.acctSavedVariables.bags = AutoCategory.defaultAcctSettings.bags
			AutoCategory.acctSavedVariables.appearance = AutoCategory.defaultAcctSettings.appearance		
		end 
		
		-- version compatible
		CheckVersionCompatible()
		
		-- initialize
		AutoCategory.UpdateCurrentSavedVars()  
		AutoCategory.LoadCollapse()
		AutoCategory.AddonMenuInit() 
		
		-- hooks
		AutoCategory.HookGamepadMode()
		AutoCategory.HookKeyboardMode()
		
		--capabilities with other add-ons
		IntegrateInventoryGridView()
		IntegrateQuickMenu()
		IntegrateDoItAll()

		AutoCategory.Inited = true
	end
end

function AutoCategory.RegisterPlugin(name, initfunc)
    AutoCategory_Plugin = AutoCategory.Plugins or {}
    AutoCategory.Plugins[name] = initfunc
end

function AutoCategory.AddPredefinedRules( ruletable )
    if #ruletable == 0 then 
        return
    end
    for i=1,#ruletable do
        AutoCategory.defaultSettings.rules[#AutoCategory.defaultSettings.rules+1] = ruletable[i]
        AutoCategory.defaultAcctSettings.rules[#AutoCategory.defaultAcctSettings.rules+1] = ruletable[i]
    end
end

function AutoCategory.Initialize(event, addon)
    -- filter for just BUI addon event as EVENT_ADD_ON_LOADED is addon-blind
	if addon ~= AutoCategory.name then return end

	AutoCategory.LazyInit()
end

-- register our event handler function to be called to do initialization
EVENT_MANAGER:RegisterForEvent(AutoCategory.name, EVENT_ADD_ON_LOADED, function(...) AutoCategory.Initialize(...) end)



--== Interface ==-- 
function AutoCategory.RefreshCurrentList()
	local function RefreshList(inventoryType) 
		PLAYER_INVENTORY:UpdateList(inventoryType)
	end
	if not ZO_PlayerInventory:IsHidden() then
		RefreshList(INVENTORY_BACKPACK)
		RefreshList(INVENTORY_QUEST_ITEM)
	elseif not ZO_CraftBag:IsHidden() then
		RefreshList(INVENTORY_CRAFT_BAG)
	elseif not ZO_GuildBank:IsHidden() then
		RefreshList(INVENTORY_GUILD_BANK)
	elseif not ZO_HouseBank:IsHidden() then
		RefreshList(INVENTORY_HOUSE_BANK)
	elseif not ZO_PlayerBank:IsHidden() then
		RefreshList(INVENTORY_BANK)
	elseif not SMITHING.deconstructionPanel.control:IsHidden() then
		SMITHING.deconstructionPanel.inventory:PerformFullRefresh()
	elseif not SMITHING.improvementPanel.control:IsHidden() then
		SMITHING.improvementPanel.inventory:PerformFullRefresh()
	end
end

function AC_ItemRowHeader_OnMouseEnter(header)  
	local cateName = header.slot.dataEntry.bestItemTypeName
	local bagTypeId = header.slot.dataEntry.bagTypeId
	
	local collapsed = AutoCategory.IsCategoryCollapsed(bagTypeId, cateName) 
	local markerBG = header:GetNamedChild("CollapseMarkerBG")
	markerBG:SetHidden(false)
	if collapsed then
		markerBG:SetTexture("EsoUI/Art/Buttons/plus_over.dds")
	else
		markerBG:SetTexture("EsoUI/Art/Buttons/minus_over.dds")
	end
end

function AC_ItemRowHeader_OnMouseExit(header)  
	local markerBG = header:GetNamedChild("CollapseMarkerBG")
	markerBG:SetHidden(true)
end

function AutoCategory.IsCategoryCollapsed(bagTypeId, categoryName)
	if AutoCategory.curSavedVars.collapses[bagTypeId][categoryName] == nil then
		AutoCategory.curSavedVars.collapses[bagTypeId][categoryName] = false
	end
	local collapsed = AutoCategory.curSavedVars.collapses[bagTypeId][categoryName]
	return collapsed
end

function AutoCategory.SetCategoryCollapsed(bagTypeId, categoryName, collapsed)
	AutoCategory.curSavedVars.collapses[bagTypeId][categoryName] = collapsed 
end
 
function AC_ItemRowHeader_OnMouseClicked(header)
	local cateName = header.slot.dataEntry.bestItemTypeName
	local bagTypeId = header.slot.dataEntry.bagTypeId
	
	local collapsed = AutoCategory.IsCategoryCollapsed(bagTypeId, cateName) 
	AutoCategory.SetCategoryCollapsed(bagTypeId, cateName, not collapsed)
	AutoCategory.RefreshCurrentList()
end

function AC_ItemRowHeader_OnShowContextMenu(header)
	ClearMenu()
	local cateName = header.slot.dataEntry.bestItemTypeName
	local bagTypeId = header.slot.dataEntry.bagTypeId
	
	local collapsed = AutoCategory.IsCategoryCollapsed(bagTypeId, cateName) 
	if collapsed then
		AddMenuItem(L(SI_CONTEXT_MENU_EXPAND), function()
			AutoCategory.SetCategoryCollapsed(bagTypeId, cateName, false)
			AutoCategory.RefreshCurrentList()
		end)
	else
		AddMenuItem(L(SI_CONTEXT_MENU_COLLAPSE), function()
			AutoCategory.SetCategoryCollapsed(bagTypeId, cateName, true)
			AutoCategory.RefreshCurrentList()
		end)
	end
	AddMenuItem(L(SI_CONTEXT_MENU_EXPAND_ALL), function()
		for k, v in pairs (AutoCategory.curSavedVars.collapses[bagTypeId]) do
			AutoCategory.curSavedVars.collapses[bagTypeId][k] = false
		end
		AutoCategory.RefreshCurrentList()
	end)
	AddMenuItem(L(SI_CONTEXT_MENU_COLLAPSE_ALL), function()
		for k, v in pairs (AutoCategory.curSavedVars.collapses[bagTypeId]) do
			AutoCategory.curSavedVars.collapses[bagTypeId][k] = true
		end
		AutoCategory.RefreshCurrentList()
	end) 
	ShowMenu()
end

function AC_Binding_ToggleCategorize()
	AutoCategory.Enabled = not AutoCategory.Enabled 
	if AutoCategory.acctSavedVariables.general["SHOW_MESSAGE_WHEN_TOGGLE"] then
		if AutoCategory.Enabled then
			d(L(SI_MESSAGE_TOGGLE_AUTO_CATEGORY_ON))
		else
			d(L(SI_MESSAGE_TOGGLE_AUTO_CATEGORY_OFF))
		end
	end
	AutoCategory.RefreshCurrentList()
end 