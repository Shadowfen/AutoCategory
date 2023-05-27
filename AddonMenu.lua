local LAM = LibAddonMenu2
local LMP = LibMediaProvider

local L = GetString
local SF = LibSFUtils
local AC = AutoCategory

local AC_EMPTY_TAG_NAME = L(SI_AC_DEFAULT_NAME_EMPTY_TAG)

local cache = AutoCategory.cache
local saved = AutoCategory.saved

--cache data for dropdown: 
cache.bags_svt.showNames = { 
	[AC_BAG_TYPE_BACKPACK]     = L(SI_AC_BAGTYPE_SHOWNAME_BACKPACK), 
	[AC_BAG_TYPE_BANK]         = L(SI_AC_BAGTYPE_SHOWNAME_BANK),
	[AC_BAG_TYPE_GUILDBANK]    = L(SI_AC_BAGTYPE_SHOWNAME_GUILDBANK),
	[AC_BAG_TYPE_CRAFTBAG]     = L(SI_AC_BAGTYPE_SHOWNAME_CRAFTBAG),
	[AC_BAG_TYPE_CRAFTSTATION] = L(SI_AC_BAGTYPE_SHOWNAME_CRAFTSTATION), 
	[AC_BAG_TYPE_HOUSEBANK]    = L(SI_AC_BAGTYPE_SHOWNAME_HOUSEBANK),
}
cache.bags_svt.values = {	
	AC_BAG_TYPE_BACKPACK, 
	AC_BAG_TYPE_BANK, 
	AC_BAG_TYPE_GUILDBANK, 
	AC_BAG_TYPE_CRAFTBAG, 
	AC_BAG_TYPE_CRAFTSTATION,
	AC_BAG_TYPE_HOUSEBANK,
}
cache.bags_svt.tooltips = {  
	L(SI_AC_BAGTYPE_TOOLTIP_BACKPACK), 
	L(SI_AC_BAGTYPE_TOOLTIP_BANK),
	L(SI_AC_BAGTYPE_TOOLTIP_GUILDBANK),
	L(SI_AC_BAGTYPE_TOOLTIP_CRAFTBAG),
	L(SI_AC_BAGTYPE_TOOLTIP_CRAFTSTATION),
	L(SI_AC_BAGTYPE_TOOLTIP_HOUSEBANK),
}

local function newCVT(ndx)
	local tbl = {
		indexValue = "", 
		choices = {}, choicesValues = {}, choicesTooltips = {}
	}
	if ndx == nil then return tbl end
	indexValue = ndx
	return tbl
end

local function newSVT()
	return {showNames = {}, values = {}, tooltips = {}, }
end

local fieldData = {
	editBag_cvt =     newCVT(AC_BAG_TYPE_BACKPACK),
	editBagRule = newCVT(),
	addCatTag =   newCVT(),
	addCatRule =  newCVT(),
	editRuleTag = newCVT(),
	editRuleCat = newCVT(),
	importBag =   newCVT(AC_BAG_TYPE_BACKPACK),
    currentRule = { 
		name = "", 
		description = "", 
		rule = "false", 
		tag = "", },
}

-- It is the responsiblity of the caller to pass in a non-duplicated entry
local function AddChoice( dataArray, choice, value, tooltip )
    -- value is only optional if we don't have a table to put it into
    if value == nil and dataArray.choicesValues then
		return  -- bad value
    end
    -- tooltip is only optional if we don't have a table to put it into
    if tooltip == nil and dataArray.choicesTooltips then
		return  -- bad tooltip
    end
    -- choice is mandatory
    if not choice then return end

    table.insert(dataArray.choices, choice)
    if dataArray.choicesValues then
        table.insert(dataArray.choicesValues, value)
    end
    if dataArray.choicesTooltips then
        table.insert(dataArray.choicesTooltips, tooltip)
    end
end

local dropdownFontStyle	= {
	'none', 'outline', 'thin-outline', 'thick-outline', 'shadow', 'soft-shadow-thin', 'soft-shadow-thick'
}
local dropdownFontAlignment = {}
dropdownFontAlignment.showNames = {
	L(SI_AC_ALIGNMENT_LEFT), 
	L(SI_AC_ALIGNMENT_CENTER), 
	L(SI_AC_ALIGNMENT_RIGHT)
}
dropdownFontAlignment.values = {0, 1, 2} 

local ruleCheckStatus = {}

function ruleCheckStatus.getTitle()
    if ruleCheckStatus.err == nil then
        if ruleCheckStatus.good == nil then
            return ""
			
        else
            return L(SI_AC_MENU_EC_BUTTON_CHECK_RESULT_GOOD)
        end
		
    else
        if not fieldData.currentRule.damaged then
            return L(SI_AC_MENU_EC_BUTTON_CHECK_RESULT_WARNING)
        end
        return L(SI_AC_MENU_EC_BUTTON_CHECK_RESULT_ERROR)
    end
end

function ruleCheckStatus.getText()
    if ruleCheckStatus.err == nil then
        return ""
		
    else
        return ruleCheckStatus.err
    end
end

local function checkKeywords(str)
   local result = {}
    for w in string.gmatch(str, "[a-zA-Z0-9_/]+") do
        local found = false
        if AC.Environment[w] then
            found = true
			
        else
            for i=1, #AC.dictionary do
                if AC.dictionary[i][w] then
                    found = true
                    break;
                end
            end
        end
        if found == false then
            table.insert(result, w)
        end
    end
   return result
end

local function checkCurrentRule()
    ruleCheckStatus.err = nil
    ruleCheckStatus.good = nil
    if fieldData.currentRule == nil then
        return
    end
    
    if fieldData.currentRule.rule == nil or fieldData.currentRule.rule == "" then
		fieldData.currentRule.err = "Rule definition cannot be empty"
		ruleCheckStatus.err = fieldData.currentRule.err
		fieldData.currentRule.damaged = true 
        return
    end
    
    local func, err = zo_loadstring("return("..fieldData.currentRule.rule..")")
    if err then
		-- logger.error("FAILED rule compile - "..err)
        ruleCheckStatus.err = err
        fieldData.currentRule.damaged = true 
		fieldData.currentRule.err = err
		
    else
        local errt = checkKeywords(fieldData.currentRule.rule)
        if #errt == 0 then
            ruleCheckStatus.good = true
            fieldData.currentRule.damaged = nil
			
        else
            ruleCheckStatus.err = table.concat(errt,", ")
            fieldData.currentRule.damaged = nil 
        end
    end
end

--warning message
local warningDuplicatedName = {
	warningMessage = nil,
}

local function UpdateDuplicateNameWarning()
	local control = WINDOW_MANAGER:GetControlByName("AC_EDITBOX_EDITRULE_NAME", "")
	if control then
		control:UpdateWarning()			
	end
end

local function RefreshPanel()
	UpdateDuplicateNameWarning()

	--restore warning
	warningDuplicatedName.warningMessage = nil

end 

local doneOnce = false
function AutoCategory.LengthenRuleBox()
	local lines = 10
	if doneOnce then return true end
	-- change lines
	local MIN_HEIGHT = 24
	local control = WINDOW_MANAGER:GetControlByName("AC_EDITBOX_EDITRULE_RULE", "")
	if control == nil or control.container == nil then return false end
	
	doneOnce = true
    local container = control.container
	local editbox = control.editbox
	
	container:SetHeight(MIN_HEIGHT * lines)
    control:SetHeight((MIN_HEIGHT * lines) + control.label:GetHeight())

	return true
end

local function ToggleSubmenu(typeString, open)
	local control = WINDOW_MANAGER:GetControlByName(typeString, "")
	if control then
		control.open = open
		if control.open then
			control.animation:PlayFromStart()
			
		else
			control.animation:PlayFromEnd()
		end	
	end
end

local function UpdateChoices(controlname, data)
	local dropdownCtrl = WINDOW_MANAGER:GetControlByName(controlname)
    if dropdownCtrl == nil then
        return
    end
	dropdownCtrl:UpdateChoices(data.choices, data.choicesValues, 
		data.choicesTooltips)  
end

local function RefreshDropdownData()
	 
	--update tag & bag selection first
	if fieldData.addCatTag.indexValue == "" and #cache.tags > 0 then
		fieldData.addCatTag.indexValue = cache.tags[1]
	end
    
	if fieldData.editRuleTag.indexValue == "" and #cache.tags > 0 then
		fieldData.editRuleTag.indexValue = cache.tags[1]
	end

	if fieldData.editBag_cvt.indexValue == "" and #cache.bags_svt.values > 0 then
		fieldData.editBag_cvt.indexValue = cache.bags_svt.values[1]
	end

	--refresh current dropdown rules
	local dataCurrentRules_EditRule = newSVT()
    local ltag = fieldData.editRuleTag.indexValue
	if ltag and cache.rulesByTag_svt[ltag] then 
		dataCurrentRules_EditRule.showNames = cache.rulesByTag_svt[ltag].showNames
		dataCurrentRules_EditRule.values    = cache.rulesByTag_svt[ltag].values
		dataCurrentRules_EditRule.tooltips  = cache.rulesByTag_svt[ltag].tooltips
	end	
	fieldData.editRuleCat.choices         = SF.safeTable(dataCurrentRules_EditRule.showNames)
	fieldData.editRuleCat.choicesValues   = SF.safeTable(dataCurrentRules_EditRule.values)
	fieldData.editRuleCat.choicesTooltips = SF.safeTable(dataCurrentRules_EditRule.tooltips)
	if fieldData.editRuleCat.indexValue == "" and #dataCurrentRules_EditRule.values > 0 then
		fieldData.editRuleCat.indexValue = dataCurrentRules_EditRule.values[1]
	end
    UpdateChoices("AC_DROPDOWN_EDITRULE_RULE", fieldData.editRuleCat)

	local dataCurrentRules_EditBag = newSVT()
    local lbag = fieldData.editBag_cvt.indexValue
	if lbag and cache.entriesByBag[lbag] then 
		dataCurrentRules_EditBag.showNames = cache.entriesByBag[lbag].showNames
		dataCurrentRules_EditBag.values    = cache.entriesByBag[lbag].values
		dataCurrentRules_EditBag.tooltips  = cache.entriesByBag[lbag].tooltips
	end
	fieldData.editBagRule.choices         = dataCurrentRules_EditBag.showNames
	fieldData.editBagRule.choicesValues   = dataCurrentRules_EditBag.values
	fieldData.editBagRule.choicesTooltips = dataCurrentRules_EditBag.tooltips
	if fieldData.editBagRule.indexValue == "" and #dataCurrentRules_EditBag.values > 0 then
		fieldData.editBagRule.indexValue = dataCurrentRules_EditBag.values[1]
	end
    UpdateChoices("AC_DROPDOWN_EDITBAG_RULE", fieldData.editBagRule)

	local dataCurrentRules_AddCategory = {choices = {}, choicesValues = {}, choicesTooltips = {}, }
    local latag = fieldData.addCatTag.indexValue
	if latag and cache.rulesByTag_svt[latag] then 
		--remove the rules alreadly in bag
		for i = 1, #cache.rulesByTag_svt[latag].values do
			local value = cache.rulesByTag_svt[latag].values[i]
			if lbag and cache.entriesByName[lbag][value] == nil then
				--add the rule if not in bag
				table.insert(dataCurrentRules_AddCategory.choices, cache.rulesByTag_svt[latag].showNames[i])
				table.insert(dataCurrentRules_AddCategory.choicesValues, cache.rulesByTag_svt[latag].values[i])
				table.insert(dataCurrentRules_AddCategory.choicesTooltips, cache.rulesByTag_svt[latag].tooltips[i])
			end
		end
	end
	fieldData.addCatRule.choices         = dataCurrentRules_AddCategory.choices
	fieldData.addCatRule.choicesValues   = dataCurrentRules_AddCategory.choicesValues
	fieldData.addCatRule.choicesTooltips = dataCurrentRules_AddCategory.choicesTooltips
	if fieldData.addCatRule.indexValue == "" 
			and #dataCurrentRules_AddCategory.choicesValues > 0 then
		fieldData.addCatRule.indexValue = dataCurrentRules_AddCategory.choicesValues[1]
	end
    UpdateChoices("AC_DROPDOWN_ADDCATEGORY_RULE", fieldData.addCatRule)
end
 
local function RemoveDropDownItem(dataArray, removeItem, emptyCallback)
	local removeIndex = -1
    if not dataArray or not dataArray.choices then return end
	local num = #dataArray.choices
	for i = 1, num do
		if removeItem == dataArray.choices[i] then
			removeIndex = i
			table.remove(dataArray.choices, removeIndex)
			break
		end
	end
	
    if removeIndex <= 0 then return end
	
	if num == 1 then
		--select none
		dataArray.indexValue = ""
		if emptyCallback then
			emptyCallback(dataArray)
		end
		
	elseif removeIndex == num then
		--no next one, select previous one
		dataArray.indexValue = dataArray.choicesValues[num-1]
		
	else
		--select next one
		dataArray.indexValue = dataArray.choicesValues[removeIndex]
	end
	
end


local function IsRuleNameUsed(name)
	return cache.rulesByName[name] ~= nil
end

local function GetUsableRuleName(name)
	local testName = name
	local index = 1
	while cache.rulesByName[testName] ~= nil do
		testName = name .. index
		index = index + 1
	end
	return testName
end

local function CreateNewRule(name, tag)
	local rule = {
		name = name,
		description = "",
		rule = "true",
		tag = tag,
	}
	return rule
end

local function CreateNewBagRuleEntry(name)
	local entry = {
		name = name,
		priority = 1000,
	}
	return entry	
end

-- -------------------------------------------------
function AutoCategory.AddonMenuInit()
    AC.cacheInitialize()
    
    -- initialize tables
	fieldData.editBag_cvt.choices = cache.bags_svt.showNames
	fieldData.editBag_cvt.choicesValues = cache.bags_svt.values
    fieldData.editBag_cvt.choicesTooltips = cache.bags_svt.tooltips
	
	fieldData.addCatTag.choices = cache.tags
	fieldData.addCatTag.choicesValues = cache.tags
	fieldData.addCatTag.choicesTooltips = cache.tags
    
    -- this will get populated by RefreshDropdownData()
    fieldData.addCatRule.choices = {}
    fieldData.addCatRule.choicesValues = {}
    fieldData.addCatRule.choicesTooltips = {}
	
	fieldData.editRuleTag.choices = cache.tags
	fieldData.editRuleTag.choicesValues = cache.tags
	fieldData.editRuleTag.choicesTooltips = cache.tags
	
	fieldData.importBag.choices = cache.bags_svt.showNames
	fieldData.importBag.choicesValues = cache.bags_svt.values
	fieldData.importBag.choicesTooltips = cache.bags_svt.tooltips
	 
	RefreshDropdownData() 
 
	local panelData =  {
		type = "panel",
		name = AutoCategory.settingName,
		displayName = AutoCategory.settingDisplayName,
		author = AutoCategory.author,
		version = AutoCategory.version,
        slashCommand = "/ac",
		registerForRefresh = true,
		registerForDefaults = true,
		resetFunc = function() 
			AutoCategory.ResetToDefaults()
			AutoCategory.UpdateCurrentSavedVars()
			AutoCategory.cacheInitialize() 
			
            fieldData.editBag_cvt.indexValue = AC_BAG_TYPE_BACKPACK
			fieldData.editBagRule.indexValue = ""
			fieldData.addCatTag.indexValue = ""
			fieldData.addCatRule.indexValue = ""
			fieldData.editRuleTag.indexValue = ""
			fieldData.editRuleCat.indexValue = ""
			
			RefreshDropdownData()
		end,
	}
	
	local optionsTable = { 
        -- Account Wide
        {
            type = "checkbox",
            name = SI_AC_MENU_BS_CHECKBOX_ACCOUNT_WIDE_SETTING,
            tooltip = SI_AC_MENU_BS_CHECKBOX_ACCOUNT_WIDE_SETTING_TOOLTIP,
            getFunc = function() 
                return AutoCategory.charSaved.accountWide
            end,
            setFunc = function(value) 
                AutoCategory.charSaved.accountWide = value
                AutoCategory.UpdateCurrentSavedVars()
                
                fieldData.editBag_cvt.indexValue = AC_BAG_TYPE_BACKPACK
                fieldData.editBagRule.indexValue = ""
                fieldData.addCatTag.indexValue = ""
                fieldData.addCatRule.indexValue = ""
                fieldData.editRuleTag.indexValue = ""
                fieldData.editRuleCat.indexValue = ""
                ruleCheckStatus.err = nil
                ruleCheckStatus.good = nil
                
                RefreshDropdownData()
                
                UpdateChoices("AC_DROPDOWN_EDITBAG_BAG",     fieldData.editBag_cvt)
                UpdateChoices("AC_DROPDOWN_ADDCATEGORY_TAG", fieldData.addCatTag)
                UpdateChoices("AC_DROPDOWN_EDITRULE_TAG",    fieldData.editRuleTag)
            end,
        },			
        {
            type = "divider",
        },
        -- Bag Settings
		{
			type = "submenu",
		    name = SI_AC_MENU_SUBMENU_BAG_SETTING, -- or string id or function returning a string
			reference = "AC_SUBMENU_BAG_SETTING",
		    controls = {
                -- Bag     - AC_DROPDOWN_EDITBAG_BAG
				{		
					type = "dropdown",
					name = SI_AC_MENU_BS_DROPDOWN_BAG,
					scrollable = false,
					tooltip = L(SI_AC_MENU_BS_DROPDOWN_BAG_TOOLTIP),
					choices         = fieldData.editBag_cvt.choices,
					choicesValues   = fieldData.editBag_cvt.choicesValues,
					choicesTooltips = fieldData.editBag_cvt.choicesTooltips,
					
					getFunc = function()  
						return fieldData.editBag_cvt.indexValue
					end,
					setFunc = function(value)
                        fieldData.editBag_cvt.indexValue = value
						fieldData.editBagRule.indexValue = ""
						--reset add rule's selection, since all data will be changed.
						fieldData.addCatRule.indexValue = ""
						 
						RefreshDropdownData() 
					end, 
                    default = AC_BAG_TYPE_BACKPACK,
					width = "half",
					reference = "AC_DROPDOWN_EDITBAG_BAG",
				},
                -- Hide ungrouped in bag
				{
					type = "checkbox",
					name = SI_AC_MENU_BS_CHECKBOX_UNGROUPED_CATEGORY_HIDDEN,
					tooltip = SI_AC_MENU_BS_CHECKBOX_UNGROUPED_CATEGORY_HIDDEN_TOOLTIP,
					getFunc = function()					
						local bag = fieldData.editBag_cvt.indexValue
						return saved.bags[bag].isUngroupedHidden
					end,
					setFunc = function(value)  
						local bag = fieldData.editBag_cvt.indexValue
						saved.bags[bag].isUngroupedHidden = value
					end,
					width = "half",
				},			
                {
                    type = "divider",
                },
                -- Rule name   - AC_DROPDOWN_EDITBAG_RULE
				{		
					type = "dropdown",
					name = SI_AC_MENU_BS_DROPDOWN_CATEGORIES,
					scrollable = true,
					choices         = fieldData.editBagRule.choices,
					choicesValues   = fieldData.editBagRule.choicesValues,
					choicesTooltips = fieldData.editBagRule.choicesTooltips,
					
					getFunc = function() 
						return fieldData.editBagRule.indexValue
					end,
					setFunc = function(value) 			 
						fieldData.editBagRule.indexValue = value
					end, 
					disabled = function() return #fieldData.editBagRule.choices == 0 end,
                    --default = "",
					width = "half",
					reference = "AC_DROPDOWN_EDITBAG_RULE",
				},
                -- Priority
				{
					type = "slider",
					name = SI_AC_MENU_BS_SLIDER_CATEGORY_PRIORITY,
					tooltip = SI_AC_MENU_BS_SLIDER_CATEGORY_PRIORITY_TOOLTIP,
					min = 0,
					max = 1000,
					getFunc = function() 
						local bag = fieldData.editBag_cvt.indexValue
						local rule = fieldData.editBagRule.indexValue
						if cache.entriesByName[bag][rule] then
							return cache.entriesByName[bag][rule].priority
						end
						return 0
					end, 
					setFunc = function(value) 
						local bag = fieldData.editBag_cvt.indexValue
						local rule = fieldData.editBagRule.indexValue
						if cache.entriesByName[bag][rule] then
							cache.entriesByName[bag][rule].priority = value 
							AutoCategory.cacheInitialize()
							RefreshDropdownData()
						end
					end,
					disabled = function() 
						if fieldData.editBagRule.indexValue == "" then
							return true
						end 
						if #fieldData.editBagRule.choices == 0 then
							return true
						end
						return false
					end,
                    default = 0,
					width = "half",
				},
                -- Hide Category
				{
					type = "checkbox",
					name = SI_AC_MENU_BS_CHECKBOX_CATEGORY_HIDDEN,
					tooltip = SI_AC_MENU_BS_CHECKBOX_CATEGORY_HIDDEN_TOOLTIP,
					getFunc = function()					
						local bag = fieldData.editBag_cvt.indexValue
						local rule = fieldData.editBagRule.indexValue
						if cache.entriesByName[bag][rule] then
							return cache.entriesByName[bag][rule].isHidden
						end
						return 0
					end,
					setFunc = function(value)  
						local bag = fieldData.editBag_cvt.indexValue
						local rule = fieldData.editBagRule.indexValue
						if cache.entriesByName[bag][rule] then
							cache.entriesByName[bag][rule].isHidden = value 
							AutoCategory.cacheInitialize()
							RefreshDropdownData()
						end
					end,
					disabled = function() 
						if fieldData.editBagRule.indexValue == "" then
							return true
						end 
						if #fieldData.editBagRule.choices == 0 then
							return true
						end
						return false
					end,
                    default = false,
				},
                -- Edit Category Button
				{
					type = "button",
					name = SI_AC_MENU_BS_BUTTON_EDIT,
					tooltip = SI_AC_MENU_BS_BUTTON_EDIT_TOOLTIP,
					func = function()
						local ruleName = fieldData.editBagRule.indexValue
						local rule = AC.GetRuleByName(ruleName)
						if rule then
							fieldData.editRuleTag.indexValue = rule.tag
							fieldData.editRuleCat.indexValue = rule.name
                            fieldData.currentRule = rule
                            checkCurrentRule()
							RefreshDropdownData()
							ToggleSubmenu("AC_SUBMENU_BAG_SETTING", false)
							ToggleSubmenu("AC_SUBMENU_CATEGORY_SETTING", true)
						end
					end,
					disabled = function() return #fieldData.editBagRule.choices == 0 end,
					width = "half",
				},
                -- Remove Category from Bag Button
				{
					type = "button",
					name = SI_AC_MENU_BS_BUTTON_REMOVE,
					tooltip = SI_AC_MENU_BS_BUTTON_REMOVE_TOOLTIP,
					func = function()  
						local bagId = fieldData.editBag_cvt.indexValue
						local ruleName = fieldData.editBagRule.indexValue
						for i = 1, #saved.bags[bagId].rules do
							local bagEntry = saved.bags[bagId].rules[i]
							if bagEntry.name == ruleName then
								table.remove(saved.bags[bagId].rules, i)
								break
							end
						end
						RemoveDropDownItem("AC_DROPDOWN_EDITBAG_RULE", fieldData.editBagRule.choicesValues, ruleName)
						if fieldData.editBagRule.indexValue == "" and #fieldData.editBagRule.choices > 0 then
                            fieldData.editBagRule.indexValue = fieldData.editBagRule.choicesValues[1]
                        end
						AutoCategory.cacheInitialize()
						RefreshDropdownData()
						if #fieldData.editBagRule.choices > 0 then
                            fieldData.editBagRule.indexValue = fieldData.editBagRule.choicesValues[1]
                        end
					end,
					disabled = function() return #fieldData.editBagRule.choices == 0 end,
					width = "half",
				},
                -- Add Category to Bag Section
				{
					type = "header",
					name = SI_AC_MENU_HEADER_ADD_CATEGORY,
					width = "full",
				},
                -- Tag Dropdown - AC_DROPDOWN_ADDCATEGORY_TAG
				{		
					type = "dropdown",
					name = SI_AC_MENU_AC_DROPDOWN_TAG,
					scrollable = true,
					choices         = fieldData.addCatTag.choices, 
					choicesValues   = fieldData.addCatTag.choicesValues,
					choicesTooltips = fieldData.addCatTag.choicesTooltips,
                    sort = "name-up",
					
					getFunc = function() 
						return fieldData.addCatTag.indexValue
					end,
					setFunc = function(value)
                        local oldvalue = fieldData.addCatTag.indexValue
                        if oldvalue == value then return end
                        
						fieldData.addCatTag.indexValue = value
						fieldData.addCatRule.indexValue = ""
						RefreshDropdownData() 
					end, 
					width = "half",
					disabled = function() return #fieldData.addCatTag.choicesValues == 0 end,
					reference = "AC_DROPDOWN_ADDCATEGORY_TAG",
				},
                -- Categories unused dropdown - AC_DROPDOWN_ADDCATEGORY_RULE
				{		
					type = "dropdown",
					name = SI_AC_MENU_AC_DROPDOWN_CATEGORY,
					scrollable = true,
					choices = fieldData.addCatRule.choices, 
					choicesValues = fieldData.addCatRule.choicesValues,
					choicesTooltips = fieldData.addCatRule.choicesTooltips,
                    sort = "name-up",
					
					getFunc = function() 
						return fieldData.addCatRule.indexValue 
					end,
					setFunc = function(value) 			
						fieldData.addCatRule.indexValue = value
					end, 
					disabled = function() return #fieldData.addCatRule.choices == 0 end,
					width = "half",
					reference = "AC_DROPDOWN_ADDCATEGORY_RULE",
				},
                -- Edit Rule Category Button
				{
					type = "button",
					name = SI_AC_MENU_AC_BUTTON_EDIT,
					tooltip = SI_AC_MENU_AC_BUTTON_EDIT_TOOLTIP,
					func = function()
						local ruleName = fieldData.addCatRule.indexValue
						local rule = AC.GetRuleByName(ruleName)
						if rule then
							fieldData.editRuleTag.indexValue = rule.tag
							fieldData.editRuleCat.indexValue = rule.name
                            fieldData.currentRule = rule
                            checkCurrentRule()
							RefreshDropdownData()
							ToggleSubmenu("AC_SUBMENU_BAG_SETTING", false)
							ToggleSubmenu("AC_SUBMENU_CATEGORY_SETTING", true)
						end
					end,
					disabled = function() return #fieldData.addCatRule.choicesValues == 0 end,
					width = "half",
				},
                -- Add to Bag Button
				{
					type = "button",
					name = SI_AC_MENU_AC_BUTTON_ADD,
					tooltip = SI_AC_MENU_AC_BUTTON_ADD_TOOLTIP,
					func = function()  
						local bagId = fieldData.editBag_cvt.indexValue
						local ruleName = fieldData.addCatRule.indexValue
						assert(cache.entriesByName[bagId][ruleName] == nil, "Bag(" .. bagId .. ") already has the rule: ".. ruleName)
					 
                        if cache.entriesByName[bagId][ruleName] == nil then
							local entry = CreateNewBagRuleEntry(ruleName)
							table.insert(saved.bags[bagId].rules, entry) 
							fieldData.editBagRule.indexValue = ruleName
							RemoveDropDownItem("AC_DROPDOWN_ADDCATEGORY_RULE", fieldData.addCatRule.choicesValues, ruleName)
							 
							AutoCategory.cacheInitialize()
							RefreshDropdownData()
                        end
                        
                        fieldData.editBagRule.indexValue = ruleName
						RemoveDropDownItem("AC_DROPDOWN_ADDCATEGORY_RULE",fieldData.addCatRule.choicesValues, ruleName)
						if #fieldData.addCatRule.choices > 0 then
                            fieldData.addCatRule.indexValue = 	
								fieldData.addCatRule.choicesValues[1]
                        end
					end,
					disabled = function() return #fieldData.addCatRule.choices == 0 end,
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
                        -- Export To All Button
						{
							type = "button",
							name = SI_AC_MENU_UBS_BUTTON_EXPORT_TO_ALL_BAGS,
							tooltip = SI_AC_MENU_UBS_BUTTON_EXPORT_TO_ALL_BAGS_TOOLTIP,
							func = function() 
								local selectedBag = saved.bags[fieldData.editBag_cvt.indexValue]
								for i = 1, 5 do
									saved.bags[i] = SF.deepCopy(selectedBag)
								end
                                
                                fieldData.editBagRule.indexValue = ""
								--reset add rule's selection, since all data will be changed.
								fieldData.addCatRule.indexValue = ""
								 
								--RefreshCache()
								RefreshDropdownData() 
							end, 
							width = "full",
						},				
						
						{
							type = "header",
							name = SI_AC_MENU_HEADER_IMPORT_BAG_SETTING,
							width = "full",
						},
                        --  - AC_DROPDOWN_IMPORTBAG_BAG
						{
							type = "dropdown",
							name = SI_AC_MENU_IBS_DROPDOWN_IMPORT_FROM_BAG,
							scrollable = false,
							tooltip = SI_AC_MENU_IBS_DROPDOWN_IMPORT_FROM_BAG_TOOLTIP,
							choices = fieldData.importBag.choices,
							choicesValues = fieldData.importBag.choicesValues,
							choicesTooltips = fieldData.importBag.choicesTooltips,
							
							getFunc = function()  
								return fieldData.importBag.indexValue
							end,
							setFunc = function(value) 	
								fieldData.importBag.indexValue = value
							end, 
							width = "half",
							reference = "AC_DROPDOWN_IMPORTBAG_BAG",
						},
                        -- Import Button
						{
							type = "button",
							name = SI_AC_MENU_IBS_BUTTON_IMPORT,
							tooltip = SI_AC_MENU_IBS_BUTTON_IMPORT_TOOLTIP,
							func = function() 

								saved.bags[fieldData.editBag_cvt.indexValue] = SF.deepCopy( saved.bags[fieldData.importBag.indexValue] )
                                fieldData.editBagRule.indexValue = ""
								--reset add rule's selection, since all data will be changed.
								fieldData.addCatRule.indexValue = ""
								 
								AutoCategory.cacheInitialize()
								RefreshDropdownData() 
							end,
							disabled = function()
								return fieldData.editBag_cvt.indexValue == fieldData.importBag.indexValue
							end,
							width = "half",
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
					func = function() RequestOpenUnsafeURL("https://github.com/Shadowfen/AutoCategory/wiki/Tutorial") end,
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
                -- Tags - AC_DROPDOWN_EDITRULE_TAG
				{		
					type = "dropdown",
					name = SI_AC_MENU_CS_DROPDOWN_TAG,
					scrollable = true,
					tooltip = SI_AC_MENU_CS_DROPDOWN_TAG_TOOLTIP,
					choices = fieldData.editRuleTag.choices, 
					choicesValues = fieldData.editRuleTag.choicesValues, 
					choicesTooltips = fieldData.editRuleTag.choicesTooltips, 
                    sort = "name-up",
					
					getFunc = function() 
						return fieldData.editRuleTag.indexValue
					end,
					setFunc = function(value) 			
                        fieldData.editRuleTag.indexValue = value
                        fieldData.editRuleCat.indexValue = ""
                        fieldData.currentRule = nil
                        RefreshDropdownData() 
                        UpdateChoices("AC_DROPDOWN_EDITRULE_RULE", fieldData.editRuleCat)
					end, 
					width = "half",
					disabled = function() return #fieldData.editRuleTag.choices == 0 end,
					reference = "AC_DROPDOWN_EDITRULE_TAG",
				},
                -- Categories - AC_DROPDOWN_EDITRULE_RULE
				{		
					type = "dropdown",
					name = SI_AC_MENU_CS_DROPDOWN_CATEGORY, 
					scrollable = true,
					choices = fieldData.editRuleCat.choices, 
					choicesValues =  fieldData.editRuleCat.choicesValues, 
					choicesTooltips =  fieldData.editRuleCat.choicesTooltips, 
                    sort = "name-up",
					
					getFunc = function() 
                        fieldData.currentRule = AC.GetRuleByName(fieldData.editRuleCat.indexValue)
						return fieldData.editRuleCat.indexValue 
					end,
					setFunc = function(value)
                        fieldData.editRuleCat.indexValue = value
                        fieldData.currentRule = AC.GetRuleByName(value)
                        checkCurrentRule()
                   end, 
					disabled = function() return #fieldData.editRuleCat.choices == 0 end,
					width = "half",
					reference = "AC_DROPDOWN_EDITRULE_RULE",
				},
                -- Delete Category/Rule Button
				{
					type = "button",
					name = SI_AC_MENU_EC_BUTTON_DELETE_CATEGORY,
					tooltip = SI_AC_MENU_EC_BUTTON_DELETE_CATEGORY_TOOLTIP,
                    isDangerous = true,
					func = function()  
						local oldRuleName = fieldData.editRuleCat.indexValue
						local oldTagName = fieldData.editRuleTag.indexValue
                        local ndx = cache.rulesByName[oldRuleName]
                        if ndx then
                            table.remove(saved.rules,ndx)
                            AC.cacheInitialize()
                            RefreshDropdownData()
                        end
						
						if oldRuleName == fieldData.addCatRule.indexValue then
							--rule removed, clean selection in add rule menu if selected
							fieldData.addCatRule.indexValue = ""
						end
						
                        fieldData.currentRule = nil
                        checkCurrentRule()
                        fieldData.editRuleCat.indexValue = ""
                        if #fieldData.editRuleCat.choicesValues > 0 then
                            fieldData.editRuleCat.indexValue = fieldData.editRuleCat.choicesValues[1]
                        end
					end,
					width = "half",
					disabled = function() return fieldData.currentRule == nil end,
				},
                -- Copy Category/Rule Button
				{
					type = "button",
					name = SI_AC_MENU_EC_BUTTON_COPY_CATEGORY,
					tooltip = SI_AC_MENU_EC_BUTTON_COPY_CATEGORY_TOOLTIP,
					func = function() 
						local ruleName = fieldData.editRuleCat.indexValue
						local newName = GetUsableRuleName(fieldData.currentRule.name)
						local tag = fieldData.editRuleTag.indexValue
						if tag == "" then
							tag = AC_EMPTY_TAG_NAME
						end
						local newRule = CreateNewRule(newName, tag)
                        local copyFrom = AC.GetRuleByName(ruleName)
                        if not copyFrom then return end
						newRule.description = copyFrom.description
						newRule.rule = copyFrom.rule
                        newRule.damaged = copyFrom.damaged
						newRule.err = copyFrom.err
                        fieldData.currentRule = newRule
						cache.AddRule(newRule)
											
						fieldData.editRuleCat.indexValue = newName
						fieldData.editRuleTag.indexValue = newRule.tag
                        checkCurrentRule()
						
						AutoCategory.cacheInitialize()
						RefreshDropdownData()
						UpdateChoices("AC_DROPDOWN_EDITRULE_TAG", fieldData.editRuleTag)
						UpdateChoices("AC_DROPDOWN_EDITRULE_RULE", fieldData.editRuleCat)
						UpdateChoices("AC_DROPDOWN_ADDCATEGORY_RULE", fieldData.addCatRule)
						UpdateChoices("AC_DROPDOWN_ADDCATEGORY_TAG", fieldData.addCatTag)
                        AutoCategory.RecompileRules(saved.rules)
					end,
					disabled = function() return fieldData.currentRule == nil end,
					width = "half",
				},
                -- Edit Category Title
				{
					type = "header",
					name = SI_AC_MENU_HEADER_EDIT_CATEGORY,
					width = "full",
				},
                -- New Category Button
				{
					type = "button",
					name = SI_AC_MENU_EC_BUTTON_NEW_CATEGORY,
					tooltip = SI_AC_MENU_EC_BUTTON_NEW_CATEGORY_TOOLTIP,
					func = function() 
						local newName = GetUsableRuleName(L(SI_AC_DEFAULT_NAME_NEW_CATEGORY))
						local tag = fieldData.editRuleTag.indexValue
						if tag == "" then
							tag = AC_EMPTY_TAG_NAME
						end
						local newRule = CreateNewRule(newName, tag)
						cache.AddRule(newRule)
                        fieldData.currentRule = newRule
											
						fieldData.editRuleCat.indexValue = newName
						fieldData.editRuleTag.indexValue = newRule.tag
						
						AutoCategory.cacheInitialize()
						RefreshDropdownData()
						UpdateChoices("AC_DROPDOWN_EDITRULE_TAG", fieldData.editRuleTag)
						UpdateChoices("AC_DROPDOWN_ADDCATEGORY_TAG", fieldData.addCatTag)
						AutoCategory.RecompileRules(saved.rules)
					end,
					width = "half",
				},
                -- Learn Rules button
				{			
					type = "button",
					name = SI_AC_MENU_EC_BUTTON_LEARN_RULES,
					func = function() RequestOpenUnsafeURL("https://github.com/Shadowfen/AutoCategory/wiki/Creating-Custom-Categories") end,
					width = "half",
				},
                -- Name EditBox - AC_EDITBOX_EDITRULE_NAME
                {
					type = "editbox",
					name = SI_AC_MENU_EC_EDITBOX_NAME,
					tooltip = SI_AC_MENU_EC_EDITBOX_NAME_TOOLTIP,
					getFunc = function()  
                        if fieldData.currentRule then
                            return fieldData.currentRule.name
                        end
                        return ""
					end,
					warning = function()
						return warningDuplicatedName.warningMessage
					end,
					setFunc = function(value) 
                        local oldName = fieldData.editRuleCat.indexValue
						if oldName == value then 
							return
						end
						if value == "" then
							warningDuplicatedName.warningMessage = L(
								SI_AC_WARNING_CATEGORY_NAME_EMPTY)
							value = oldName
                            return
						end
						
						local isDuplicated = IsRuleNameUsed(value)
						if isDuplicated then
							warningDuplicatedName.warningMessage = string.format(
								L(SI_AC_WARNING_CATEGORY_NAME_DUPLICATED), 
								value, GetUsableRuleName(value))
							value = oldName
                            --change editbox's value
                            local control = WINDOW_MANAGER:GetControlByName("AC_EDITBOX_EDITRULE_NAME", "")
                            control.editbox:SetText(value)
                            return
						end

						fieldData.editRuleCat.indexValue = value
                        fieldData.currentRule.name = value
                        
						--Update bags so that every entry has the same name, should be changed to new name.
						for i = 1, #saved.bags do
							local bag = saved.bags[i]
							local rules = bag.rules
							for j = 1, #rules do
								local rule = rules[j]
								if rule.name == oldName then
									rule.name = value
								end
							end
						end
						--Update drop downs
						AutoCategory.cacheInitialize()
						RefreshDropdownData()
					end,
					isMultiline = false,
					disabled = function() return fieldData.currentRule == nil end,
					width = "half",
					reference = "AC_EDITBOX_EDITRULE_NAME",
				},
                -- Tag EditBox - AC_EDITBOX_EDITRULE_TAG
				{
					type = "editbox",
					name = SI_AC_MENU_EC_EDITBOX_TAG,
					tooltip = SI_AC_MENU_EC_EDITBOX_TAG_TOOLTIP,
					getFunc = function() 
						if fieldData.currentRule then
                            return fieldData.currentRule.tag
                        end
                        return ""
					end, 
				 	setFunc = function(value) 
                        local oldtag = fieldData.currentRule.tag
						if value == "" then
							value = AC_EMPTY_TAG_NAME
                            local control = WINDOW_MANAGER:GetControlByName("AC_EDITBOX_EDITRULE_TAG", "")
                            control.editbox:SetText(value)
						end
                        
                        fieldData.currentRule.tag = value
						
						AutoCategory.cacheInitialize()
						RefreshDropdownData()
						fieldData.editRuleTag.indexValue = fieldData.currentRule.tag
						fieldData.editRuleCat.indexValue = fieldData.currentRule.name
					end,
					isMultiline = false,
					disabled = function() return fieldData.currentRule == nil end,
					width = "half",
					reference = "AC_EDITBOX_EDITRULE_TAG",
				},
                --Description EditBox
				{
					type = "editbox",
					name = SI_AC_MENU_EC_EDITBOX_DESCRIPTION,
					tooltip = SI_AC_MENU_EC_EDITBOX_DESCRIPTION_TOOLTIP,
					getFunc = function()
                        if fieldData.currentRule then
                            return fieldData.currentRule.description
                        end
                        return ""
					end, 
					setFunc = function(value) 
                        local oldval = fieldData.currentRule.description
                        fieldData.currentRule.description = value
                        if oldval ~= value then
                            AC.cacheInitialize() -- reset tooltips to new value
                            RefreshDropdownData()
                        end
					end,
					isMultiline = false,
					isExtraWide = true,
					disabled = function() 
                        if not fieldData or not fieldData.currentRule then
                            return true
                        end
                        return false
                    end,
					width = "full",
				},
                -- Rule EditBox
				{
					type = "editbox",
					name = SI_AC_MENU_EC_EDITBOX_RULE,
					tooltip = SI_AC_MENU_EC_EDITBOX_RULE_TOOLTIP,
					getFunc = function() 
                        if fieldData.currentRule then
                            return fieldData.currentRule.rule
                        end
                        ruleCheckStatus.err = nil
                        ruleCheckStatus.good = nil
                        return ""
					end, 
					setFunc = function(value) 
                        fieldData.currentRule.rule = value
                        ruleCheckStatus.err = AC.CompileRule(fieldData.currentRule)
                        if ruleCheckStatus.err == "" then
                            ruleCheckStatus.err = nil
                            ruleCheckStatus.good = true
							
                        else
                            ruleCheckStatus.good = nil
                        end
                        end,
					isMultiline = true,
					isExtraWide = true,
					disabled = function() return fieldData.currentRule == nil end,
					width = "full",
					reference = "AC_EDITBOX_EDITRULE_RULE",
				},
                -- RuleCheck Text - AutoCategoryCheckText
                {
                    type = "description",
                    text = ruleCheckStatus.getText, -- or string id or function returning a string
                    title = ruleCheckStatus.getTitle, -- or string id or function returning a string (optional)
                    width = "half", --or "half" (optional)
                },
                -- RuleCheck Button
				{			
					type = "button",
					name = SI_AC_MENU_EC_BUTTON_CHECK_RULE,
                    tooltip = SI_AC_MENU_EC_BUTTON_CHECK_RULE_TOOLTIP,
					func = function()
                        local ruleName = fieldData.currentRule.name
                        checkCurrentRule()
                    end,
					disabled = function() return fieldData.currentRule == nil end,
					width = "half",
				},
		    },
			
		},
        -- General Settings
        {
            type = "submenu",
            name = SI_AC_MENU_SUBMENU_GENERAL_SETTING,
            reference = "AC_MENU_SUBMENU_GENERAL_SETTING",
            controls = {
                -- Show message when toggle
                {
                    type = "checkbox",
                    name = SI_AC_MENU_GS_CHECKBOX_SHOW_MESSAGE_WHEN_TOGGLE,
                    tooltip = SI_AC_MENU_GS_CHECKBOX_SHOW_MESSAGE_WHEN_TOGGLE_TOOLTIP,
                    getFunc = function() return saved.general["SHOW_MESSAGE_WHEN_TOGGLE"] end,
                    setFunc = function(value) saved.general["SHOW_MESSAGE_WHEN_TOGGLE"] = value end,
                },
                -- Show category item count
                {
                    type = "checkbox",
                    name = SI_AC_MENU_GS_CHECKBOX_SHOW_CATEGORY_ITEM_COUNT,
                    tooltip = 
						SI_AC_MENU_GS_CHECKBOX_SHOW_CATEGORY_ITEM_COUNT_TOOLTIP,
                    getFunc = function() 
						return saved.general["SHOW_CATEGORY_ITEM_COUNT"] 
						end,
                    setFunc = function(value) 
						saved.general["SHOW_CATEGORY_ITEM_COUNT"] = value 
						end,
                },
                -- Show category collapse icon
                {
                    type = "checkbox",
                    name = SI_AC_MENU_GS_CHECKBOX_SHOW_CATEGORY_COLLAPSE_ICON,
                    tooltip = SI_AC_MENU_GS_CHECKBOX_SHOW_CATEGORY_COLLAPSE_ICON_TOOLTIP,
                    getFunc = function() 
						return saved.general["SHOW_CATEGORY_COLLAPSE_ICON"] 
						end,
                    setFunc = function(value) 
                    	saved.general["SHOW_CATEGORY_COLLAPSE_ICON"] = value 
                    	AutoCategory.RefreshCurrentList(true)
                    end,
                },                
                -- Save category collapse status
                {
                    type = "checkbox",
                    name = SI_AC_MENU_GS_CHECKBOX_SAVE_CATEGORY_COLLAPSE_STATUS,
                    tooltip = SI_AC_MENU_GS_CHECKBOX_SAVE_CATEGORY_COLLAPSE_STATUS_TOOLTIP,
                    getFunc = function() return saved.general["SAVE_CATEGORY_COLLAPSE_STATUS"] end,
                    setFunc = function(value) saved.general["SAVE_CATEGORY_COLLAPSE_STATUS"] = value end,
                    disabled = function() return saved.general["SHOW_CATEGORY_COLLAPSE_ICON"] == false end,
                },
                -- Show category "SET ()"
                {
                    type = "checkbox",
                    name = SI_AC_MENU_GS_CHECKBOX_SHOW_CATEGORY_SET_TITLE,
                    tooltip = SI_AC_MENU_GS_CHECKBOX_SHOW_CATEGORY_SET_TITLE_TOOLTIP,
                    getFunc = function() return saved.general["SHOW_CATEGORY_SET_TITLE"] end,
                    setFunc = function(value) 
						saved.general["SHOW_CATEGORY_SET_TITLE"] = value 
						AutoCategory.ResetCollapse(saved)
					end,
                },
            }
        },
        -- Appearance Settings
		{
            type = "submenu",
            name = SI_AC_MENU_SUBMENU_APPEARANCE_SETTING,
            reference = "AC_SUBMENU_APPEARANCE_SETTING",
            controls = { 
                {
                    type = "description",
                    text = L(SI_AC_MENU_AS_DESCRIPTION_REFRESH_TIP), -- or string id or function returning a string						
                },
                {
                    type = "divider",
                },
                -- Category Text Font
                {
                    type = 'dropdown',
                    name = SI_AC_MENU_EC_DROPDOWN_CATEGORY_TEXT_FONT,
                    choices = LMP:List('font'),
                    getFunc = function()
                        return saved.appearance["CATEGORY_FONT_NAME"]
                    end,
                    setFunc = function(v)
                        saved.appearance["CATEGORY_FONT_NAME"] = v
                    end,
                    scrollable = 7,
                },
                -- Category Text Style
                {
                    type = 'dropdown',
                    name = SI_AC_MENU_EC_DROPDOWN_CATEGORY_TEXT_STYLE,
                    choices = dropdownFontStyle,
                    getFunc = function()
                        return saved.appearance["CATEGORY_FONT_STYLE"]
                    end,
                    setFunc = function(v)
                        saved.appearance["CATEGORY_FONT_STYLE"] = v
                    end,
                    scrollable = 7,
                },
                -- Category Text Alignment
                {
                    type = 'dropdown',
                    name = SI_AC_MENU_EC_DROPDOWN_CATEGORY_TEXT_ALIGNMENT,
                    choices = dropdownFontAlignment.showNames,
                    choicesValues = dropdownFontAlignment.values,
                    getFunc = function()
                        return saved.appearance["CATEGORY_FONT_ALIGNMENT"]
                    end,
                    setFunc = function(v)
                        saved.appearance["CATEGORY_FONT_ALIGNMENT"] = v
                    end,
                    scrollable = 7,
                },
                -- Category Text Font Size
                {
                    type = 'slider',
                    name = SI_AC_MENU_EC_DROPDOWN_CATEGORY_TEXT_FONT_SIZE,
                    min = 8,
                    max = 32,
                    getFunc = function()
                        return saved.appearance["CATEGORY_FONT_SIZE"]
                    end,
                    setFunc = function(v)
                        saved.appearance["CATEGORY_FONT_SIZE"] = v
                    end,
                },
                -- Category Text Color
                {
                    type = 'colorpicker',
                    name = SI_AC_MENU_EC_DROPDOWN_CATEGORY_TEXT_COLOR,
                    getFunc = function()
                        return unpack(saved.appearance["CATEGORY_FONT_COLOR"])
                    end,
                    setFunc = function(r, g, b, a)
                        saved.appearance["CATEGORY_FONT_COLOR"][1] = r
                        saved.appearance["CATEGORY_FONT_COLOR"][2] = g
                        saved.appearance["CATEGORY_FONT_COLOR"][3] = b
                        saved.appearance["CATEGORY_FONT_COLOR"][4] = a 
                    end,
                    widgetRightAlign		= true,
                    widgetPositionAndResize	= -15,
                },
                -- Hidden Category Text Color
                {
                    type = 'colorpicker',
                    name = SI_AC_MENU_EC_DROPDOWN_HIDDEN_CATEGORY_TEXT_COLOR,
                    getFunc = function()
                        return unpack(saved.appearance["HIDDEN_CATEGORY_FONT_COLOR"])
                    end,
                    setFunc = function(r, g, b, a)
                        saved.appearance["HIDDEN_CATEGORY_FONT_COLOR"][1] = r
                        saved.appearance["HIDDEN_CATEGORY_FONT_COLOR"][2] = g
                        saved.appearance["HIDDEN_CATEGORY_FONT_COLOR"][3] = b
                        saved.appearance["HIDDEN_CATEGORY_FONT_COLOR"][4] = a 
                    end,
                    widgetRightAlign		= true,
                    widgetPositionAndResize	= -15,
                },
                -- Category Ungrouped Title EditBox
                {
                    type = "editbox",
                    name = SI_AC_MENU_EC_EDITBOX_CATEGORY_UNGROUPED_TITLE,
                    tooltip = SI_AC_MENU_EC_EDITBOX_CATEGORY_UNGROUPED_TITLE_TOOLTIP,
                    getFunc = function() 
                        return saved.appearance["CATEGORY_OTHER_TEXT"]
                    end, 
                    setFunc = function(value) saved.appearance["CATEGORY_OTHER_TEXT"] = value end,  
                    width = "full",
                },
                -- Category Header Height
                {
                    type = 'slider',
                    name = SI_AC_MENU_EC_SLIDER_CATEGORY_HEADER_HEIGHT,
                    min = 1,
                    max = 100,
                    requiresReload = true,
                    getFunc = function()
                        return saved.appearance["CATEGORY_HEADER_HEIGHT"]
                    end,
                    setFunc = function(v)
                        saved.appearance["CATEGORY_HEADER_HEIGHT"] = v
                    end,
                    warning = SI_AC_WARNING_NEED_RELOAD_UI,
                },
            },
        }, 
		-- Gamepad settings
		{
            type = "submenu",
            name = SI_AC_MENU_SUBMENU_GAMEPAD_SETTING,
            reference = "AC_SUBMENU_GAMEPAD_SETTING",
            controls = { 
                {
                    type = "description",
                    text = L(SI_AC_MENU_GMS_DESCRIPTION_TIP),
                },
                {
                    type = "divider",
                },
                {
                    type = "checkbox",
                    name = SI_AC_MENU_GMS_CHECKBOX_ENABLE_GAMEPAD,
                    tooltip = SI_AC_MENU_GMS_CHECKBOX_ENABLE_GAMEPAD_TOOLTIP,
                    requiresReload = true,
                    getFunc = function() return saved.general["ENABLE_GAMEPAD"] end,
                    setFunc = function(value) saved.general["ENABLE_GAMEPAD"] = value end,
                },
				{
                    type = "checkbox",
                    name = SI_AC_MENU_GMS_CHECKBOX_EXTENDED_GAMEPAD_SUPPLIES,
                    tooltip = SI_AC_MENU_GMS_CHECKBOX_EXTENDED_GAMEPAD_SUPPLIES_TOOLTIP,
                    requiresReload = false,
                    getFunc = function() return saved.general["EXTENDED_GAMEPAD_SUPPLIES"] end,
                    setFunc = function(value) saved.general["EXTENDED_GAMEPAD_SUPPLIES"] = value end,
					disabled = function() return saved.general["ENABLE_GAMEPAD"] == false end,
                },
			},
		},
	}
    if not LAM then return end
	LAM:RegisterAddonPanel("AC_CATEGORY_SETTINGS", panelData)
	LAM:RegisterOptionControls("AC_CATEGORY_SETTINGS", optionsTable)
	CALLBACK_MANAGER:RegisterCallback("LAM-RefreshPanel", RefreshPanel)
	CALLBACK_MANAGER:RegisterCallback("LAM-PanelControlsCreated", AC.LengthenRuleBox)
end