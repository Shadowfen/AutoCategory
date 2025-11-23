local SF = LibSFUtils

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
function AutoCategory.RuleList:size()
	return #self.ruleList
end

function AutoCategory.RuleList:AddRule(newRule, overwriteFlag)
	if not newRule or not newRule.name then return end	-- bad rule
	local rulename = newRule.name

	local ndx = self.ruleNames[rulename]
	if ndx then
		-- rule by name already in list
		if overwriteFlag then
			self.ruleList[ndx] = newRule
		end
		return
	end

	self.ruleList[#self.ruleList+1] = newRule
	self.ruleNames[rulename] = #self.ruleList
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
-- or nil if named rule does not exist
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
		if not self.ruleNames[arrules[k].name ] then
			self.ruleNames[arrules[k].name] = k
		end
	end
end
