
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

-- AC_UI.BagSet_OrderCat_LAM is defined in OrderListUI.lua
--local BagSet_OrderCat_LAM = AC_UI.BagSet_OrderCat_LAM
-- AC_UI.BagSet_DisplayCat_LAM is defined in DisplayListUI.lua
--local BagSet_DisplayCat_LAM = AC_UI.BagSet_DisplayCat_LAM


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

	aclogger:Debug("SelectRule:refresh: Updating cvt lists for BagSet_SelectRule for bag "..tostring(currentBag))
	do
		-- dropdown lists for Edit Bag Rules selection (AC_DROPDOWN_EDITBAG_BAG)
		local dataCurrentRules_EditBag = CVT:New(self.controlName,nil, CVT.USE_VALUES + CVT.USE_TOOLTIPS)
		if currentBag and AutoCategory.cache.entriesByBag[currentBag] then
			aclogger:Debug("SelectRule:refresh: Getting rules for bag "..tostring(currentBag))
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
	aclogger:Debug("SelectRule:refresh: Done updating cvt lists for BagSet_SelectRule for bag "..tostring(currentBag))
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
AC_UI.BagSet_Priority_LAM.maxVal = 1000
AC_UI.BagSet_Priority_LAM.minVal = 2

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
		CatSet_SelectRule_LAM:setValue(ruleName)
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

-- customization of BaseUI for BagSet_RemoveCat_LAM Button
-- ----------------------------------------------------------
function AC_UI.BagSet_RemoveCat_LAM:execute()
	local bagId = getCurrentBagId()
	local ruleName = currentBagRule or BagSet_SelectRule_LAM:getValue()
	local savedbag = AutoCategory.saved.bags[bagId]
	aclogger:Debug("Removing rule name "..ruleName)
	for i = 1, #savedbag.rules do
		local bagEntry = savedbag.rules[i]
		if bagEntry.name == ruleName then
			aclogger:Debug("Found it! - "..ruleName)
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
