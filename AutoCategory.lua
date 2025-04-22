----------------------
-- Aliases
local L = GetString
local SF = LibSFUtils
local AC = AutoCategory

local CVT = AutoCategory.CVT
local aclogger = AutoCategory.logger
local RuleApi = AutoCategory.RuleApi
--local BagRuleApi = AutoCategory.BagRuleApi
--local ARW = AutoCategory.ARW
local ac_rules = AutoCategory.RulesW

----------------------
-- Lists and variables

--AutoCategory.rules = {}	--  [#] rule {rkey, name, tag, description, rule, pred, damaged, err}
--AutoCategory.compiledRules = SF.safeTable(AutoCategory.compiledRules)
--AutoCategory.ARW = SF.safeTable(AutoCategory.ARW)

-- AutoCategory.saved contains table references from the appropriate saved variables - either acctSaved or charSaved
-- depending on the setting of charSaved.accountWide
AutoCategory.saved = {
    rules = {}, -- [#] rule {rkey, name, tag, description, rule, damaged, err} -- obsolete
    bags = {}, -- [bagId] {rules={name, priority, isHidden}, isUngroupedHidden} -- pairs with collapses
	general = {},   -- from savedvars
	appearance = {}, -- from savedvars
	collapses = {},  -- from savedvars -- charSaved.collapses or acctSaved.collapses -- pairs with bags
}

AutoCategory.cache = {
    bags_cvt = CVT:New(nil, nil, CVT.USE_VALUES + CVT.USE_TOOLTIPS), -- {choices{bagname}, choicesValues{bagid}, choicesTooltips{bagname}} -- for the bags themselves
							-- used for both the EditBag_cvt and ImportBag dropdowns
    entriesByBag = {}, -- [bagId] {choices{ico rule.name (pri)}, choicesValues{rule.name}, choicesTooltips{rule.desc/name or missing}} --
    entriesByName = {}, -- [bagId][rulename]  (BagRule){ name, priority, isHidden }
}

AutoCategory.BagRuleEntry = {}


local saved = AutoCategory.saved
local cache = AutoCategory.cache

local AC_EMPTY_TAG_NAME = L(SI_AC_DEFAULT_NAME_EMPTY_TAG)

function AutoCategory.debugCache()
    d("User rules: " .. AutoCategory.ARW:size()) --#AutoCategory.acctRules.rules)
    d("Saved rules: " .. #AutoCategory.saved.rules)						-- should be 0 after conversion
    d("Predefined rules: " .. #AutoCategory.predefinedRules)			-- predefined rules from base and plugins
    d("Combined rules: " .. ac_rules:sizeRules())						-- complete list of user rules and predefined rules
    d("Compiled rules: " .. SF.GetSize(ac_rules.compiled))
    d("Rules by Name: " .. SF.GetSize(ac_rules.ruleNames))	-- lookup table for rules by rule name
    d("Rules by Tag: " .. SF.GetSize(ac_rules.tagGroups))	-- actually returns the # of Tags defined
    d("Tags: " .. ac_rules:sizeTags())					-- returns the # of Tags defined
    d("Saved bags: " .. #AutoCategory.saved.bags)						-- returns # of bags, collections of bagrules by bagId
    d("Cache bags: " .. AutoCategory.cache.bags_cvt:size())			-- CVT of bags for bag id dropdowns, returns 3 for CVT
    d("Entries by Bag: " .. SF.GetSize(AutoCategory.cache.entriesByBag))		-- CVT of bagrules by bagid, so always returns # bags
    d("Entries by Name: " .. SF.GetSize(AutoCategory.cache.entriesByName))	-- bagrules lookup by bagid and rule name, returns # bags
end

--unused (debug) - Not sure why called "EBT" since it uses entriesByName!!
function AutoCategory.debugEBT()
	for k, v in pairs(AutoCategory.cache.entriesByName[1]) do
		d("k = "..k)
		if type(v) == "table" then
			for k1,v1 in pairs(v) do
				d("  k1="..k1.."  v1="..SF.str(v1))
			end
		else
		    d("v= "..SF.str(v))
		end
	end
end

--unused (debug)
function AutoCategory.debugTags()
	d("RulesW.tags:")
	for k, v in pairs(ac_rules.tags) do
		if type(v) == "table" then
			for k1,v1 in pairs(v) do
				d("k = "..k.."   k1="..k1.."  v1="..SF.str(v1))
			end
		else
		    d("k = "..k.." v= "..SF.str(v))
		end
	end
end

-- ------------------------ RulesW  -------------------------------
-- not a class - just a structure with functions
--[[
AutoCategory.RulesW = {
	ruleList= {},	--  [#] rule {rkey, name, tag, description, rule, pred, damaged, err}
	ruleNames={},		-- [name] rule#
	compiled = AutoCategory.compiledRules,	-- [name] function

	tags = {},		-- [#] tagname
	tagGroups={},	-- [tag] CVT{choices{rule.name}, choicesTooltips{rule.desc/name}}
}
--]]
ac_rules = AutoCategory.RulesW

-- Add a tag if it is not already in the list(s)
function AutoCategory.RulesW.AddTag(name)
	local RulesW = AutoCategory.RulesW
	if not name then return end
	if not RulesW.tagGroups[name] then
		RulesW.tags[#RulesW.tags+1] = name
		RulesW.tagGroups[name] = CVT:New(nil,nil,CVT.USE_TOOLTIPS) -- uses choicesTooltips
	end
end

-- Compile all of the rules that we know (if necessary)
-- Mark those that failed to compile as damaged
--
function AutoCategory.RulesW.CompileAll(self)
	if not self then self = AutoCategory.RulesW end
	-- reset AutoCategory.compiledRules to empty, creating only if necessary
	self.compiled = SF.safeClearTable(self.compiled)

    if self.ruleList == nil then
		-- there are no rules to compile
		return
    end
	-- compile and store each of the rules in the ruleset
    for j = 1, #self.ruleList do
        if self.ruleList[j] then
            RuleApi.compile(self.ruleList[j])
        end
    end
end


-- return number of entries in the base rule list
function AutoCategory.RulesW.sizeRules(self)
	return #self.ruleList
end

-- return number of entries in the base tag list
function AutoCategory.RulesW.sizeTags(self)
	return #self.tags
end

-- override addRule from RuleList to add in lookup table updates
function AutoCategory.RulesW.AddRule(self, newRule, overwriteFlag)
	if not newRule or not newRule.name then return end	-- bad rule
	if not newRule.tag or newRule.tag == "" then
        newRule.tag = AC_EMPTY_TAG_NAME
    end
	self.AddTag(newRule.tag)

	local ndx = self.ruleNames[newRule.name]
	if ndx then
		-- rule by name already in list
		if overwriteFlag then
			self.ruleList[ndx] = newRule
		end
	else
		self.ruleList[#self.ruleList+1] = newRule
		self.ruleNames[newRule.name] = #self.ruleList
	end
	self.tagGroups[newRule.tag]:append(newRule.name, nil, AutoCategory.RuleApi.getDesc(newRule))

	RuleApi.compile(newRule)
end
--]]
-- ---------------------end RulesW  -------------------------------


-- ----------------------------- Sorting comparators ------------------
-- for sorting rules by name
-- returns true if the a should come before b
local function RuleSortingFunction(a, b)
    --alphabetical sort, cannot have same name rules
    if not (a and b and a.name and b.name) then
        return false
    end
    return a.name < b.name
end

-- for sorting rules by tag and name
-- returns true if the a should come before b
-- unused
--[[
local function RuleDataSortingFunction(a, b)
    local result = false
    if a.tag ~= b.tag then
        result = a.tag < b.tag

    else
        --alphabetical sort, cannot have same name rules
        result = a.name < b.name
    end

    return result
end
--]]

-- for sorting bagged rules by priority and name
-- returns true if the a should come before b
local function BagRuleSortingFunction(a, b)
    local result = false
	if not (a and b and a.name and b.name and a.priority and b.priority) then return false end
    if a.priority ~= b.priority then
        result = a.priority > b.priority

    else
		if type(a.name) == "table" or type(b.name) == "table" then return false end
		result = a.name < b.name
    end
    return result
end

-- swap between account-wide and char-wide settings
function AutoCategory.UpdateCurrentSavedVars()
	--local RulesW = AutoCategory.RulesW
    -- general, and appearance are always accountWide
    AutoCategory.saved.general = AutoCategory.acctSaved.general
    AutoCategory.saved.appearance = AutoCategory.acctSaved.appearance

	--AutoCategory.saved.displayOrder = AutoCategory.acctSaved.displayOrder
	AutoCategory.acctSaved.displayOrder = nil
	AutoCategory.acctSaved.displayName = nil

	AutoCategory.charSaved.general = nil	-- fix old data corruption error
	AutoCategory.charSaved.appearance = nil	-- fix old data corruption error
	AutoCategory.charSaved.displayOrder = nil
	AutoCategory.charSaved.displayName = nil

	-- rule definitions are always account-wide
	-- AutoCategory.acctRules only has user-defined rules
	-- RulesW.ruleList will have acctRules plus the predefined rules

	table.sort(ac_rules.ruleList, RuleSortingFunction)

    ac_rules:CompileAll()

	-- bags/collapses might or might not be acct wide
    if not AutoCategory.charSaved.accountWide then
        AutoCategory.saved.bags = AutoCategory.charSaved.bags
        AutoCategory.saved.collapses = AutoCategory.charSaved.collapses
        --AutoCategory.saved.displayOrder = AutoCategory.charSaved.displayOrder

    else
        AutoCategory.saved.bags = AutoCategory.acctSaved.bags
        AutoCategory.saved.collapses = AutoCategory.acctSaved.collapses
        --AutoCategory.saved.displayOrder = AutoCategory.acctSaved.displayOrder
    end
	if AutoCategory.saved.bags[7] then AutoCategory.saved.bags[7] = nil end -- fix old data corruption

    AutoCategory.cacheInitialize()
end

-- -----------------------------------------------------------
-- Manage collapses
-- -----------------------------------------------------------
function AutoCategory.LoadCollapse()
    if not AutoCategory.acctSaved.general["SAVE_CATEGORY_COLLAPSE_STATUS"] then
        --init
        return AutoCategory.ResetCollapse(AutoCategory.saved)
    end
end

function AutoCategory.ResetCollapse(vars)
    for j = 1, #cache.bags_cvt do
		local bagcol = vars.collapses[j]
		for k,_ in pairs(bagcol) do
			bagcol[k] = nil
		end
	end
end

-- Determine if the specified category of the particular bag is collapsed or not
function AutoCategory.IsCategoryCollapsed(bagTypeId, categoryName)
	if bagTypeId == nil or categoryName == nil then return false end

	local collapsetbl = SF.safeTable(AutoCategory.saved.collapses[bagTypeId])
    return collapsetbl[categoryName] or false
end


function AutoCategory.SetCategoryCollapsed(bagTypeId, categoryName, collapsed)
	if not categoryName then return end
	AutoCategory.saved.collapses[bagTypeId][categoryName] = collapsed
end
-- -----------------------------------------------------------

-- will need to rebuild RulesW.ruleList after this
function AutoCategory.ResetToDefaults()

	AutoCategory.ARW.clear()
	ZO_DeepTableCopy(AutoCategory.defaultAcctSettings.rules, AutoCategory.acctRules.rules)
	AutoCategory.ARW = AutoCategory.RuleList:New(AutoCategory.acctRules.rules)

	AutoCategory.acctSaved.rules = nil	-- no longer used
	AutoCategory.charSaved.rules = nil	-- no longer used

	AutoCategory.acctSaved.bags = SF.safeClearTable(AutoCategory.acctSaved.bags)
    ZO_DeepTableCopy(AutoCategory.defaultAcctSettings.bags, AutoCategory.acctSaved.bags)

	AutoCategory.charSaved.bags = SF.safeClearTable(AutoCategory.charSaved.bags)
    ZO_DeepTableCopy(AutoCategory.defaultSettings.bags, AutoCategory.charSaved.bags)

    AutoCategory.ResetCollapse(AutoCategory.acctSaved)
    AutoCategory.ResetCollapse(AutoCategory.charSaved)

	AutoCategory.acctSaved.appearance = SF.safeClearTable(AutoCategory.acctSaved.appearance)
    ZO_DeepTableCopy(AutoCategory.defaultAcctSettings.appearance,
			AutoCategory.acctSaved.appearance)

	AutoCategory.acctSaved.general = SF.safeClearTable(AutoCategory.acctSaved.general)
	ZO_DeepTableCopy(AutoCategory.defaultAcctSettings.general,
			AutoCategory.acctSaved.general)

	AutoCategory.charSaved.general = nil	-- fix old data corruption error
	AutoCategory.charSaved.appearance = nil	-- fix old data corruption error

	AutoCategory.charSaved.accountWide = AutoCategory.defaultSettings.accountWide
end

-- create local alias for references in this file
local setCategoryCollapsed = AutoCategory.SetCategoryCollapsed

-- rename a rule, updates the cache lookups and bagsets too
function AutoCategory.renameRule(oldName, newName)
	if oldName == newName then return oldname end

	local rule = AutoCategory.GetRuleByName(oldName)
	if rule == nil then return end		-- no such rule to rename

	local oldrndx = ac_rules.ruleNames[oldName]
	ac_rules.ruleNames[oldName] = nil

	newName = AutoCategory.GetUsableRuleName(newName)

	rule.name = newName
	ac_rules.ruleNames[rule.name] = oldrndx

	AutoCategory.renameBagRule(oldName, newName)
	return newName
end

-- When a rule changes names, referencees to in the bag rules also need to change
function AutoCategory.renameBagRule(oldName, newName)
	if oldName == newName then return end

	--Update bags so that every entry has the same name, should be changed to new name.
	for i = 1, 6 do	-- for all bags
		local bag = AutoCategory.saved.bags[i]
		if not bag then 
			bag = { rules = {}, }
			AutoCategory.saved.bags[i] = bag
		end
		local rules = bag.rules
		for j = 1, #rules do   -- for all bagrules in the bag
			local rule = rules[j]
			if rule.name == oldName then
				rule.name = newName
			end
		end
	end
end

-- initialize the RulesW.ruleNames, RulesW.tagGroups, and the RulesW.tags tables from RulesW.ruleList
function AutoCategory.cacheRuleInitialize()
	-- initialize the rules-based lookups
    ac_rules.ruleNames = SF.safeClearTable(ac_rules.ruleNames)
    ac_rules.tagGroups = SF.safeClearTable(ac_rules.tagGroups)
    ac_rules.tags = SF.safeClearTable(ac_rules.tags)

	-- refill the rules-based lookups
	local ruletbl = ac_rules.ruleList
    for ndx = 1, #ruletbl do
		-- add rule to ac_rules.ruleNames lookup
        local rule = ruletbl[ndx]
        local name = rule.name
        ac_rules.ruleNames[name] = ndx

		-- ensure tag value is valid
        local tag = rule.tag
        if tag == "" then
            tag = AC_EMPTY_TAG_NAME
        end

        --update tag grouping lookups
		ac_rules.AddTag(tag)
        ac_rules.tagGroups[tag]:append(name, nil, RuleApi.getDesc(rule))
    end
end


-- populate the entriesByName and entriesByBag lists in the cache from the saved.bags table
-- bagId needs to be between 1 and 6 (inclusive)
function AutoCategory.cacheInitBag(bagId)
	if bagId == nil or bagId < 1 or bagId > 6 then 
		return
	end

	-- initialize the bag-based lookups for this bag
	cache.entriesByName[bagId] = SF.safeTable(cache.entriesByName[bagId])
    ZO_ClearTable(cache.entriesByName[bagId])

	cache.entriesByBag[bagId] = CVT:New(nil, nil, CVT.USE_VALUES + CVT.USE_TOOLTIPS)

	local ename = cache.entriesByName[bagId]	-- { [name] BagRule{ name, priority, isHidden } }
	local ebag = cache.entriesByBag[bagId]		-- CVT

	-- fill the bag-based lookups
    -- load in the bagged rules (sorted by priority high-to-low) into the dropdown
	if AutoCategory.saved.bags[bagId] == nil then
		AutoCategory.saved.bags[bagId] = {rules={}}
	elseif not AutoCategory.saved.bags[bagId].rules then
		AutoCategory.saved.bags[bagId].rules={}
	end
	local svdbag = AutoCategory.saved.bags[bagId]
	table.sort(svdbag.rules, BagRuleSortingFunction)

	aclogger:Debug("Initializing bag "..bagId.." with bagrules")
	for entry = 1, #svdbag.rules do
		local bagrule = svdbag.rules[entry] -- BagRule {name, priority, isHidden}
		if not bagrule then break end

		local ruleName = bagrule.name
		--aclogger:Debug("bag "..entry.." bagrule.name "..tostring(bagrule.name))
		if not ename[ruleName] then
			ename[ruleName] = bagrule
			ebag.choicesValues[#ebag.choicesValues+1] = AutoCategory.BagRuleApi.formatValue(bagrule)

			local sn = AutoCategory.BagRuleApi.formatShow(bagrule)
			local tt = AutoCategory.BagRuleApi.formatTooltip(bagrule)
			ebag.choices[#ebag.choices+1] = sn
			ebag.choicesTooltips[#ebag.choicesTooltips+1] = tt
        else
            ename[ruleName] = bagrule
		end
	end
end

-- populate the entriesByName and entriesByBag lists in the cache from the saved.bags table
function AutoCategory.cacheBagInitialize()
	-- initialize the bag-based lookups
    ZO_ClearTable(cache.entriesByName)
    ZO_ClearTable(cache.entriesByBag)

	-- fill the bag-based lookups
    -- load in the bagged rules (sorted by priority high-to-low) into the dropdown
    for bagId = 1, 6 do
		AutoCategory.cacheInitBag(bagId)
    end
end


-- ----------------------------------------------------
-- assumes that RulesW.ruleList and saved.bags have entries but
-- some or all of the cache tables need (re)initializing
--
function AutoCategory.cacheInitialize()
    -- initialize the rules-based lookups
    AutoCategory.cacheRuleInitialize()
	AutoCategory.cacheBagInitialize()

end


-- find and return the rule referenced by name
function AutoCategory.GetRuleByName(name)
    if not name then
        return nil
    end

	local ndx = ac_rules.ruleNames[name]
    if not ndx then
        return nil
    end

    return ac_rules.ruleList[ndx]
end

-- when we add a new rule to RulesW.ruleList, also add it to the various lookups and dropdowns
-- returns nil on success or error message
function AutoCategory.cache.AddRule(rule)
    if not rule or not rule.name then
        return "AddRule: Rule or name of rule was nil"
    end -- can't use a nil rule

    if not rule.tag or rule.tag == "" then
        rule.tag = AC_EMPTY_TAG_NAME
    end

    if ac_rules.tagGroups[rule.tag] == nil then
        ac_rules.tagGroups[rule.tag] = CVT:New(nil, nil, CVT.USE_TOOLTIPS) -- uses choicesTooltips
    end

	local rule_ndx = ac_rules.ruleNames[rule.name]
    if rule_ndx then
		-- rule already exists
		-- overwrite rule with new one
		ac_rules.ruleList[rule_ndx] = rule

	else
		-- add the new rule
		ac_rules.ruleList[#ac_rules.ruleList+1] = rule
		rule_ndx = #ac_rules.ruleList
		ac_rules.ruleNames[rule.name] = rule_ndx
		ac_rules.tagGroups[rule.tag]:append(rule.name, nil, AutoCategory.RuleApi.getDesc(rule))
    end

	RuleApi.compile(rule)
end

-- Set up the context menu item for AutoCategory
local LCM = LibCustomMenu
local function setupContextMenu()

	local function AC_GetItem(rowControl) 
		local bagId, slotIndex = ZO_Inventory_GetBagAndIndex(rowControl)
		local itemId = GetItemId(bagId, slotIndex)
		local name = GetItemName(bagId, slotIndex)
		d("[AC] "..tostring(name).."   itemId = "..tostring(itemId))
	end
	local function AC_AddMenuItem(rowControl, slotActions)
		AddCustomMenuItem("AC: Get itemId", function() AC_GetItem(rowControl) end, MENU_ADD_OPTION_LABEL)
		  --Show the context menu entries at the inventory row now
		  ShowMenu(rowControl)
	end
	LCM:RegisterContextMenu(AC_AddMenuItem, LibCustomMenu.CATEGORY_LATE )
end

function AutoCategory.initializePlugins()
	-- initialize plugins
	for _, v in pairs(AutoCategory.Plugins) do
		if v.init then
			v.init()
		end
	end

end	

-- Add the rules in a table of rules to the combined, acctRules, and predefinedRules lists
-- as appropriate.
-- The table must be { rules = {} } and tbl.rules contains the list of rules.
--
-- The tblname is used only for logger messages - i.e. debugging.
--
-- If notdel is true then the rules are NOT removed from the source table.
-- The ispredef flag signals that ALL of the rules in the source table are predefines if true.
--
local function addTableRules(tbl, tblname, ispredef)
	--local RulesW = AutoCategory.RulesW
	if not tbl.rules or tbl.rules == ac_rules.ruleList then return end

	aclogger:Info("Adding rules from table "..(tblname or "unknown").."  count = "..#tbl.rules)

	-- create name lookup for acctRules
	--local lkacctRules = AutoCategory.ARW:getLookup()
	local newName

	-- add a rule to the combined rules list and the name-lookup
	local function addCombinedRule(rl)
		ac_rules.ruleList = SF.safeTable(ac_rules.ruleList)
		local n = ac_rules.ruleNames[rl.name]
		if not n then
			ac_rules.ruleList[#ac_rules.ruleList+1] = rl
			--aclogger:Info("Adding rule "..rl.name.." to ac_rules.ruleList ndx="..#ac_rules.ruleList)
			ac_rules.ruleNames[rl.name] = #ac_rules.ruleList
			return true
		else
			ac_rules.ruleList[n] = rl
			--aclogger:Info("Overwriting rule "..rl.name.." to Rulac_rulesesW.ruleList ndx="..n)
			ac_rules.ruleNames[rl.name] = n
		end
		return false
	end

	local function addPredef(stbl, rule)
		-- add to predefinedRules list
		if stbl.rules ~= AutoCategory.predefinedRules then
			AutoCategory.predefinedRules[#AutoCategory.predefinedRules+1] = rule
		end
	end

	local function addUserRule(stbl, rule)
		-- add to acctRules list
		if stbl.rules ~= AutoCategory.acctRules.rules then
			return AutoCategory.ARW:addRule(rule)
		end
	end

	-- process all of the rules in the table
	local v, r
	for k=#tbl.rules, 1, -1 do
		v = tbl.rules[k]
		if ispredef == true then
			v.pred=1
		end

		r = AutoCategory.GetRuleByName(v.name)
		if r then
			aclogger:Warn("Found duplicate rule name - "..v.name)
			-- already have one
			if v.rule == r.rule then
				-- same rule def, so don't add it again
				aclogger:Warn("1 Dropped duplicate rule - "..v.name.."  from AC.rules sourced "..(tblname or "unknown"))

			else
				local oldname = v.name
				-- rename different rule
				newName = AutoCategory.GetUsableRuleName(v.name)
				v.name = newName
				aclogger:Warn("Renaming duplicate rule name - "..oldname.." to "..v.name)

				addCombinedRule(v)
				AutoCategory.renameBagRule(oldname, newName)
				if RuleApi.isPredefined(v) then 
					addPredef(tbl, v)

				else
					-- add to acctRules
					addUserRule(tbl, v)
					aclogger:Warn("adding to user rules - "..v.name.."  from sourced "..(tblname or "unknown"))
				end
			end

		else
			-- brand new (never seen) rule
			-- add it to the combined (AutoCategory.rule) list
			addCombinedRule(v)

			if RuleApi.isPredefined(v) then 
				-- it's a predefined rule
				addPredef(tbl, v)
				aclogger:Warn("adding to predefined rules - "..v.name.."  from sourced "..(tblname or "unknown"))

		    else
				-- it's a user rule
				addUserRule(tbl, v)
				aclogger:Warn("adding to user rules - "..v.name.."  from sourced "..(tblname or "unknown"))
			end
        end
    end
end

local function pruneUserRules()
	aclogger:Debug ("Executing pruneUserRules ")
	local arrules = AutoCategory.ARW.ruleList --AutoCategory.acctRules.rules
	local lkacctRules = AutoCategory.ARW:getLookup()
	for k = #arrules,1,-1 do
		local ndx = lkacctRules[arrules[k].name]
		if  ndx and k ~= ndx then
			aclogger:Debug ("Removing duplicate rule ".. arrules[k].name.." from acctRules")
			AutoCategory.ARW.removeRule(ndx)
			--table.remove(arrules, k)
		end
	end

	-- remove predefined rules from acctRules
	for k = #AutoCategory.predefinedRules,1,-1 do
		local ndx = lkacctRules[AutoCategory.predefinedRules[k].name]
		aclogger:Debug ("Removing predefined rule ".. AutoCategory.predefinedRules[k].name.." from acctRules")
		AutoCategory.ARW:removeRule(ndx)
		--table.remove(arrules, k)
	end
end

-- cannot use this until after addons are finally loaded!!
local function loadPluginPredefines()
	aclogger:Debug ("Executing loadPluginPredefines ")
	-- add plugin predefined rules to the base predefined rules
	for name, plugin in pairs(AutoCategory.Plugins) do
		if plugin.predef then
			aclogger:Debug ("Processing predefs from plugin ".. name.." "..SF.GetSize(plugin.predef))

			-- process all of the rules in the table
			addTableRules( { rules=plugin.predef}, name..".predefinedRules", true)
		end
	end
	aclogger:Debug ("Done executing loadPluginPredefines ")
	aclogger:Debug("2.5 predefined "..SF.GetSize(AutoCategory.predefinedRules))
 end


-- setup that needs to be done when the addon is loaded into the game
function AutoCategory.onLoad(event, addon)
    if addon ~= AutoCategory.name then
        return
    end

	-- make sure we are not called again
	AutoCategory.evtmgr:unregEvt(EVENT_ADD_ON_LOADED)

	AutoCategory.logger = SF.Createlogger("AutoCategory")
	aclogger = AutoCategory.logger
	AutoCategory.logger:SetEnabled(true)

    --AutoCategory.checkLibraryVersions()

    -- load our saved variables (no longer loads pre-defined rules)
    AutoCategory.acctSaved, AutoCategory.charSaved = SF.getAllSavedVars("AutoCategorySavedVars",
		1.1, AutoCategory.defaultAcctSettings, AutoCategory.defaultCharSettings)
	if SF.isEmpty(AutoCategory.acctSaved.bags) then 
		SF.defaultMissing(AutoCategory.acctSaved.bags, AutoCategory.defaultAcctBagSettings.bags)
	end
	if SF.isEmpty(AutoCategory.charSaved.bags) then
		SF.defaultMissing(AutoCategory.charSaved.bags, AutoCategory.defaultAcctBagSettings.bags)
	end

		-- There are no char-level variables for AutoCatRules!
    AutoCategory.acctRules  = SF.getAcctSavedVars("AutoCatRules", 1.1, AutoCategory.default_rules)
	--if SF.isEmpty(AutoCategory.acctRules) then
	--	SF.defaultMissing(AutoCategory.acctRules,AutoCategory.default_rules)
	--end
	AutoCategory.ARW = AutoCategory.RuleList:New(AutoCategory.acctRules.rules)

	AutoCategory.LoadCollapse()

	-- Set up the context menu item for AutoCategory
	setupContextMenu()

	-- hooks
	AutoCategory.HookGamepadMode()
	AutoCategory.HookKeyboardMode()

end

-- --------------------------------------------------------------------
-- keep track of registered events for AutoCategory
AutoCategory.evtmgr = SF.EvtMgr:New("AutoCategory")

-- only runs once
-- continues initialization after all addons are loaded into the game
function AutoCategory.onPlayerActivated()
	local evtmgr = AutoCategory.evtmgr

	-- make sure we are only called once
	evtmgr:unregEvt(EVENT_PLAYER_ACTIVATED)

	evtmgr:registerEvt(EVENT_CLOSE_GUILD_BANK, function () AutoCategory.BulkMode = false end)
	evtmgr:registerEvt(EVENT_CLOSE_BANK, function () AutoCategory.BulkMode = false end)

	--capabilities with other (older) add-ons
	IntegrateQuickMenu()

	AutoCategory.meta = SF.safeTable(AutoCategory.meta)
	SF.addonMeta(AutoCategory.meta,"AutoCategory")

	-- add plugin predefined rules to the combined rules and name-lookup
	loadPluginPredefines()
	local pd = { rules = AutoCategory.predefinedRules, }
	addTableRules(pd, ".predefinedRules", true)
	--pruneUserRules()

	addTableRules(AutoCategory.acctRules, ".acctRules", false)
	addTableRules(AutoCategory.acctSaved, ".acctSaved", false)
	AutoCategory.acctSaved.rules = nil	-- no longer used
	addTableRules(AutoCategory.charSaved, ".charSaved", false)
	AutoCategory.charSaved.rules = nil	-- no longer used

	AutoCategory.logger:Debug("2.5 predefined "..SF.GetSize(AutoCategory.predefinedRules))

    AutoCategory.UpdateCurrentSavedVars()
	AutoCategory.initializePlugins()
	AutoCategory.cacheInitialize()
	AutoCategory.AddonMenuInit()
	AutoCategory.Inited = true -- put back in for BetterUI users, AutoCategory itself does not use this.
end

do
	-- register our event handler function to be called to do initialization
	AutoCategory.evtmgr:registerEvt(EVENT_ADD_ON_LOADED, 		AutoCategory.onLoad)
	AutoCategory.evtmgr:registerEvt(EVENT_PLAYER_ACTIVATED, 	AutoCategory.onPlayerActivated)
end


-- -----------------------------------------------
--== Interface ==--
local AC_DECON = 880
local AC_IMPROV = 881
local UV_DECON = 882

local inven_data = {
	[INVENTORY_BACKPACK] = {
		object = ZO_PlayerInventory,
		control = ZO_PlayerInventory,
	},

	[INVENTORY_CRAFT_BAG] = {
		object = ZO_CraftBag,
		control = ZO_CraftBag,
	},

	[INVENTORY_GUILD_BANK] = {
		object = ZO_GuildBank,
		control = ZO_GuildBank,
	},

	[INVENTORY_HOUSE_BANK] = {
		object = ZO_HouseBank,
		control = ZO_HouseBank,
	},

	[INVENTORY_BANK] = {
		object = ZO_PlayerBank,
		control = ZO_PlayerBank,
	},

	[AC_DECON] = {
		object = SMITHING.deconstructionPanel.inventory,
		control = SMITHING.deconstructionPanel.control,
	},
	[AC_IMPROV] = {
		object = SMITHING.improvementPanel.inventory,
		control = SMITHING.improvementPanel.control,
	},

	[UV_DECON] = {
		object = UNIVERSAL_DECONSTRUCTION.deconstructionPanel.inventory,
		control = UNIVERSAL_DECONSTRUCTION.deconstructionPanel.control,
	},
}

local function refreshList(inventoryType, even_if_hidden)
	if even_if_hidden == nil then even_if_hidden = false end
	if not inventoryType or not inven_data[inventoryType] then return end

	local obj = inven_data[inventoryType].object
	local ctl = inven_data[inventoryType].control

	if inventoryType == AC_DECON then
		if even_if_hidden == false and not ctl:IsHidden() then
			obj:PerformFullRefresh()
		end

	elseif inventoryType == AC_IMPROV then
		if even_if_hidden == false and not ctl:IsHidden() then
			obj:PerformFullRefresh()
		end

	elseif inventoryType == UV_DECON then
		if even_if_hidden == false and not ctl:IsHidden() then
			obj:PerformFullRefresh()
		end

	else
		PLAYER_INVENTORY:UpdateList(inventoryType, even_if_hidden)
	end
end

-- make accessible
AutoCategory.RefreshList = refreshList

function AutoCategory.RefreshCurrentList(even_if_hidden)
	if not even_if_hidden then even_if_hidden = false end

	refreshList(INVENTORY_BACKPACK, even_if_hidden)
	refreshList(INVENTORY_CRAFT_BAG, even_if_hidden)
	refreshList(INVENTORY_GUILD_BANK, even_if_hidden)
	refreshList(INVENTORY_HOUSE_BANK, even_if_hidden)
	refreshList(INVENTORY_BANK, even_if_hidden)
	refreshList(AC_DECON, even_if_hidden)
	refreshList(AC_IMPROV, even_if_hidden)
	refreshList(UV_DECON, even_if_hidden)
end
-- create local alias for references within this file

-- -----------------------------------------------
-- used only for AC_ItemRowHeader functions
local function getBagTypeId(header)
	SF.dTable(header,5,"getBagTypeId - header")
	local bagTypeId = header.slot.dataEntry.data.AC_bagTypeId
    if not bagTypeId then
		bagTypeId = header.slot.dataEntry.AC_bagTypeId
	end
	return bagTypeId
end

-- called from AutoCategory.xml
function AC_ItemRowHeader_OnMouseEnter(header)
    local cateName = header.slot.dataEntry.data.AC_categoryName
    local bagTypeId = getBagTypeId(header)


    local collapsed = AutoCategory.IsCategoryCollapsed(bagTypeId, cateName)
    local markerBG = header:GetNamedChild("CollapseMarkerBG")

    if AutoCategory.acctSaved.general["SHOW_CATEGORY_COLLAPSE_ICON"] then
        markerBG:SetHidden(false)
        if collapsed then
            markerBG:SetTexture("EsoUI/Art/Buttons/plus_over.dds")

        else
            markerBG:SetTexture("EsoUI/Art/Buttons/minus_over.dds")
        end

    else
        markerBG:SetHidden(true)
    end
end

-- called from AutoCategory.xml
function AC_ItemRowHeader_OnMouseExit(header)
    local markerBG = header:GetNamedChild("CollapseMarkerBG")
    markerBG:SetHidden(true)
end

-- called from AutoCategory.xml
-- collapse/expand a header by clicking on the -/+ icon
function AC_ItemRowHeader_OnMouseClicked(header)
    if (AutoCategory.acctSaved.general["SHOW_CATEGORY_COLLAPSE_ICON"] == false) then
        return
    end

    local cateName = header.slot.dataEntry.data.AC_categoryName
    local bagTypeId = getBagTypeId(header)

    local collapsed = AutoCategory.IsCategoryCollapsed(bagTypeId, cateName)
    setCategoryCollapsed(bagTypeId, cateName, not collapsed)
    AutoCategory.RefreshCurrentList()
end

-- called from AutoCategory.xml
-- context menu for collapse/expand on category headers
function AC_ItemRowHeader_OnShowContextMenu(header)
    ClearMenu()
    local cateName = header.slot.dataEntry.data.AC_categoryName
    local bagTypeId = getBagTypeId(header)

	-- add either single Expand or Collapse to menu as appropriate for category state
    local collapsed = AutoCategory.IsCategoryCollapsed(bagTypeId, cateName)
    if collapsed then
        AddMenuItem(
            L(SI_CONTEXT_MENU_EXPAND),
            function()
                setCategoryCollapsed(bagTypeId, cateName, false)
                AutoCategory.RefreshCurrentList()
            end
        )

    else
        AddMenuItem(
            L(SI_CONTEXT_MENU_COLLAPSE),
            function()
                setCategoryCollapsed(bagTypeId, cateName, true)
                AutoCategory.RefreshCurrentList()
            end
        )
    end

	-- add Expand All to menu
    AddMenuItem(
        L(SI_CONTEXT_MENU_EXPAND_ALL),
        function()
            for k, _ in pairs(AutoCategory.saved.collapses[bagTypeId]) do
				setCategoryCollapsed(bagTypeId,k,false)
            end
            AutoCategory.RefreshCurrentList()
        end
    )

	-- add Collapse All to menu
    AddMenuItem(
        L(SI_CONTEXT_MENU_COLLAPSE_ALL),
        function()
            for k, _ in pairs(AutoCategory.saved.collapses[bagTypeId]) do
				setCategoryCollapsed(bagTypeId,k,true)
            end
			setCategoryCollapsed(bagTypeId,AutoCategory.saved.appearance["CATEGORY_OTHER_TEXT"],true)
            AutoCategory.RefreshCurrentList()
        end
    )
    ShowMenu()
end

-- called from binding.xml
-- toggle AutoCategory on or off
function AC_Binding_ToggleCategorize()
    AutoCategory.Enabled = not AutoCategory.Enabled
    if AutoCategory.acctSaved.general["SHOW_MESSAGE_WHEN_TOGGLE"] then
        if AutoCategory.Enabled then
            d(L(SI_MESSAGE_TOGGLE_AUTO_CATEGORY_ON))

        else
            d(L(SI_MESSAGE_TOGGLE_AUTO_CATEGORY_OFF))
        end
    end
    AutoCategory.RefreshCurrentList()
end
