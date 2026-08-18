local SF = LibSFUtils

-- -------------------------------------------------
-- collected (wrapper) functions to be applied to a rule list
--
AutoCategory.RuleList = ZO_Object:Subclass()
--AutoCategory.RuleMetatable = {
--    __index = AutoCategory.RuleApiMixin,
--}
-- creates a rule list wrapper with a numeric-sequenced list of rules (not under a .rules!)
function AutoCategory.RuleList:New(...)
    local obj = ZO_Object.New(self)
    obj:Initialize(...)
    return obj
end

-- rule list wrapper adds a name lookup to accompany the base list of rules
function AutoCategory.RuleList:Initialize(rules)
	self.ruleList = rules
	self.ruleNames = {}		-- lookup by name for ruleList   [name] ruleListIndex
	local arrules = self.ruleList
	for k = #arrules,1,-1 do
		if not self.ruleNames[arrules[k].name ] then
			self.ruleNames[arrules[k].name] = k
		end
		AutoCategory.attachRuleMixin(arrules[k])
	end
end

-- return number of entries in the base rule list
function AutoCategory.RuleList:size()
	return #self.ruleList
end

function AutoCategory.RuleList:AddRule(newRule, overwriteFlag)
	if not newRule or not newRule.name then return end	-- bad rule
	AutoCategory.attachRuleMixin(newRule)

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

function AutoCategory.RuleList:rebuildLookup()
    SF.safeClearTable(self.ruleNames)

    for k = #self.ruleList, 1, -1 do
        local name = self.ruleList[k].name
        if name and not self.ruleNames[name] then
            self.ruleNames[name] = k
        end
    end
end

-- remove a rule from the ruleList
function AutoCategory.RuleList:removeRuleByName(ruleName)
    if not ruleName then return end

    local ndx = self.ruleNames[ruleName]
    if not ndx then return end

    table.remove(self.ruleList, ndx)
    self:rebuildLookup()
end

-- remove a rule from the ruleList by position (index) in the ruleList
function AutoCategory.RuleList:removeRule(ndx)
    if not ndx or not self.ruleList[ndx] then return end

    table.remove(self.ruleList, ndx)
    self:rebuildLookup()
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
function AutoCategory.RuleList:clear()
    SF.safeClearTable(self.ruleList)
    SF.safeClearTable(self.ruleNames)
end

-- returns the name lookup table used by the wrapper (temporary measure)
function AutoCategory.RuleList.getLookup(self)
	return self.ruleNames
end

-- sort the contents of the ruleList using sortfn
function AutoCategory.RuleList:sort(sortfn)
    if type(sortfn) ~= "function" then return end

    table.sort(self.ruleList, sortfn)
    self:rebuildLookup()
end