--====AutoCategory Classes====--

--local L = GetString
--local SF = LibSFUtils

local logDebug = AutoCategory.logDebug


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

	logDebug("[AC_Classes] updateControl: getting control for ", self.controlName)
	local uiCtrl = WINDOW_MANAGER:GetControlByName(self.controlName)
    if uiCtrl == nil then
        return
    end

	logDebug("[AC_Classes] updateValue: value changed - need to update ", self.controlName)
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

	logDebug("[AC_Classes] updateControl: getting control for ", self.cvt.controlName)
	local dropdownCtrl = WINDOW_MANAGER:GetControlByName(self.cvt.controlName)
    if dropdownCtrl == nil then
        return
    end

	if self.cvt.dirty == 1 then		-- only do this if cvt lists have been modified
		logDebug("[AC_Classes] updateControl: dropdown lists changed - updating ", self.cvt.controlName)
		-- only update the choices if we know that the lists contents changed
		self.cvt.dirty = nil
        local numchoices = #self.cvt.choices
        local numvalues = 0
        if self.cvt.choicesValues then numvalues = #self.cvt.choicesValues end
        local numtt = 0
        if self.cvt.choicesTooltips then numtt = #self.cvt.choicesTooltips end
        logDebug("[AC_Classes] #choices=", numchoices, " #choicesValues=", numvalues,
            " #choicesTooltips=", numtt)
		dropdownCtrl:UpdateChoices(self.cvt.choices, self.cvt.choicesValues,
			self.cvt.choicesTooltips)
	end

	if self.cvt.indexValue then
		logDebug("[AC_Classes] updateControl: value changed - need to update ", self.cvt.controlName)
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
    name = tostring(name)
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
    setmetatable(rule,{__index = AutoCategory.RuleApiMixin})
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
    --setmetatable(newRule,{__index = AutoCategory.RuleApiMixin})
	return newRule
end

-- The BagRule class assists in the definition, management, and formatting of
-- bag rules for the collection of them in the Bag Settings Categories dropdown.
-- The minimum that a bagrule has is { name, runpriority }.
-- -------------------------------------------------------
-- helper functions for BagRules (for bag settings)

-- --------------------------------------------
-- Create a new Bag Entry (factory)
-- Rule parameter is required, runpriority is optional.
-- If a runpriority is not provided, default to 1000
-- Returns a table {name=, runpriority=, showpriority=} or nil
--
function AutoCategory.CreateNewBagRule(rule, runpriority, showprior)
	local rulename
	local ruleRunprior
	if not rule then
		return nil
	end
	if type(rule) == "string" then
		rulename = rule
		rule = AutoCategory.GetRuleByName(rulename)

	end
	if not rule.name then
		return nil

	else
		rulename = rule.name
	end

	if runpriority == nil then
		ruleRunprior = 1000
	else
		ruleRunprior = runpriority
	end

	if showprior == nil then
		showprior = ruleRunprior
	end

	local bagrule = {
		name = rulename,
		runpriority = ruleRunprior,
		showpriority = showprior,
	}
    setmetatable(bagrule,{__index = AutoCategory.BagRuleApiMixin})
    return bagrule
end

