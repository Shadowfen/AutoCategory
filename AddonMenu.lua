local _
local LAM = LibStub:GetLibrary("LibAddonMenu-2.0")
local LMP = LibStub:GetLibrary("LibMediaProvider-1.0")
  
local L = GetString
local SF = LibSFUtils
local AC = AutoCategory

local needReloadUI = false
--cache data for dropdown: 
local cacheTags = {}
cacheTags = {}
 
-- ----------------------------------------------
-- The cacheBags tables only change when Zenimax changes bags
local cacheBags = {}
cacheBags.showNames = { 
    [AC_BAG_TYPE_BACKPACK] = L(SI_AC_BAGTYPE_SHOWNAME_BACKPACK), 
    [AC_BAG_TYPE_BANK] = L(SI_AC_BAGTYPE_SHOWNAME_BANK),
    [AC_BAG_TYPE_GUILDBANK] = L(SI_AC_BAGTYPE_SHOWNAME_GUILDBANK),
    [AC_BAG_TYPE_CRAFTBAG] = L(SI_AC_BAGTYPE_SHOWNAME_CRAFTBAG),
    [AC_BAG_TYPE_CRAFTSTATION] = L(SI_AC_BAGTYPE_SHOWNAME_CRAFTSTATION), 
    [AC_BAG_TYPE_HOUSEBANK] = L(SI_AC_BAGTYPE_SHOWNAME_HOUSEBANK),
}
cacheBags.values = {	
    AC_BAG_TYPE_BACKPACK, 
    AC_BAG_TYPE_BANK, 
    AC_BAG_TYPE_GUILDBANK, 
    AC_BAG_TYPE_CRAFTBAG, 
    AC_BAG_TYPE_CRAFTSTATION,
    AC_BAG_TYPE_HOUSEBANK,
}
cacheBags.tooltips = {  
    L(SI_AC_BAGTYPE_TOOLTIP_BACKPACK), 
    L(SI_AC_BAGTYPE_TOOLTIP_BANK),
    L(SI_AC_BAGTYPE_TOOLTIP_GUILDBANK),
    L(SI_AC_BAGTYPE_TOOLTIP_CRAFTBAG),
    L(SI_AC_BAGTYPE_TOOLTIP_CRAFTSTATION),
    L(SI_AC_BAGTYPE_TOOLTIP_HOUSEBANK),
}
-- ----------------------------------------------

local cacheRulesByTag = {}
local cacheRulesByBag = {}

--cache for quick index
local cacheRulesByName = {}
local cacheBagEntriesByName = {}

local fontStyle	= {'none', 'outline', 'thin-outline', 'thick-outline', 'shadow', 'soft-shadow-thin', 'soft-shadow-thick'}
local fontAlignment = {
    showNames = {L(SI_AC_ALIGNMENT_LEFT), L(SI_AC_ALIGNMENT_CENTER), L(SI_AC_ALIGNMENT_RIGHT)},
    values = {0, 1, 2} 
}


--dropdown data for index
-- the keys to this table are the reference names (global) for the dropdown controls
local dropdownData = {
	["AC_DROPDOWN_IMPORTBAG_BAG"] = {indexValue = AC_BAG_TYPE_BACKPACK, choices = {}, choicesValues = {}, choicesTooltips = {}},
	["AC_DROPDOWN_EDITBAG_BAG"] = {indexValue = AC_BAG_TYPE_BACKPACK, choices = {}, choicesValues = {}, choicesTooltips = {}},
	["AC_DROPDOWN_EDITBAG_RULE"] = {indexValue = "", choices = {}, choicesValues = {}, choicesTooltips = {}},
	["AC_DROPDOWN_ADDCATEGORY_TAG"] = {indexValue = "", choices = {}, choicesValues = {}, choicesTooltips = {}},
	["AC_DROPDOWN_ADDCATEGORY_RULE"] = {indexValue = "", choices = {}, choicesValues = {}, choicesTooltips = {}},
	["AC_DROPDOWN_EDITRULE_TAG"] = {indexValue = "", choices = {}, choicesValues = {}, choicesTooltips = {}},
	["AC_DROPDOWN_EDITRULE_RULE"] = {indexValue = "", choices = {}, choicesValues = {}, choicesTooltips = {}},
}

-- setting the selected value in the specified dropdown data table
local function SelectDropDownItem(typeString, item)
	dropdownData[typeString].indexValue = item
end

-- return the item that was selected in the specified dropdown data table
local function GetDropDownSelection(typeString)
	return dropdownData[typeString].indexValue
end


--warning message
local warningDuplicatedName = {
	warningMessage = nil,
}

local function UpdateDuplicateNameWarning()
	local control = WINDOW_MANAGER:GetControlByName("AC_EDITBOX_EDITRULE_NAME")
	if control then
		control:UpdateWarning()			
	end
end

local function RefreshPanel()
	UpdateDuplicateNameWarning()

	--restore warning
	warningDuplicatedName.warningMessage = nil	
end 

-- for sorting rules by tag and name
-- returns true if the a should come before b
local function RuleDataSortingFunction(a, b)
	local result = false
	if a.tag ~= b.tag then
		result = a.tag < b.tag
	else
		--alphabetical sort, cannot have same name rules
		result = a.name < b.name
	end
	
	return result
end

-- for sorting bagged rules by priority and name
-- returns true if the a should come before b
local function BagDataSortingFunction(a, b)
	local result = false
	if a.priority ~= b.priority then
		result = a.priority > b.priority
	else
		result = a.name < b.name
	end
	return result
end 

local function ToggleSubmenu(typeString, open)
	local control = WINDOW_MANAGER:GetControlByName(typeString)
	if control then
		control.open = open
		if control.open then
			control.animation:PlayFromStart()
		else
			control.animation:PlayFromEnd()
		end	
	end
end

local function RefreshCache() 
	--d("|cFF4444RefreshCache|r")
	cacheRulesByName = {}
	cacheBagEntriesByName = {}
	cacheTags = {}
	cacheRulesByTag = {}
	cacheRulesByBag = {}

	table.sort(AutoCategory.saved.rules, RuleDataSortingFunction )
	for ndx = 1, #AutoCategory.saved.rules do
		local rule = AutoCategory.saved.rules[ndx]
		local tag = rule.tag
		if tag == "" then
			tag = AC_EMPTY_TAG_NAME
		end
		--update cache for tag grouping 
		local name = rule.name
		cacheRulesByName[name] = ndx

		--update data for showing in the dropdown menu
		if not cacheRulesByTag[tag] then
			--d("add tag rule: ".. tag)
			cacheRulesByTag[tag] = {showNames = {}, values = {}, tooltips = {}}
			table.insert(cacheTags, tag)
		end
		local tooltip = rule.description
		if rule.description == "" then
			tooltip = rule.name
		end
		--d("added rule: ".. name)
		table.insert(cacheRulesByTag[tag].showNames, name)
		table.insert(cacheRulesByTag[tag].values, name)
		table.insert(cacheRulesByTag[tag].tooltips, tooltip)
	end

	for i = 1, #AutoCategory.saved.bags do
		local bag = AutoCategory.saved.bags[i]
		table.sort(bag.rules, BagDataSortingFunction )
		--update data for showing in the dropdown menu
		local bagId = i
		if not cacheRulesByBag[bagId] then
			cacheRulesByBag[bagId] = {showNames = {}, values = {}, tooltips = {}}
		end
		if not cacheBagEntriesByName[bagId] then
			cacheBagEntriesByName[bagId] = {}
		end
		for j = 1, #bag.rules do
			local data = bag.rules[j]
			local ruleName = data.name
			cacheBagEntriesByName[bagId][ruleName] = data
			
			local priority = data.priority
            local missing = true
            local rule = nil
            if AC.GetRuleByName(ruleName) then
                rule = AC.GetRuleByName(ruleName)
                missing = false
            end
			if not rule then
				missing = true
			end
			if not missing then
				local tooltip = rule.description
				if tooltip == "" then
					tooltip = rule.name
				end 
				if data.isHidden then
					table.insert(cacheRulesByBag[bagId].showNames, string.format("|c626250%s (%d)|r", ruleName, priority))
					table.insert(cacheRulesByBag[bagId].values, ruleName)
					table.insert(cacheRulesByBag[bagId].tooltips, tooltip)
				else 
					table.insert(cacheRulesByBag[bagId].showNames, string.format("%s (%d)", ruleName, priority))
					table.insert(cacheRulesByBag[bagId].values, ruleName)
					table.insert(cacheRulesByBag[bagId].tooltips, tooltip)
				end
				
			else
                -- missing rule
				table.insert(cacheRulesByBag[bagId].showNames, string.format("|cFF4444(!)|r %s (%d)", ruleName, priority))				
				table.insert(cacheRulesByBag[bagId].values, ruleName)
				table.insert(cacheRulesByBag[bagId].tooltips, L(SI_AC_WARNING_CATEGORY_MISSING))
			end
		end
	end
	
end 

local function RefreshDropdown_EditBag()
	local dataCurrentRules_EditBag = {
        showNames = {},
        values = {},
        tooltips = {},
    }

	if GetDropDownSelection("AC_DROPDOWN_EDITBAG_BAG") == "" and #cacheBags.values > 0 then
		SelectDropDownItem("AC_DROPDOWN_EDITBAG_BAG", cacheBags.values[1])
	end

    local editRuleBagCache = cacheRulesByBag[GetDropDownSelection("AC_DROPDOWN_EDITBAG_BAG")]
	if editRuleBagCache then 
		dataCurrentRules_EditBag.showNames = editRuleBagCache.showNames
		dataCurrentRules_EditBag.values = editRuleBagCache.values
		dataCurrentRules_EditBag.tooltips = editRuleBagCache.tooltips
	end

	--update rules selection base on current dropdown data
	if GetDropDownSelection("AC_DROPDOWN_EDITBAG_RULE") == "" and #dataCurrentRules_EditBag.values > 0 then
		SelectDropDownItem("AC_DROPDOWN_EDITBAG_RULE", dataCurrentRules_EditBag.values[1])
	end
	 
	--update data indices
	dropdownData["AC_DROPDOWN_EDITBAG_RULE"].choices = dataCurrentRules_EditBag.showNames
	dropdownData["AC_DROPDOWN_EDITBAG_RULE"].choicesValues = dataCurrentRules_EditBag.values
	dropdownData["AC_DROPDOWN_EDITBAG_RULE"].choicesTooltips = dataCurrentRules_EditBag.tooltips
end

local function RefreshDropdown_AddCategory()
	local dataCurrentRules_AddCategory = {
        showNames = {},
        values = {},
        tooltips = {},
    }
    
	--update tag & bag selection first
	if GetDropDownSelection("AC_DROPDOWN_ADDCATEGORY_TAG") == "" and #cacheTags > 0 then
		SelectDropDownItem("AC_DROPDOWN_ADDCATEGORY_TAG", cacheTags[1])
	end
    
    local addRuleTagCache = cacheRulesByTag[GetDropDownSelection("AC_DROPDOWN_ADDCATEGORY_TAG")]
    local addRuleBagCache = cacheBagEntriesByName[GetDropDownSelection("AC_DROPDOWN_EDITBAG_BAG")]
	if addRuleTagCache then 
		--remove the rules already in bag
		for i = 1, #addRuleTagCache.values do
			local value = addRuleTagCache.values[i]
			if addRuleBagCache[value] == nil then
				--add the rule if not in bag
				table.insert(dataCurrentRules_AddCategory.showNames, addRuleTagCache.showNames[i])
				table.insert(dataCurrentRules_AddCategory.values, addRuleTagCache.values[i])
				table.insert(dataCurrentRules_AddCategory.tooltips, addRuleTagCache.tooltips[i])
			end
		end
	end
    
	--update rules selection base on current dropdown data
	if GetDropDownSelection("AC_DROPDOWN_ADDCATEGORY_RULE") == "" and #dataCurrentRules_AddCategory.values > 0 then
		SelectDropDownItem("AC_DROPDOWN_ADDCATEGORY_RULE", dataCurrentRules_AddCategory.values[1])
	end
	
	--update data indices
	dropdownData["AC_DROPDOWN_ADDCATEGORY_TAG"].choices = cacheTags
	dropdownData["AC_DROPDOWN_ADDCATEGORY_TAG"].choicesValues = cacheTags
	dropdownData["AC_DROPDOWN_ADDCATEGORY_TAG"].choicesTooltips = cacheTags

	dropdownData["AC_DROPDOWN_ADDCATEGORY_RULE"].choices = dataCurrentRules_AddCategory.showNames
	dropdownData["AC_DROPDOWN_ADDCATEGORY_RULE"].choicesValues = dataCurrentRules_AddCategory.values
	dropdownData["AC_DROPDOWN_ADDCATEGORY_RULE"].choicesTooltips = dataCurrentRules_AddCategory.tooltips
end

-- This refreshes the AC_DROPDOWN_IMPORTBAG_BAG from the static cacheBags table
-- This only needs to be done once because cacheBags does not change once initialized
local function RefreshDropdown_Import()
	dropdownData["AC_DROPDOWN_IMPORTBAG_BAG"].choices = cacheBags.showNames
	dropdownData["AC_DROPDOWN_IMPORTBAG_BAG"].choicesValues = cacheBags.values
	dropdownData["AC_DROPDOWN_IMPORTBAG_BAG"].choicesTooltips = cacheBags.tooltips
end

-- This refreshes the AC_DROPDOWN_EDITBAG_BAG from the static cacheBags table
-- This only needs to be done once because cacheBags does not change once initialized
local function RefreshDropdown_EditBag_Bag()
	dropdownData["AC_DROPDOWN_EDITBAG_BAG"].choices = cacheBags.showNames
	dropdownData["AC_DROPDOWN_EDITBAG_BAG"].choicesValues = cacheBags.values
	dropdownData["AC_DROPDOWN_EDITBAG_BAG"].choicesTooltips = cacheBags.tooltips
end

-- This is run multiple times
local function RefreshDropdownData()
	--d("|cFF8888RefreshDropdownData|r")
    RefreshDropdown_EditBag()
    RefreshDropdown_AddCategory()
    
	local dataCurrentRules_EditRule = {
        showNames = {},
        values = {},
        tooltips = {},
    }
    
	--update tag & bag selection first
	if GetDropDownSelection("AC_DROPDOWN_EDITRULE_TAG") == "" and #cacheTags > 0 then
		SelectDropDownItem("AC_DROPDOWN_EDITRULE_TAG", cacheTags[1])
	end

	--refresh current dropdown rules
    local editRuleTagCache = cacheRulesByTag[GetDropDownSelection("AC_DROPDOWN_EDITRULE_TAG")]
	if editRuleTagCache then 
		dataCurrentRules_EditRule.showNames = editRuleTagCache.showNames
		dataCurrentRules_EditRule.values = editRuleTagCache.values
		dataCurrentRules_EditRule.tooltips = editRuleTagCache.tooltips
	end
	
	--update rules selection base on current dropdown data
	if GetDropDownSelection("AC_DROPDOWN_EDITRULE_RULE") == "" and #dataCurrentRules_EditRule.values > 0 then
		SelectDropDownItem("AC_DROPDOWN_EDITRULE_RULE", dataCurrentRules_EditRule.values[1])
	end
	
	--update data indices
	dropdownData["AC_DROPDOWN_EDITRULE_TAG"].choices = cacheTags
	dropdownData["AC_DROPDOWN_EDITRULE_TAG"].choicesValues = cacheTags
	dropdownData["AC_DROPDOWN_EDITRULE_TAG"].choicesTooltips = cacheTags
	
	dropdownData["AC_DROPDOWN_EDITRULE_RULE"].choices = dataCurrentRules_EditRule.showNames
	dropdownData["AC_DROPDOWN_EDITRULE_RULE"].choicesValues = dataCurrentRules_EditRule.values
	dropdownData["AC_DROPDOWN_EDITRULE_RULE"].choicesTooltips = dataCurrentRules_EditRule.tooltips
end
 
 -- inform the drop down control to update itself because its values have changed
local function UpdateDropDownMenu(name)
	local dropdownCtrl = WINDOW_MANAGER:GetControlByName(name)
	local data = dropdownData[name]

	dropdownCtrl:UpdateChoices(data.choices, data.choicesValues, data.choicesTooltips)  
end

-- Remove a particular item from the specified dropdown control values
-- optionally provide a callback to execute if the dropdown control becomes empty
local function RemoveDropDownItem(typeString, removeItem, emptyCallback)
    local dataArray = dropdownData[typeString].choicesValues
	local removeIndex = -1
	local num = #dataArray
	for i = 1, num do
		if removeItem == dataArray[i] then
			removeIndex = i
			table.remove(dataArray, removeIndex)
			break
		end
	end
	
	assert(removeIndex ~= -1, "Cannot remove item " .. removeItem .. " in dropdown: " .. typeString)
	
	if num == 1 then
		--select none
		SelectDropDownItem(typeString, "")
		if emptyCallback then
			emptyCallback(typeString)
		end
	elseif removeIndex == num then
		--no next one, select previous one
		SelectDropDownItem(typeString, dataArray[removeIndex-1])
	else
		--select next one
		SelectDropDownItem(typeString, dataArray[removeIndex])
	end
	
end


local function IsRuleNameUsed(name)
	return cacheRulesByName[name] ~= nil
end

local function GetUsableRuleName(name)
	local testName = name
	local index = 1
	while cacheRulesByName[testName] ~= nil do
		testName = name .. index
		index = index + 1
	end
	return testName
end

-- ----------------------------------------------------
-- Category/Rule Entry and List functions

-- never used
local function CreateNewRule(name, tag)
	local rule = {
		tag = tag,
		name = name,
		description = "",
		rule = "false",
	}
	return rule
end

-- ----------------------------------------------------
-- Bag Rule Entry and List functions

local function CreateNewBagRuleEntry(name)
	local entry = {
		name = name,
		priority = 100,
	}
	return entry	
end

local function RemoveRuleFromBag(ruleName, bagId)
	for i = 1, #AutoCategory.saved.bags[bagId].rules do
		local rule = AutoCategory.saved.bags[bagId].rules[i]
		if rule.name == ruleName then
			table.remove(AutoCategory.saved.bags[bagId].rules, i)
			return i
		end
	end
	return -1
end

function AutoCategory.GetRuleByName(name)
	if name and cacheRulesByName and cacheRulesByName[name] then
		return AC.saved.rules[cacheRulesByName[name] ]
	end
    return nil
end

function AutoCategory.GetRuleBySelection(reference)
    local chosen = GetDropDownSelection(reference)
	if chosen and cacheRulesByName and cacheRulesByName[chosen] then
		return AC.saved.rules[cacheRulesByName[chosen] ]
	end
    return nil
end

function AutoCategory.AddonMenuInit()
	RefreshCache()  
	RefreshDropdownData() 
    RefreshDropdown_Import()
    RefreshDropdown_EditBag_Bag() 
    
	local panelData =  {
		type = "panel",
		name = AutoCategory.settingName,
		displayName = AutoCategory.settingDisplayName,
		author = AutoCategory.author,
		version = AutoCategory.version,
		registerForRefresh = true,
		registerForDefaults = true,
		resetFunc = function() 
			AutoCategory.ResetToDefaults()
            AutoCategory.UpdateCurrentSavedVars()
			RefreshCache() 
			
			SelectDropDownItem("AC_DROPDOWN_EDITBAG_BAG", AC_BAG_TYPE_BACKPACK)
			SelectDropDownItem("AC_DROPDOWN_EDITBAG_RULE", "")
			SelectDropDownItem("AC_DROPDOWN_ADDCATEGORY_TAG", "")
			SelectDropDownItem("AC_DROPDOWN_ADDCATEGORY_RULE", "")
			SelectDropDownItem("AC_DROPDOWN_EDITRULE_TAG", "")
			SelectDropDownItem("AC_DROPDOWN_EDITRULE_RULE", "")
			
			RefreshDropdownData()
			
			UpdateDropDownMenu("AC_DROPDOWN_EDITBAG_BAG")
			UpdateDropDownMenu("AC_DROPDOWN_EDITBAG_RULE")
			UpdateDropDownMenu("AC_DROPDOWN_ADDCATEGORY_TAG")
			UpdateDropDownMenu("AC_DROPDOWN_ADDCATEGORY_RULE")
			UpdateDropDownMenu("AC_DROPDOWN_EDITRULE_TAG")
			UpdateDropDownMenu("AC_DROPDOWN_EDITRULE_RULE")
		end,
	    slashCommand = "/ac",
	}
	
	local optionsTable = { 
        -- Account Wide
		{
			type = "checkbox",
			name = SI_AC_MENU_BS_CHECKBOX_ACCOUNT_WIDE_SETTING,
			tooltip = SI_AC_MENU_BS_CHECKBOX_ACCOUNT_WIDE_SETTING_TOOLTIP,
            getFunc = function() return AutoCategory.charSaved.accountWide end,
            setFunc = function(value) 
                AutoCategory.UpdateCurrentSavedVars()
                RefreshCache() 
                
                SelectDropDownItem("AC_DROPDOWN_EDITBAG_BAG", AC_BAG_TYPE_BACKPACK)
                SelectDropDownItem("AC_DROPDOWN_EDITBAG_RULE", "")
                SelectDropDownItem("AC_DROPDOWN_ADDCATEGORY_TAG", "")
                SelectDropDownItem("AC_DROPDOWN_ADDCATEGORY_RULE", "")
                SelectDropDownItem("AC_DROPDOWN_EDITRULE_TAG", "")
                SelectDropDownItem("AC_DROPDOWN_EDITRULE_RULE", "")
                
                RefreshDropdownData()
                
                UpdateDropDownMenu("AC_DROPDOWN_EDITBAG_BAG")
                UpdateDropDownMenu("AC_DROPDOWN_EDITBAG_RULE")
                UpdateDropDownMenu("AC_DROPDOWN_ADDCATEGORY_TAG")
                UpdateDropDownMenu("AC_DROPDOWN_ADDCATEGORY_RULE")
                UpdateDropDownMenu("AC_DROPDOWN_EDITRULE_TAG")
                UpdateDropDownMenu("AC_DROPDOWN_EDITRULE_RULE")
            end,
			default = true,
		},
        {
            type = "divider",
        },
        -- Bag Settings
		{
			type = "submenu",
		    name = SI_AC_MENU_SUBMENU_BAG_SETTING,
			reference = "AC_SUBMENU_BAG_SETTING",
		    controls = {
                -- Bag
				{		
					type = "dropdown",
					name = L(SI_AC_MENU_BS_DROPDOWN_BAG),
					scrollable = false,
					tooltip = L(SI_AC_MENU_BS_DROPDOWN_BAG_TOOLTIP),
                width = "half",
                reference = "AC_DROPDOWN_EDITBAG_BAG",
					choices = dropdownData["AC_DROPDOWN_EDITBAG_BAG"].choices,
					choicesValues = dropdownData["AC_DROPDOWN_EDITBAG_BAG"].choicesValues,
					choicesTooltips = dropdownData["AC_DROPDOWN_EDITBAG_BAG"].choicesTooltips,
					
					getFunc = function()  
						return GetDropDownSelection("AC_DROPDOWN_EDITBAG_BAG")
					end,
                
					setFunc = function(value) 	
						SelectDropDownItem("AC_DROPDOWN_EDITBAG_BAG", value)
                    -- change other drop down lists based on the value selected from
                    -- this one
						SelectDropDownItem("AC_DROPDOWN_EDITBAG_RULE", "")
						--reset add rule's selection, since all data will be changed.
						SelectDropDownItem("AC_DROPDOWN_ADDCATEGORY_RULE", "")
						 
						RefreshDropdownData() 
						UpdateDropDownMenu("AC_DROPDOWN_EDITBAG_RULE")
						UpdateDropDownMenu("AC_DROPDOWN_ADDCATEGORY_RULE")
					end, 
				},
                -- Hide ungrouped in bag
				{
					type = "checkbox",
                    name = SI_AC_MENU_BS_CHECKBOX_UNGROUPED_CATEGORY_HIDDEN,
                    tooltip = SI_AC_MENU_BS_CHECKBOX_UNGROUPED_CATEGORY_HIDDEN_TOOLTIP,
                    width = "half",
					getFunc = function()					
						local bag = GetDropDownSelection("AC_DROPDOWN_EDITBAG_BAG") 
						return AutoCategory.saved.bags[bag].isUngroupedHidden
					end,
					setFunc = function(value)  
						local bag = GetDropDownSelection("AC_DROPDOWN_EDITBAG_BAG") 
						AutoCategory.saved.bags[bag].isUngroupedHidden = value
					end,
                },			
                {
                    type = "divider",
                },
                -- Add Rules to bags
                -- Rule name
				{		
					type = "dropdown",
                    name = SI_AC_MENU_BS_DROPDOWN_CATEGORIES,
					scrollable = true,
					choices = dropdownData["AC_DROPDOWN_EDITBAG_RULE"].choices,
					choicesValues = dropdownData["AC_DROPDOWN_EDITBAG_RULE"].choicesValues,
					choicesTooltips = dropdownData["AC_DROPDOWN_EDITBAG_RULE"].choicesTooltips,
					
					getFunc = function() 
						return GetDropDownSelection("AC_DROPDOWN_EDITBAG_RULE") 
					end,
					setFunc = function(value) 			 
						SelectDropDownItem("AC_DROPDOWN_EDITBAG_RULE", value )
					end, 
					disabled = function() return #dropdownData["AC_DROPDOWN_EDITBAG_RULE"].choicesValues == 0 end,
					width = "half",
					reference = "AC_DROPDOWN_EDITBAG_RULE"
				},
                -- Priority
				{
					type = "slider",
                    name = SI_AC_MENU_BS_SLIDER_CATEGORY_PRIORITY,
                    tooltip = SI_AC_MENU_BS_SLIDER_CATEGORY_PRIORITY_TOOLTIP,
					min = 0,
					max = 100,
                width = "half",
					getFunc = function() 
						local bag = GetDropDownSelection("AC_DROPDOWN_EDITBAG_BAG")
						local rule = GetDropDownSelection("AC_DROPDOWN_EDITBAG_RULE")
						if cacheBagEntriesByName[bag][rule] then
							return cacheBagEntriesByName[bag][rule].priority
						end
						return 0
					end, 
					setFunc = function(value) 
						local bag = GetDropDownSelection("AC_DROPDOWN_EDITBAG_BAG")
						local rule = GetDropDownSelection("AC_DROPDOWN_EDITBAG_RULE")
						if cacheBagEntriesByName[bag][rule] then
							cacheBagEntriesByName[bag][rule].priority = value 
							RefreshCache()
							RefreshDropdownData()
							UpdateDropDownMenu("AC_DROPDOWN_EDITBAG_RULE")
						end
					end,
					disabled = function() 
						if GetDropDownSelection("AC_DROPDOWN_EDITBAG_RULE") == "" then
							return true
						end 
						if #dropdownData["AC_DROPDOWN_EDITBAG_RULE"].choicesValues == 0 then
							return true
						end
						return false
					end,
				},
                -- Hide Category
				{
					type = "checkbox",
                    name = SI_AC_MENU_BS_CHECKBOX_CATEGORY_HIDDEN,
                    tooltip = SI_AC_MENU_BS_CHECKBOX_CATEGORY_HIDDEN_TOOLTIP,
					getFunc = function()					
						local bag = GetDropDownSelection("AC_DROPDOWN_EDITBAG_BAG")
						local rule = GetDropDownSelection("AC_DROPDOWN_EDITBAG_RULE")
						if cacheBagEntriesByName[bag][rule] then
							return cacheBagEntriesByName[bag][rule].isHidden
						end
						return 0
					end,
					setFunc = function(value)  
						local bag = GetDropDownSelection("AC_DROPDOWN_EDITBAG_BAG")
						local rule = GetDropDownSelection("AC_DROPDOWN_EDITBAG_RULE")
						if cacheBagEntriesByName[bag][rule] then
							cacheBagEntriesByName[bag][rule].isHidden = value 
							RefreshCache()
							RefreshDropdownData()
							UpdateDropDownMenu("AC_DROPDOWN_EDITBAG_RULE")
						end
					end,
					disabled = function() 
						if GetDropDownSelection("AC_DROPDOWN_EDITBAG_RULE") == "" then
							return true
						end 
						if #dropdownData["AC_DROPDOWN_EDITBAG_RULE"].choicesValues == 0 then
							return true
						end
						return false
					end,
				},
                -- Edit Category Button
				{
					type = "button",
                    name = SI_AC_MENU_BS_BUTTON_EDIT,
                    tooltip = SI_AC_MENU_BS_BUTTON_EDIT_TOOLTIP,
					func = function()
						local rule = AC.GetRuleBySelection("AC_DROPDOWN_EDITBAG_RULE")
						if rule then
							SelectDropDownItem("AC_DROPDOWN_EDITRULE_TAG", rule.tag)
							SelectDropDownItem("AC_DROPDOWN_EDITRULE_RULE", rule.name) 
							RefreshDropdownData()
							UpdateDropDownMenu("AC_DROPDOWN_EDITRULE_RULE")
							ToggleSubmenu("AC_SUBMENU_BAG_SETTING", false)
							ToggleSubmenu("AC_SUBMENU_CATEGORY_SETTING", true)
						end
					end,
					disabled = function() return #dropdownData["AC_DROPDOWN_EDITBAG_RULE"].choicesValues == 0 end,
					width = "half",
				},
                -- Remove Category Button
				{
					type = "button",
                    name = SI_AC_MENU_BS_BUTTON_REMOVE,
                    tooltip = SI_AC_MENU_BS_BUTTON_REMOVE_TOOLTIP,
					func = function()  
						local bagId = GetDropDownSelection("AC_DROPDOWN_EDITBAG_BAG")
						local ruleName = GetDropDownSelection("AC_DROPDOWN_EDITBAG_RULE")
						for i = 1, #AutoCategory.saved.bags[bagId].rules do
							local bagEntry = AutoCategory.saved.bags[bagId].rules[i]
							if bagEntry.name == ruleName then
								table.remove(AutoCategory.saved.bags[bagId].rules, i)
								break
							end
						end
						RemoveDropDownItem("AC_DROPDOWN_EDITBAG_RULE", ruleName)
						
						RefreshCache()
						RefreshDropdownData()
						UpdateDropDownMenu("AC_DROPDOWN_EDITBAG_RULE")
						UpdateDropDownMenu("AC_DROPDOWN_ADDCATEGORY_RULE")
					end,
					disabled = function() return #dropdownData["AC_DROPDOWN_EDITBAG_RULE"].choicesValues == 0 end,
					width = "half",
				},
                -- Add Category to Bag Section
				{
					type = "header",
                    name = SI_AC_MENU_HEADER_ADD_CATEGORY,
					width = "full",
				},
                -- Tag Dropdown
				{		
					type = "dropdown",
                    name = SI_AC_MENU_AC_DROPDOWN_TAG,
					scrollable = true,
					choices = dropdownData["AC_DROPDOWN_ADDCATEGORY_TAG"].choices, 
					choicesValues = dropdownData["AC_DROPDOWN_ADDCATEGORY_TAG"].choicesValues,
					choicesTooltips = dropdownData["AC_DROPDOWN_ADDCATEGORY_TAG"].choicesTooltips,
					
					getFunc = function() 
						return GetDropDownSelection("AC_DROPDOWN_ADDCATEGORY_TAG") 
					end,
					setFunc = function(value) 			
						SelectDropDownItem("AC_DROPDOWN_ADDCATEGORY_TAG", value)
						--SelectDropDownItem("AC_DROPDOWN_ADDCATEGORY_RULE", "")
						RefreshDropdownData() 
						UpdateDropDownMenu("AC_DROPDOWN_ADDCATEGORY_RULE")
					end, 
					width = "half",
					disabled = function() return #dropdownData["AC_DROPDOWN_ADDCATEGORY_TAG"].choicesValues == 0 end,
					reference = "AC_DROPDOWN_ADDCATEGORY_TAG"
				},
                -- Categories unused dropdown
				{		
					type = "dropdown",
                    name = SI_AC_MENU_AC_DROPDOWN_CATEGORY,
					scrollable = true,
					choices = dropdownData["AC_DROPDOWN_ADDCATEGORY_RULE"].choices, 
					choicesValues = dropdownData["AC_DROPDOWN_ADDCATEGORY_RULE"].choicesValues,
					choicesTooltips = dropdownData["AC_DROPDOWN_ADDCATEGORY_RULE"].choicesTooltips,
					
					getFunc = function() 
						return GetDropDownSelection("AC_DROPDOWN_ADDCATEGORY_RULE") 
					end,
					setFunc = function(value) 			
						SelectDropDownItem("AC_DROPDOWN_ADDCATEGORY_RULE", value)
					end, 
					disabled = function() return #dropdownData["AC_DROPDOWN_ADDCATEGORY_RULE"].choicesValues == 0 end,
					width = "half",
					reference = "AC_DROPDOWN_ADDCATEGORY_RULE"
				},
                -- Edit Category Button
				{
					type = "button",
                    name = SI_AC_MENU_AC_BUTTON_EDIT,
                    tooltip = SI_AC_MENU_AC_BUTTON_EDIT_TOOLTIP,
					func = function()
						local rule = AC.GetRuleBySelection("AC_DROPDOWN_ADDCATEGORY_RULE")
						if rule then
							SelectDropDownItem("AC_DROPDOWN_EDITRULE_TAG", rule.tag)
							SelectDropDownItem("AC_DROPDOWN_EDITRULE_RULE", rule.name) 
							RefreshDropdownData()
							UpdateDropDownMenu("AC_DROPDOWN_EDITRULE_RULE")
							ToggleSubmenu("AC_SUBMENU_BAG_SETTING", false)
							ToggleSubmenu("AC_SUBMENU_CATEGORY_SETTING", true)
						end
					end,
					disabled = function() return #dropdownData["AC_DROPDOWN_ADDCATEGORY_RULE"].choicesValues == 0 end,
					width = "half",
				},
                -- Add to Bag Button
				{
					type = "button",
                    name = SI_AC_MENU_AC_BUTTON_ADD,
                    tooltip = SI_AC_MENU_AC_BUTTON_ADD_TOOLTIP,
					func = function()  
						local bagId = GetDropDownSelection("AC_DROPDOWN_EDITBAG_BAG")
						local ruleName = GetDropDownSelection("AC_DROPDOWN_ADDCATEGORY_RULE")
						assert(cacheBagEntriesByName[GetDropDownSelection("AC_DROPDOWN_EDITBAG_BAG")][ruleName] == nil, "Bag(" .. bagId .. ") already has the rule: ".. ruleName)
					 
						local entry = CreateNewBagRuleEntry(ruleName)
						table.insert(AutoCategory.saved.bags[bagId].rules, entry) 
						SelectDropDownItem("AC_DROPDOWN_EDITBAG_RULE", ruleName) 
						RemoveDropDownItem("AC_DROPDOWN_ADDCATEGORY_RULE", ruleName)
						 
						RefreshCache()
						RefreshDropdownData()
						UpdateDropDownMenu("AC_DROPDOWN_EDITBAG_RULE")
						UpdateDropDownMenu("AC_DROPDOWN_ADDCATEGORY_RULE")
					end,
					disabled = function() return #dropdownData["AC_DROPDOWN_ADDCATEGORY_RULE"].choicesValues == 0 end,
					width = "half",
				}, 
				{
					type = "divider",
				},
                -- Import/Export Bag Settings
				{
					type = "submenu",
                    name = SI_AC_MENU_SUBMENU_IMPORT_EXPORT,
					reference = "SI_AC_MENU_SUBMENU_IMPORT_EXPORT",
					controls = {
						{
							type = "header",
                            name = SI_AC_MENU_HEADER_UNIFY_BAG_SETTINGS,
							width = "full",
						},
						{
							type = "button",
                            name = SI_AC_MENU_UBS_BUTTON_EXPORT_TO_ALL_BAGS,
                            tooltip = SI_AC_MENU_UBS_BUTTON_EXPORT_TO_ALL_BAGS_TOOLTIP,
							func = function() 
								local selectedBag = AutoCategory.saved.bags[GetDropDownSelection("AC_DROPDOWN_EDITBAG_BAG")]
								for i = 1, 5 do
									AutoCategory.saved.bags[i] = SF.deepCopy(selectedBag)
								end
								 
								SelectDropDownItem("AC_DROPDOWN_EDITBAG_RULE", "")
								--reset add rule's selection, since all data will be changed.
								SelectDropDownItem("AC_DROPDOWN_ADDCATEGORY_RULE", "")
								 
								RefreshCache()
								RefreshDropdownData() 
								UpdateDropDownMenu("AC_DROPDOWN_EDITBAG_RULE")
								UpdateDropDownMenu("AC_DROPDOWN_ADDCATEGORY_RULE")
							end, 
							width = "full",
						},				
						
						{
							type = "header",
                            name = SI_AC_MENU_HEADER_IMPORT_BAG_SETTING,
							width = "full",
						},
						{
							type = "dropdown",
                            name = SI_AC_MENU_IBS_DROPDOWN_IMPORT_FROM_BAG,
							scrollable = false,
                            tooltip = SI_AC_MENU_IBS_DROPDOWN_IMPORT_FROM_BAG_TOOLTIP,
							choices = dropdownData["AC_DROPDOWN_IMPORTBAG_BAG"].choices,
							choicesValues = dropdownData["AC_DROPDOWN_IMPORTBAG_BAG"].choicesValues,
							choicesTooltips = dropdownData["AC_DROPDOWN_IMPORTBAG_BAG"].choicesTooltips,
							
							getFunc = function()  
								return GetDropDownSelection("AC_DROPDOWN_IMPORTBAG_BAG")
							end,
							setFunc = function(value) 	
								SelectDropDownItem("AC_DROPDOWN_IMPORTBAG_BAG", value)  
							end, 
							width = "full",
							reference = "AC_DROPDOWN_IMPORTBAG_BAG"
						},
						{
							type = "button",
                            name = SI_AC_MENU_IBS_BUTTON_IMPORT,
                            tooltip = SI_AC_MENU_IBS_BUTTON_IMPORT_TOOLTIP,
							func = function() 

								AutoCategory.saved.bags[GetDropDownSelection("AC_DROPDOWN_EDITBAG_BAG")] = SF.deepCopy( AutoCategory.saved.bags[GetDropDownSelection("AC_DROPDOWN_IMPORTBAG_BAG")] )
								 
								SelectDropDownItem("AC_DROPDOWN_EDITBAG_RULE", "")
								--reset add rule's selection, since all data will be changed.
								SelectDropDownItem("AC_DROPDOWN_ADDCATEGORY_RULE", "")
								 
								RefreshCache()
								RefreshDropdownData() 
								UpdateDropDownMenu("AC_DROPDOWN_EDITBAG_RULE")
								UpdateDropDownMenu("AC_DROPDOWN_ADDCATEGORY_RULE")
							end,
							disabled = function()
								return GetDropDownSelection("AC_DROPDOWN_EDITBAG_BAG") == GetDropDownSelection("AC_DROPDOWN_IMPORTBAG_BAG")
							end,
							width = "full",
						},	 
					},
				}, 
				{
					type = "divider",
				}, 
                -- Need Help button
				{			
					type = "button",
                    name = SI_AC_MENU_AC_BUTTON_NEED_HELP,
					func = function() RequestOpenUnsafeURL("https://github.com/rockingdice/AutoCategory/wiki/Become-veteran!") end,
					width = "full",
				},
		    },
		},
        -- Category Settings
		{
			type = "submenu",
		    name = SI_AC_MENU_SUBMENU_CATEGORY_SETTING,
			reference = "AC_SUBMENU_CATEGORY_SETTING",
		    controls = {
                -- Tags
				{		
					type = "dropdown",
					name = SI_AC_MENU_CS_DROPDOWN_TAG,
					scrollable = true,
					tooltip = SI_AC_MENU_CS_DROPDOWN_TAG_TOOLTIP,
					choices = dropdownData["AC_DROPDOWN_EDITRULE_TAG"].choices, 
					choicesValues = dropdownData["AC_DROPDOWN_EDITRULE_TAG"].choicesValues, 
					choicesTooltips = dropdownData["AC_DROPDOWN_EDITRULE_TAG"].choicesTooltips, 
					
					getFunc = function() 
						return GetDropDownSelection("AC_DROPDOWN_EDITRULE_TAG") 
					end,
					setFunc = function(value) 			
						SelectDropDownItem("AC_DROPDOWN_EDITRULE_TAG", value)
						SelectDropDownItem("AC_DROPDOWN_EDITRULE_RULE", "")
						RefreshDropdownData() 
						UpdateDropDownMenu("AC_DROPDOWN_EDITRULE_RULE")
					end, 
					width = "half",
					disabled = function() return #dropdownData["AC_DROPDOWN_EDITRULE_TAG"].choicesValues == 0 end,
					reference = "AC_DROPDOWN_EDITRULE_TAG"
				},
                -- Categories
				{		
					type = "dropdown",
					name = SI_AC_MENU_CS_DROPDOWN_CATEGORY, 
					scrollable = true,
					choices = dropdownData["AC_DROPDOWN_EDITRULE_RULE"].choices, 
					choicesValues =  dropdownData["AC_DROPDOWN_EDITRULE_RULE"].choicesValues, 
					choicesTooltips =  dropdownData["AC_DROPDOWN_EDITRULE_RULE"].choicesTooltips, 
					
					getFunc = function() 
						return GetDropDownSelection("AC_DROPDOWN_EDITRULE_RULE") 
					end,
					setFunc = function(value) 			
						SelectDropDownItem("AC_DROPDOWN_EDITRULE_RULE", value)
					end, 
					disabled = function() return #dropdownData["AC_DROPDOWN_EDITRULE_RULE"].choicesValues == 0 end,
					width = "half",
					reference = "AC_DROPDOWN_EDITRULE_RULE"
				},
                -- Edit Category Title
				{
					type = "header",
					name = SI_AC_MENU_HEADER_EDIT_CATEGORY,
					width = "full",
				},
				{			
					type = "button",
					name = SI_AC_MENU_EC_BUTTON_LEARN_RULES,
					func = function() RequestOpenUnsafeURL("https://github.com/rockingdice/AutoCategory/wiki/Rule-Index-Page") end,
					width = "full",
				},
                -- Name
				{
					type = "editbox",
					name = SI_AC_MENU_EC_EDITBOX_NAME,
					tooltip = SI_AC_MENU_EC_EDITBOX_NAME_TOOLTIP,
					getFunc = function()  
						local rule = AC.GetRuleBySelection("AC_DROPDOWN_EDITRULE_RULE")
						if rule then
							return rule.name
						end
						return "" 
					end,
					warning = function()
						return warningDuplicatedName.warningMessage
					end,
					setFunc = function(value) 
						local rule =  AC.GetRuleBySelection("AC_DROPDOWN_EDITRULE_RULE")
						local oldName = rule.name
						if oldName == value then 
							return
						end
						if value == "" then
							warningDuplicatedName.warningMessage = L(SI_AC_WARNING_CATEGORY_NAME_EMPTY)
							value = oldName
						end
						
						local isDuplicated = IsRuleNameUsed(value)
						if isDuplicated then
							warningDuplicatedName.warningMessage = string.format(L(SI_AC_WARNING_CATEGORY_NAME_DUPLICATED), value, GetUsableRuleName(value))
							value = oldName
						end
						--change editbox's value
						local control = WINDOW_MANAGER:GetControlByName("AC_EDITBOX_EDITRULE_NAME")
						control.editbox:SetText(value)

						rule.name = value  				
						SelectDropDownItem("AC_DROPDOWN_EDITRULE_RULE", value )

						--Update bags so that every entry has the same name, should be changed to new name.
						for i = 1, #AutoCategory.saved.bags do
							local bag = AutoCategory.saved.bags[i]
							local rules = bag.rules
							for j = 1, #rules do
								local rule = rules[j]
								if rule.name == oldName then
									rule.name = value
								end
							end
						end
						--Update drop downs
						RefreshCache()
						RefreshDropdownData()
						UpdateDropDownMenu("AC_DROPDOWN_EDITRULE_RULE")
						UpdateDropDownMenu("AC_DROPDOWN_EDITBAG_RULE")
						UpdateDropDownMenu("AC_DROPDOWN_ADDCATEGORY_RULE")
						AutoCategory.RecompileRules(AutoCategory.saved.rules)
					end,
					isMultiline = false,
					disabled = function() return #dropdownData["AC_DROPDOWN_EDITRULE_TAG"].choicesValues == 0 end,
					width = "half",
					reference = "AC_EDITBOX_EDITRULE_NAME",
				},
                -- Tag
				{
					type = "editbox",
					name = SI_AC_MENU_EC_EDITBOX_TAG,
					tooltip = SI_AC_MENU_EC_EDITBOX_TAG_TOOLTIP,
					isMultiline = false,
					disabled = function() return #dropdownData["AC_DROPDOWN_EDITRULE_TAG"].choicesValues == 0 end,
					width = "half",
					reference = "AC_EDITBOX_EDITRULE_TAG",
					getFunc = function()  
						local rule = AC.GetRuleBySelection("AC_DROPDOWN_EDITRULE_RULE")
						if rule then
							return rule.tag
						end
						return "" 
					end, 
				 	setFunc = function(value) 
						if value == "" then
							value = AC_EMPTY_TAG_NAME
						end
						local ruleName = GetDropDownSelection("AC_DROPDOWN_EDITRULE_RULE")
						local control = WINDOW_MANAGER:GetControlByName("AC_EDITBOX_EDITRULE_TAG")
						control.editbox:SetText(value)

						local oldGroup = AC.GetRuleByName(GetDropDownSelection("AC_DROPDOWN_EDITRULE_RULE")).tag
						AC.GetRuleByName(GetDropDownSelection("AC_DROPDOWN_EDITRULE_RULE")).tag = value
						
						
						RemoveDropDownItem("AC_DROPDOWN_EDITRULE_RULE", ruleName, function(typeString)
							--try to remove this rule from the tag, if tag needs delete, reselect it in add rule tab		
							SelectDropDownItem("AC_DROPDOWN_ADDCATEGORY_TAG", "")		
							SelectDropDownItem("AC_DROPDOWN_ADDCATEGORY_RULE", "")
						end)
						
						if GetDropDownSelection("AC_DROPDOWN_ADDCATEGORY_RULE") == ruleName then
							--modify the same rule, reselect add rule tab
							SelectDropDownItem("AC_DROPDOWN_ADDCATEGORY_TAG", value)
							SelectDropDownItem("AC_DROPDOWN_ADDCATEGORY_RULE", ruleName)
						end

						SelectDropDownItem("AC_DROPDOWN_EDITRULE_TAG", value) 
						SelectDropDownItem("AC_DROPDOWN_EDITRULE_RULE", ruleName) 
						
						RefreshCache()
						RefreshDropdownData()
						UpdateDropDownMenu("AC_DROPDOWN_ADDCATEGORY_TAG")
						UpdateDropDownMenu("AC_DROPDOWN_ADDCATEGORY_RULE")
						UpdateDropDownMenu("AC_DROPDOWN_EDITRULE_TAG")
						UpdateDropDownMenu("AC_DROPDOWN_EDITRULE_RULE")
					 
					end,
				},
                --Description 
				{
                    type = "editbox",
					name = SI_AC_MENU_EC_EDITBOX_DESCRIPTION,
					tooltip = SI_AC_MENU_EC_EDITBOX_DESCRIPTION_TOOLTIP,
					isMultiline = false,
					isExtraWide = true,
					disabled = function() return #dropdownData["AC_DROPDOWN_EDITRULE_TAG"].choicesValues == 0 end,
					width = "full",
					getFunc = function() 
						local rule = AC.GetRuleBySelection("AC_DROPDOWN_EDITRULE_RULE")
						if rule then
							return rule.description
						end
						return "" 
					end, 
					setFunc = function(value) 
						AC.GetRuleBySelection("AC_DROPDOWN_EDITRULE_RULE").description = value 
						RefreshCache()
						RefreshDropdownData()
						UpdateDropDownMenu("AC_DROPDOWN_EDITBAG_RULE")
						UpdateDropDownMenu("AC_DROPDOWN_EDITRULE_RULE")
						UpdateDropDownMenu("AC_DROPDOWN_ADDCATEGORY_RULE")
					end,
				},
                -- Rule
				{
					type = "editbox",
					name = SI_AC_MENU_EC_EDITBOX_RULE,
					tooltip = SI_AC_MENU_EC_EDITBOX_RULE_TOOLTIP,
					getFunc = function() 
						local rule = AC.GetRuleBySelection("AC_DROPDOWN_EDITRULE_RULE")
						if rule then
							return rule.rule
						end
						return "" 
					end, 
					setFunc = function(value) 
						AC.GetRuleBySelection("AC_DROPDOWN_EDITRULE_RULE").rule = value 
					    AutoCategory.RecompileRules(AutoCategory.saved.rules)
					    end,
					isMultiline = true,
					isExtraWide = true,
					disabled = function() return #dropdownData["AC_DROPDOWN_EDITRULE_TAG"].choicesValues == 0 end,
					width = "full",
				},
                {
                    type = "description",
                    text = " ", -- or string id or function returning a string
                    title = " ", -- or string id or function returning a string (optional)
                    width = "half", --or "half" (optional)
                    reference = "AutoCategoryCheckText" -- unique global reference to control (optional)
                },
				{			
					type = "button",
					name = SI_AC_MENU_EC_BUTTON_CHECK_RULE,
                    tooltip = SI_AC_MENU_EC_BUTTON_CHECK_RULE_TOOLTIP,
					func = function()
                        local control = WINDOW_MANAGER:GetControlByName("AutoCategoryCheckText")
                        control.data.text = ""
						local ruleName = GetDropDownSelection("AC_DROPDOWN_EDITRULE_RULE")
                        local func,err = zo_loadstring("return("..AC.GetRuleByName(ruleName).rule..")")
                        if not func then
                            --d("Rule Error: " .. err)
                            control.data.title = L(SI_AC_MENU_EC_BUTTON_CHECK_RESULT_ERROR)
                            control.data.text = err
                            AC.GetRuleByName(ruleName).damaged = true 
                        else
                            control.data.title = L(SI_AC_MENU_EC_BUTTON_CHECK_RESULT_GOOD)
                            control.data.text = " "
                        end
                    end,
					width = "half",
				},
				{
					type = "divider",
				},
				{
					type = "button",
					name = SI_AC_MENU_EC_BUTTON_NEW_CATEGORY,
					tooltip = SI_AC_MENU_EC_BUTTON_NEW_CATEGORY_TOOLTIP,
					width = "half",
					func = function() 
						local newName = GetUsableRuleName(L(SI_AC_DEFAULT_NAME_NEW_CATEGORY))
						local tag = GetDropDownSelection("AC_DROPDOWN_EDITRULE_TAG")
						if tag == "" then
							tag = AC_EMPTY_TAG_NAME
						end
						local newRule = CreateNewRule(newName, tag)
						table.insert(AutoCategory.saved.rules, newRule)
											
						SelectDropDownItem("AC_DROPDOWN_EDITRULE_RULE", newName)
						SelectDropDownItem("AC_DROPDOWN_EDITRULE_TAG", newRule.tag)
						
						RefreshCache()
						RefreshDropdownData()
						UpdateDropDownMenu("AC_DROPDOWN_EDITRULE_TAG")
						UpdateDropDownMenu("AC_DROPDOWN_EDITRULE_RULE")
						UpdateDropDownMenu("AC_DROPDOWN_ADDCATEGORY_RULE")
						UpdateDropDownMenu("AC_DROPDOWN_ADDCATEGORY_TAG")
						AutoCategory.RecompileRules(AutoCategory.saved.rules)
					end,
				},
				{
					type = "button",
					name = SI_AC_MENU_EC_BUTTON_DELETE_CATEGORY,
					tooltip = SI_AC_MENU_EC_BUTTON_DELETE_CATEGORY_TOOLTIP,
					width = "half",
					func = function()  
						local oldRuleName = GetDropDownSelection("AC_DROPDOWN_EDITRULE_RULE")
						local oldTagName = GetDropDownSelection("AC_DROPDOWN_EDITRULE_TAG")
						local num = #AutoCategory.saved.rules
						for i = 1, num do
							if oldRuleName == AutoCategory.saved.rules[i].name then
								table.remove(AutoCategory.saved.rules, i)
								break
							end
						end 
						
						if oldRuleName == GetDropDownSelection("AC_DROPDOWN_ADDCATEGORY_RULE") then
							--rule removed, clean selection in add rule menu if selected
							SelectDropDownItem("AC_DROPDOWN_ADDCATEGORY_RULE", "")
						end
						
						RemoveDropDownItem("AC_DROPDOWN_EDITRULE_RULE", oldRuleName, function(typeString)
							--if tag has no rules, will remove it.
							if oldTagName == GetDropDownSelection("AC_DROPDOWN_ADDCATEGORY_TAG") then
								--tag removed, clean tag selection in add rule menu if selected
								SelectDropDownItem("AC_DROPDOWN_ADDCATEGORY_TAG", "")
							end
							RemoveDropDownItem("AC_DROPDOWN_EDITRULE_TAG", oldTagName)
						end)
 
						RefreshCache()   
						RefreshDropdownData()
						UpdateDropDownMenu("AC_DROPDOWN_EDITRULE_TAG")
						UpdateDropDownMenu("AC_DROPDOWN_EDITRULE_RULE")
						UpdateDropDownMenu("AC_DROPDOWN_ADDCATEGORY_TAG")
						UpdateDropDownMenu("AC_DROPDOWN_ADDCATEGORY_RULE")
						--rule is missing
						UpdateDropDownMenu("AC_DROPDOWN_EDITBAG_RULE")
                        AutoCategory.RecompileRules(AutoCategory.saved.rules)
					end,
					disabled = function() return #dropdownData["AC_DROPDOWN_EDITRULE_RULE"].choicesValues	== 0 end,
				},
				{
					type = "button",
					name = SI_AC_MENU_EC_BUTTON_COPY_CATEGORY,
					tooltip = SI_AC_MENU_EC_BUTTON_COPY_CATEGORY_TOOLTIP,
					width = "half",
					func = function() 
						local rule = AC.GetRuleBySelection("AC_DROPDOWN_EDITRULE_RULE")
						local newName = GetUsableRuleName(rule.name)
						local tag = rule.tag
						if tag == "" then
							tag = AC_EMPTY_TAG_NAME
						end
						local newRule = CreateNewRule(newName, tag)
						newRule.description = rule.description
						newRule.rule = rule.rule
						table.insert(AutoCategory.saved.rules, newRule)
											
						SelectDropDownItem("AC_DROPDOWN_EDITRULE_RULE", newName)
						SelectDropDownItem("AC_DROPDOWN_EDITRULE_TAG", newRule.tag)
						
						RefreshCache()
						RefreshDropdownData()
						UpdateDropDownMenu("AC_DROPDOWN_EDITRULE_TAG")
						UpdateDropDownMenu("AC_DROPDOWN_EDITRULE_RULE")
						UpdateDropDownMenu("AC_DROPDOWN_ADDCATEGORY_RULE")
						UpdateDropDownMenu("AC_DROPDOWN_ADDCATEGORY_TAG")
                        AutoCategory.RecompileRules(AutoCategory.saved.rules)
					end,
				},
		    },
			
		},
        {
            type = "divider",
        },
		-- General Settings
        {
            type = "submenu",
            name = SI_AC_MENU_SUBMENU_GENERAL_SETTING,
            reference = "AC_MENU_SUBMENU_GENERAL_SETTING",
            controls = { 					
                {
                    type = "checkbox",
                    name = SI_AC_MENU_GS_CHECKBOX_SHOW_MESSAGE_WHEN_TOGGLE,
                    tooltip = L(SI_AC_MENU_GS_CHECKBOX_SHOW_MESSAGE_WHEN_TOGGLE_TOOLTIP),
                    getFunc = function() return AutoCategory.acctSaved.general["SHOW_MESSAGE_WHEN_TOGGLE"] end,
                    setFunc = function(value) AutoCategory.acctSaved.general["SHOW_MESSAGE_WHEN_TOGGLE"] = value
                        
                    end,
                },			
                {
                    type = "checkbox",
                    name = SI_AC_MENU_GS_CHECKBOX_SHOW_CATEGORY_ITEM_COUNT,
                    tooltip = SI_AC_MENU_GS_CHECKBOX_SHOW_CATEGORY_ITEM_COUNT_TOOLTIP,
                    getFunc = function() return AutoCategory.acctSaved.general["SHOW_CATEGORY_ITEM_COUNT"] end,
                    setFunc = function(value) AutoCategory.acctSaved.general["SHOW_CATEGORY_ITEM_COUNT"] = value
                        
                    end,
                },	
                {
                    type = "checkbox",
                    name = SI_AC_MENU_GS_CHECKBOX_SAVE_CATEGORY_COLLAPSE_STATUS,
                    tooltip = SI_AC_MENU_GS_CHECKBOX_SAVE_CATEGORY_COLLAPSE_STATUS_TOOLTIP,
                    getFunc = function() 
                        return AutoCategory.acctSaved.general["SAVE_CATEGORY_COLLAPSE_STATUS"] 
                    end,
                    setFunc = function(value) 
                        AutoCategory.acctSaved.general["SAVE_CATEGORY_COLLAPSE_STATUS"] = value
                    end,
                },
            }
        },
        {
            type = "divider",
        },
        -- Appearance Settings
		{
				type = "submenu",
            name = SI_AC_MENU_SUBMENU_APPEARANCE_SETTING,
				reference = "AC_SUBMENU_APPEARANCE_SETTING",
				controls = { 
					{
						type = "description",
                    text = SI_AC_MENU_AS_DESCRIPTION_REFRESH_TIP, -- or string id or function returning a string						
					},
					{
						type = "divider",
					},
					{
						type = 'dropdown',
                    name = SI_AC_MENU_EC_DROPDOWN_CATEGORY_TEXT_FONT,
						choices = LMP:List('font'),
						getFunc = function()
							return AutoCategory.acctSaved.appearance["CATEGORY_FONT_NAME"]
						end,
						setFunc = function(v)
							AutoCategory.acctSaved.appearance["CATEGORY_FONT_NAME"] = v
						end,
						scrollable = 7,
					},
					{
						type = 'dropdown',
                    name = SI_AC_MENU_EC_DROPDOWN_CATEGORY_TEXT_STYLE,
						choices = fontStyle,
						getFunc = function()
							return AutoCategory.acctSaved.appearance["CATEGORY_FONT_STYLE"]
						end,
						setFunc = function(v)
							AutoCategory.acctSaved.appearance["CATEGORY_FONT_STYLE"] = v
						end,
						scrollable = 7,
					},
					{
						type = 'dropdown',
                    name = SI_AC_MENU_EC_DROPDOWN_CATEGORY_TEXT_ALIGNMENT,
						choices = fontAlignment.showNames,
						choicesValues = fontAlignment.values,
						getFunc = function()
							return AutoCategory.acctSaved.appearance["CATEGORY_FONT_ALIGNMENT"]
						end,
						setFunc = function(v)
							AutoCategory.acctSaved.appearance["CATEGORY_FONT_ALIGNMENT"] = v
						end,
						scrollable = 7,
					},
					{
						type = 'colorpicker',
                    name = SI_AC_MENU_EC_DROPDOWN_CATEGORY_TEXT_COLOR,
						getFunc = function()
							return unpack(AutoCategory.acctSaved.appearance["CATEGORY_FONT_COLOR"])
						end,
						setFunc = function(r, g, b, a)
							AutoCategory.acctSaved.appearance["CATEGORY_FONT_COLOR"][1] = r
							AutoCategory.acctSaved.appearance["CATEGORY_FONT_COLOR"][2] = g
							AutoCategory.acctSaved.appearance["CATEGORY_FONT_COLOR"][3] = b
							AutoCategory.acctSaved.appearance["CATEGORY_FONT_COLOR"][4] = a 
						end,
						widgetRightAlign		= true,
						widgetPositionAndResize	= -15,
					},
					{
						type = 'slider',
                    name = SI_AC_MENU_EC_DROPDOWN_CATEGORY_TEXT_FONT_SIZE,
						min = 8,
						max = 32,
						getFunc = function()
							return AutoCategory.acctSaved.appearance["CATEGORY_FONT_SIZE"]
						end,
						setFunc = function(v)
							AutoCategory.acctSaved.appearance["CATEGORY_FONT_SIZE"] = v
						end,
					},
					{
						type = "editbox",
						name = SI_AC_MENU_EC_EDITBOX_CATEGORY_UNGROUPED_TITLE,
						tooltip = SI_AC_MENU_EC_EDITBOX_CATEGORY_UNGROUPED_TITLE_TOOLTIP,
                    width = "full",
						getFunc = function() 
							return AutoCategory.acctSaved.appearance["CATEGORY_OTHER_TEXT"]
						end, 
						setFunc = function(value) AutoCategory.acctSaved.appearance["CATEGORY_OTHER_TEXT"] = value end,  
					},
					{
						type = 'slider',
                    name = SI_AC_MENU_EC_SLIDER_CATEGORY_HEADER_HEIGHT,
						min = 1,
						max = 100,
                        warning = L(SI_AC_WARNING_NEED_RELOAD_UI),
                        requiresReload = true,
						getFunc = function()
							return AutoCategory.acctSaved.appearance["CATEGORY_HEADER_HEIGHT"]
						end,
						setFunc = function(v)
							AutoCategory.acctSaved.appearance["CATEGORY_HEADER_HEIGHT"] = v
							needReloadUI = true
						end,
					},
					{
						type = "button",
						name = SI_AC_MENU_EC_BUTTON_RELOAD_UI,
                    width = "full",
						disabled = function() 
							return not needReloadUI
						end,
						func = function()
							ReloadUI()
						end,
					},
				},
			}, 
	}
	LAM:RegisterAddonPanel("AC_CATEGORY_SETTINGS", panelData)
	LAM:RegisterOptionControls("AC_CATEGORY_SETTINGS", optionsTable)
	CALLBACK_MANAGER:RegisterCallback("LAM-RefreshPanel", RefreshPanel)
end