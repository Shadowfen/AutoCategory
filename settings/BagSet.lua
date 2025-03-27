local AC = AutoCategory
local SF = LibSFUtils

local aclogger  -- set when the init is called

local L = GetString
local CVT = AutoCategory.CVT

--cache data for dropdown: 
AutoCategory.cache.bags_cvt.choices = {
	L(SI_AC_BAGTYPE_SHOWNAME_BACKPACK),
	L(SI_AC_BAGTYPE_SHOWNAME_BANK),
	L(SI_AC_BAGTYPE_SHOWNAME_GUILDBANK),
	L(SI_AC_BAGTYPE_SHOWNAME_CRAFTBAG),
	L(SI_AC_BAGTYPE_SHOWNAME_CRAFTSTATION),
	L(SI_AC_BAGTYPE_SHOWNAME_HOUSEBANK),
}
AutoCategory.cache.bags_cvt.choicesValues = {
	AC_BAG_TYPE_BACKPACK,
	AC_BAG_TYPE_BANK,
	AC_BAG_TYPE_GUILDBANK,
	AC_BAG_TYPE_CRAFTBAG,
	AC_BAG_TYPE_CRAFTSTATION,
	AC_BAG_TYPE_HOUSEBANK,
}
AutoCategory.cache.bags_cvt.choicesTooltips = {
	L(SI_AC_BAGTYPE_TOOLTIP_BACKPACK),
	L(SI_AC_BAGTYPE_TOOLTIP_BANK),
	L(SI_AC_BAGTYPE_TOOLTIP_GUILDBANK),
	L(SI_AC_BAGTYPE_TOOLTIP_CRAFTBAG),
	L(SI_AC_BAGTYPE_TOOLTIP_CRAFTSTATION),
	L(SI_AC_BAGTYPE_TOOLTIP_HOUSEBANK),
}


local BagSet_SelectBag_LAM = AC.BaseDD:New("AC_DROPDOWN_EDITBAG_BAG", AC_BAG_TYPE_BACKPACK, CVT.USE_VALUES + CVT.USE_TOOLTIPS)
AC_UI.BagSet_SelectBag_LAM = BagSet_SelectBag_LAM

-- local to this screen
local BagSet_HideOther_LAM = AC.BaseUI:New("AC_CHECKBOX_HIDEOTHER")	-- checkbox
AC_UI.BagSet_HideOther_LAM = BagSet_HideOther_LAM

local BagSet_SelectRule_LAM = AC.BaseDD:New("AC_DROPDOWN_EDITBAG_RULE", nil, CVT.USE_VALUES + CVT.USE_TOOLTIPS)
AC_UI.BagSet_SelectRule_LAM = BagSet_SelectRule_LAM

-- local to this screen
local BagSet_Priority_LAM = AC.BaseUI:New()		-- slider
AC_UI.BagSet_Priority_LAM = BagSet_Priority_LAM		-- slider

-- local to this screen
local BagSet_HideCat_LAM = AC.BaseUI:New()		-- checkbox
AC_UI.BagSet_HideCat_LAM = BagSet_HideCat_LAM

-- local to this screen
local BagSet_EditCat_LAM = AC.BaseUI:New()	-- button
AC_UI.BagSet_EditCat_LAM = BagSet_EditCat_LAM

-- local to this screen
local bagSet_RemoveCat_LAM = AC.BaseUI:New()	-- button
--AC_UI.BagSet_RemoveCat_LAM = bagSet_RemoveCat_LAM

-- AC_UI.BagSet_OrderCat_LAM is defined in OrderListUI.lua
--local BagSet_OrderCat_LAM = AC_UI.BagSet_OrderCat_LAM
-- AC_UI.BagSet_DisplayCat_LAM is defined in DisplayListUI.lua
--local BagSet_DisplayCat_LAM = AC_UI.BagSet_DisplayCat_LAM

local AddCat_SelectTag_LAM = AC.BaseDD:New("AC_DROPDOWN_ADDCATEGORY_TAG")	-- only uses choices
AC_UI.AddCat_SelectTag_LAM = AddCat_SelectTag_LAM

local AddCat_SelectRule_LAM = AC.BaseDD:New("AC_DROPDOWN_ADDCATEGORY_RULE",nil ,CVT.USE_TOOLTIPS) -- uses choicesTooltips
AC_UI.AddCat_SelectRule_LAM = AddCat_SelectRule_LAM

-- local to this screen
local AddCat_EditRule_LAM = AC.BaseUI:New()	-- button
AC_UI.AddCat_EditRule_LAM = AddCat_EditRule_LAM

-- local to this screen
local AddCat_BagAdd_LAM = AC.BaseUI:New()	-- button
AC_UI.AddCat_BagAdd_LAM = AddCat_BagAdd_LAM

-- local to this screen
local ImpExp_ExportAll_LAM = AC.BaseUI:New()	-- button
AC_UI.ImpExp_ExportAll_LAM = ImpExp_ExportAll_LAM	-- button

-- local to this screen
local ImpExp_ImportBag_LAM = AC.BaseDD:New("AC_DROPDOWN_IMPORTBAG_BAG", nil, CVT.USE_VALUES + CVT.USE_TOOLTIPS)
AC_UI.ImpExp_ImportBag_LAM = ImpExp_ImportBag_LAM

-- local to this screen
local ImpExp_Import_LAM = AC.BaseUI:New()	-- button
AC_UI.ImpExp_Import_LAM = ImpExp_Import_LAM


AC_UI.BagSet = {}

local currentBagRule = nil
local function CatSet_DisplayRule(rule)
	AC_UI.CatSet_SelectTag_LAM:refresh()
	--AC_UI.CatSet_SelectTag_LAM:setValue(rule.tag)

	AC_UI.CatSet_SelectRule_LAM:refresh()
	AC_UI.CatSet.setRule(rule)		-- sets tag and name
	--AC_UI.CatSet_SelectRule_LAM:setValue(rule.name)
	AC_UI.CatSet_SelectRule_LAM:updateControl()

	currentRule = rule
	AC_UI.checkCurrentRule()
end

local function getCurrentBagId()
	return BagSet_SelectBag_LAM:getValue()
end
AutoCategory.getCurrentBagId = getCurrentBagId   -- make available

-- returns the current bagSetting table (or nil if the bag was not found)
-- if parameter bagId is nil then get the current bagId from BagSet
-- bagSetting table = {isOtherHidden, {rules{name, priority, isHidden}} }
local function getBagSettings(bagId)
	if not bagId then bagId = getCurrentBagId() end
	local saved = AutoCategory.saved
	if saved and saved.bags then
		return saved.bags[bagId]	-- still might be nil
	end
	return nil
end



-- customization of BaseDD for BagSet_SelectBag_LAM
-- ------------------------------------------------
AC_UI.BagSet_SelectBag_LAM.defaultVal = AC_BAG_TYPE_BACKPACK

-- refresh the selection value of the cvt lists for BagSet_SelectBag_LAM from the 
-- current contents of the cache.bags_cvt list.
function AC_UI.BagSet_SelectBag_LAM:refresh()
	if self:getValue() == nil then
		self:select(AutoCategory.cache.bags_cvt.choicesValues)
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
	if not bs then return end

	-- value will always be a valid cvt value, so we don't need to check CVT lists first
	self.cvt.indexValue = value
	-- we don't need to add/remove for the CVT as those lists are static

	BagSet_HideOther_LAM:setValue(SF.nilDefault(bs.isUngroupedHidden, false))

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

			getFunc = function() return self:getValue() end,
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
	if bag and ruleNm and AutoCategory.cache.entriesByName[bag][ruleNm] then
		return AutoCategory.cache.entriesByName[bag][ruleNm].isHidden or false
	end
	return 0
end

function AC_UI.BagSet_HideCat_LAM:setValue(value)
	local bag = getCurrentBagId()
	local ruleNm = currentBagRule or BagSet_SelectRule_LAM:getValue()
	if AutoCategory.cache.entriesByName[bag][ruleNm] then
		local isHidden = AutoCategory.cache.entriesByName[bag][ruleNm].isHidden or false
		if isHidden ~= value then
			if not value then value = nil end

			AutoCategory.cache.entriesByName[bag][ruleNm].isHidden = value
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

	--aclogger:Debug("SelectRule:refresh: Updating cvt lists for BagSet_SelectRule for bag "..tostring(currentBag))
	do
		-- dropdown lists for Edit Bag Rules selection (AC_DROPDOWN_EDITBAG_BAG)
		local dataCurrentRules_EditBag = CVT:New(self.controlName,nil, CVT.USE_VALUES + CVT.USE_TOOLTIPS)
		if currentBag and AutoCategory.cache.entriesByBag[currentBag] then
			--aclogger:Debug("SelectRule:refresh: Getting rules for bag "..tostring(currentBag))
			dataCurrentRules_EditBag:assign(AutoCategory.cache.entriesByBag[currentBag])
		end
		self:assign(dataCurrentRules_EditBag)
	end
	if not ndx then 
		self:select({})
	else
		self:select(ndx)
	end
	self:setValue(self:getValue())
	--aclogger:Debug("SelectRule:refresh: Done updating cvt lists for BagSet_SelectRule for bag "..tostring(currentBag))
end

-- set the selection of the BagSet_SelectRule_LAM field
function AC_UI.BagSet_SelectRule_LAM:setValue(val)
	if not val then return end
	
	self:select(val)
	currentBagRule = val
	local bagrule = AutoCategory.cache.entriesByName[getCurrentBagId()][val]
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
BagSet_Priority_LAM.maxVal = 1000
BagSet_Priority_LAM.minVal = 2

function AC_UI.BagSet_Priority_LAM:getValue()
	local bag = getCurrentBagId()
	local bagrule = currentBagRule --BagSet_SelectRule_LAM:getValue()
	if bag and bagrule and AutoCategory.cache.entriesByName[bag][bagrule] then
		return AutoCategory.cache.entriesByName[bag][bagrule].priority
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
	local ruleName = currentBagRule or AC_UI.BagSet_SelectRule_LAM:getValue()
	if ruleName == nil then return end

	if AutoCategory.cache.entriesByName[bag][ruleName] then
		if AutoCategory.cache.entriesByName[bag][ruleName].priority == value then return end
		--local bagrule = AutoCategory.cache.entriesByName[bag][ruleName]
		AutoCategory.cache.entriesByName[bag][ruleName].priority = value
		AutoCategory.cacheInitialize()
		AC_UI.CatSet_SelectRule_LAM:setValue(ruleName)
		BagSet_SelectRule_LAM:setValue(ruleName)
		BagSet_SelectRule_LAM:refresh()
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
	local ruleName = currentBagRule or BagSet_SelectRule_LAM:getValue()
	local rule = AutoCategory.GetRuleByName(ruleName)
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

-- customization of BaseUI for bagSet_RemoveCat_LAM Button
-- ----------------------------------------------------------
function bagSet_RemoveCat_LAM:execute()
	local bagId = getCurrentBagId()
	local ruleName = currentBagRule or BagSet_SelectRule_LAM:getValue()
	local savedbag = AutoCategory.saved.bags[bagId]
	--aclogger:Debug("Removing rule name "..ruleName)
	for i = 1, #savedbag.rules do
		local bagEntry = savedbag.rules[i]
		if bagEntry.name == ruleName then
			--aclogger:Debug("Found it! - "..ruleName)
			table.remove(savedbag.rules, i)
			break
		end
	end
	BagSet_SelectRule_LAM.cvt:removeItemChoiceValue(ruleName)
	if BagSet_SelectRule_LAM:getValue() == nil and BagSet_SelectRule_LAM:size() > 0 then
		BagSet_SelectRule_LAM:select({}) 	-- select first
	end

	AutoCategory.cacheBagInitialize()
	BagSet_SelectRule_LAM:refresh()
	AddCat_SelectRule_LAM:refresh()
	AC_UI.RefreshControls()
end

function bagSet_RemoveCat_LAM:controlDef()
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


-- ----------------------------------------------------------

-- customization of BaseDD for AddCat_SelectTag_LAM
-- ----------------------------------------------------------
-- refresh the selection value of the cvt lists for AddCat_SelectTag_LAM from the 
-- current contents of the RulesW.tags list.
function AC_UI.AddCat_SelectTag_LAM:refresh()
	if self:getValue() == nil or self:getValue() == "" then
		self:select(AutoCategory.RulesW.tags)
	end
end

function AC_UI.AddCat_SelectTag_LAM:setValue(value)
	local oldvalue = self:getValue()
	if oldvalue == value then return end

	self.cvt.indexValue = value

	AddCat_SelectRule_LAM:clearIndex()
	AddCat_SelectRule_LAM:assign(AddCat_SelectRule_LAM.filterRules(getCurrentBagId(),value))
	AddCat_SelectRule_LAM:refresh()
	AC_UI.RefreshControls()
end

function AC_UI.AddCat_SelectTag_LAM:controlDef()
	return
		{
			type = "dropdown",
			name = SI_AC_MENU_AC_DROPDOWN_TAG,
			scrollable = true,
			choices = self.cvt.choices,
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

-- returns a CVT of all of the known rules of a tag (group) that are not already in the bag
-- will return empty CVT if no rules match the filter
function AC_UI.AddCat_SelectRule_LAM.filterRules(bagId, tag)
	local cache = AutoCategory.cache
	if not bagId or not tag then return nil end
	if not cache.entriesByName[bagId] then
		cache.entriesByName[bagId] = SF.safeTable(cache.entriesByName[bagId] )
	end

	-- filter out already-in-use rules from the "add category" list for bag rules
	local dataCurrentRules_AddCategory = CVT:New(AddCat_SelectRule_LAM:getControlName(), nil, CVT.USE_TOOLTIPS) -- uses choicesTooltips
	if not AutoCategory.RulesW.tagGroups[tag] then
		-- no rules available for tag
		return dataCurrentRules_AddCategory
	end

	local rbyt = AutoCategory.RulesW.tagGroups[tag]
	for i = 1, rbyt:size() do
		local value = rbyt.choices[i]
		if value and cache.entriesByName[bagId][value] == nil then
			--add the rule if not in bag
			dataCurrentRules_AddCategory:append(rbyt.choices[i], nil, rbyt.choicesTooltips[i])
		end
	end
	return dataCurrentRules_AddCategory
end

-- refresh the selection value of the cvt lists for AddCat_SelectRule_LAM from the 
-- output of the filterRules().
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
	local rule = AutoCategory.GetRuleByName(ruleName)
	if not rule then return end

	CatSet_DisplayRule(rule)
	AC_UI.RefreshDropdownData()
	currentRule = rule
	AC_UI.CatSet_SelectTag_LAM:setValue(rule.tag)
	AC_UI.CatSet_SelectTag_LAM:refresh()
	--AC_UI.CatSet_SelectTag_LAM:updateControl()

	AC_UI.checkCurrentRule()
	AC_UI.RefreshDropdownData()
	AC_UI.CatSet_SelectRule_LAM:refresh()
	AC_UI.CatSet_SelectRule_LAM:setValue(rule.name)
	--AC_UI.CatSet_SelectRule_LAM:updateControl()

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
	assert(AutoCategory.cache.entriesByName[bagId][ruleName] == nil, "Bag(" .. bagId .. ") already has the rule: ".. ruleName)

	if AutoCategory.cache.entriesByName[bagId][ruleName] then return end

	local saved = AutoCategory.saved
	local entry = AutoCategory.CreateNewBagRule(ruleName)
	saved.bags[bagId].rules[#saved.bags[bagId].rules+1] = entry
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
	AutoCategory.saved.bags[destBagId] = SF.deepCopy( AutoCategory.saved.bags[srcBagId] )
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

	local bagId = getCurrentBagId()
	local srcBagId = ImpExp_ImportBag_LAM:getValue()
	copyBagToBag(srcBagId, bagId)

	BagSet_SelectRule_LAM:clearIndex()
	--reset add rule's selection, since all data will be changed.
	AddCat_SelectRule_LAM:clearIndex()

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

function AC_UI.BagSet.controlDef()
	-- Bag Settings Section Submenu
	return {
		type = "submenu",
		name = SI_AC_MENU_SUBMENU_BAG_SETTING, -- or string id or function returning a string
		reference = "AC_SUBMENU_BAG_SETTING",
		controls = {
			-- Select bag
			BagSet_SelectBag_LAM:controlDef(),

			-- Hide ungrouped in bag Checkbox
			BagSet_HideOther_LAM:controlDef(),

			AC_UI.divider(),

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
			bagSet_RemoveCat_LAM:controlDef(),

			--AC_UI.BagSet_OrderCat_LAM:controlDef(),

			-- Add Category to Bag Section
			AC_UI.header(SI_AC_MENU_HEADER_ADD_CATEGORY),
			-- Select Tag Dropdown - AC_DROPDOWN_ADDCATEGORY_TAG
			AC_UI.AddCat_SelectTag_LAM:controlDef(),
			-- Categories currently unused dropdown - AC_DROPDOWN_ADDCATEGORY_RULE
			AddCat_SelectRule_LAM:controlDef(),
			-- Edit Rule Category Button
			AddCat_EditRule_LAM:controlDef(),
			-- Add to Bag Button
			AddCat_BagAdd_LAM:controlDef(),

			--AC_UI.divider(),
			--AC_UI.BagSet_DisplayCat_LAM:controlDef(),

			AC_UI.divider(),
			-- Import/Export Bag Settings
			{
				type = "submenu",
				name = SI_AC_MENU_SUBMENU_IMPORT_EXPORT,
				reference = "SI_AC_MENU_SUBMENU_IMPORT_EXPORT",
				controls = {
					AC_UI.header(SI_AC_MENU_HEADER_UNIFY_BAG_SETTINGS),

					-- Export To All Bags Button
					ImpExp_ExportAll_LAM:controlDef(),
					AC_UI.header(SI_AC_MENU_HEADER_IMPORT_BAG_SETTING),

					-- Import From Bag - AC_DROPDOWN_IMPORTBAG_BAG
					ImpExp_ImportBag_LAM:controlDef(),

					-- Import Button
					ImpExp_Import_LAM:controlDef(),
				},
			},
			AC_UI.divider(),
			-- Need Help button
			{
				type = "button",
				name = SI_AC_MENU_AC_BUTTON_NEED_HELP,
				func = function() RequestOpenUnsafeURL("https://github.com/Shadowfen/AutoCategory/wiki/Tutorial") end,
				width = "full",
			},
		},
	}
end	

function AC_UI.BagSet.clear()				
	AC_UI.BagSet_SelectBag_LAM:select(AC_BAG_TYPE_BACKPACK)
	AC_UI.BagSet_SelectRule_LAM:clearIndex()
	AC_UI.AddCat_SelectTag_LAM:clearIndex()
	AC_UI.AddCat_SelectRule_LAM:clearIndex()
end

function AC_UI.BagSet.refresh()
	-- refresh selections
	AC_UI.BagSet_SelectBag_LAM:refresh()
	AC_UI.AddCat_SelectTag_LAM:refresh()

	--refresh current dropdown rules
	AC_UI.BagSet_SelectRule_LAM:refresh()
	AC_UI.AddCat_SelectRule_LAM:refresh()
	
end

function AC_UI.BagSet.SelectRule(name)
	AC_UI.BagSet_SelectRule_LAM:refresh()
	AC_UI.BagSet_SelectRule_LAM:setValue(name)
	AC_UI.BagSet_SelectRule_LAM:updateControl()
end

function AC_UI.BagSet.updateControls()
	BagSet_SelectRule_LAM:updateControl()

	AddCat_SelectTag_LAM:updateControl()
	AC_UI.AddCat_SelectRule_LAM:refresh()
	AddCat_SelectRule_LAM:updateControl()
end


function AC_UI.BagSet.Init()
	aclogger = AutoCategory.logger

    -- initialize tables
	AC_UI.BagSet_SelectBag_LAM:assign(AutoCategory.cache.bags_cvt)
	AC_UI.AddCat_SelectTag_LAM:assign( { choices=AutoCategory.RulesW.tags } )

	AC_UI.BagSet_SelectBag_LAM:select({})

    -- AddCat_SelectRule_LAM will get populated by RefreshDropdownData()
	AddCat_SelectRule_LAM:clear()

	ImpExp_ImportBag_LAM:assign(AutoCategory.cache.bags_cvt)
end


