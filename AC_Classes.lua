--====AutoCategory Classes====--

local L = GetString
local SF = LibSFUtils

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
	return bagrule
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

function AutoCategory.BagRuleList:size()
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
            if type(rule) ~= "table" then
                logDebug("[AutoCategory] compile: rule is not a table")
                return "Invalid rule object"
            end
			if rule.name == nil or rule.name == "" then
                logDebug("[AutoCategory] compile: rule has no name")
				return "Rule missing name"
			end

			local compiledRules = AutoCategory.compiledRules
			local ruleapi = AutoCategory.RuleApi

			ruleapi.clearError(rule)
			local rkey = ruleapi.key(rule)
            if not rkey then 
                ruleapi.setError(rule, true, "Unable to generate rule key")
                return rule.err
            end
            
			compiledRules[rkey] = nil

			if rule.rule == nil or rule.rule == "" then
				ruleapi.setError(rule, true,"Missing rule definition")
				return rule.err
			end

			local rulestr = string.format("return(%s)", rule.rule)
			local compiledfunc, err = zo_loadstring(rulestr)
			if not compiledfunc then
				ruleapi.setError(rule, true, err)
				return err
			end
			compiledRules[rkey] = compiledfunc
			return ""
		end,
	
	-- returns nil if the rule is not compiled, non-nil if it is compiled
	isCompiled = function(rule)
		if rule == nil or rule.name == nil or rule.name == "" then
			return
		end
		return AutoCategory.compiledRules[AutoCategory.RuleApi.key(rule)]
	end,
}


-- -------------------------------------------------
-- collected functions to be applied to a BagRule
--
local bagRuleApi = {
	convertPriority = function (bagrule)
			if bagrule.priority then 
				bagrule.runpriority = bagrule.priority
				bagrule.priority = nil
			end
			if not bagrule.showpriority then 
				bagrule.showpriority = bagrule.runpriority
			end
		end,

	isValid = function (bagrule)
			if not bagrule.name or bagrule.name == "" then
				return false
			end
			if not bagrule.runpriority then return false end
			return true
		end,

    formatValue = function (bagrule)
			return bagrule.name
		end,

	-- formatShow() creates a string to represent the bagrule in the UI dropdown.
	-- It combines the name and runpriority and showpriority and optionally marks or colorizes them
	-- based on if the bag rule is marked "hidden" or if the backing Rule has
	-- disappeared (i.e the bag rule is now invalid).
	-- If no priority is passed in then the rule's runpriority is used.
	-- Returns the string for the bagrule dropdown. Format: "name (runpriority/showpriority)"
	formatShow	= function (bagrule)

			local rule = AutoCategory.BagRuleApi.getBackingRule(bagrule)
			AutoCategory.BagRuleApi.convertPriority(bagrule)

			local sn
			if not rule then
				-- missing rule (nil was passed in)
				sn = string.format("|cFF4444(!)|r %s (%d/%d)", bagrule.name, bagrule.runpriority, bagrule.showpriority)

			else
				if bagrule.isHidden then
					-- grey out the "hidden" category header
					local r, g, b = unpack(AutoCategory.saved.appearance["HIDDEN_CATEGORY_FONT_COLOR"])
					local hex = "626250"
					if r and not AutoCategory.saved.general["ENABLE_GAMEPAD"] then
						--r, g, b = unpack(AutoCategory.saved.appearance["HIDDEN_CATEGORY_FONT_COLOR"])
						hex = SF.colorRGBToHex(r, g, b)
					end
					sn = string.format("|c%s%s (%d/%d)|r", hex, bagrule.name, bagrule.runpriority, bagrule.showpriority)

				else
					if  AutoCategory.saved.general["ENABLE_GAMEPAD"] then
						sn = string.format("%s (%d/%d)", bagrule.name, bagrule.runpriority, bagrule.showpriority)
					else
						local r, g, b = unpack(AutoCategory.saved.appearance["CATEGORY_FONT_COLOR"])
						local hex = SF.colorRGBToHex(r, g, b)
						sn = string.format("|c%s%s (%d/%d)|r", hex, bagrule.name, bagrule.runpriority, bagrule.showpriority)
					end
				end
			end
			return sn
		end,

	-- Provides a tooltip string for the bag rule which may be displayed
	-- when hovering over the bag rule in the dropdown menu.
	formatTooltip = function (bagrule)
			local tt
			local rule =AutoCategory.BagRuleApi.getBackingRule(bagrule)
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
		if isHidden == false then 
			bagrule.isHidden = nil
			return false
		end
		if bagrule.isHidden == isHidden then return bagrule.isHidden end
		bagrule.isHidden = isHidden
		return bagrule.isHidden
	end,
}
-- make accessible
AutoCategory.BagRuleApi = bagRuleApi

function AutoCategory.AC_Classes_Init()

end
