--====AutoCategory Classes====--

local L = GetString
local SF = LibSFUtils
local AC = AutoCategory

-- -------------------------------------------------------
-- The CVT class manages the choices, choicesValues, and
-- choicesTooltips list for a particular dropdown control.
-- -------------------------------------------------------

AutoCategory.CVT = ZO_Object:Subclass()


function AutoCategory.CVT:New(...)
    local obj = ZO_Object.New(self)
    obj:initialize(...)
    return obj
end

function AutoCategory.CVT:initialize(ctlname, ndx)
	if ctlname then
		self.controlName = ctlname
	end
	
	self.choices = {}
	self.choicesValues = {}
	self.choicesTooltips = {}
	
	if ndx == nil then return end
	indexValue = ndx
end

-- assign the choices, choicesValues, and choicesTooltips from tblB to self
function AutoCategory.CVT:assign(tblB, nm)
	if not tblB then return end
	AC.logger:Debug("assign: nm = "..tostring(nm)..", controlName = "..tostring(self.controlName))
	
	local namestr = self.controlName or nm
	namestr = tostring(namestr)
	self.choices = SF.safeClearTable(self.choices)
	self.choicesValues = SF.safeClearTable(self.choicesValues)
	self.choicesTooltips = SF.safeClearTable(self.choicesTooltips)
	
	local function shallowcpy(src, dest)
		for k=1, SF.GetSize(src) do
			dest[k] = src[k]
		end
		return dest
	end
	self.choices = shallowcpy(tblB.choices, self.choices)
	self.choicesValues = shallowcpy(tblB.choicesValues, self.choicesValues)
	self.choicesTooltips = shallowcpy(tblB.choicesTooltips, self.choicesTooltips)
	
	-- select the first value as the "current" value
	if tblB.indexValue then
		AC.logger:Debug("setting selected "..tostring(tblB.indexValue).." after assign - "..namestr)
		self.indexValue = tblB.indexValue
	
	--else
	--	if #tblB.choicesValues > 0 then
	--		AC.logger:Debug("setting selected as the first choicesValues" .. tblB.choicesValues[1].." after assign - "..namestr)
	--		self:selectFirst(tblB.choicesValues)
	--	end
	end
end

-- must specify the table that you want the first entry from
function AutoCategory.CVT:selectFirst(tbl)
	if not self.indexValue then
		if tbl and #tbl > 0 then
			self.indexValue = tbl[1]
			
		--else
		--	AC.logger:Debug("Error selecting first value on "..self.controlName)
		end
	end
end

-- append a row selection to the cvt tables
function AutoCategory.CVT:append(choice, value, tooltip)
	table.insert(self.choices, choice)
	if value then
		table.insert(self.choicesValues, value)
	end
	if tooltip then
		table.insert(self.choicesTooltips, tooltip)
	end
end

-- set the name of the associated control for these lists (if there is one)
function AutoCategory.CVT:setControlName(fld)
	self.controlName = fld
end

-- update the dropdown control with the new/current list values
function AutoCategory.CVT:updateControl()
	if not self.controlName then return end
	
	local dropdownCtrl = WINDOW_MANAGER:GetControlByName(self.controlName)
    if dropdownCtrl == nil then
        return
    end
	--AC.logger:Debug("updating control "..self.controlName)
	dropdownCtrl:UpdateChoices(self.choices, self.choicesValues, 
		self.choicesTooltips)  
end

-- remove an item from the dropdown lists (does not update the control)
function AutoCategory.CVT:removeItemChoice(removeItem)
	local removeIndex = -1
    if not self.choices then return end
	
	-- find the choice to remove
	local num = #self.choices
	for i = num, 1, -1 do
		if removeItem == self.choices[i] then
			removeIndex = i
			-- remove it
			table.remove(self.choices, removeIndex)
			if #self.choicesValues then
				table.remove(self.choicesValues, removeIndex)
			end
			if #self.choicesTooltips then
				table.remove(self.choicesTooltips, removeIndex)
			end
			--AC.logger:Debug("removeItemChoice: selecting first choicesValues - "..self.controlName)
			break
		end
	end
	
    if removeIndex <= 0 then return end
	if num == 1 then
		--select none
		self.indexValue = nil
		
	elseif removeIndex == num then
		--no next one, select previous one
		self.indexValue = self.choicesValues[num-1]
		
	else
		--select next one
		self.indexValue = self.choicesValues[removeIndex]
	end
end

-- -------------------------------------------------------
-- Rule functions and helpers

-- based on the requested rule name, create a name that
-- is not already in use (rule names must be unique)
function AutoCategory.GetUsableRuleName(name)
	local testName = name
	local index = 1
	while AC.cache.rulesByName[testName] ~= nil do
		testName = name .. index
		index = index + 1
	end
	return testName
end

-- Compile an individual Rule
-- Return a string that is either empty (good compile)
-- or an error string returned from the compile
--
-- Stores the compiled rule into AC.compiledRules table
local function CompileRule(rule)
    if rule == nil or rule.name == nil or rule.name == "" then
		return
	end
	AC.compiledRules = SF.safeTable(AC.compiledRules)

	rule:clearError()
	AC.compiledRules[rule:key()] = nil
	
	if rule.rule == nil or rule.rule == "" then
		rule:setError(true,"Missing rule definition")
		return rule.err
	end

    local rulestr = "return(" .. rule.rule .. ")"
    local compiledfunc, err = zo_loadstring(rulestr)
    if not compiledfunc then
		rule:setError(true, err)
		AC.logger:Warn("Rule "..rule.name.." failed to compile, with the following error: ".. err)
        AC.compiledRules[rule:key()] = nil
		return err
    end
    AC.compiledRules[rule:key()] = compiledfunc
    return ""
end


-- -------------------------------------------------
-- collected functions to be applied to a rule
--
-- This will be set as the metatable for each rule structure loaded in or created
-- because the metatable does not count against the stricture of no functions 
-- within saved variables.
AC.rulefuncs = {
	-- compile the rule
	compile = function(r) 
			--AC.logger:Info("Calling compile on rule "..r.name)
			return CompileRule(r) 
		end,
		
	-- check if rule def is valid (required keys all present)
	isValid = function(r) 
			AC.logger:Info("Calling isValid on rule "..r.name)
			return AutoCategory.isValidRule(r) 
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
	clearError = function(r,dmg,errm)
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
	
	-- compare a rule to another rule for certain equalities
	-- used for converting from acct/char rules to acctwide-only
	isequiv = function(r, a)
			if not a then return false, false end
			local notname = r.name ~= a.name
			local notrule = r.rule ~= a.rule
			return notname, notrule
		end
}

-- factory for creating new rules
function AutoCategory.CreateNewRule(name, tag)
	local rule = {
		name = name,
		description = "",
		rule = "true",
		tag = tag,
	}
	local mt = { __index = AC.rulefuncs, }
	setmetatable(rule,mt)
	return rule
end

-- factory for making copies of rules
function AutoCategory.CopyFrom(copyFrom)
	if not copyFrom then return end
	
	local ruleName = copyFrom.name
	-- get a unique name based on the old rule name
	local newName = AC.GetUsableRuleName(ruleName)
	local tag = copyFrom.tag
	if tag == "" then
		tag = AC_EMPTY_TAG_NAME
	end
	
	local newRule = AC.CreateNewRule(newName, tag)
	newRule.description = copyFrom.description
	newRule.rule = copyFrom.rule
	newRule.damaged = copyFrom.damaged
	newRule.err = copyFrom.err
	newRule.pred = nil		-- defaults to not pre-defined
	return newRule
end


-- -------------------------------------------------------
-- helper functions for BagRules (for bag settings)

-- -------------------------------------------------
-- collected functions to be applied to a bagrule
--
-- This will be set as the metatable for each bagrule structure loaded in or created
-- because the metatable does not count against the stricture of no functions 
-- within saved variables.
AC.bagrulefuncs = {
	isValid = function (bagrule)
			if not bagrule.name or bagrule.name == "" then
				return false
			end
			return true
		end,
		
    formatValue = function (bagrule)
			return bagrule.name
			--return string.format("(%04d) %s", bagrule.priority, bagrule.name )
		end,
		
	formatShow	= function (bagrule)
			local sn = nil
			local rule = bagrule:getBackingRule()
			if not rule then
				-- missing rule (nil was passed in)
				sn = string.format("|cFF4444(!)|r %s (%d)", bagrule.name, bagrule.priority)

			else
				if bagrule.AC_isHidden then
					-- grey out the "hidden" category header
					sn = string.format("|c626250%s (%d)|r", bagrule.name, bagrule.priority)

				else
					sn = string.format("%s (%d)", bagrule.name, bagrule.priority)
				end
			end
			return sn
		end,
		
	formatTooltip = function (bagrule)
			local tt = nil
			local rule = bagrule:getBackingRule()
			if not rule then
				-- missing rule (nil was passed in)
				tt = L(SI_AC_WARNING_CATEGORY_MISSING)

			else
				tt = rule:getDesc()
			end
			return tt
		end,
		
	getBackingRule = function (bagrule)
			if not bagrule.name then return nil end
			local rule = AC.GetRuleByName(bagrule.name)
			return rule
		end,
		
	-- When a rule changes names, referencees to it in the bag rules also need to change
	renameRule = function(bagrule, newName)
			bagrule.name = newName
		end,
		
	-- returns priority, rulename from a formatted BagRule text entry
	splitValue = function (value)
			return string.find(value, "%((%d+)%) (%a+)")
		end,
	
	-- comparison function used to sort bag rules by priority and then by name
	-- returns true if a is greater than b
	-- returns false if a is less than b
	sortByPriority = function (a, b)
			if b == nil then return true end

			-- b is not nil
			if a == nil then return false end

			local result = false
			-- a is not nil
			if a.priority and b.priority and a.priority ~= b.priority then
				result = a.priority > b.priority

			else
				if a.name == nil then return false end
				if b.name == nil then return true end
				result = a.name < b.name
			end
			return result
		end,
}



-- --------------------------------------------
-- Create a new Bag Entry (factory)
-- Rule parameter is required, priority is optional.
-- If a priority is not provided, default to 1000
-- Returns a table {name=, priority=} or nil
--
function AutoCategory.CreateNewBagRule(rule, priority)
	local rulename = nil
	local ruleprior = nil
	if rule and rule.name then
		rulename = rule.name
	end

	if rulename then
		if priority == nil then
			ruleprior = 1000
		else 
			ruleprior = priority
		end
	end
	local bagrule = {
		name = rulename,
		priority = ruleprior,
	}
	local mt = { __index = AC.bagrulefuncs, }
	setmetatable(bagrule,mt)
	return bagrule
end

-- Associate an existing BagRule (loaded from saved
-- variables) with the BagRule functions in a metatable.
--
function AutoCategory.AssociateBagRule(bagrule)
	if bagrule == nil then return end
	
	local mt = { __index = AC.bagrulefuncs, }
	setmetatable(bagrule,mt)
end