local AC = AutoCategory
--local SF = LibSFUtils

local aclogger

local L = GetString
local CVT = AutoCategory.CVT

local auBagSet = AC_UI.BagSet

local CatSet_SelectTag_LAM = AC.BaseDD:New("AC_DROPDOWN_EDITRULE_TAG") -- only uses choices
-- Make accessible to BagSet
AC_UI.CatSet_SelectTag_LAM = CatSet_SelectTag_LAM

local CatSet_SelectRule_LAM = AC.BaseDD:New("AC_DROPDOWN_EDITRULE_RULE", nil,  CVT.USE_TOOLTIPS) -- uses choicesTooltips
-- Make accessible to BagSet
AC_UI.CatSet_SelectRule_LAM = CatSet_SelectRule_LAM

-- local to this screen
local catSet_NewCat_LAM = AC.BaseUI:New() 	-- button
local catSet_CopyCat_LAM = AC.BaseUI:New() 	-- button
local CatSet_DeleteCat_LAM = AC.BaseUI:New()	-- button
local CatSet_NameEdit_LAM = AC.BaseUI:New("AC_EDITBOX_EDITRULE_NAME") -- editbox
local CatSet_TagEdit_LAM = AC.BaseUI:New("AC_EDITBOX_EDITRULE_TAG")	-- editbox

local AC_EMPTY_TAG_NAME = L(SI_AC_DEFAULT_NAME_EMPTY_TAG)

AC_UI.CatSet = {}

local currentRule = AutoCategory.CreateNewRule("","")

--warning message
local warningDuplicatedName = {
	warningMessage = nil,
}
AC_UI.warningDuplicatedName = warningDuplicatedName

-- aliases
local getCurrentBagId = AutoCategory.getCurrentBagId

function AC_UI.CatSet.clearRuleCheckStatus()
	ruleCheckStatus.err = nil
	ruleCheckStatus.good = nil
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
         if AutoCategory.Environment[w] then
             found = true
 
         else
             for i=1, #AutoCategory.dictionary do
                 if AutoCategory.dictionary[i][w] then
                     found = true
                     break;
                 end
             end
         end
         if found == false then
             result[#result+1] = w
             --table.insert(result, w)
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
		AutoCategory.RuleApi.setError(currentRule, true,"Rule definition cannot be empty")
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

-- customization of BaseDD for CatSet_SelectTag_LAM
-- -------------------------------------------------------
function CatSet_SelectTag_LAM:setValue(value)
	if not value then return end
	local oldvalue = self:getValue()
	if oldvalue == value then return end

	self:select(value)

	CatSet_SelectRule_LAM:assign(AutoCategory.RulesW.tagGroups[value])
	if currentRule and currentRule.tag == value then
		CatSet_SelectRule_LAM:select(currentRule.name)
	end
	CatSet_SelectRule_LAM:refresh()
	CatSet_SelectRule_LAM:updateControl()

	AC_UI.AddCat_SelectTag_LAM:assign({choices=AutoCategory.RulesW.tags})
	AC_UI.AddCat_SelectTag_LAM:updateControl()

	AC_UI.AddCat_SelectRule_LAM:updateControl()
end

-- refresh the value of the cvt lists for CatSet_SelectTag_LAM from the 
-- current contents of the AutoCategory.RulesW.tags list.
function CatSet_SelectTag_LAM:refresh()
	if self:getValue() == nil then
		self:select(AutoCategory.RulesW.tags)
	end
end

function CatSet_SelectTag_LAM:controlDef()
	return
		-- Tags - AC_DROPDOWN_EDITRULE_TAG
		{
			type = "dropdown",
			name = SI_AC_MENU_CS_DROPDOWN_TAG,
			tooltip = SI_AC_MENU_CS_DROPDOWN_TAG_TOOLTIP,
			scrollable = true,
			choices = self.cvt.choices,
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
function CatSet_SelectRule_LAM:getValue()
	--aclogger:Debug("CatSet_SelectRule_LAM:getValue returns "..tostring(self.cvt.indexValue))
  	return self.cvt.indexValue
end

-- refresh the contents and value of the cvt lists for CatSet_SelectRule_LAM from the 
-- current contents of the AutoCategory.RulesW.tagGroups[tag] list.
function CatSet_SelectRule_LAM:refresh()
	local ltag = CatSet_SelectTag_LAM:getValue()
	if not ltag then return end

	-- dropdown lists for Edit Rule (Category) selection (AC_DROPDOWN_EDITRULE_RULE)
	local dataCurrentRules_EditRule = CVT:New(nil,nil,CVT.USE_TOOLTIPS)
	local oldndx = self:getValue()
	if AutoCategory.RulesW.tagGroups[ltag] then
		dataCurrentRules_EditRule:assign(AutoCategory.RulesW.tagGroups[ltag])
	end
	self:assign(dataCurrentRules_EditRule)
	if oldndx then
		self:select(oldndx)
	end
	if self:getValue() == nil then
		self:select({})	-- select first
	end
end

function CatSet_SelectRule_LAM:setValue(value)
	self:select(value)
	currentRule = AutoCategory.GetRuleByName(value)
	AC_UI.checkCurrentRule()
end

function CatSet_SelectRule_LAM:controlDef()
	-- Categories - AC_DROPDOWN_EDITRULE_RULE
	return
		{
			type = "dropdown",
			name = SI_AC_MENU_CS_DROPDOWN_CATEGORY,
			scrollable = true,
			choices = self.cvt.choices,
			choicesTooltips =  self.cvt.choicesTooltips,
			sort = "name-up",

			getFunc = function()
				currentRule = AutoCategory.GetRuleByName(self:getValue())
				return self:getValue()
			end,
			setFunc = function(value) self:setValue(value) end,
			disabled = function() return self:size() == 0 end,
			width = "half",
			reference = self:getControlName(),
		}
end
-- -------------------------------------------------------

-- customization of BaseUI for catSet_NewCat_LAM button
-- -------------------------------------------------------
function catSet_NewCat_LAM:execute()
	local newName = AutoCategory.GetUsableRuleName(L(SI_AC_DEFAULT_NAME_NEW_CATEGORY))
	local tag = CatSet_SelectTag_LAM:getValue()
	if tag == "" then
		tag = AC_EMPTY_TAG_NAME
	end
	local newRule = AutoCategory.CreateNewRule(newName, tag)
	AutoCategory.ARW:addRule(newRule)
	AutoCategory.cache.AddRule(newRule)

	currentRule = newRule

	CatSet_SelectRule_LAM:refresh()
	CatSet_SelectRule_LAM:setValue(currentRule.name)
	CatSet_SelectRule_LAM:updateControl()

	CatSet_SelectTag_LAM:setValue(currentRule.tag)
	CatSet_SelectTag_LAM:refresh()
	CatSet_SelectTag_LAM:updateControl()

	AC_UI.AddCat_SelectTag_LAM:setValue(currentRule.tag)
	AC_UI.AddCat_SelectRule_LAM:assign(AC_UI.AddCat_SelectRule_LAM.filterRules(getCurrentBagId(),currentRule.tag))
	AC_UI.AddCat_SelectTag_LAM:refresh()
	AC_UI.BagSet.updateControls()

	AC_UI.RefreshDropdownData()
	if currentRule and AutoCategory.RuleApi.isCompiled(currentRule) == nil then
    	AutoCategory.RulesW.CompileAll(AutoCategory.RulesW)
	end
end

function catSet_NewCat_LAM:controlDef()
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

-- customization of BaseUI for catSet_CopyCat_LAM button
-- -------------------------------------------------------
function catSet_CopyCat_LAM:execute()
	local ruleName = CatSet_SelectRule_LAM:getValue()	-- source
	local tag = CatSet_SelectTag_LAM:getValue()
	if tag == "" then
		tag = AC_EMPTY_TAG_NAME
	end

	local srcRule = AutoCategory.GetRuleByName(ruleName)
	if not srcRule then return end

	local newRule = AutoCategory.CopyFrom(srcRule)
	AutoCategory.ARW:addRule(newRule)
	AutoCategory.cache.AddRule(newRule)

	currentRule = newRule

	CatSet_SelectTag_LAM:setValue(currentRule.tag)
	CatSet_SelectTag_LAM:refresh()

	CatSet_SelectRule_LAM:refresh()
	CatSet_SelectRule_LAM:setValue(currentRule.name)
	CatSet_SelectRule_LAM:updateControl()
	AC_UI.checkCurrentRule()


    AutoCategory.RulesW.CompileAll(AutoCategory.RulesW)
	-- Add the rule to the bagSet Add Category dropdown and perform appropriate updates
	AC_UI.AddCat_SelectRule_LAM:assign(AC_UI.AddCat_SelectRule_LAM.filterRules(getCurrentBagId(),currentRule.tag))
	AC_UI.BagSet.updateControls()
end

function catSet_CopyCat_LAM:controlDef()
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

-- customization of BaseUI for CatSet_NameEdit_LAM editbox
-- -------------------------------------------------------
function CatSet_NameEdit_LAM:getValue()
	if currentRule then
		return currentRule.name
	end
	return ""
end

function CatSet_NameEdit_LAM:setValue(value)
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

	local isDuplicated = AutoCategory.RulesW.ruleNames[value] ~= nil
	if isDuplicated then
		warningDuplicatedName.warningMessage = string.format(
			L(SI_AC_WARNING_CATEGORY_NAME_DUPLICATED),
			value, AutoCategory.GetUsableRuleName(value))
		value = oldName
		--change editbox's value
		local control = WINDOW_MANAGER:GetControlByName("AC_EDITBOX_EDITRULE_NAME")
		control.editbox:SetText(value)
		return
	end

	currentRule.name = AutoCategory.renameRule(currentRule.name, value)

	--Update drop downs
	AutoCategory.cacheInitialize()
	AC_UI.RefreshDropdownData()

	if currentRule == nil then
		currentRule = AutoCategory.GetRuleByName(value)
	end
	AC_UI.AddCat_SelectRule_LAM:assign(AC_UI.AddCat_SelectRule_LAM.filterRules(getCurrentBagId(),currentRule.tag))
	AC_UI.AddCat_SelectRule_LAM:updateControl()
	-- apparently one the AddCat_SelectRule_LAM calls is reseting the currentRule!
	currentRule = AutoCategory.GetRuleByName(value)

	--aclogger:Debug("new name1 - "..tostring(value))
	--aclogger:Debug("new name2 - "..tostring(currentRule))
	--aclogger:Debug("new name3 - "..tostring(currentRule.name))
	CatSet_SelectRule_LAM:refresh()
	CatSet_SelectRule_LAM:setValue(currentRule.name)
	CatSet_SelectRule_LAM:updateControl()

	auBagSet.SelectRule(currentRule.name)
end

function CatSet_NameEdit_LAM:controlDef()
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
			disabled = function() return currentRule == nil or AutoCategory.RuleApi.isPredefined(currentRule) end,
			width = "half",
			reference = self:getControlName(),
		}

end
-- -------------------------------------------------------

-- customization of BaseUI for CatSet_TagEdit_LAM editbox
-- -------------------------------------------------------
-- when a rule changes the tag name, we need to update the various lists tracking tags vs rules
-- returns the rule name, and a list of rules that belong to newtag.
-- When parameters are bad, return nil,nil
function CatSet_TagEdit_LAM.changeTag(rule, oldtag, newtag)
	-- bad parameters
	if not rule or not rule.name or not newtag then return nil,nil end

	-- nothing needs changing?
	if oldtag == newtag then return rule.name, AutoCategory.RulesW.tagGroups[rule.tag] end

	-- if tag is new, then update tags lists
	AutoCategory.RulesW.AddTag(newtag)

	-- add the rule to the new tag list
	AutoCategory.RulesW.tagGroups[newtag]:append(rule.name, nil, AutoCategory.RuleApi.getDesc(rule))
	-- remove the current rule from the oldtag list
	if oldtag and AutoCategory.RulesW.tagGroups[oldtag] then
		AutoCategory.RulesW.tagGroups[oldtag]:removeItemChoiceValue(rule.name)
		if AutoCategory.RulesW.tagGroups[oldtag]:size() == 0 then
			local ndx = ZO_IndexOfElementInNumericallyIndexedTable(AutoCategory.RulesW.tags, oldtag)
			if ndx then
				table.remove(AutoCategory.RulesW.tags, ndx)
			end
		end
	end
	rule.tag = newtag
	return rule.name, AutoCategory.RulesW.tagGroups[newtag]
end


function CatSet_TagEdit_LAM:getValue()
	if not currentRule then return "" end

	return currentRule.tag
end

function CatSet_TagEdit_LAM:setValue(value)
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

function CatSet_TagEdit_LAM:controlDef()
	-- Tag EditBox - AC_EDITBOX_EDITRULE_TAG
	return
	{
		type = "editbox",
		name = SI_AC_MENU_EC_EDITBOX_TAG,
		tooltip = SI_AC_MENU_EC_EDITBOX_TAG_TOOLTIP,
		getFunc = function() return self:getValue() end,
		setFunc = function(value) self:setValue(value) end,
		isMultiline = false,
		disabled = function() return currentRule == nil or AutoCategory.RuleApi.isPredefined(currentRule) end,
		width = "half",
		reference = self:getControlName(),
	}
end
-- -------------------------------------------------------

-- customization of BaseUI for CatSet_DeleteCat_LAM button
-- -------------------------------------------------------
function CatSet_DeleteCat_LAM:execute()
	local oldRuleName = CatSet_SelectRule_LAM:getValue()
	local ndx = AutoCategory.RulesW.ruleNames[oldRuleName]
	if ndx then
		table.remove(AutoCategory.RulesW.ruleList,ndx)
		-- remove from the rule list that gets saved
		AutoCategory.ARW:removeRuleByName(oldRuleName)
		AutoCategory.cacheRuleInitialize()
	end

	if oldRuleName == AC_UI.AddCat_SelectRule_LAM:getValue() then
		--rule removed, clean selection in add rule menu if selected
		AC_UI.AddCat_SelectRule_LAM:clearIndex()
	end

	-- removing the rule from any bags
	--local bagId
	for bagId = 1,7 do
		local savedbag = AutoCategory.saved.bags[bagId]
		for i = 1, #savedbag.rules do
			local bagEntry = savedbag.rules[i]
			if bagEntry.name == oldRuleName then
				table.remove(savedbag.rules, i)
				break
			end
		end
	end
	AC_UI.BagSet_SelectRule_LAM.cvt:removeItemChoiceValue(oldRuleName)
	if AC_UI.BagSet_SelectRule_LAM:getValue() == nil and AC_UI.BagSet_SelectRule_LAM:size() > 0 then
		AC_UI.BagSet_SelectRule_LAM:select({}) 	-- select first
	end
	AC_UI.BagSet_SelectRule_LAM:refresh()


	currentRule = nil
	CatSet_SelectRule_LAM:clearIndex()
	if CatSet_SelectRule_LAM:size() > 0 then
		CatSet_SelectRule_LAM:select({})
	end

	AutoCategory.cacheBagInitialize()
	CatSet_SelectRule_LAM:refresh()
	CatSet_SelectRule_LAM:updateControl()

	AC_UI.AddCat_SelectRule_LAM:refresh()
	AC_UI.AddCat_SelectRule_LAM:updateControl()

	CatSet_SelectRule_LAM:refresh()
	--CatSet_SelectRule_LAM:setValue(currentRule.name)
	CatSet_SelectRule_LAM:updateControl()

	AC_UI.BagSet_SelectRule_LAM:refresh()
	AC_UI.BagSet_SelectRule_LAM:updateControl()
	AC_UI.BagSet_ShowRule_LAM:refresh(bag)

	AC_UI.AddCat_SelectRule_LAM:refresh()
	AC_UI.RefreshControls()
	AC_UI.BagSet_RefreshOrder()
end

function CatSet_DeleteCat_LAM:controlDef()
	-- Delete Category/Rule Button
	return
		{
			type = "button",
			name = SI_AC_MENU_EC_BUTTON_DELETE_CATEGORY,
			tooltip = SI_AC_MENU_EC_BUTTON_DELETE_CATEGORY_TOOLTIP,
			isDangerous = true,
			func = function()  self:execute() end,
			width = "half",
			disabled = function() return currentRule == nil or AutoCategory.RuleApi.isPredefined(currentRule) end,
		}
end
-- -------------------------------------------------------

local function editCat_getPredef()
    if currentRule and AutoCategory.RuleApi.isPredefined(currentRule) then
        return L(SI_AC_MENU_EC_BUTTON_PREDEFINED)

    else
        return ""
    end
end

local description = AC_UI.description
local header = AC_UI.header

function AC_UI.CatSet.controlDef()
    -- Category Settings
    return {
        type = "submenu",
        name = SI_AC_MENU_SUBMENU_CATEGORY_SETTING,
        reference = "AC_SUBMENU_CATEGORY_SETTING",
        controls = {
            -- Select Existing Description
            description(SI_AC_MENU_CS_CATEGORY_DESC),

            -- Tags - AC_DROPDOWN_EDITRULE_TAG
            CatSet_SelectTag_LAM:controlDef(),

            -- Categories - AC_DROPDOWN_EDITRULE_RULE
            CatSet_SelectRule_LAM:controlDef(),

            -- Create/Copy a New Category Description
            description(SI_AC_MENU_CS_CREATENEW_DESC),

            -- New Category Button
            catSet_NewCat_LAM:controlDef(),

            -- Copy Category/Rule Button
            catSet_CopyCat_LAM:controlDef(),

            -- Learn Rules button
            {
                type = "button",
                name = SI_AC_MENU_EC_BUTTON_LEARN_RULES,
                func = function() RequestOpenUnsafeURL("https://github.com/Shadowfen/AutoCategory/wiki/Creating-Custom-Categories") end,
                width = "half",
            },

            -- Delete Category/Rule Button
            CatSet_DeleteCat_LAM:controlDef(),

            -- ------------------------------------------------------
            -- Edit Category Title
            header(SI_AC_MENU_HEADER_EDIT_CATEGORY),

            -- Predefined Text Description
            description(editCat_getPredef),
            
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
                    if not currentRule then return end
                    local oldval = currentRule.description
                    currentRule.description = value
                    if oldval ~= value then
                        AutoCategory.cacheInitialize() -- reset tooltips to new value
                        AC_UI.RefreshDropdownData()
                        AC_UI.RefreshControls()
                    end
                end,
                isMultiline = false,
                isExtraWide = true,
                disabled = function() return currentRule == nil or AutoCategory.RuleApi.isPredefined(currentRule) end,
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
                    ruleCheckStatus.err = AutoCategory.RuleApi.compile(currentRule)
                    if ruleCheckStatus.err == "" then
                        ruleCheckStatus.err = nil
                        ruleCheckStatus.good = true

                    else
                        ruleCheckStatus.good = nil
                    end
                    end,
                isMultiline = true,
                isExtraWide = true,
                disabled = function() return currentRule == nil or AutoCategory.RuleApi.isPredefined(currentRule) end,
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
                    AC_UI.checkCurrentRule()
                end,
                disabled = function() return currentRule == nil or AutoCategory.RuleApi.isPredefined(currentRule) end,
                width = "half",
            },
        },

    }

end

function AC_UI.CatSet.clear()
	CatSet_SelectTag_LAM:clearIndex()
	CatSet_SelectRule_LAM:clearIndex()
	AC_UI.CatSet.clearRuleCheckStatus()
end

function AC_UI.CatSet.refresh()
	-- refresh selections
	CatSet_SelectTag_LAM:refresh()

	--refresh current dropdown rules
	CatSet_SelectRule_LAM:refresh()
end

function AC_UI.CatSet.updateControls()
	CatSet_SelectTag_LAM:updateControl()
	CatSet_SelectRule_LAM:updateControl()
end

function AC_UI.CatSet.setRule(rule)
	CatSet_SelectTag_LAM:refresh()
	CatSet_SelectTag_LAM:setValue(rule.tag)

	CatSet_SelectRule_LAM:refresh()
	CatSet_SelectRule_LAM:setValue(rule.name)
	CatSet_SelectRule_LAM:updateControl()
end
-- -------------------------------------------------------

function AC_UI.CatSet_Init()
	aclogger = AutoCategory.logger
	
    CatSet_SelectTag_LAM:assign( { choices=AutoCategory.RulesW.tags} )
end

