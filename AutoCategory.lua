----------------------
--INITIATE VARIABLES--
---------------------- 

local L = GetString
local SF = LibSFUtils
local AC = AutoCategory

AC.compiledRules = {}

AC_EMPTY_TAG_NAME = L(SI_AC_DEFAULT_NAME_EMPTY_TAG)

function AutoCategory.CompileRule(rule)
  if rule == nil then return end
  
    local n = rule.name
    local compiled = rule.compiled
    if not rule.compiled then
        compiled,err = zo_loadstring("return("..rule.rule..")")
        if not compiled then
          --d("Error1: " .. err)
          rule.damaged = true 
        end
    end
    AC.compiled[n] = compiled
end

function AutoCategory.RecompileRules(ruleset)
  local compiled = {}
  if ruleset == nil then return end
  for j = 1, #ruleset do
    local n = ruleset[j].name
    if ruleset[j].compiled then
        compiled[n] = ruleset[j].compiled
    else
        compiled[n],err = zo_loadstring("return("..ruleset[j].rule..")")
        if not compiled[n] then
          d("Error1: " .. err)
          ruleset[j].damaged = true 
        end
    end
  end
  AutoCategory.compiledRules = compiled
end

function AutoCategory.UpdateCurrentSavedVars()
	AutoCategory.saved= {}
    
    -- rules, general, and appearance are always accountWide
    AutoCategory.saved.rules = AutoCategory.acctSaved.rules
    AutoCategory.RecompileRules(AutoCategory.saved.rules)
    AutoCategory.saved.general = AutoCategory.acctSaved.general
    AutoCategory.saved.appearance = AutoCategory.acctSaved.appearance
    
	if not AutoCategory.charSaved.accountWide  then
		AutoCategory.saved.bags = AutoCategory.charSaved.bags 
		AutoCategory.saved.collapses = AutoCategory.charSaved.collapses 
	else 
		AutoCategory.saved.bags = AutoCategory.acctSaved.bags  
		AutoCategory.saved.collapses = AutoCategory.acctSaved.collapses 
	end
end 

-- -----------------------------------------------------------
-- Manage collapses
function AutoCategory.LoadCollapse()
	if not AutoCategory.saved.general["SAVE_CATEGORY_COLLAPSE_STATUS"] then
		--init
		AutoCategory.ResetCollapse(AutoCategory.saved)
	end
end

function AutoCategory.ResetCollapse(vars)
    local collapses = {
		[AC_BAG_TYPE_BACKPACK] = {},
		[AC_BAG_TYPE_BANK] = {},
		[AC_BAG_TYPE_GUILDBANK] = {},
		[AC_BAG_TYPE_CRAFTBAG] = {},
		[AC_BAG_TYPE_CRAFTSTATION] = {},
		[AC_BAG_TYPE_HOUSEBANK] = {},
	}
    vars.collapses = collapses
end

function AutoCategory.IsCategoryCollapsed(bagTypeId, categoryName)
    AC.saved.collapses[bagTypeId][categoryName] = SF.nilDefault(AC.saved.collapses[bagTypeId][categoryName],false)
	return AC.saved.collapses[bagTypeId][categoryName]
end

function AutoCategory.SetCategoryCollapsed(bagTypeId, categoryName, collapsed)
	AutoCategory.saved.collapses[bagTypeId][categoryName] = collapsed 
end
-- -----------------------------------------------------------
 
function AutoCategory.ResetToDefaults()
	AutoCategory.acctSaved.rules = AutoCategory.defaultAcctSettings.rules
	AutoCategory.acctSaved.bags = AutoCategory.defaultAcctSettings.bags
	AutoCategory.acctSaved.appearance = AutoCategory.defaultAcctSettings.appearance
    
	AutoCategory.charSaved.rules = AutoCategory.defaultSettings.rules
	AutoCategory.charSaved.bags = AutoCategory.defaultSettings.bags
	AutoCategory.charSaved.accountWide = AutoCategory.defaultSettings.accountWide
    
	AutoCategory.ResetCollapse(AutoCategory.charSaved)
	AutoCategory.ResetCollapse(AutoCategory.acctSaved)
end

--[[
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

local function RebuildBagSettingIfNeeded(setting, defaultSetting, bagId)
    if not setting.bags[bagId] then
        setting.bags[bagId] = defaultSetting.bags[bagId]
    end
end

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

--]]

function AutoCategory.LazyInit()
	if not AutoCategory.Inited then
		 
		-- initialize plugins
        for name, initfunc in pairs(AutoCategory.Plugins) do
            if initfunc then
                initfunc()
            end
        end

		AutoCategory.AddonMenuInit() 
		
		-- hooks
		AutoCategory.HookGamepadMode()
		AutoCategory.HookKeyboardMode()
		
		--capabilities with other add-ons
		IntegrateInventoryGridView()
		IntegrateQuickMenu()

		AutoCategory.Inited = true
	end
end


function AutoCategory.Initialize(event, addon)
	if addon ~= AutoCategory.name then return end
    
    EVENT_MANAGER:UnregisterForEvent(AutoCategory.name, EVENT_ADD_ON_LOADED)
    
    -- load our saved variables
    AC.acctSaved, AC.charSaved = SF.getAllSavedVars("AutoCategorySavedVars", 1.1, AC.defaultAcctSettings, AC.defaultSettings)
    AutoCategory.UpdateCurrentSavedVars()
    AutoCategory.LoadCollapse()
    
    --AutoCategory.masterRules = AutoCategory_Master:New()

    AutoCategory.LazyInit()
end

-- register our event handler function to be called to do initialization
EVENT_MANAGER:RegisterForEvent(AutoCategory.name, EVENT_ADD_ON_LOADED, AutoCategory.Initialize)



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
		for k, v in pairs (AutoCategory.saved.collapses[bagTypeId]) do
			AutoCategory.saved.collapses[bagTypeId][k] = false
		end
		AutoCategory.RefreshCurrentList()
	end)
	AddMenuItem(L(SI_CONTEXT_MENU_COLLAPSE_ALL), function()
		for k, v in pairs (AutoCategory.saved.collapses[bagTypeId]) do
			AutoCategory.saved.collapses[bagTypeId][k] = true
		end
		AutoCategory.RefreshCurrentList()
	end) 
	ShowMenu()
end

function AC_Binding_ToggleCategorize()
	AutoCategory.Enabled = not AutoCategory.Enabled 
	if AutoCategory.acctSaved.general["SHOW_MESSAGE_WHEN_TOGGLE"] then
		if AutoCategory.Enabled then
			d(L(SI_MESSAGE_TOGGLE_AUTO_CATEGORY_ON))
		else
			d(L(SI_MESSAGE_TOGGLE_AUTO_CATEGORY_OFF))
		end
	end
	AutoCategory.RefreshCurrentList()
end 