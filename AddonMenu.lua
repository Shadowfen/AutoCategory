local LAM = LibAddonMenu2
local LMP = LibMediaProvider

local L = GetString
local SF = LibSFUtils
local AC = AutoCategory

AC_UI = {}

local AC_EMPTY_TAG_NAME = L(SI_AC_DEFAULT_NAME_EMPTY_TAG)

local cache = AutoCategory.cache
local saved = AutoCategory.saved

--cache data for dropdown: 
cache.bags_cvt.choices = {
	L(SI_AC_BAGTYPE_SHOWNAME_BACKPACK),
	L(SI_AC_BAGTYPE_SHOWNAME_BANK),
	L(SI_AC_BAGTYPE_SHOWNAME_GUILDBANK),
	L(SI_AC_BAGTYPE_SHOWNAME_CRAFTBAG),
	L(SI_AC_BAGTYPE_SHOWNAME_CRAFTSTATION),
	L(SI_AC_BAGTYPE_SHOWNAME_HOUSEBANK),
}
cache.bags_cvt.choicesValues = {
	AC_BAG_TYPE_BACKPACK,
	AC_BAG_TYPE_BANK,
	AC_BAG_TYPE_GUILDBANK,
	AC_BAG_TYPE_CRAFTBAG,
	AC_BAG_TYPE_CRAFTSTATION,
	AC_BAG_TYPE_HOUSEBANK,
}
cache.bags_cvt.choicesTooltips = {
	L(SI_AC_BAGTYPE_TOOLTIP_BACKPACK),
	L(SI_AC_BAGTYPE_TOOLTIP_BANK),
	L(SI_AC_BAGTYPE_TOOLTIP_GUILDBANK),
	L(SI_AC_BAGTYPE_TOOLTIP_CRAFTBAG),
	L(SI_AC_BAGTYPE_TOOLTIP_CRAFTSTATION),
	L(SI_AC_BAGTYPE_TOOLTIP_HOUSEBANK),
}

local function divider()
	return {
		type = "divider",
		width = "full", --or "half" (optional)
		height = 10,
		alpha = 0.5,
	}
end

local function header(strId)
	return {
		type = "header",
		name = strId,
		width = "full",
	}
end

local function description(textId, titleId)
	return
		{
			type = "description",
			text = textId, -- text or string id or function returning a string
			title = titleId, -- or string id or function returning a string (optional)
			width = "full", --or "half" (optional)
		}
end


-- aliases
local CVT = AutoCategory.CVT

-- -------------------------------------------------------

-- CVT containers for the dropdowns that we use
local fieldData = {
	importBag =   CVT:New("AC_DROPDOWN_IMPORTBAG_BAG", AC_BAG_TYPE_BACKPACK),
}

local currentRule = AC.CreateNewRule("","")
local currentBagRule = nil


local dropdownFontStyle	= {
	'none', 'outline', 'thin-outline', 'thick-outline',
	'shadow', 'soft-shadow-thin', 'soft-shadow-thick',
}

local dropdownFontAlignment = {}
dropdownFontAlignment.choices = {
	L(SI_AC_ALIGNMENT_LEFT),
	L(SI_AC_ALIGNMENT_CENTER),
	L(SI_AC_ALIGNMENT_RIGHT)
}
dropdownFontAlignment.choicesValues = {0, 1, 2}

-- This is not a "class"! It is more of a singleton instance.
AC_UI.BagSet_SelectBag_LAM = AC.BaseDD:New("AC_DROPDOWN_EDITBAG_BAG", AC_BAG_TYPE_BACKPACK, CVT.USE_VALUES + CVT.USE_TOOLTIPS)
local BagSet_SelectBag_LAM = AC_UI.BagSet_SelectBag_LAM

AC_UI.BagSet_HideOther_LAM = AC.BaseUI:New("AC_CHECKBOX_HIDEOTHER")	-- checkbox
local BagSet_HideOther_LAM = AC_UI.BagSet_HideOther_LAM

AC_UI.BagSet_SelectRule_LAM = AC.BaseDD:New("AC_DROPDOWN_EDITBAG_RULE", nil, CVT.USE_VALUES + CVT.USE_TOOLTIPS)
local BagSet_SelectRule_LAM = AC_UI.BagSet_SelectRule_LAM

AC_UI.BagSet_Priority_LAM = AC.BaseUI:New()		-- slider
local BagSet_Priority_LAM = AC_UI.BagSet_Priority_LAM

AC_UI.BagSet_HideCat_LAM = AC.BaseUI:New()		-- checkbox
local BagSet_HideCat_LAM = AC_UI.BagSet_HideCat_LAM

AC_UI.BagSet_EditCat_LAM = AC.BaseUI:New()	-- button
local BagSet_EditCat_LAM = AC_UI.BagSet_EditCat_LAM

AC_UI.BagSet_RemoveCat_LAM = AC.BaseUI:New()	-- button
local BagSet_RemoveCat_LAM = AC_UI.BagSet_RemoveCat_LAM

AC_UI.AddCat_SelectTag_LAM = AC.BaseDD:New("AC_DROPDOWN_ADDCATEGORY_TAG")	-- only uses choices
local AddCat_SelectTag_LAM = AC_UI.AddCat_SelectTag_LAM

AC_UI.AddCat_SelectRule_LAM = AC.BaseDD:New("AC_DROPDOWN_ADDCATEGORY_RULE",nil ,CVT.USE_TOOLTIPS) -- uses choicesTooltips
local AddCat_SelectRule_LAM = AC_UI.AddCat_SelectRule_LAM

AC_UI.AddCat_EditRule_LAM = AC.BaseUI:New()	-- button
local AddCat_EditRule_LAM = AC_UI.AddCat_EditRule_LAM

AC_UI.AddCat_BagAdd_LAM = AC.BaseUI:New()	-- button
local AddCat_BagAdd_LAM = AC_UI.AddCat_BagAdd_LAM

AC_UI.ImpExp_ExportAll_LAM = AC.BaseUI:New()	-- button
local ImpExp_ExportAll_LAM = AC_UI.ImpExp_ExportAll_LAM

AC_UI.ImpExp_ImportBag_LAM = AC.BaseDD:New("AC_DROPDOWN_IMPORTBAG_BAG", nil, CVT.USE_VALUES + CVT.USE_TOOLTIPS)
local ImpExp_ImportBag_LAM = AC_UI.ImpExp_ImportBag_LAM

AC_UI.ImpExp_Import_LAM = AC.BaseUI:New()	-- button
local ImpExp_Import_LAM = AC_UI.ImpExp_Import_LAM

AC_UI.CatSet_SelectTag_LAM = AC.BaseDD:New("AC_DROPDOWN_EDITRULE_TAG") -- only uses choices
local CatSet_SelectTag_LAM = AC_UI.CatSet_SelectTag_LAM

AC_UI.CatSet_SelectRule_LAM = AC.BaseDD:New("AC_DROPDOWN_EDITRULE_RULE", nil,  CVT.USE_TOOLTIPS) -- uses choicesTooltips
local CatSet_SelectRule_LAM = AC_UI.CatSet_SelectRule_LAM

AC_UI.CatSet_NewCat_LAM = AC.BaseUI:New() 	-- button
local CatSet_NewCat_LAM = AC_UI.CatSet_NewCat_LAM

AC_UI.CatSet_CopyCat_LAM = AC.BaseUI:New() 	-- button
local CatSet_CopyCat_LAM = AC_UI.CatSet_CopyCat_LAM

AC_UI.CatSet_DeleteCat_LAM = AC.BaseUI:New()	-- button
local CatSet_DeleteCat_LAM = AC_UI.CatSet_DeleteCat_LAM

AC_UI.CatSet_NameEdit_LAM = AC.BaseUI:New("AC_EDITBOX_EDITRULE_NAME") -- editbox
local CatSet_NameEdit_LAM = AC_UI.CatSet_NameEdit_LAM

AC_UI.CatSet_TagEdit_LAM = AC.BaseUI:New("AC_EDITBOX_EDITRULE_TAG")	-- editbox
local CatSet_TagEdit_LAM = AC_UI.CatSet_TagEdit_LAM


local function CatSet_DisplayRule(rule)
	--AC.logger:Debug("DisplayRule: tag= "..rule.tag.." name="..rule.name)
	CatSet_SelectTag_LAM:refresh()
	CatSet_SelectTag_LAM:setValue(rule.tag)

	CatSet_SelectRule_LAM:refresh()
	CatSet_SelectRule_LAM:setValue(rule.name)
	CatSet_SelectRule_LAM:updateControl()


	--AC.logger:Debug("displayRule2: tag= "..currentRule.tag.." name="..currentRule.name)
	--AC.logger:Debug("displayRule3: tag= "..rule.tag.." name="..rule.name)
	currentRule = rule
	AC_UI.checkCurrentRule()
end

local function getCurrentBagId()
	return BagSet_SelectBag_LAM:getValue()
end
AC.getCurrentBagId = getCurrentBagId   -- make available

--warning message
local warningDuplicatedName = {
	warningMessage = nil,
}

-- returns the current bagSetting table (or nil if the bag was not found)
-- if parameter bagId is nil then get the current bagId from BagSet
-- bagSetting table = {isOtherHidden, {rules{name, priority, isHidden}} }
local function getBagSettings(bagId)
	if not bagId then bagId = getCurrentBagId() end
	if saved and saved.bags then
		return saved.bags[bagId]	-- still might be nil
	end
	return nil
end


-- customization of BaseDD for BagSet_SelectBag_LAM
-- ------------------------------------------------
AC_UI.BagSet_SelectBag_LAM.defaultVal = AC_BAG_TYPE_BACKPACK

function AC_UI.BagSet_SelectBag_LAM:refresh()
	if self:getValue() == nil then
		--AC.logger:Debug("SelectBag:refresh - old bagid = "..tostring(getCurrentBagId()))
		self:select(cache.bags_cvt.choicesValues)
		--AC.logger:Debug("SelectBag:refresh - new bagid = "..tostring(getCurrentBagId()))
	end
end

function AC_UI.BagSet_SelectBag_LAM:getValue()
	return self.cvt.indexValue
end

function AC_UI.BagSet_SelectBag_LAM:setValue(value)
	if value == self:getValue() then
		-- nothing to do because no change
		return
	end

	local bs = getBagSettings(value)
	--if not bs then return end

	-- value will always be a valid cvt value, so we don't need to check CVT lists first
	self.cvt.indexValue = value
	-- we don't need to add/remove for the CVT as those lists are static
	--AC.logger:Debug("SelectBag:setValue - new bagid = "..tostring(getCurrentBagId()))

	BagSet_HideOther_LAM:setValue(bs.isUngroupedHidden)

	-- manage related control values
	AC_UI.RefreshDropdownData()

	BagSet_SelectRule_LAM:clearIndex()
	BagSet_SelectRule_LAM:refresh()

	--reset add rule's selection, since all data will be changed.
	AddCat_SelectRule_LAM:clearIndex()
	AddCat_SelectRule_LAM:refresh()

	AC_UI.RefreshControls()
end

function AC_UI.BagSet_SelectBag_LAM:controlDef()
	-- Bag     - AC_DROPDOWN_EDITBAG_BAG
	return
		{
			type = "dropdown",
			name = SI_AC_MENU_BS_DROPDOWN_BAG,
			scrollable = false,
			tooltip = L(SI_AC_MENU_BS_DROPDOWN_BAG_TOOLTIP),
			choices         = self.cvt.choices,
			choicesValues   = self.cvt.choicesValues,
			choicesTooltips = self.cvt.choicesTooltips,

			getFunc = function(value) return self:getValue() end,
			setFunc = function(value) self:setValue(value) end,
			default = AC_BAG_TYPE_BACKPACK,
			width = "half",
			reference = self:getControlName(),
		}
end
-- -------------------------------------------------------

-- customization of BaseUI for BagSet_HideOther_LAM checkbox
-- -------------------------------------------------------
function AC_UI.BagSet_HideOther_LAM:getValue()
	local bs = getBagSettings()
	if not bs then
		-- no such bag
		return false
	end
	return bs.isUngroupedHidden
end

function AC_UI.BagSet_HideOther_LAM:setValue(value)
	local bs = getBagSettings()
	if not bs then return false end

	if value == false then 
		value = nil
	end
	bs.isUngroupedHidden = value

end

function AC_UI.BagSet_HideOther_LAM:controlDef()
	-- Hide ungrouped in bag Checkbox
	return
		{
			type = "checkbox",
			name = SI_AC_MENU_BS_CHECKBOX_UNGROUPED_CATEGORY_HIDDEN,
			tooltip = SI_AC_MENU_BS_CHECKBOX_UNGROUPED_CATEGORY_HIDDEN_TOOLTIP,
			getFunc = function() return self:getValue() end,
			setFunc = function(value) self:setValue(value) end,
			default = false,
			width = "half",
			reference = self:getControlName(),
		}
end
-- -------------------------------------------------------

-- customization of BaseUI for BagSet_HideCat_LAM checkbox
-- -------------------------------------------------------
function AC_UI.BagSet_HideCat_LAM:getValue()
	local bag = getCurrentBagId()
	local ruleNm = currentBagRule or BagSet_SelectRule_LAM:getValue()
	if bag and ruleNm and cache.entriesByName[bag][ruleNm] then
		return cache.entriesByName[bag][ruleNm].isHidden or false
	end
	return 0
end

function AC_UI.BagSet_HideCat_LAM:setValue(value)
	local bag = getCurrentBagId()
	local ruleNm = currentBagRule or BagSet_SelectRule_LAM:getValue()
	AC.logger:Debug("HideCat:setValue - bag = "..bag.."  rule = "..tostring(ruleNm))
	if cache.entriesByName[bag][ruleNm] then
		local isHidden = cache.entriesByName[bag][ruleNm].isHidden or false
		AC.logger:Debug("HideCat:setValue - bagrule found for rule = "..ruleNm.." isHidden = "..tostring( cache.entriesByName[bag][ruleNm].isHidden))
		if isHidden ~= value then
			AC.logger:Debug("HideCat:setValue - value is changing to "..tostring(value))
			if not value then value = nil end
			cache.entriesByName[bag][ruleNm].isHidden = value
			AutoCategory.cacheBagInitialize()
			AC_UI.RefreshDropdownData()
			BagSet_SelectRule_LAM:setValue(ruleNm)
			AC_UI.RefreshControls()
		end
	end
end

function AC_UI.BagSet_HideCat_LAM:controlDef()
	-- Hide Category Checkbox
	return
		{
			type = "checkbox",
			name = SI_AC_MENU_BS_CHECKBOX_CATEGORY_HIDDEN,
			tooltip = SI_AC_MENU_BS_CHECKBOX_CATEGORY_HIDDEN_TOOLTIP,
			getFunc = function()	return self:getValue() end,
			setFunc = function(value)  self:setValue(value) end,
			disabled = function()
				if BagSet_SelectRule_LAM:getValue() == nil then
					return true
				end
				if BagSet_SelectRule_LAM:size() == 0 then
					return true
				end
				return false
			end,
			default = false,
			width = "half",
		}
end
-- -------------------------------------------------------

-- customization of BaseDD for BagSet_SelectRule_LAM
-- ------------------------------------------------
-- refresh the contents of the cvt lists for BagSet_SelectRule_LAM from the 
-- current contents of the cache.entriesByBag[bagId] list.
function AC_UI.BagSet_SelectRule_LAM:refresh(bagId)
	local currentBag = bagId or getCurrentBagId()
	local ndx = BagSet_SelectRule_LAM:getValue()

	AC.logger:Debug("SelectRule:refresh: Updating cvt lists for BagSet_SelectRule for bag "..tostring(currentBag))
	do
		-- dropdown lists for Edit Bag Rules selection (AC_DROPDOWN_EDITBAG_BAG)
		local dataCurrentRules_EditBag = CVT:New(self.controlName,nil, CVT.USE_VALUES + CVT.USE_TOOLTIPS)
		if currentBag and cache.entriesByBag[currentBag] then
			AC.logger:Debug("SelectRule:refresh: Getting rules for bag "..tostring(currentBag))
			dataCurrentRules_EditBag:assign(cache.entriesByBag[currentBag])
		end
		self:assign(dataCurrentRules_EditBag)
		--self:updateControl()
	end
	BagSet_SelectRule_LAM:setValue(ndx)
	AC.logger:Debug("SelectRule:refresh: Done updating cvt lists for BagSet_SelectRule for bag "..tostring(currentBag))
end

-- set the selection of the BagSet_SelectRule_LAM field
function AC_UI.BagSet_SelectRule_LAM:setValue(val)
	if self:getValue() == val then return end
	self:select(val)
	currentBagRule = val
	local bagrule = cache.entriesByName[getCurrentBagId()][val]
	if bagrule and bagrule.priority then
		BagSet_Priority_LAM:setValue(bagrule.priority)
	end
end

function AC_UI.BagSet_SelectRule_LAM:controlDef()
	-- Rule name   - AC_DROPDOWN_EDITBAG_RULE
	return
		{
			type = "dropdown",
			name = SI_AC_MENU_BS_DROPDOWN_CATEGORIES,
			tooltip = "",
			scrollable = true,
			choices         = self.cvt.choices,
			choicesValues   = self.cvt.choicesValues,
			choicesTooltips = self.cvt.choicesTooltips,

			getFunc = function() return self:getValue() end,
			setFunc = function(value) self:setValue(value) end,
			disabled = function() return self:size() == 0 end,
			width = "half",
			reference = self:getControlName(),
		}
end
-- ----------------------------------------------------------

-- customization of BaseUI for BagSet_Priority_LAM
-- ------------------------------------------------
AC_UI.BagSet_Priority_LAM.maxVal = 1000
AC_UI.BagSet_Priority_LAM.minVal = 0

function AC_UI.BagSet_Priority_LAM:getValue()
	local bag = getCurrentBagId()
	local bagrule = currentBagRule --BagSet_SelectRule_LAM:getValue()
	if bag and bagrule and cache.entriesByName[bag][bagrule] then
		return cache.entriesByName[bag][bagrule].priority
	end
	return self.minVal
end

function AC_UI.BagSet_Priority_LAM:setValue(value)
	if value > self.maxVal then
		value = self.maxVal
	end
	if value < self.minVal then
		value = self.minVal
	end
	local bag = getCurrentBagId()
	local ruleName = currentBagRule --AC_UI.BagSet_SelectRule_LAM:getValue()
	if cache.entriesByName[bag][ruleName] then
		cache.entriesByName[bag][ruleName].priority = value
		AutoCategory.cacheBagInitialize()
		AC_UI.RefreshDropdownData()
		BagSet_SelectRule_LAM:setValue(ruleName)
		AC_UI.RefreshControls()
	end
end

function AC_UI.BagSet_Priority_LAM:controlDef()
	-- Priority Slider
	return
		{
			type = "slider",
			name = SI_AC_MENU_BS_SLIDER_CATEGORY_PRIORITY,
			tooltip = SI_AC_MENU_BS_SLIDER_CATEGORY_PRIORITY_TOOLTIP,
			min = self.minVal,
			max = self.maxVal,
			getFunc = function() return self:getValue() end,
			setFunc = function(value) self:setValue(value) end,
			disabled = function()
				if BagSet_SelectRule_LAM:getValue() == nil then
					return true
				end
				if BagSet_SelectRule_LAM:size() == 0 then
					return true
				end
				return false
			end,
			default = 0,
			width = "half",
		}
end
-- ------------------------------------------------


-- customization of BaseUI for BagSet_EditCat_LAM Button
-- ------------------------------------------------
function AC_UI.BagSet_EditCat_LAM:execute()
	local ruleName = BagSet_SelectRule_LAM:getValue()
	AC.logger:Debug("Executing BagSet_EditCat_LAM for rule "..tostring(ruleName))
	local rule = AC.GetRuleByName(ruleName)
	if rule then
		CatSet_DisplayRule(rule)
		AC_UI.ToggleSubmenu("AC_SUBMENU_BAG_SETTING", false)
		AC_UI.ToggleSubmenu("AC_SUBMENU_CATEGORY_SETTING", true)
	end
end

function AC_UI.BagSet_EditCat_LAM:controlDef()
	return
		{
			type = "button",
			name = SI_AC_MENU_BS_BUTTON_EDIT,
			tooltip = SI_AC_MENU_BS_BUTTON_EDIT_TOOLTIP,
			func = function() self:execute() end,
			disabled = function()
				return BagSet_SelectRule_LAM:size() == 0 or BagSet_SelectRule_LAM:getValue() == nil
			end,
			width = "half",
		}
end
-- ----------------------------------------------------------

-- customization of BaseUI for BagSet_RemoveCat_LAM Button
-- ----------------------------------------------------------
function AC_UI.BagSet_RemoveCat_LAM:execute()
	local bagId = getCurrentBagId()
	local ruleName = BagSet_SelectRule_LAM:getValue()
	local savedbag = saved.bags[bagId]
	for i = 1, #savedbag.rules do
		local bagEntry = savedbag.rules[i]
		if bagEntry.name == ruleName then
			table.remove(savedbag.rules, i)
			break
		end
	end
	BagSet_SelectRule_LAM.cvt:removeItemChoiceValue(ruleName)
	if BagSet_SelectRule_LAM:getValue() == nil and BagSet_SelectRule_LAM:size() > 0 then
		BagSet_SelectRule_LAM:select({}) 	-- select first
	end

	AC.cacheBagInitialize()
	BagSet_SelectRule_LAM:refresh()
	AddCat_SelectRule_LAM:refresh()
	AC_UI.RefreshControls()
end

function AC_UI.BagSet_RemoveCat_LAM:controlDef()
	-- Remove Category from Bag Button
	return
		{
			type = "button",
			name = SI_AC_MENU_BS_BUTTON_REMOVE,
			tooltip = SI_AC_MENU_BS_BUTTON_REMOVE_TOOLTIP,
			func = function() self:execute() end,
			disabled = function() return BagSet_SelectRule_LAM:size() == 0 end,
			width = "half",
		}

end
-- ----------------------------------------------------------

-- customization of BaseDD for AddCat_SelectTag_LAM
-- ----------------------------------------------------------
function AC_UI.AddCat_SelectTag_LAM:refresh()
	if self:getValue() == nil then
		self:select(cache.tags)
	end
end

function AC_UI.AddCat_SelectTag_LAM:setValue(value)
	local oldvalue = self:getValue()
	if oldvalue == value then return end

	self.cvt.indexValue = value
	AddCat_SelectRule_LAM:clearIndex()

	AddCat_SelectRule_LAM:assign(AddCat_SelectRule_LAM.filterRules(getCurrentBagId(),value))
	AddCat_SelectRule_LAM:refresh()
	--AddCat_SelectRule_LAM:updateControl()
	AC_UI.RefreshControls()
end

function AC_UI.AddCat_SelectTag_LAM:controlDef()
	return
		{
			type = "dropdown",
			name = SI_AC_MENU_AC_DROPDOWN_TAG,
			scrollable = true,
			choices         = self.cvt.choices,
			--choicesValues   = self.cvt.choicesValues,
			--choicesTooltips = self.cvt.choicesTooltips,
			sort = "name-up",

			getFunc = function()
				return self:getValue()
			end,
			setFunc = function(value) self:setValue(value) end,
			width = "half",
			disabled = function() return self.cvt:size() == 0 end,
			reference = self:getControlName(),
		}
end
-- ----------------------------------------------------------

-- customization of BaseDD for AddCat_SelectRule_LAM
-- ----------------------------------------------------------

-- will return empty CVT if no rules match the filter
function AC_UI.AddCat_SelectRule_LAM.filterRules(bagId, tag)
	if not bagId or not tag then return nil end
	if not cache.entriesByName[bagId] then
		cache.entriesByName[bagId] = SF.safeTable(cache.entriesByName[bagId] )
	end

	-- filter out already-in-use rules from the "add category" list for bag rules
	local dataCurrentRules_AddCategory = CVT:New(AddCat_SelectRule_LAM:getControlName(),nil,CVT.USE_TOOLTIPS) -- uses choicesTooltips
	dataCurrentRules_AddCategory.dirty = 1
	if not cache.rulesByTag_cvt[tag] then
		-- no rules available for tag
		return dataCurrentRules_AddCategory
	end

	local rbyt = cache.rulesByTag_cvt[tag]
	AC.logger:Debug("size for rulesByTag_cvt for tag "..tag.." = "..rbyt:size().." control "..tostring(AddCat_SelectRule_LAM:getControlName()))
	for i = 1, rbyt:size() do
		local value = rbyt.choices[i]
		if value and cache.entriesByName[bagId][value] == nil then
			--add the rule if not in bag
			--AC.logger:Debug("Added rule "..value.." with tooltip to filtered list")
			dataCurrentRules_AddCategory:append(rbyt.choices[i], nil, rbyt.choicesTooltips[i])
		end
	end
	return dataCurrentRules_AddCategory
end

function AC_UI.AddCat_SelectRule_LAM:refresh()
	local currentBag = getCurrentBagId()
	do
		-- dropdown lists for Adding Rules to Bag selection (AC_DROPDOWN_ADDCATEGORY_RULE)
		local latag = AddCat_SelectTag_LAM:getValue()
		local dataCurrentRules_AddCategory = AddCat_SelectRule_LAM.filterRules(currentBag, latag)
		if dataCurrentRules_AddCategory then
			AddCat_SelectRule_LAM:assign(dataCurrentRules_AddCategory)
			AddCat_SelectRule_LAM:select()
		end
	end

end

function AC_UI.AddCat_SelectRule_LAM:setValue(value)
	self:select(value)
end

function AC_UI.AddCat_SelectRule_LAM:controlDef()
	-- Categories currently unused dropdown - AC_DROPDOWN_ADDCATEGORY_RULE
	return
		{
			type = "dropdown",
			name = SI_AC_MENU_AC_DROPDOWN_CATEGORY,
			scrollable = true,
			choices = self.cvt.choices,
			--choicesValues = self.cvt.choicesValues,
			choicesTooltips = self.cvt.choicesTooltips,
			sort = "name-up",

			getFunc = function() return self:getValue() end,
			setFunc = function(value) self:setValue(value) end,
			disabled = function() return self:size() == 0 end,
			width = "half",
			reference = self:getControlName(),
		}

end
-- ----------------------------------------------------------

-- customization of BaseUI for AddCat_EditRule_LAM button
-- ----------------------------------------------------------
function AC_UI.AddCat_EditRule_LAM:execute()
	local ruleName = AddCat_SelectRule_LAM:getValue()
	AC.logger:Debug("AddCat_EditRule_LAM for rule "..tostring(ruleName))
	local rule = AC.GetRuleByName(ruleName)
	if not rule then return end

	AC.logger:Debug("found rule for name "..tostring(ruleName).." tag "..rule.tag)
	CatSet_DisplayRule(rule)
	AC_UI.RefreshDropdownData()
	currentRule = rule
	CatSet_SelectTag_LAM:setValue(rule.tag)
	CatSet_SelectTag_LAM:refresh()
	--CatSet_SelectTag_LAM:updateControl()

	AC_UI.checkCurrentRule()
	AC_UI.RefreshDropdownData()
	CatSet_SelectRule_LAM:refresh()
	CatSet_SelectRule_LAM:setValue(rule.name)
	--CatSet_SelectRule_LAM:updateControl()
	AC.logger:Debug("set to current rule for name "..tostring(ruleName).." tag "..rule.tag)

	AC_UI.ToggleSubmenu("AC_SUBMENU_BAG_SETTING", false)
	AC_UI.ToggleSubmenu("AC_SUBMENU_CATEGORY_SETTING", true)
end

function AC_UI.AddCat_EditRule_LAM:controlDef()
                -- Edit Rule Category Button
	return
		{
			type = "button",
			name = SI_AC_MENU_AC_BUTTON_EDIT,
			tooltip = SI_AC_MENU_AC_BUTTON_EDIT_TOOLTIP,
			func = function()	self:execute() end,
			disabled = function() return AddCat_SelectRule_LAM:size() == 0 end,
			width = "half",
		}

end
-- ----------------------------------------------------------

-- -------------------------------------------------------
-- customization of BaseUI for AddCat_BagAdd_LAM button
function AC_UI.AddCat_BagAdd_LAM:execute()
	local bagId = getCurrentBagId()
	local ruleName = AddCat_SelectRule_LAM:getValue()
	AC.logger:Debug("AddCat_BagAdd: bagId = "..bagId.." rule = "..ruleName)
	assert(cache.entriesByName[bagId][ruleName] == nil, "Bag(" .. bagId .. ") already has the rule: ".. ruleName)

	if cache.entriesByName[bagId][ruleName] then return end

	local entry = AC.CreateNewBagRule(ruleName)
	AC.logger:Debug("AddCat_BagAdd: inserting new bagrule to saved.bags - bagId = "..bagId.." rule = "..ruleName)
	table.insert(saved.bags[bagId].rules, entry)
	currentBagRule = entry.name

	AutoCategory.cacheBagInitialize()

	BagSet_SelectRule_LAM:select(ruleName)
	BagSet_Priority_LAM:setValue(entry.priority)
	AddCat_SelectRule_LAM.cvt:removeItemChoiceValue(ruleName)

	AddCat_SelectRule_LAM:refresh()
	AddCat_SelectRule_LAM:updateControl()

	BagSet_SelectRule_LAM:refresh()
	BagSet_SelectRule_LAM:updateControl()

	AddCat_SelectRule_LAM:updateControl()
end

function AC_UI.AddCat_BagAdd_LAM:controlDef()
	-- Add to Bag Button
	return
		{
			type = "button",
			name = SI_AC_MENU_AC_BUTTON_ADD,
			tooltip = SI_AC_MENU_AC_BUTTON_ADD_TOOLTIP,
			func = function()  self:execute() end,
			disabled = function() return AddCat_SelectRule_LAM:size() == 0 end,
			width = "half",
		}
end
-- -------------------------------------------------------

local function copyBagToBag(srcBagId, destBagId)
	AC.logger:Info("copyBagToBag started, destBagId = "..destBagId.." srcBagId = "..tostring(srcBagId))
	--saved.bags[bagId] = SF.safeClearTable(saved.bags[destBagId])
	saved.bags[destBagId] = SF.deepCopy( saved.bags[srcBagId] )
end

-- customization of BaseUI for ImpExp_ExportAll_LAM button
-- -------------------------------------------------------
function AC_UI.ImpExp_ExportAll_LAM:execute()
	local selectedBag = getCurrentBagId()
	for bagId = 1, 6 do
		if bagId ~= selectedBag then
			copyBagToBag(selectedBag, bagId)
		end
	end

	AC_UI.BagSet_SelectRule_LAM:clearIndex()
	--reset add rule's selection, since all data will be changed.
	AddCat_SelectRule_LAM:clearIndex()

	AutoCategory.cacheInitialize()
	AC_UI.RefreshDropdownData()
	AC_UI.RefreshControls()
end

function AC_UI.ImpExp_ExportAll_LAM:controlDef()
	-- Export To All Bags Button
	return
		{
			type = "button",
			name = SI_AC_MENU_UBS_BUTTON_EXPORT_TO_ALL_BAGS,
			tooltip = SI_AC_MENU_UBS_BUTTON_EXPORT_TO_ALL_BAGS_TOOLTIP,
			func = function() self:execute() end,
			width = "full",
		}
end
-- -------------------------------------------------------


-- customization of BaseDD for ImpExp_ImportBag_LAM
-- -------------------------------------------------------
function AC_UI.ImpExp_ImportBag_LAM:setValue(value)
	AC.logger:Info("ImportBag_LAM:setValue() value = "..value)
	self:select(value)
end

function AC_UI.ImpExp_ImportBag_LAM:controlDef()
	-- Import From Bag - AC_DROPDOWN_IMPORTBAG_BAG
	return
		{
			type = "dropdown",
			name = SI_AC_MENU_IBS_DROPDOWN_IMPORT_FROM_BAG,
			scrollable = false,
			tooltip = SI_AC_MENU_IBS_DROPDOWN_IMPORT_FROM_BAG_TOOLTIP,
			choices = self.cvt.choices,
			choicesValues = self.cvt.choicesValues,
			choicesTooltips = self.cvt.choicesTooltips,

			getFunc = function() return self:getValue() end,
			setFunc = function(value) 	self:setValue(value) end,
			default = AC_BAG_TYPE_BACKPACK,
			width = "half",
			reference = self:getControlName(),
		}

end
-- -------------------------------------------------------

-- customization of BaseUI for ImpExp_Import_LAM button
-- -------------------------------------------------------
function AC_UI.ImpExp_Import_LAM:execute()

	AC.logger:Info("ImpExp_Import_LAM:execute() started")
	local bagId = getCurrentBagId()
	local srcBagId = ImpExp_ImportBag_LAM:getValue()
	AC.logger:Info("ImpExp_Import_LAM:execute() cur bagId = "..bagId.." srcBagId = "..tostring(srcBagId))
	--saved.bags[bagId] = SF.safeClearTable(saved.bags[bagId])
	--saved.bags[bagId] = SF.deepCopy( saved.bags[srcBagId] )
	copyBagToBag(srcBagId, bagId)

	AC.logger:Info("ImpExp_Import_LAM:execute() finished copy, clearing indexes for BagSet and AddCat")
	BagSet_SelectRule_LAM:clearIndex()
	--reset add rule's selection, since all data will be changed.
	AddCat_SelectRule_LAM:clearIndex()
	AC.logger:Info("ImpExp_Import_LAM:execute() rebuild cache and refresh dropdowns/controls")

	AutoCategory.cacheInitialize()
	AC_UI.RefreshDropdownData()
	AC_UI.RefreshControls()
end

function AC_UI.ImpExp_Import_LAM:controlDef()
	-- Import Button
	return
		{
			type = "button",
			name = SI_AC_MENU_IBS_BUTTON_IMPORT,
			tooltip = SI_AC_MENU_IBS_BUTTON_IMPORT_TOOLTIP,
			func = function() self:execute() end,
			disabled = function()
				return getCurrentBagId() == ImpExp_ImportBag_LAM:getValue()
			end,
			width = "half",
		}
end
-- -------------------------------------------------------

-- customization of BaseDD for CatSet_SelectTag_LAM
-- -------------------------------------------------------
function AC_UI.CatSet_SelectTag_LAM:setValue(value)
	local oldvalue = self:getValue()
	if oldvalue == value then return end

	self:select(value)

	CatSet_SelectRule_LAM:assign(cache.rulesByTag_cvt[value])
	if currentRule.tag == value then
		CatSet_SelectRule_LAM:select(currentRule.name)
	end
	CatSet_SelectRule_LAM:refresh()
	CatSet_SelectRule_LAM:updateControl()

	AddCat_SelectTag_LAM:assign({choices=cache.tags})
	AddCat_SelectTag_LAM:updateControl()

	AddCat_SelectRule_LAM:updateControl()
end

function AC_UI.CatSet_SelectTag_LAM:refresh()
	if self:getValue() == nil then
		self:select(cache.tags)
	end
end

function AC_UI.CatSet_SelectTag_LAM:controlDef()
	return
		-- Tags - AC_DROPDOWN_EDITRULE_TAG
		{
			type = "dropdown",
			name = SI_AC_MENU_CS_DROPDOWN_TAG,
			tooltip = SI_AC_MENU_CS_DROPDOWN_TAG_TOOLTIP,
			scrollable = true,
			choices = self.cvt.choices,
			--choicesValues = self.cvt.choicesValues, 
			--choicesTooltips = self.cvt.choicesTooltips, 
			sort = "name-up",

			getFunc = function()
				return self:getValue()
			end,

			setFunc = function(value) self:setValue(value) end,
			width = "half",
			disabled = function() return CatSet_SelectTag_LAM:size() == 0 end,
			reference = self:getControlName(),
		}
end
-- -------------------------------------------------------


-- customization of BaseDD for CatSet_SelectRule_LAM
-- -------------------------------------------------------
function AC_UI.CatSet_SelectRule_LAM:getValue()
  return self.cvt.indexValue
end

function AC_UI.CatSet_SelectRule_LAM:refresh()
	local ltag = CatSet_SelectTag_LAM:getValue()
	if not ltag then return end

	-- dropdown lists for Edit Rule (Category) selection (AC_DROPDOWN_EDITRULE_RULE)
	local dataCurrentRules_EditRule = CVT:New(nil,nil,CVT.USE_TOOLTIPS)
	local oldndx = self:getValue()
	if cache.rulesByTag_cvt[ltag] then
		dataCurrentRules_EditRule:assign(cache.rulesByTag_cvt[ltag])
	end
	self:assign(dataCurrentRules_EditRule)
	if oldndx then
		self:select(oldndx)
	end
	if self:getValue() == nil then
		self:select({})	-- select first
	end
end

function AC_UI.CatSet_SelectRule_LAM:setValue(value)
	self:select(value)
	currentRule = AC.GetRuleByName(value)
	AC_UI.checkCurrentRule()
end

function AC_UI.CatSet_SelectRule_LAM:controlDef()
	-- Categories - AC_DROPDOWN_EDITRULE_RULE
	return
		{
			type = "dropdown",
			name = SI_AC_MENU_CS_DROPDOWN_CATEGORY,
			scrollable = true,
			choices = self.cvt.choices,
			--choicesValues =  self.cvt.choicesValues, 
			choicesTooltips =  self.cvt.choicesTooltips,
			sort = "name-up",

			getFunc = function()
				currentRule = AC.GetRuleByName(self:getValue())
				return self:getValue()
			end,
			setFunc = function(value) self:setValue(value) end,
			disabled = function() return self:size() == 0 end,
			width = "half",
			reference = self:getControlName(),
		}
end
-- -------------------------------------------------------

-- customization of BaseUI for CatSet_NewCat_LAM button
-- -------------------------------------------------------
function AC_UI.CatSet_NewCat_LAM:execute()
	local newName = AC.GetUsableRuleName(L(SI_AC_DEFAULT_NAME_NEW_CATEGORY))
	local tag = CatSet_SelectTag_LAM:getValue()
	if tag == "" then
		tag = AC_EMPTY_TAG_NAME
	end
	local newRule = AC.CreateNewRule(newName, tag)
	cache.AddRule(newRule)

	currentRule = newRule

	CatSet_SelectRule_LAM:refresh()
	CatSet_SelectRule_LAM:setValue(currentRule.name)
	CatSet_SelectRule_LAM:updateControl()

	CatSet_SelectTag_LAM:setValue(currentRule.tag)
	CatSet_SelectTag_LAM:refresh()
	CatSet_SelectTag_LAM:updateControl()

	AddCat_SelectTag_LAM:refresh()
	AddCat_SelectTag_LAM:updateControl()

	--AC_UI.RefreshDropdownData()
	AutoCategory.RecompileRules(AC.rules)
end

function AC_UI.CatSet_NewCat_LAM:controlDef()
	-- New Category Button
	return
		{
			type = "button",
			name = SI_AC_MENU_EC_BUTTON_NEW_CATEGORY,
			tooltip = SI_AC_MENU_EC_BUTTON_NEW_CATEGORY_TOOLTIP,
			func = function() self:execute() end,
			width = "half",
		}
end
-- -------------------------------------------------------

-- customization of BaseUI for CatSet_CopyCat_LAM button
-- -------------------------------------------------------
function AC_UI.CatSet_CopyCat_LAM:execute()
	local ruleName = CatSet_SelectRule_LAM:getValue()	-- source
	local tag = CatSet_SelectTag_LAM:getValue()
	if tag == "" then
		tag = AC_EMPTY_TAG_NAME
	end

	local srcRule = AC.GetRuleByName(ruleName)
	if not srcRule then return end

	local newRule = AC.CopyFrom(srcRule)
	cache.AddRule(newRule)

	currentRule = newRule

	CatSet_SelectTag_LAM:setValue(currentRule.tag)
	CatSet_SelectTag_LAM:refresh()

	CatSet_SelectRule_LAM:refresh()
	CatSet_SelectRule_LAM:setValue(currentRule.name)
	CatSet_SelectRule_LAM:updateControl()
	AC_UI.checkCurrentRule()


	AutoCategory.RecompileRules(AC.rules)
end

function AC_UI.CatSet_CopyCat_LAM:controlDef()
	-- Copy Category/Rule Button
	return
		{
			type = "button",
			name = SI_AC_MENU_EC_BUTTON_COPY_CATEGORY,
			tooltip = SI_AC_MENU_EC_BUTTON_COPY_CATEGORY_TOOLTIP,
			func = function() self:execute() end,
			disabled = function() return currentRule == nil end,
			width = "half",
		}

end
-- -------------------------------------------------------

-- customization of BaseUI for CatSet_NameEdit_LAM button
-- -------------------------------------------------------
function AC_UI.CatSet_NameEdit_LAM:getValue()
	if currentRule then
		return currentRule.name
	end
	return ""
end

function AC_UI.CatSet_NameEdit_LAM:setValue(value)
	local oldName = CatSet_SelectRule_LAM:getValue()
	if oldName == value then
		return
	end
	if value == "" then
		warningDuplicatedName.warningMessage = L(
			SI_AC_WARNING_CATEGORY_NAME_EMPTY)
		value = oldName
		return
	end

	local isDuplicated = cache.rulesByName[value] ~= nil
	if isDuplicated then
		warningDuplicatedName.warningMessage = string.format(
			L(SI_AC_WARNING_CATEGORY_NAME_DUPLICATED),
			value, AC.GetUsableRuleName(value))
		value = oldName
		--change editbox's value
		local control = WINDOW_MANAGER:GetControlByName("AC_EDITBOX_EDITRULE_NAME")
		control.editbox:SetText(value)
		return
	end

	AC.renameRule(currentRule.name, value)

	--Update drop downs
	AutoCategory.cacheInitialize()
	AC_UI.RefreshDropdownData()
	CatSet_SelectRule_LAM:select(value)
	AC_UI.RefreshControls()
end

function AC_UI.CatSet_NameEdit_LAM:controlDef()
	return
		-- Name EditBox - AC_EDITBOX_EDITRULE_NAME
		{
			type = "editbox",
			name = SI_AC_MENU_EC_EDITBOX_NAME,
			tooltip = SI_AC_MENU_EC_EDITBOX_NAME_TOOLTIP,
			getFunc = function() return self:getValue() end,
			warning = function()
				return warningDuplicatedName.warningMessage
			end,
			setFunc = function(value) self:setValue(value) end,
			isMultiline = false,
			disabled = function() return currentRule == nil or currentRule.pred == 1 end,
			width = "half",
			reference = self:getControlName(),
		}

end
-- -------------------------------------------------------

-- customization of BaseUI for CatSet_TagEdit_LAM button
-- -------------------------------------------------------
-- when a rule changes the tag name, we need to update the various lists tracking tags vs rules
-- returns the rule name, and a list of rules that belong to newtag
-- when parameters are bad, return nil,nil
function AC_UI.CatSet_TagEdit_LAM.changeTag(rule, oldtag, newtag)
	-- bad parameters
	if not rule or not rule.name or not newtag then return nil,nil end

	-- nothing needs changing
	if oldtag == newtag then return rule.name, cache.rulesByTag_cvt[rule.tag] end

	-- if tag is new, then update tags lists
	if not ZO_IsElementInNumericallyIndexedTable(cache.tags, newtag) then
		table.insert(cache.tags, newtag)
		-- create a new tag list if necessary
		cache.rulesByTag_cvt[newtag] = CVT:New(nil,nil,CVT.USE_TOOLTIPS)	--uses choicesTooltips
	end

	-- add the rule to the new tag list
	cache.rulesByTag_cvt[newtag]:append(rule.name, rule.name, rule:getDesc())
	-- remove the current rule from the oldtag list
	if oldtag and cache.rulesByTag_cvt[oldtag] then
		cache.rulesByTag_cvt[oldtag]:removeItemChoiceValue(rule.name)
		if cache.rulesByTag_cvt[oldtag]:size() == 0 then
			local ndx = ZO_IndexOfElementInNumericallyIndexedTable(cache.tags, oldtag)
			if ndx then
				table.remove(cache.tags, ndx)
			end
		end
	end
	rule.tag = newtag
	return rule.name, cache.rulesByTag_cvt[newtag]
end


function AC_UI.CatSet_TagEdit_LAM:getValue()
	if not currentRule then return "" end

	return currentRule.tag
end

function AC_UI.CatSet_TagEdit_LAM:setValue(value)
	if not currentRule then return end

	local oldtag = currentRule.tag

	if value == "" then
		value = L(AC_EMPTY_TAG_NAME)
		local control = WINDOW_MANAGER:GetControlByName("AC_EDITBOX_EDITRULE_TAG")
		control.editbox:SetText(value)
	end
	local _, rbyt = CatSet_TagEdit_LAM.changeTag(currentRule, oldtag, value)
	CatSet_SelectTag_LAM:select(currentRule.tag)
	CatSet_SelectRule_LAM:assign(rbyt)
	CatSet_SelectRule_LAM:select(currentRule.name)
	AddCat_SelectTag_LAM:select(currentRule.tag)
	AddCat_SelectRule_LAM:assign(AddCat_SelectRule_LAM.filterRules(getCurrentBagId(), value))
	AddCat_SelectRule_LAM:select(currentRule.name)
	AC_UI.RefreshControls()
end

function AC_UI.CatSet_TagEdit_LAM:controlDef()
	-- Tag EditBox - AC_EDITBOX_EDITRULE_TAG
	return
	{
		type = "editbox",
		name = SI_AC_MENU_EC_EDITBOX_TAG,
		tooltip = SI_AC_MENU_EC_EDITBOX_TAG_TOOLTIP,
		getFunc = function() return self:getValue() end,
		setFunc = function(value) self:setValue(value) end,
		isMultiline = false,
		disabled = function() return currentRule == nil or currentRule.pred == 1 end,
		width = "half",
		reference = self:getControlName(),
	}
end
-- -------------------------------------------------------

-- customization of BaseUI for CatSet_DeleteCat_LAM button
-- -------------------------------------------------------
function AC_UI.CatSet_DeleteCat_LAM:execute()
	local oldRuleName = CatSet_SelectRule_LAM:getValue()
	local ndx = cache.rulesByName[oldRuleName]
	if ndx then
		AC.logger:Debug("DeleteCat:execute - removing rule "..oldRuleName.." at "..tostring(ndx))
		table.remove(AC.rules,ndx)
		-- remove from the rule list that gets saved
		for i,v in pairs(AC.acctRules.rules) do
			if AC.acctRules.rules[i].name == oldRuleName then
				--AC.logger:Debug("removing acctRule "..oldRuleName.." at "..tostring(i))
				table.remove(AC.acctRules.rules,i)
				break
			end
		end
		AC.logger:Debug("DeleteCat:execute - rebuilding rule cache tables "..currentRule.name)
		AC.cacheRuleInitialize()
		--AC.logger:Debug("DeleteCat:execute - refreshing dropdown tables "..currentRule.name)
		--AC_UI.RefreshDropdownData()
	end

	if oldRuleName == AddCat_SelectRule_LAM:getValue() then
		--rule removed, clean selection in add rule menu if selected
		AddCat_SelectRule_LAM:clearIndex()
	end

	-- removing the rule from any bags
	local bagId
	for bagId = 1,6 do
		local savedbag = saved.bags[bagId]
		--AC.logger:Debug("removing rule "..currentRule.name.." from bagrules "..bagId)
		for i = 1, #savedbag.rules do
			local bagEntry = savedbag.rules[i]
			if bagEntry.name == oldRuleName then
				--AC.logger:Debug("found bagrule to delete ")
				table.remove(savedbag.rules, i)
				break
			end
		end
	end
	--AC.logger:Debug("removing from BagSet_SelectRule CVT")
	BagSet_SelectRule_LAM.cvt:removeItemChoiceValue(oldRuleName)
	if BagSet_SelectRule_LAM:getValue() == nil and BagSet_SelectRule_LAM:size() > 0 then
		BagSet_SelectRule_LAM:select({}) 	-- select first
	end
	BagSet_SelectRule_LAM:refresh()


	currentRule = nil
	--AC_UI.checkCurrentRule()
	CatSet_SelectRule_LAM:clearIndex()
	if CatSet_SelectRule_LAM:size() > 0 then
		CatSet_SelectRule_LAM:select({})
	end

	--AC.logger:Debug("refreshing all the tables and controls")

	AutoCategory.cacheBagInitialize()
	BagSet_SelectRule_LAM:refresh()
	AddCat_SelectRule_LAM:refresh()
	AC_UI.RefreshDropdownData()
	AC_UI.RefreshControls()
end

function AC_UI.CatSet_DeleteCat_LAM:controlDef()
	-- Delete Category/Rule Button
	return
		{
			type = "button",
			name = SI_AC_MENU_EC_BUTTON_DELETE_CATEGORY,
			tooltip = SI_AC_MENU_EC_BUTTON_DELETE_CATEGORY_TOOLTIP,
			isDangerous = true,
			func = function()  self:execute() end,
			width = "half",
			disabled = function() return currentRule == nil or currentRule.pred == 1 end,
		}
end
-- -------------------------------------------------------


local function editCat_getPredef()
    if currentRule and currentRule.pred == 1 then
        return L(SI_AC_MENU_EC_BUTTON_PREDEFINED)

    else
        return ""
    end
end

-- -------------------------------------------------------
local ruleCheckStatus = {}

function ruleCheckStatus.getTitle()
    if ruleCheckStatus.err == nil then
        if ruleCheckStatus.good == nil then
            return ""

        else
            return L(SI_AC_MENU_EC_BUTTON_CHECK_RESULT_GOOD)
        end

    else
        if not currentRule.damaged then
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

function AC_UI.checkCurrentRule()
    ruleCheckStatus.err = nil
    ruleCheckStatus.good = nil
    if currentRule == nil then
        return
    end

    if currentRule.rule == nil or currentRule.rule == "" then
		currentRule:setError(true,"Rule definition cannot be empty")
		ruleCheckStatus.err = currentRule.err
        return
    end

    local _, err = zo_loadstring("return("..currentRule.rule..")")
    if err then
		ruleCheckStatus.err = err
        currentRule.damaged = true
		currentRule.err = err

    else
        local errt = checkKeywords(currentRule.rule)
        if #errt == 0 then
            ruleCheckStatus.good = true
            currentRule.damaged = nil

        else
            ruleCheckStatus.err = table.concat(errt,", ")
            currentRule.damaged = nil
        end
    end
end

local function UpdateDuplicateNameWarning()
	local control = WINDOW_MANAGER:GetControlByName("AC_EDITBOX_EDITRULE_NAME", "")
	if control then
		control:UpdateWarning()
	end
end

-- -------------------------------------------------------

function AC_UI.RefreshDropdownData()

	-- refresh selections
	BagSet_SelectBag_LAM:refresh()
	AddCat_SelectTag_LAM:refresh()
	CatSet_SelectTag_LAM:refresh()

	--refresh current dropdown rules
	BagSet_SelectRule_LAM:refresh()
	AddCat_SelectRule_LAM:refresh()
	CatSet_SelectRule_LAM:refresh()
end

-- updates the LAM cvt lists from our BaseDD objects
local RCpending = false
function AC_UI.RefreshControls()
	local waittime = 500
	if RCPending then return end

	RCpending = true

	zo_callLater(function()
		BagSet_SelectRule_LAM:updateControl()

		AddCat_SelectTag_LAM:updateControl()
		AddCat_SelectRule_LAM:updateControl()

		CatSet_SelectTag_LAM:updateControl()
		CatSet_SelectRule_LAM:updateControl()
		RCPending = false
	end, waitTime)
end


-- ------------------------------------------------------

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

	container:SetHeight(MIN_HEIGHT * lines)
	control:SetHeight((MIN_HEIGHT * lines) + control.label:GetHeight())

	return true
end

function AC_UI.ToggleSubmenu(typeString, open)
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

-- aliases
local GetUsableRuleName = AC.GetUsableRuleName
local CreateNewRule = AC.CreateNewRule
local CreateNewBagRule = AC.CreateNewBagRule

-- -------------------------------------------------------
local function CreatePanel()
	return {
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

			--AC.logger:Debug("panel: initial bagid = "..tostring(getCurrentBagId()))
			BagSet_SelectBag_LAM:select(AC_BAG_TYPE_BACKPACK)
			--AC.logger:Debug("panel: new bagid = "..tostring(getCurrentBagId()))
            BagSet_SelectRule:clearIndex()
			AddCat_SelectTag_LAM:clearIndex()
			AddCat_SelectRule_LAM:clearIndex()
			CatSet_SelectTag_LAM:clearIndex()
			CatSet_SelectRule_LAM:clearIndex()

			AC_UI.RefreshDropdownData()
			AC_UI.RefreshControls()
			--AC.logger:Debug("panel: final bagid = "..tostring(getCurrentBagId()))
		end,
	}
end



function AutoCategory.AddonMenuInit()
    AC.cacheInitialize()

    -- initialize tables
	BagSet_SelectBag_LAM:assign(cache.bags_cvt)
	--BagSet_SelectBag_LAM:select(cache.bags_cvt.choicesValues)
	AddCat_SelectTag_LAM:assign( { choices=cache.tags }) --, choicesTooltips=cache.tags})

    -- AddCat_SelectRule_LAM will get populated by RefreshDropdownData()
	AddCat_SelectRule_LAM:clear()

	CatSet_SelectTag_LAM:assign( { choices=cache.tags})

	ImpExp_ImportBag_LAM:assign(cache.bags_cvt)

	AC_UI.RefreshDropdownData()
	AC_UI.RefreshControls()

	local panelData = CreatePanel()


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

				--AC.logger:Debug("initial bagid = "..tostring(getCurrentBagId()))
				BagSet_SelectBag_LAM:select(AC_BAG_TYPE_BACKPACK)
				--AC.logger:Debug("final bagid = "..tostring(getCurrentBagId()))
                BagSet_SelectRule_LAM:clearIndex()
                AddCat_SelectTag_LAM:clearIndex()
                AddCat_SelectRule_LAM:clearIndex()
                CatSet_SelectTag_LAM:clearIndex()
                CatSet_SelectRule_LAM:clearIndex()
                ruleCheckStatus.err = nil
                ruleCheckStatus.good = nil

                AC_UI.RefreshDropdownData()
				AC_UI.RefreshControls()
            end,
        },
        divider(),
        -- Bag Settings
		{
			type = "submenu",
		    name = SI_AC_MENU_SUBMENU_BAG_SETTING, -- or string id or function returning a string
			reference = "AC_SUBMENU_BAG_SETTING",
		    controls = {
				-- Select bag
				BagSet_SelectBag_LAM:controlDef(),

                -- Hide ungrouped in bag Checkbox
				BagSet_HideOther_LAM:controlDef(),

                divider(),

				-- Rule name   - AC_DROPDOWN_EDITBAG_RULE
				BagSet_SelectRule_LAM:controlDef(),

				-- Priority Slider
				BagSet_Priority_LAM:controlDef(),

                -- Hide Category Checkbox
				BagSet_HideCat_LAM:controlDef(),
				-- blank "pad" for Hide Category button
				{
					type = "custom",
					width = "half",
				},

                -- Edit Category Button
				BagSet_EditCat_LAM:controlDef(),
                -- Remove Category from Bag Button
				BagSet_RemoveCat_LAM:controlDef(),
                -- Add Category to Bag Section
				header(SI_AC_MENU_HEADER_ADD_CATEGORY),
                -- Select Tag Dropdown - AC_DROPDOWN_ADDCATEGORY_TAG
				AddCat_SelectTag_LAM:controlDef(),
                -- Categories currently unused dropdown - AC_DROPDOWN_ADDCATEGORY_RULE
				AddCat_SelectRule_LAM:controlDef(),
                -- Edit Rule Category Button
				AddCat_EditRule_LAM:controlDef(),
                -- Add to Bag Button
				AddCat_BagAdd_LAM:controlDef(),

				divider(),
                -- Import/Export Bag Settings
				{
					type = "submenu",
					name = SI_AC_MENU_SUBMENU_IMPORT_EXPORT,
					reference = "SI_AC_MENU_SUBMENU_IMPORT_EXPORT",
					controls = {
						header(SI_AC_MENU_HEADER_UNIFY_BAG_SETTINGS),
						-- Export To All Bags Button
						ImpExp_ExportAll_LAM:controlDef(),
						header(SI_AC_MENU_HEADER_IMPORT_BAG_SETTING),
                        -- Import From Bag - AC_DROPDOWN_IMPORTBAG_BAG
						ImpExp_ImportBag_LAM:controlDef(),

                        -- Import Button
						ImpExp_Import_LAM:controlDef(),
					},
				},
				divider(),
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
                -- Select Existing Description
				description("Select Existing Category:"),
                -- Tags - AC_DROPDOWN_EDITRULE_TAG
				CatSet_SelectTag_LAM:controlDef(),
                -- Categories - AC_DROPDOWN_EDITRULE_RULE
				CatSet_SelectRule_LAM:controlDef(),
                -- Create/Copy a New Category Description
				description("Create/Copy a new Category:"),

                -- New Category Button
				CatSet_NewCat_LAM:controlDef(),
				-- Copy Category/Rule Button
				CatSet_CopyCat_LAM:controlDef(),

                -- Learn Rules button
				{
					type = "button",
					name = SI_AC_MENU_EC_BUTTON_LEARN_RULES,
					func = function() RequestOpenUnsafeURL("https://github.com/Shadowfen/AutoCategory/wiki/Creating-Custom-Categories") end,
					width = "half",
				},
                -- Delete Category/Rule Button
				AC_UI.CatSet_DeleteCat_LAM:controlDef(),
                -- Edit Category Title
				header(SI_AC_MENU_HEADER_EDIT_CATEGORY),
                -- Predefined Text Description
                {
                    type = "description",
                    text = editCat_getPredef, -- or string id or function returning a string
                    --title = SI_AC_MENU_EC_BUTTON_PREDEFINED, -- or string id or function returning a string (optional)
                    width = "full", --or "half" (optional)
                },
                -- Name EditBox - AC_EDITBOX_EDITRULE_NAME
				CatSet_NameEdit_LAM:controlDef(),
                -- Tag EditBox - AC_EDITBOX_EDITRULE_TAG
				CatSet_TagEdit_LAM:controlDef(),
                --Description EditBox
				{
					type = "editbox",
					name = SI_AC_MENU_EC_EDITBOX_DESCRIPTION,
					tooltip = SI_AC_MENU_EC_EDITBOX_DESCRIPTION_TOOLTIP,
					getFunc = function()
                        if currentRule then
                            return currentRule.description
                        end
                        return ""
					end,
					setFunc = function(value)
                        local oldval = currentRule.description
                        currentRule.description = value
                        if oldval ~= value then
                            AC.cacheInitialize() -- reset tooltips to new value
                            AC_UI.RefreshDropdownData()
							AC_UI.RefreshControls()
                        end
					end,
					isMultiline = false,
					isExtraWide = true,
					disabled = function() return currentRule == nil or currentRule.pred == 1 end,
					width = "full",
					reference = "AC_EDITBOX_EDITRULE_DESC",
				},
                -- Rule EditBox
				{
					type = "editbox",
					name = SI_AC_MENU_EC_EDITBOX_RULE,
					tooltip = SI_AC_MENU_EC_EDITBOX_RULE_TOOLTIP,
					getFunc = function()
                        if currentRule then
                            return currentRule.rule
                        end
                        ruleCheckStatus.err = nil
                        ruleCheckStatus.good = nil
                        return ""
					end,
					setFunc = function(value)
                        currentRule.rule = value
                        ruleCheckStatus.err = currentRule:compile()
                        if ruleCheckStatus.err == "" then
                            ruleCheckStatus.err = nil
                            ruleCheckStatus.good = true

                        else
                            ruleCheckStatus.good = nil
                        end
                        end,
					isMultiline = true,
					isExtraWide = true,
					disabled = function() return currentRule == nil or currentRule.pred == 1 end,
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
                        --local ruleName = currentRule.name
                        AC_UI.checkCurrentRule()
                    end,
					disabled = function() return currentRule == nil or currentRule.pred == 1 end,
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
				description(SF.ColorText(L(SI_AC_MENU_AS_DESCRIPTION_REFRESH_TIP), SF.hex.mocassin)),
                divider(),
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
						AC.resetface()
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
                    choices = dropdownFontAlignment.choices,
                    choicesValues = dropdownFontAlignment.choicesValues,
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
				description(SF.ColorText(L(SI_AC_MENU_GMS_DESCRIPTION_TIP), SF.hex.mocassin)),
                divider(),
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