--====AutoCategory Classes====--

local L = GetString
local SF = LibSFUtils
local AC = AutoCategory

--local aclogger = AutoCategory.logger
--local RuleApi = AutoCategory.RuleApi
--local BagRuleApi = AutoCategory.BagRuleApi

-- -------------------------------------------------------
-- The CVT class manages the choices, choicesValues, and
-- choicesTooltips list for a particular dropdown control.
--
-- Note that the choices, choicesValues, and choicesTooltips
-- are 1-based contiguous lists (or possibly nil for values
-- and tooltips as these are optional).
--
-- A CVT can also be associated with a particular LAM dropdown
-- control by providing the control name (reference= in LAM options).
-- This allows the updateControls() function to refresh the
-- control from (possibly changed) choices, values, and
-- tooltips lists.
--
-- The indexValue field can keep track of the desired "current value"
-- of the CVT and is a value from either the choicesValues list
-- (if it exists) or else a value from the choices list. If you
-- wish to use this, you must ensure that the control setfunc() sets
-- the indexValue appropriately.
-- -------------------------------------------------------

AutoCategory.CVT = ZO_Object:Subclass()

AutoCategory.CVT.USE_NONE = 0
AutoCategory.CVT.USE_VALUES = 1
AutoCategory.CVT.USE_TOOLTIPS = 3
AutoCategory.CVT.USE_ALL = 4

local USE_NONE = AutoCategory.CVT.USE_NONE
local USE_VALUES = AutoCategory.CVT.USE_VALUES
local USE_TOOLTIPS = AutoCategory.CVT.USE_TOOLTIPS
local USE_ALL = AutoCategory.CVT.USE_ALL

function AutoCategory.CVT:New(...)
    local obj = ZO_Object.New(self)
    obj:initialize(...)
    return obj
end

function AutoCategory.CVT:initialize(ctlname, ndx, usesFlags)
	if ctlname then
		self.controlName = ctlname
	end

	self.choices = {}		-- mandatory list

	if usesFlags and (usesFlags == USE_VALUES or usesFlags == USE_ALL)  then
		self.choicesValues = {}
	end

	if usesFlags and (usesFlags == USE_TOOLTIPS or usesFlags == USE_ALL) then
		self.choicesTooltips = {}
	end

	self.indexValue = ndx
end

-- clear all of the tables in the CVT while preserving the references to the tables themselves
function AutoCategory.CVT:clear()
	self.dirty = 1
	self.choices = SF.safeClearTable(self.choices)

	if self.choicesValues then
		self.choicesValues = SF.safeClearTable(self.choicesValues)
	end
	if self.choicesTooltips then
		self.choicesTooltips = SF.safeClearTable(self.choicesTooltips)
	end

	self.indexValue = nil
end

function AutoCategory.CVT:getControlName()
	return self.controlName
end

-- assign the choices, choicesValues, and choicesTooltips from tblB to self
function AutoCategory.CVT:assign(tblB)
	if not tblB then return end

	if self.choicesValues and not tblB.choicesValues then
		--AutoCategory.logger:Debug("don't have choicesValues for src tables in assign "..tostring(self.controlName))
		return
	end
	if self.choicesTooltips and not tblB.choicesTooltips then
		--AutoCategory.logger:Debug("don't have choicesTooltips for dest tables in assign "..tostring(self.controlName))
		return
	end

	local ndx = self.indexValue
	self.dirty = 1
	self:clear()

	-- 1-based and contiguous, remember?
	-- may return nil
	local function shallowcpy(src, dest)
		if not src then return dest end
		if not dest then return dest end --dest = {} end
		for k=1, #src do
			dest[k] = src[k]
		end
		return dest
	end

	self.choices = shallowcpy(tblB.choices, self.choices)
	self.choicesValues = shallowcpy(tblB.choicesValues, self.choicesValues)
	self.choicesTooltips = shallowcpy(tblB.choicesTooltips, self.choicesTooltips)

	-- select the first value as the "current" value
	if tblB.indexValue then
		self:select(tblB.indexValue)

	elseif ndx then
		self:select(ndx)

	else --if #self.choicesValues > 0 then
		self:select()
	end
end

-- set the current indexValue of the CVT from available values of the dropdown
-- if "value" is a non-empty table, then select the first entry from that table.
-- returns the value selected (may be nil)
function AutoCategory.CVT:select(value)
	local searchtbl = self.choices
	if self.choicesValues then
		searchtbl = self.choicesValues
	end
	if not searchtbl then return nil end

	if type(value) == "table" then
		if #value > 0 then
			self.indexValue = value[1]
			return self.indexValue
		end
		if #searchtbl > 0 then
			self.indexValue = searchtbl[1]
			return self.indexValue
		end
		self.indexValue = nil
		return nil
	end

	-- not a table

	if value == "" then value = nil end

	if value and ZO_IsElementInNumericallyIndexedTable(searchtbl, value) then
		-- we have a valid value, so use it
		self.indexValue=value
		return self.indexValue

	elseif self.indexValue and ZO_IsElementInNumericallyIndexedTable(searchtbl, self.indexValue) then
		-- already has a value that is still valid so leave it alone
		return self.indexValue

	elseif searchtbl and #searchtbl > 0 then
		-- fall back to using the initial list value of the CVT
		self.indexValue = searchtbl[1]
		return self.indexValue
	end
	return self.indexValue
end

function AutoCategory.CVT:clearIndex()
	self.indexValue = nil
end


-- append a row selection to the cvt tables
-- returns whether or not it succeeded
function AutoCategory.CVT:append(choice, value, tooltip)
	if not value and self.choicesValues then return false end	-- value required when have choicesValues
	if not tooltip and self.choicesTooltips then return false end	-- tooltip required when have choicesTooltips
	if not choice then return false end	-- choice is mandatory

	self.dirty = 1
	self.choices[#self.choices+1] = choice -- (required)
	if value and self.choicesValues then
		self.choicesValues[#self.choicesValues+1] = value	-- (optional)
	end
	if tooltip and self.choicesTooltips then
		self.choicesTooltips[#self.choicesTooltips+1] = tooltip	-- (optional)
	end
	return true
end

-- set the name of the associated control for these lists (if there is one)	--	not currently used
function AutoCategory.CVT:setControlName(fld)
	self.controlName = fld
end

-- returns the size of the required list for the CVT
--  (when other lists are used they must also have the same size!)
function AutoCategory.CVT:size()
	return #self.choices
end


-- update the dropdown control with the new/current list values
-- only works if a controlName was assigned to this CVT.
function AutoCategory.CVT:updateControl()
	if not self.controlName then return end

	if self.dirty == 1 then
		self.dirty = nil
	else
		-- does not need updating
		return
	end

	--AutoCategory.logger:Debug("CVT:updateControl: getting control for "..tostring(self.controlName))
	local dropdownCtrl = WINDOW_MANAGER:GetControlByName(self.controlName)
    if dropdownCtrl == nil then
        return
    end

	--AutoCategory.logger:Debug("CVT:updateControl: lists changed - need to update "..tostring(self.controlName))
	dropdownCtrl:UpdateChoices(self.choices, self.choicesValues,
		self.choicesTooltips)
end

-- remove an item (by choice) from the dropdown lists (does not update the control)
-- returns the new (maybe new) index value
function AutoCategory.CVT:removeItemChoice(removeItem)
	local removeIndex = -1
    if not self.choices then	-- corrupt cvt
		self.dirty = 1
		self.choices = {}
		self.indexValue = nil
		return nil
	end

	-- find the choice to remove
	local ndx = ZO_IndexOfElementInNumericallyIndexedTable(self.choices, removeItem)
	if not ndx then return self.indexValue end		-- nothing to remove

	removeIndex = ndx
	self.dirty = 1
	local num = #self.choices		-- value BEFORE removal

	-- remove it from lists
	table.remove(self.choices, removeIndex)
	if self.choicesValues and #self.choicesValues > 0 then
		table.remove(self.choicesValues, removeIndex)
	end
	if self.choicesTooltips and #self.choicesTooltips > 0 then
		table.remove(self.choicesTooltips, removeIndex)
	end

	-- choose what the new indexValue (selection) will be
    if removeIndex <= 0 then return self.indexValue end
	if num == 1 then
		--select none
		self.indexValue = nil

	elseif removeIndex == num then
		--no next one, select previous one
		self.indexValue = self.choices[num-1]

	else
		--select next one
		self.indexValue = self.choices[removeIndex]
	end
	return self.indexValue
end

-- remove an item by choiceValue from the dropdown lists (does not update the control)
-- returns new selected value/choice
function AutoCategory.CVT:removeItemChoiceValue(removeItem)
	local removeIndex = -1
    if not self.choicesValues then return nil end

	-- find the choiceValue to remove
	local ndx = ZO_IndexOfElementInNumericallyIndexedTable(self.choicesValues, removeItem)
	if not ndx then return self.indexValue end		-- nothing to remove
	self.dirty = 1
	removeIndex = ndx
	local num = #self.choicesValues		-- value BEFORE removal
	-- remove it
	table.remove(self.choicesValues, removeIndex)
	table.remove(self.choices, removeIndex)		-- not optional
	if #self.choicesTooltips then
		table.remove(self.choicesTooltips, removeIndex)
	end

	-- find the choice to remove
	if num == 1 then
		--select none
		self:clearIndex()

	elseif removeIndex == num then
		--no next one, select previous one
		self:select(self.choicesValues[num-1])

	else
		--select next one
		self:select(self.choicesValues[removeIndex])
	end
	return self.indexValue
end

-- --------------------------------------------
AutoCategory.BaseUI = ZO_Object:Subclass()

function AutoCategory.BaseUI:New(...)
    local obj = ZO_Object.New(self)
    obj:initialize(...)
    return obj
end

function AutoCategory.BaseUI:initialize(ctlname, ...)
	self.controlName = ctlname
end

function AutoCategory.BaseUI:getControlName()
	return self.controlName
end

function AutoCategory.BaseUI:updateValue()
	if not self.controlName then return end
	local val = self:getValue()
	if not val then return end

	--AutoCategory.logger:Debug("updateControl: getting control for "..tostring(self.cvt.controlName))
	local uiCtrl = WINDOW_MANAGER:GetControlByName(self.controlName)
    if uiCtrl == nil then
        return
    end

	--AutoCategory.logger:Debug("updateValue: value changed - need to update "..tostring(self.controlName))
	uiCtrl:UpdateValue(false, val)
end

-- --------------------------------------------
AutoCategory.BaseDD = ZO_Object:Subclass()

function AutoCategory.BaseDD:New(...)
    local obj = ZO_Object.New(self)
    obj:initialize(...)
    return obj
end

function AutoCategory.BaseDD:initialize(ctlname, ndx, usesFlags)
	self.cvt = AutoCategory.CVT:New(ctlname, ndx, usesFlags)
end

function AutoCategory.BaseDD:getControlName()
	return self.cvt.controlName
end

function AutoCategory.BaseDD:select(val)
	self.cvt:select(val)
end

function AutoCategory.BaseDD:clearIndex()
	self.cvt:clearIndex()
end

function AutoCategory.BaseDD:clear()
	self.cvt:clear()
end

function AutoCategory.BaseDD:assign(cvtTbl)
	self.cvt:assign(cvtTbl)
end

function AutoCategory.BaseDD:updateControl()
	if not self.cvt.controlName then return end

	--AutoCategory.logger:Debug("updateControl: getting control for "..tostring(self.cvt.controlName))
	local dropdownCtrl = WINDOW_MANAGER:GetControlByName(self.cvt.controlName)
    if dropdownCtrl == nil then
        return
    end

	if self.cvt.dirty == 1 then		-- only do this if cvt lists have been modified
		--AutoCategory.logger:Debug("updateControl: dropdown lists changed - updating "..tostring(self.cvt.controlName))
		-- only update the choices if we know that the lists contents changed
		self.cvt.dirty = nil
		dropdownCtrl:UpdateChoices(self.cvt.choices, self.cvt.choicesValues,
			self.cvt.choicesTooltips)
	end

	if self.cvt.indexValue then
		--AutoCategory.logger:Debug("updateControl: value changed - need to update "..tostring(self.cvt.controlName))
		dropdownCtrl:UpdateValue(false, self.cvt.indexValue)
	end

end

function AutoCategory.BaseDD:size()
  return #self.cvt.choices
end

function AutoCategory.BaseDD:getValue()
  return self.cvt.indexValue
end


-- -------------------------------------------------------
-- Rule functions and helpers

-- based on the requested rule name, create a name that
-- is not already in use (since rule names must be unique)
function AutoCategory.GetUsableRuleName(name)
	local testName = name
	local index = 1
	while AutoCategory.RulesW.ruleNames[testName] ~= nil do
		testName = name .. index
		index = index + 1
	end
	return testName
end

-- check that all required fields are set
-- returns err (t/f), errmsg (string)
function AutoCategory.isValidRule(ruledef)
    --make sure rule is well-formed
	-- validate rule name
    if (not ruledef or not ruledef.name
			or type(ruledef.name) ~= "string" or ruledef.name == "") then
        return false, "name is required"
    end
	-- validate rule text
    if (not ruledef.rule or type(ruledef.rule) ~= "string" or ruledef.rule == "") then
		ruledef.error = true
        return false, "rule text is required"
    end
	-- validate optional rule description
    if ruledef.description then -- description is optional
        if (type(ruledef.description) ~= "string") then
            return false, "non-nil description must be a string"
        end
    end
	-- validate optional rule tag
    if ruledef.tag then -- tag is optional
        if (type(ruledef.tag) ~= "string") then
            return false, "non-nil tag must be a string"
        end
    end
    return true
end

-- -------------------------------------------------
-- collected functions to be applied to a rule
--

-- factory for creating new rules
function AutoCategory.CreateNewRule(name, tag)
	local rule = {
		name = name,
		description = "",
		rule = "true",
		tag = tag,
	}
	return rule
end

-- factory for making copies of rules
function AutoCategory.CopyFrom(copyFrom)
	if not copyFrom then return end

	local ruleName = copyFrom.name
	-- get a unique name based on the old rule name
	local newName = AutoCategory.GetUsableRuleName(ruleName)
	local tag = copyFrom.tag
	if tag == "" then
		tag = AC_EMPTY_TAG_NAME
	end

	local newRule = AutoCategory.CreateNewRule(newName, tag)
	newRule.description = copyFrom.description
	newRule.rule = copyFrom.rule
	newRule.damaged = copyFrom.damaged
	newRule.err = copyFrom.err
	newRule.pred = nil		-- defaults to not pre-defined, because copies are user-defined rules
	return newRule
end

-- The BagRule class assists in the definition, management, and formatting of
-- bag rules for the collection of them in the Bag Settings Categories dropdown.
-- The minimum that a bagrule has is { name, priority }.
-- -------------------------------------------------------
-- helper functions for BagRules (for bag settings)

-- --------------------------------------------
-- Create a new Bag Entry (factory)
-- Rule parameter is required, priority is optional.
-- If a priority is not provided, default to 1000
-- Returns a table {name=, priority=} or nil
--
function AutoCategory.CreateNewBagRule(rule, priority)
	local rulename = nil
	local ruleprior = nil
	if not rule then
		return nil
	end
	if type(rule) == "string" then
		rulename = rule
		rule = AutoCategory.GetRuleByName(rulename)

	elseif not rule.name then
		return nil

	else
		rulename = rule.name
	end

	if priority == nil then
		ruleprior = 1000

	else
		ruleprior = priority
	end

	local bagrule = {
		name = rulename,
		priority = ruleprior,
	}
	return bagrule
end

-- -------------------------------------------------
-- collected (wrapper) functions to be applied to a rule list
--
AutoCategory.RuleList = ZO_Object:Subclass()

-- creates a rule list wrapper with a numeric-sequenced list of rules (not under a .rules!)
function AutoCategory.RuleList:New(...)
    local obj = ZO_Object.New(self)
    obj:initialize(...)
    return obj
end

-- rule list wrapper adds a name lookup to accompany the base list of rules
function AutoCategory.RuleList:initialize(rules)
	self.ruleList = rules
	self.ruleNames = {}		-- lookup by name for ruleList   [name] ruleListIndex
	local arrules = self.ruleList
	for k = #arrules,1,-1 do
		if not self.ruleNames[arrules[k].name ] then
			self.ruleNames[arrules[k].name] = k
		end
	end
end

-- return number of entries in the base rule list
function AutoCategory.RuleList.size(self)
	return #self.ruleList
end

function AutoCategory.RuleList.addRule(self, newRule, overwriteFlag)
	if not newRule or not newRule.name then return end	-- bad rule

	local ndx = self.ruleNames[newRule.name]
	if ndx then
		-- rule by name already in list
		if overwriteFlag then
			self.ruleList[ndx] = newRule
		end
		return
	end

	self.ruleList[#self.ruleList+1] = newRule
	self.ruleNames[newRule.name] = #self.ruleList
end

-- remove a rule from the ruleList
function AutoCategory.RuleList.removeRuleByName(self, ruleName)
	if not ruleName then return end

	local ndx = self.ruleNames[ruleName]
	if ndx then
		self.ruleNames[ruleName] = nil
		table.remove(self.ruleList, ndx)
	end
end

-- remove a rule from the ruleList by position (index) in the ruleList
function AutoCategory.RuleList.removeRule(self, ndx)
	if not ndx then return end
	local rl = self.ruleList[ndx]
	if not rl then return end
	local name = rl.name
	if name then
		self.ruleNames[name] = nil
	end
	table.remove(self.ruleList, ndx)
end

-- returns a rule from the ruleList as specified by name
function AutoCategory.RuleList.getRuleByName(self, ruleName)
	if not ruleName then return nil end
	local ndx = self.ruleNames[ruleName]
	if not ndx then return nil end
	return self.ruleList[ndx]
end

-- clear the contents of the ruleList
function AutoCategory.RuleList.clear(self)
	SF.safeClearTable(self.ruleList)
end

-- returns the name lookup table used by the wrapper (temporary measure)
function AutoCategory.RuleList.getLookup(self)
	return self.ruleNames
end

-- sort the contents of the ruleList using sortfn
function AutoCategory.RuleList.sort(self, sortfn)
	if type(sortfn ~= "function") then return end

	SF.safeClearTable(ruleNames)
	table.sort(self.ruleList, sortfn)

	-- rebuild name lookup
	local arrules = self.ruleList
	for k = #arrules,1,-1 do
		if not self.lkRruleNamesules[arrules[k].name ] then
			self.ruleNames[arrules[k].name] = k
		end
	end
end
--[[
-- not currently used (and not complete)
-- -------------------------------------------------
-- collected functions to be applied to a bagrule list
--
AutoCategory.BagRuleList = ZO_Object:Subclass()

function AutoCategory.BagRuleList:New(...)
    local obj = ZO_Object.New(self)
    obj:initialize(...)
    return obj
end

function AutoCategory.BagRuleList:initialize(bagrules)
	self.bagrule = bagrules
	self.ruleList = bagrules.rules
	self.lkRules = {}
	local arrules = self.ruleList
	for k = #arrules,1,-1 do
		if not self.lkRules[arrules[k].name ] then
			self.lkRules[arrules[k].name] = k
		end
	end
end

function AutoCategory.BagRuleList.size(self)
	return #self.ruleList
end

function AutoCategory.BagRuleList.addBagRule(self, newRule, overwriteFlag)
	if not newRule or not newRule.name then return end

	local ndx = self.lkRules[newRule.name]
	if ndx then
		if overwriteFlag then
			self.ruleList[ndx] = newRule
		end
		return
	end

	self.ruleList[#self.ruleList+1] = newRule
	self.lkRules[newRule.name] = #self.ruleList
end
--]]

-- -------------------------------------------------
-- collected functions to be applied to a rule
--
-- This functions to be used with rule structures loaded in or created.
AutoCategory.RuleApi = {
	-- check if rule def is valid (required keys all present)
	isValid = function(r)
			return AutoCategory.isValidRule(r)
	end,

	--determine if a rule is marked as pre-defined
	isPredefined = function(r)
	    return r.pred and r.pred ==1
	end,

	-- return the description if the rule has one, otherwise return the name
	getDesc = function(r)
			local tt = r.description
			if not tt or tt == "" then
				tt = r.name
			end
			return tt
		end,

	-- handle error marking for a rule
	setError = function(r,dmg,errm)
			r.damaged = dmg
			r.err = errm
		end,

	clearError = function(r)
			r.damaged = nil
			r.err = nil
		end,

	-- get assigned key for the rule (if nil, returns name)
	key = function(r)
			if r.rkey then
				return r.rkey
			end
			return r.name
		end,

	-- compare a rule to another rule for certain basic equalities
	-- used for converting from acct/char rules to acctwide-only
	-- returns two bools - (name is ~=), (rule def ~=)
	isequiv = function(r, a)
			if not a then return false, false end
			local notname = r.name ~= a.name
			local notrule = r.rule ~= a.rule
			return notname, notrule
		end,

	-- Compile the Rule
	-- Return a string that is either empty (good compile)
	-- or an error string returned from the compile
	--
	-- Stores the compiled rule into AutoCategory.compiledRules table
	compile = function(rule)
			if rule == nil or rule.name == nil or rule.name == "" then
				return
			end
			AutoCategory.compiledRules = SF.safeTable(AutoCategory.compiledRules)

			AutoCategory.RuleApi.clearError(rule)
			AutoCategory.compiledRules[AutoCategory.RuleApi.key(rule)] = nil

			if rule.rule == nil or rule.rule == "" then
				AutoCategory.RuleApi.setError(rule, true,"Missing rule definition")
				return rule.err
			end

			local rulestr = "return(" .. rule.rule .. ")"
			local compiledfunc, err = zo_loadstring(rulestr)
			if not compiledfunc then
				AutoCategory.RuleApi.setError(rule, true, err)
				AutoCategory.compiledRules[AutoCategory.RuleApi.key(rule)] = nil
				return err
			end
			AutoCategory.compiledRules[AutoCategory.RuleApi.key(rule)] = compiledfunc
			return ""
		end,
}


-- -------------------------------------------------
-- collected functions to be applied to a BagRule
--
AutoCategory.BagRuleApi = {
	isValid = function (bagrule)
			if not bagrule.name or bagrule.name == "" then
				return false
			end
			if not bagrule.priority then return false end
			return true
		end,

    formatValue = function (bagrule)
			return bagrule.name
		end,

	-- formatShow() creates a string to represent the bagrule in the UI dropdown.
	-- It combines the name and priority and optionally marks or colorizes them
	-- based on if the bag rule is marked "hidden" or if the backing Rule has
	-- disappeared (i.e the bag rule is now invalid).
	formatShow	= function (bagrule)
			local sn = nil
			local rule = AutoCategory.BagRuleApi.getBackingRule(bagrule)
			if not rule then
				-- missing rule (nil was passed in)
				sn = string.format("|cFF4444(!)|r %s (%d)", bagrule.name, bagrule.priority)

			else
				if bagrule.isHidden then
					-- grey out the "hidden" category header
					sn = string.format("|c626250%s (%d)|r", bagrule.name, bagrule.priority)

				else
					sn = string.format("%s (%d)", bagrule.name, bagrule.priority)
				end
			end
			return sn
		end,

	-- Provides a tooltip string for the bag rule which may be displayed
	-- when hovering over the bag rule in the dropdown menu.
	-- Note: A bug in LAM has broken the display of tooltips from
	-- the menu, but I hope that the fix recommended by Calamath may
	-- soon be released for LAM.
	formatTooltip = function (bagrule)
			local tt = nil
			local rule = AutoCategory.BagRuleApi.getBackingRule(bagrule)
			if not rule then
				-- missing rule (nil was passed in)
				tt = L(SI_AC_WARNING_CATEGORY_MISSING)

			else
				tt = AutoCategory.RuleApi.getDesc(rule)
			end
			return tt
		end,

	-- Get the rule structure (if it exists) for the bag rule name
	getBackingRule = function (bagrule)
			if not bagrule.name then return nil end
			local rule = AutoCategory.GetRuleByName(bagrule.name)
			return rule
		end,

	-- Allows setting the isHidden value for the bag rule
	-- (translates false into nil to reduce junk in saved variables).
	setHidden = function (bagrule, isHidden)
		if isHidden == false then isHidden = nil end
		if bagrule.isHidden == isHidden then return bagrule.isHidden end
		bagrule.isHidden = isHidden
		return bagrule.isHidden
	end,
}
