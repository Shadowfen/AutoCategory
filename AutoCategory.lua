----------------------
-- Aliases
local L = GetString
local SF = LibSFUtils
local AutoCat = AutoCategory

local CVT = AutoCategory.CVT
local ac_rules = AutoCategory.RulesW

-- restore a version of d() that is not captured by libDebugLogger
local sysd = function(msg)
    CHAT_ROUTER:AddSystemMessage(msg)
end

AutoCat_Internal = {}
----------------------
-- Lists and variables

-- AutoCategory.saved contains table references from the appropriate saved variables - either acctSaved or charSaved
-- depending on the setting of charSaved.accountWide
AutoCat.saved = {
    rules = {}, -- [#] rule {rkey, name, tag, description, rule, damaged, err} -- obsolete
    bags = {}, -- [bagId] {rules={name, runpriority, showpriority, isHidden}, isUngroupedHidden} -- pairs with collapses
	general = {},   -- from savedvars
	appearance = {}, -- from savedvars
	collapses = {},  -- from savedvars -- charSaved.collapses or acctSaved.collapses -- pairs with bags
}

AutoCat.cache = {
    bags_cvt = CVT:New(nil, nil, CVT.USE_VALUES + CVT.USE_TOOLTIPS), -- {choices{bagname}, choicesValues{bagid}, choicesTooltips{bagname}} -- for the bags themselves
							-- used for both the EditBag_cvt and ImportBag dropdowns
    entriesByBag = {}, -- [bagId] {choices{ico rule.name (pri)}, choicesValues{rule.name}, choicesTooltips{rule.desc/name or missing}} --
    entriesByShowBag = {}, -- [bagId] {choices{ico rule.name (pri)}, choicesValues{rule.name}, bagrules} --
    entriesByName = {}, -- [bagId][rulename]  (BagRule){ name, runpriority, showpriority, isHidden }
}

AutoCat.BagRuleEntry = {}


local saved = AutoCat.saved
local cache = AutoCat.cache

local AC_EMPTY_TAG_NAME = L(SI_AC_DEFAULT_NAME_EMPTY_TAG) or "<Empty>"

-- convenience function for a call to AutoCat_Logger():Debug(SF.str(...))
-- only done for Debug() because there is no special handling for the other message levels
-- always returns nil
local logDebug = AutoCategory.logDebug
local logWouldDebug = AutoCategory.logWouldDebug


-- ------------------------ RulesW defined in Globals  -------------------------------

-- Add a tag if it is not already present.
function AutoCat.RulesW.AddTag(name)
    local RulesW = AutoCat.RulesW
    if not name or name == "" then name = AC_EMPTY_TAG_NAME end

    RulesW.tags = RulesW.tags or {}
    RulesW.tagGroups = RulesW.tagGroups or {}

    if not RulesW.tagGroups[name] then
        RulesW.tags[#RulesW.tags + 1] = name
        RulesW.tagGroups[name] = CVT:New(nil, nil, CVT.USE_TOOLTIPS)
    end
end

-- Compile all of the rules that we know (if necessary)
-- Mark those that failed to compile as damaged
function AutoCat.RulesW:CompileAll()
	-- Reset the compiled-rule lookup, creating it if necessary.
	self.compiled = SF.safeClearTable(self.compiled)

    if not self.ruleList or #self.ruleList == 0 then
		-- there are no rules to compile
		return 0, 0
    end
	-- compile and store each of the rules in the ruleset
    local compiled  = 0
	local damaged = 0
    local safeCall = SF.safeCall    -- alias
    for _, rule in ipairs(self.ruleList) do
        local ok, err = safeCall(rule.compile, rule)
        if ok then
            compiled = compiled + 1
			rule:clearError()

        else
            -- Mark the rule as damaged so UI can highlight it
			damaged = damaged + 1
			rule:setError(true, err)
            logDebug("[AutoCategory] Rule compile error for '%s': %s", rule.name, err)
        end
    end
	return compiled, damaged
end


-- return number of entries in the base rule list
function AutoCat.RulesW:sizeRules()
	return #self.ruleList
end

-- return number of entries in the base tag list
function AutoCat.RulesW:sizeTags()
	return #self.tags
end

-- override AddRule from RuleList to add in lookup table updates
function AutoCat.RulesW:AddRule(newRule, overwriteFlag)
	if not newRule or not newRule.name then return end	-- bad rule

    local ruleNames = self.ruleNames
    local name = newRule.name

	-- Ignore an existing rule unless overwrite was requested.
	local ndx = ruleNames[name]
	if ndx and not overwriteFlag then
		return
	end
	AutoCat.attachRuleMixin(newRule)

	if not newRule.tag or newRule.tag == "" then
        newRule.tag = AC_EMPTY_TAG_NAME
    end

    if not self.tagGroups[newRule.tag] then
	    self.AddTag(newRule.tag)
    end

    local ruleList = self.ruleList
	if ndx then
        -- Overwrite path – keep a reference to the old rule for tag cleanup
        local oldRule = ruleList[ndx]

        -- If the tag changed, purge the old name from the old tag’s CVT
        if oldRule.tag ~= newRule.tag then
            local oldCvt = self.tagGroups[oldRule.tag]
            if oldCvt then oldCvt:removeItemChoice(oldRule.name) end
        end

        ruleList[ndx] = newRule
        logDebug("[AutoCategory] Rule '%s' overwritten.", name)

	else
        if not newRule.formatShow then
            setmetatable(newRule,{__index = AutoCategory.BagRuleApiMixin})
        end
        ruleList[#ruleList+1] = newRule
		ruleNames[name] = #ruleList
        logDebug("[AutoCategory] Rule '%s' added.", name)
	end

  local tagCvt = self.tagGroups[newRule.tag]
  if tagCvt then 
    tagCvt:removeItemChoice(name)   -- no‑op if not present
    tagCvt:append(name, nil, newRule:getDesc())
  end
    
	newRule:compile()
end
-- ---------------------end RulesW  -------------------------------


-- ----------------------------- Sorting comparators ------------------
-- for sorting rules by name
-- returns true if the a should come before b
local function RuleSortingFunction(a, b)
    --alphabetical sort, will not have same name rules
    if not (a and b and a.name and b.name) then
        return false
    end
    return a.name < b.name
end

-- for sorting bagged rules by showpriority and name
-- returns true if the a should come before b
local function BagRuleShowSortingFunction(a, b)
    if not a or not b then return false end
    if not a.name or not b.name then return false end

    local aPriority = a.showpriority or a.runpriority
    local bPriority = b.showpriority or b.runpriority

    if not aPriority then
        if bPriority then
            return false
        end

	-- both have no priority; sort by name
    elseif not bPriority then
        return true

    elseif aPriority ~= bPriority then
        return aPriority > bPriority
    end

    return a.name < b.name
end
AutoCat_Internal.BagRuleShowSortingFunction = BagRuleShowSortingFunction

-- for sorting bagged rules by runpriority and name
-- returns true if the a should come before b
local function BagRuleRunSortingFunction(a, b)
    if not (a and b and a.name and b.name) then
        return false
    end

    local aPriority = a.runpriority
    local bPriority = b.runpriority

    if not aPriority then
        if bPriority then
            return false
        end

	-- both have no priority; sort by name
    elseif not bPriority then
        return true
		
    elseif aPriority ~= bPriority then
        return aPriority > bPriority
    end

    --[[if type(a.name) ~= "string" or type(b.name) ~= "string" then
        return false
    end
	--]]

    return a.name < b.name
end
AutoCat_Internal.BagRuleRunSortingFunction = BagRuleRunSortingFunction

-- swap between account-wide and char-wide settings
function AutoCat.UpdateCurrentSavedVars()
	--local RulesW = AutoCategory.RulesW
    local acctSaved = AutoCat.acctSaved
    local charSaved = AutoCat.charSaved

    -- general, and appearance are always accountWide
    saved.general = acctSaved.general
    saved.appearance = acctSaved.appearance

	--AutoCategory.saved.displayOrder = acctSaved.displayOrder
	acctSaved.displayOrder = nil
	acctSaved.displayName = nil

	charSaved.general = nil	-- fix old data corruption error
	charSaved.appearance = nil	-- fix old data corruption error
	charSaved.displayOrder = nil
	charSaved.displayName = nil

	-- rule definitions are always account-wide
	-- AutoCategory.acctRules only has user-defined rules
	-- RulesW.ruleList will have acctRules plus the predefined rules
	table.sort(ac_rules.ruleList, RuleSortingFunction)

    local compiled, damaged = ac_rules:CompileAll()
	logDebug("[AutoCategory] Compiled rules: ", compiled, " damaged rules: ", damaged)

	AutoCat.PruneCollapse(charSaved)
	AutoCat.PruneCollapse(acctSaved)
	-- bags/collapses might or might not be acct wide
    if not charSaved.accountWide then
        saved.bags = charSaved.bags
        saved.collapses = charSaved.collapses
    
    else
        saved.bags = acctSaved.bags
        saved.collapses = acctSaved.collapses
    end
    AutoCat.cacheInitialize()
end

-- -----------------------------------------------------------
-- Manage collapses
-- -----------------------------------------------------------
function AutoCat.LoadCollapse()
	if not saved.general["SAVE_CATEGORY_COLLAPSE_STATUS"] then
        --init
        return AutoCat.ResetCollapse(saved)
    end
end

function AutoCat.PruneCollapse(vars)
    if not vars or not vars.collapses then return end

    for _, bagcol in pairs(vars.collapses) do
        if bagcol then
            for k in pairs(bagcol) do
                if bagcol[k] == false then bagcol[k] = nil end
            end
        end
    end
end

function AutoCat.ResetCollapse(vars)
    if not vars or not vars.collapses then return end

    for _, bagcol in pairs(vars.collapses) do
        if bagcol then
            for k in pairs(bagcol) do
                bagcol[k] = nil
            end
        end
    end
end

-- Determine if the specified category of the particular bag is collapsed or not
function AutoCat.IsCategoryCollapsed(bagTypeId, categoryName)
    if bagTypeId == nil or categoryName == nil then
        return false
    end
    local saved = AutoCat.saved
    
    local collapsetbl = saved.collapses[bagTypeId]
    return collapsetbl and collapsetbl[categoryName] or false
end

function AutoCat.SetCategoryCollapsed(bagTypeId, categoryName, collapsed)
    if bagTypeId == nil or categoryName == nil then
        return
    end
    if collapsed == false then collapsed = nil end
    local saved = AutoCat.saved

    saved.collapses[bagTypeId] = SF.safeTable(saved.collapses[bagTypeId])
    local collapsetbl = saved.collapses[bagTypeId]

    collapsetbl[categoryName] = collapsed
end
-- create local alias for references in this function
local setCategoryCollapsed = AutoCat.SetCategoryCollapsed

-- -----------------------------------------------------------

-- will need to rebuild RulesW.ruleList after this
function AutoCat.ResetToDefaults()

	AutoCat.ARW.clear()
	ZO_DeepTableCopy(AutoCat.defaultAcctSettings.rules, AutoCat.acctRules.rules)
	AutoCat.ARW = AutoCat.RuleList:New(AutoCat.acctRules.rules)

    local acctSaved = AutoCat.acctSaved
    local charSaved = AutoCat.charSaved

	acctSaved.rules = nil	-- no longer used
	charSaved.rules = nil	-- no longer used

	acctSaved.bags = SF.safeClearTable(acctSaved.bags)
    ZO_DeepTableCopy(AutoCat.defaultAcctSettings.bags, acctSaved.bags)

	charSaved.bags = SF.safeClearTable(charSaved.bags)
    ZO_DeepTableCopy(AutoCat.defaultSettings.bags, charSaved.bags)

    AutoCat.ResetCollapse(acctSaved)
    AutoCat.ResetCollapse(charSaved)

	acctSaved.appearance = SF.safeClearTable(acctSaved.appearance)
    ZO_DeepTableCopy(AutoCat.defaultAcctSettings.appearance,
			acctSaved.appearance)

	acctSaved.general = SF.safeClearTable(acctSaved.general)
	ZO_DeepTableCopy(AutoCat.defaultAcctSettings.general,
			acctSaved.general)

	charSaved.general = nil	-- fix old data corruption error
	charSaved.appearance = nil	-- fix old data corruption error

	charSaved.accountWide = AutoCat.defaultSettings.accountWide
end


-- rename a rule, updates the cache lookups and bagsets too
function AutoCat.renameRule(oldName, newName)
	if oldName == newName then return oldName end

	local rule = AutoCat.GetRuleByName(oldName)
	if rule == nil then return end		-- no such rule to rename

	newName = AutoCat.GetUsableRuleName(newName)

	local oldrndx = ac_rules.ruleNames[oldName]
	ac_rules.ruleNames[oldName] = nil
	rule.name = newName
	ac_rules.ruleNames[rule.name] = oldrndx

	AutoCat.renameBagRule(oldName, newName)
	return newName
end

-- When a rule changes names, referencees to in the bag rules also need to change
function AutoCat.renameBagRule(oldName, newName)
	if oldName == newName then return end
	local bags = saved.bags

	--Update bags so that every entry has the same name, should be changed to new name.
	local function func(bagId)
		local bag = bags[bagId]
		if not bag then 
			bag = { rules = {}, }
			bags[bagId] = bag
		end
		local rules = bag.rules
		for j = 1, #rules do   -- for all bagrules in the bag
			local rule = rules[j]
			if rule.name == oldName then
				rule.name = newName
				break
			end
		end
	end
    AutoCategory.foreachBag(func)
end

-- initialize the RulesW.ruleNames, RulesW.tagGroups, and the RulesW.tags tables from RulesW.ruleList
function AutoCat.cacheRuleInitialize()
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
		if not rule.tag or rule.tag == "" then
			rule.tag = AC_EMPTY_TAG_NAME
		end
		local tag = rule.tag

        --update tag grouping lookups
		ac_rules.AddTag(tag)
        ac_rules.tagGroups[tag]:append(name, nil, rule:getDesc())
    end
end

function AutoCat.InitScrollBag(bagId)
	logDebug("[InitScrollBag]  bagId ", bagId)
	if bagId == nil or bagId < AC_BAG_TYPE_MIN or bagId > AC_BAG_TYPE_MAX then 
		return
	end

	local svdbag = AutoCat.saved.bags[bagId]		-- alias
	if not svdbag or not svdbag.rules then return end
	
	table.sort(svdbag.rules, BagRuleShowSortingFunction)

	-- Populate the display list in show order.
	local win = AutoCat.dspWin
	win:ClearList()
	logDebug("[InitScrollBag] #svdbag.rules ", #svdbag.rules)

	for entry = 1, #svdbag.rules do
		local bagrule = svdbag.rules[entry] 	-- BagRule {name, runpriority, showpriority, isHidden}
		if not bagrule then break end

		logDebug("[InitScrollBag] sbag ", entry, " bagrule.name ", bagrule.name)
		win:AddItem(bagrule)
	end
	win:UpdateScrollList()
end

-- populate the entriesByName and entriesByBag lists in the cache from the saved.bags table
-- bagId needs to be between AC_BAG_TYPE_MIN and AC_BAG_TYPE_MAX (inclusive)
function AutoCat.cacheInitBag(bagId)
	if bagId == nil or bagId < AC_BAG_TYPE_MIN or bagId > AC_BAG_TYPE_MAX then 
		return
	end
  local saved = AutoCat.saved

	-- initialize the bag-based lookups for this bag
    cache.entriesByName[bagId] = SF.safeClearTable(cache.entriesByName[bagId])

	cache.entriesByBag[bagId] = CVT:New(nil, nil, CVT.USE_VALUES + CVT.USE_TOOLTIPS)
	cache.entriesByShowBag[bagId] = CVT:New(nil, nil, CVT.USE_VALUES)
	cache.entriesByShowBag[bagId].bagrules = {}

	if saved.bags[bagId] == nil then
		saved.bags[bagId] = {rules={}}

	elseif not saved.bags[bagId].rules then
		saved.bags[bagId].rules={}
	end

	-- aliases
	local ename = cache.entriesByName[bagId]	-- { [name] BagRule{ name, runpriority, showpriority, isHidden } }
	local ebag = cache.entriesByBag[bagId]		-- CVT
	local sbag = cache.entriesByShowBag[bagId]		-- CVT

	local svdbag = saved.bags[bagId]		-- alias

	-- Normalize the bag rules (order is not important)
	logDebug("[cacheInitBag] Normalize bag rules for ", bagId)
	local savedrules = svdbag.rules
	local countrules = #savedrules
	for ndx = countrules, 1, -1 do
		local bagrule = savedrules[ndx] -- BagRule {name, runpriority, showpriority, isHidden}
		if not bagrule then break end
		if not bagrule.formatValue then 
			setmetatable(bagrule,{__index = AutoCategory.BagRuleApiMixin})
		end
		bagrule:convertPriority()
	end

    -- load in the bagged rules (sorted by showpriority high-to-low) into the dropdown
	logDebug("[cacheInitBag] Initializing sbag ", bagId, " with bagrules")

	-- initialize dspWin with bag rules sorted by showpriority high-to-low order
	AutoCat.InitScrollBag(bagId)
	
	--table.sort(svdbag.rules, BagRuleShowSortingFunction)		-- already sorted by InitScrollBag
	for entry = 1, countrules do
		local bagrule = savedrules[entry] -- BagRule {name, runpriority, showpriority, isHidden}
		if not bagrule then break end

		logDebug("[cacheInitBag] sbag ", entry, " bagrule.name ", bagrule.name)

		sbag:append(bagrule:formatShow(),  bagrule:formatValue())
		sbag.bagrules[#sbag.bagrules+1] = bagrule
	end
		
    -- load in the bagged rules (sorted by runpriority high-to-low) into the dropdown
	table.sort(svdbag.rules, BagRuleRunSortingFunction)
	
	logDebug("[cacheInitBag] Initializing ebag ", bagId, " with bagrules")
	local bagrule
	for entry = 1, countrules do
		bagrule = savedrules[entry] 		-- BagRule {name, runpriority, showpriority, isHidden}
		if not bagrule then break end

		local ruleName = bagrule.name
		logDebug("[cacheInitBag] ebag ", entry, " bagrule.name ", bagrule.name)
		if not ename[ruleName] then
			ebag:append(bagrule:formatShow(),  bagrule:formatValue(), bagrule:formatTooltip())
		end
		ename[ruleName] = bagrule
	end

end

-- populate the entriesByName and entriesByBag lists in the cache from the saved.bags table
function AutoCat.cacheBagInitialize()
	-- initialize the bag-based lookups
    ZO_ClearTable(cache.entriesByName)
    ZO_ClearTable(cache.entriesByBag)
    ZO_ClearTable(cache.entriesByShowBag)

	-- fill the bag-based lookups
    -- load in the bagged rules (sorted by runpriority high-to-low) into the dropdown
    AutoCategory.foreachBag(AutoCat.cacheInitBag)
end


-- ----------------------------------------------------
-- assumes that RulesW.ruleList and saved.bags have entries but
-- some or all of the cache tables need (re)initializing
--
function AutoCat.cacheInitialize()
    -- initialize the rules-based lookups
    AutoCat.cacheRuleInitialize()
    AutoCat.cacheBagInitialize()
end


-- find and return the rule referenced by name
function AutoCat.GetRuleByName(name)
    if not name then return nil end

	local ndx = ac_rules.ruleNames[name]
    if not ndx then return nil end

    return ac_rules.ruleList[ndx]
end

function AutoCat.GetBagRuleByName(bagId, name)
    if not name then return nil, nil end
    local bagrules = cache.entriesByShowBag[bagId]
    if not bagrules then return nil, nil end
    
    -- Check if rule still exists in main list
    if not ac_rules.ruleNames[name] then
        -- Stale entry detected - trigger cleanup for this bag
		AutoCat.cacheInitBag(bagId)
        return nil, nil
    end
    
    -- Normal lookup
    local ndx = ZO_IndexOfElementInNumericallyIndexedTable(
        bagrules.choicesValues, name)
    if not ndx then return nil, nil end
    
    return bagrules.bagrules[ndx], ndx
end


-- when we add a new rule to RulesW.ruleList, also add it to the various lookups and dropdowns
-- returns nil on success or error message
function AutoCat.cache.AddRule(rule)
    if not rule or not rule.name then
        return "AddRule: Rule or name of rule was nil"
    end -- can't use a nil rule
	AutoCat.attachRuleMixin(rule)

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
		ac_rules.tagGroups[rule.tag]:append(rule.name, nil, rule:getDesc())
    end

	rule:compile()
end

-- Set up the context menu item for AutoCategory
local LCM = LibCustomMenu
local function setupContextMenu()

	local function AC_GetItem(rowControl) 
		local bagId, slotIndex = ZO_Inventory_GetBagAndIndex(rowControl)
		local itemId = GetItemId(bagId, slotIndex)
		local name = GetItemName(bagId, slotIndex)
		sysd("[AC] "..tostring(name).."   itemId = "..tostring(itemId))
	end
	local function AC_AddMenuItem(rowControl, slotActions)
		local bagId, slotIndex = ZO_Inventory_GetBagAndIndex(rowControl)
		AddCustomMenuItem("AC: Get itemId", function() AC_GetItem(rowControl) end, MENU_ADD_OPTION_LABEL)
        if AutoCat.displayItem then
		    AddCustomMenuItem("AC: Debug", function() AutoCat.displayItem(bagId, slotIndex) end, MENU_ADD_OPTION_LABEL)
        end
		--Show the context menu entries at the inventory row now
		ShowMenu(rowControl)
	end
	LCM:RegisterContextMenu(AC_AddMenuItem, LibCustomMenu.CATEGORY_LATE )
end

function AutoCat.initializePlugins()
	-- Initialize registered plugins.
	for _, plugin in pairs(AutoCat.Plugins) do
		if plugin and plugin.init then
			SF.safeCall10(plugin.init)
		end
	end
end	

--[[ Add the rules in a table of rules to the combined, acctRules, and predefinedRules lists
	as appropriate.
	The table must be { rules = {} } and tbl.rules contains the list of rules.

	The tblname is used only for AutoCat_Logger()/logDebug() messages - i.e. debugging.

	The ispredef flag signals that ALL of the rules in the source table are predefines if true.
--]]
local function addTableRules(tbl, tblname, ispredef)
	if not tbl or not tbl.rules or tbl.rules == ac_rules.ruleList then return end

	AutoCat_Logger():Info("Adding rules from table "..(tblname or "unknown").."  count = "..#tbl.rules)

	local newName
	ac_rules.ruleList = ac_rules.ruleList or {}
	ac_rules.ruleNames = ac_rules.ruleNames or {}

	-- add a rule to the combined rules list and the name-lookup
	local function addCombinedRule(rl)
		local n = ac_rules.ruleNames[rl.name]
		local ruleList = ac_rules.ruleList
		local newListLen = #ruleList + 1
		if not n then
			ruleList[newListLen] = rl
			logDebug("[AutoCategory] Adding rule ", rl.name, " to ac_rules.ruleList ndx=", newListLen)
			ac_rules.ruleNames[rl.name] = newListLen
			return true
			
		else
			ruleList[n] = rl
			logDebug("[AutoCategory] Overwriting rule ", rl.name, " in ac_rules.ruleList ndx=", n)
			ac_rules.ruleNames[rl.name] = n
		end
		return false
	end

	local function addPredef(stbl, rule)
		local predefinedRules = AutoCat.predefinedRules
		-- add to predefinedRules list
		if stbl.rules ~= predefinedRules then
			predefinedRules[#predefinedRules+1] = rule
		end
	end

	local function addUserRule(stbl, rule)
		-- add to acctRules list
		if stbl.rules ~= AutoCat.acctRules.rules then
			return AutoCat.ARW:AddRule(rule)
		end
	end

	--- aliases
	local getRuleByName = AutoCat.GetRuleByName
	local getUsableRuleName = AutoCat.GetUsableRuleName
	-- process all of the rules in the table
	local v, r
	for k=#tbl.rules, 1, -1 do
		v = tbl.rules[k]
		if ispredef == true then
			v.pred=1
		end
		AutoCat.attachRuleMixin(v)

		r = getRuleByName(v.name)
		if r then
			logDebug("[AutoCategory] Found duplicate rule name - ", v.name)
			-- already have one
			if v.rule == r.rule then
				-- same rule def, so don't add it again
				logDebug("[AutoCategory] 1 Dropped duplicate rule - ", v.name, 
                        "  from AC.rules sourced ", (tblname or "unknown"))

			else
				local oldname = v.name
				-- rename different rule
				newName = getUsableRuleName(v.name)
				v.name = newName
				logDebug("[AutoCategory] Renaming duplicate rule name - ", oldname, " to ", v.name)

				addCombinedRule(v)
				AutoCat.renameBagRule(oldname, newName)
				if v:isPredefined() then 
					addPredef(tbl, v)

				else
					-- add to acctRules
					addUserRule(tbl, v)
					logDebug("[AutoCategory] adding to user rules - ", v.name, "  from sourced ", (tblname or "unknown"))
				end
			end

		else
			-- brand new (never seen) rule
			-- add it to the combined (AutoCategory.rule) list
			addCombinedRule(v)

			if v:isPredefined() then 
				-- it's a predefined rule
				addPredef(tbl, v)
				logDebug("[AutoCategory] adding to predefined rules - ", v.name, "  from sourced ", (tblname or "unknown"))

		    else
				-- it's a user rule
				addUserRule(tbl, v)
				logDebug("[AutoCategory] adding to user rules - ", v.name, "  from sourced ", (tblname or "unknown"))
			end
        end
    end
end
AutoCategory._addTableRules = addTableRules

-- cannot use this until after addons are finally loaded!!
local function loadPluginPredefines()
	logDebug ("[AutoCategory] Executing loadPluginPredefines ")
	-- Add each plugin's predefined rules to AutoCat.predefinedRules.
	for name, plugin in pairs(AutoCat.Plugins) do
		if plugin.predef and #plugin.predef > 0 then
			-- process all of the rules in the table
			addTableRules( { rules=plugin.predef}, name..".predefinedRules", true)

        else
            AutoCat_Logger():Info("No predefinedRules to add from "..name)
		end
	end
	logDebug ("[AutoCategory] Done executing loadPluginPredefines ")
	logDebug("[AutoCategory] 2.5 predefined ", SF.GetSize(AutoCat.predefinedRules))
 end


local function assertBagRuleMixins()

    local function func(bagId)
        local bag = AutoCategory.saved.bags[bagId]
        if bag and bag.rules then
            for _, br in ipairs(bag.rules) do
                assert(br.formatShow, "BagRule missing mixin! bagId="..bagId.." name="..br.name)
            end
        end
    end

    AutoCategory.foreachBag(func)
end

function AutoCategory:setChecking(bagId, slotIndex)
	-- set up bagId and slotIndex to "pass in" to the rule functions
    self.checking = SF.safeClearTable(self.checking)
    self.checking.BagId = bagId
    self.checking.SlotIndex = slotIndex
    self.checking.ItemLink = GetItemLink(bagId, slotIndex)
end


-- Load the saved variables and rules tables
local function loadSavedVars()
    local isEmpty = SF.isEmpty
    local defaultMissing = SF.defaultMissing

    -- load our saved variables (no longer loads pre-defined rules)
    AutoCat.acctSaved, AutoCat.charSaved = SF.getAllSavedVars("AutoCategorySavedVars",
		1.1, AutoCat.defaultAcctSettings, AutoCat.defaultCharSettings)
	if isEmpty(AutoCat.acctSaved.bags) then 
		defaultMissing(AutoCat.acctSaved.bags, AutoCat.defaultAcctBagSettings.bags)
	end
	if isEmpty(AutoCat.charSaved.bags) then
		defaultMissing(AutoCat.charSaved.bags, AutoCat.defaultAcctBagSettings.bags)
	end

	-- There are no char-level variables for AutoCatRules!
    AutoCat.acctRules  = SF.getAcctSavedVars("AutoCatRules", 1.1, AutoCat.default_rules)
end

-- setup that needs to be done when the addon is loaded into the game
function AutoCat.onLoad(event, addon)
    if addon ~= AutoCat.name then return end

	-- make sure we are not called again
	AutoCat.evtmgr:unregEvt(EVENT_ADD_ON_LOADED)
	AutoCat.evtmgr:registerEvt(EVENT_PLAYER_ACTIVATED, 	AutoCat.onPlayerActivated)
    AutoCat.evtmgr:registerEvt(EVENT_ADD_ON_UNLOADED, function(...) AutoCat:OnAddOnUnloaded(...) end)

    loadSavedVars()

	AutoCat.ARW = AutoCat.RuleList:New(AutoCat.acctRules.rules)

    AutoCat.LoadCollapse()

	-- Set up the context menu item for AutoCategory
	setupContextMenu()

	-- hooks
	AutoCat.HookGamepadMode()
	AutoCat.HookKeyboardMode()
end

-- -------------------------------------------------------------------------
-- Unload handling – make sure the hooks are cleared when the add‑on stops
function AutoCategory:OnAddOnUnloaded(eventCode, addonName)
    if addonName ~= self.name then return end

    AutoCat.UnHookKeyboardMode()

    if self.evtmgr then
        self.evtmgr:unregAllUpdateEvt()
        self.evtmgr:unregAllEvt()
        self.evtmgr = nil
    end
    if self.hookmgr then
        self.hookmgr:disableAll()
        self.hookmgr = nil
    end
end


-- --------------------------------------------------------------------
-- keep track of registered events for AutoCategory
AutoCat.evtmgr = SF.EvtMgr:New("AutoCategory")
-- keep track of  hooks for AutoCategory
AutoCat.hookmgr = SF.HookManager:New("AutoCat_")

-- only runs once
-- continues initialization after all addons are loaded into the game
function AutoCat.onPlayerActivated()
	local evtmgr = AutoCat.evtmgr

	-- make sure we are only called once
	evtmgr:unregEvt(EVENT_PLAYER_ACTIVATED)

    assertBagRuleMixins()

	evtmgr:registerEvt(EVENT_CLOSE_GUILD_BANK, function () AutoCat.BulkMode = false end)
	evtmgr:registerEvt(EVENT_CLOSE_BANK, function () AutoCat.BulkMode = false end)

	--create window to show display order
	AutoCat.dspWin = AC_UI.DspWin.New()
		
	--capabilities with other (older) add-ons
	AC_IntegrateQuickMenu()

	AutoCat.meta = SF.safeTable(AutoCat.meta)
	SF.addonMeta(AutoCat.meta,"AutoCategory")

	-- add plugin predefined rules to the combined rules and name-lookup
	loadPluginPredefines()
	local pd = { rules = AutoCat.predefinedRules, }
	addTableRules(pd, ".predefinedRules", true)

	addTableRules(AutoCat.acctRules, ".acctRules", false)
	addTableRules(AutoCat.acctSaved, ".acctSaved", false)
	AutoCat.acctSaved.rules = nil	-- no longer used
	addTableRules(AutoCat.charSaved, ".charSaved", false)
	AutoCat.charSaved.rules = nil	-- no longer used

	if logWouldDebug() then
		-- protects SF.GetSize execution
		logDebug("[AutoCategory] 2.5 predefined ", SF.GetSize(AutoCat.predefinedRules))
	end

    AutoCat.UpdateCurrentSavedVars()
	AutoCat.initializePlugins()
	AutoCat.cacheInitialize()
	AutoCat.AddonMenu_Init()
	AutoCat.Inited = true -- put back in for BetterUI users, AutoCategory itself does not use this.
end

-- -----------------------------------------------
do
	-- register our event handler function to be called to do initialization
	AutoCat.evtmgr:registerEvt(EVENT_ADD_ON_LOADED, 	AutoCat.onLoad)
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
        listView = ZO_PlayerInventoryList,
        ac_bag = AC_BAG_TYPE_BACKPACK,
        zos_bag = BAG_BACKPACK,
	},

	[INVENTORY_CRAFT_BAG] = {
		object = ZO_CraftBag,
		control = ZO_CraftBag,
        listView = ZO_CraftBagList,
	},

	[INVENTORY_GUILD_BANK] = {
		object = ZO_GuildBank,
		control = ZO_GuildBank,
        listView = ZO_GuildBankBackpack,
        ac_bag = AC_BAG_TYPE_GUILDBANK,
        zos_bag = BAG_GUILDBANK,
	},

	[INVENTORY_HOUSE_BANK] = {  -- for house banks 1-10
		object = ZO_HouseBank,
		control = ZO_HouseBank,
        listView = ZO_HouseBankBackpack,
        ac_bag = AC_BAG_TYPE_HOUSEBANK,
        --zos_bag = BAG_HOUSE_BANK_ONE,
	},

	[INVENTORY_BANK] = {
		object = ZO_PlayerBank,
		control = ZO_PlayerBank,
        listView = ZO_PlayerBankBackpack,
        ac_bag = AC_BAG_TYPE_BANK,
        zos_bag = BAG_BANK,
	},

	[INVENTORY_FURNITURE_VAULT] = {
		object = ZO_FurnitureVault,
		control = ZO_FurnitureVault,
        listView = ZO_FurnitureVaultList,
        ac_bag = AC_BAG_TYPE_FURNVAULT,
        zos_bag = BAG_FURNITURE_VAULT,
	},
    [INVENTORY_VENGEANCE] = {
        object = ZO_VengeanceInventory,
        control = ZO_VengeanceInventory,
        listView = ZO_VengeanceInventoryList,
        ac_bag = AC_BAG_TYPE_VENGEANCE,
        zos_bag = BAG_VENGEANCE,
    },

	[AC_DECON] = {
		object = SMITHING.deconstructionPanel.inventory,
		control = SMITHING.deconstructionPanel.control,
        listView = SMITHING.deconstructionPanel.inventory.list,
	},
	[AC_IMPROV] = {
		object = SMITHING.improvementPanel.inventory,
		control = SMITHING.improvementPanel.control,
        listView = SMITHING.improvementPanel.inventory.list,
	},

	[UV_DECON] = {
		object = UNIVERSAL_DECONSTRUCTION.deconstructionPanel.inventory,
		control = UNIVERSAL_DECONSTRUCTION.deconstructionPanel.control,
        listView = ZO_UniversalDeconstructionTopLevel_KeyboardPanelInventoryBackpack,
	},
}

local function refreshList(inventoryType, even_if_hidden)
	if even_if_hidden == nil then even_if_hidden = false end
	if not inventoryType or not inven_data[inventoryType] then return false end

	local obj = inven_data[inventoryType].object
	local ctl = inven_data[inventoryType].control
    if not obj or not ctl then return false end

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
AutoCat.RefreshList = refreshList

function AutoCat.RefreshCurrentList(even_if_hidden)
	if not even_if_hidden then even_if_hidden = false end

	for k,_ in pairs( inven_data ) do
		refreshList(k, even_if_hidden) 
	end
end

-- -----------------------------------------------
-- used only for AC_ItemRowHeader functions
local function getBagTypeId(header)
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


    local collapsed = AutoCat.IsCategoryCollapsed(bagTypeId, cateName)
    local markerBG = header:GetNamedChild("CollapseMarkerBG")

    if AutoCat.acctSaved.general["SHOW_CATEGORY_COLLAPSE_ICON"] then
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
    if (AutoCat.acctSaved.general["SHOW_CATEGORY_COLLAPSE_ICON"] == false) then
        return
    end

    local cateName = header.slot.dataEntry.data.AC_categoryName
    local bagTypeId = getBagTypeId(header)

    local collapsed = AutoCat.IsCategoryCollapsed(bagTypeId, cateName)
    setCategoryCollapsed(bagTypeId, cateName, not collapsed)
    AutoCat.RefreshCurrentList()
end

-- called from AutoCategory.xml
-- context menu for collapse/expand on category headers
function AC_ItemRowHeader_OnShowContextMenu(header)
    ClearMenu()
    local cateName = header.slot.dataEntry.data.AC_categoryName
    local bagTypeId = getBagTypeId(header)

	-- add either single Expand or Collapse to menu as appropriate for category state
    local collapsed = AutoCat.IsCategoryCollapsed(bagTypeId, cateName)
    if collapsed then
        AddMenuItem(
            L(SI_CONTEXT_MENU_EXPAND),
            function()
                setCategoryCollapsed(bagTypeId, cateName, false)
                AutoCat.RefreshCurrentList()
            end
        )

    else
        AddMenuItem(
            L(SI_CONTEXT_MENU_COLLAPSE),
            function()
                setCategoryCollapsed(bagTypeId, cateName, true)
                AutoCat.RefreshCurrentList()
            end
        )
    end

	-- add Expand All to menu
    AddMenuItem(
        L(SI_CONTEXT_MENU_EXPAND_ALL),
        function()
            for k, _ in pairs(AutoCat.saved.collapses[bagTypeId]) do
				setCategoryCollapsed(bagTypeId,k,false)
            end
            AutoCat.RefreshCurrentList()
        end
    )

	-- add Collapse All to menu
    AddMenuItem(
        L(SI_CONTEXT_MENU_COLLAPSE_ALL),
        function()
            for k, _ in pairs(AutoCat.saved.collapses[bagTypeId]) do
				setCategoryCollapsed(bagTypeId,k,true)
            end
			setCategoryCollapsed(bagTypeId,AutoCat.saved.appearance["CATEGORY_OTHER_TEXT"],true)
            AutoCat.RefreshCurrentList()
        end
    )
    ShowMenu()
end

-- called from binding.xml
-- toggle AutoCategory on or off
function AC_Binding_ToggleCategorize()
    AutoCat.Enabled = not AutoCat.Enabled
    if AutoCat.acctSaved.general["SHOW_MESSAGE_WHEN_TOGGLE"] then
        if AutoCat.Enabled then
            sysd(L(SI_MESSAGE_TOGGLE_AUTO_CATEGORY_ON))

        else
            sysd(L(SI_MESSAGE_TOGGLE_AUTO_CATEGORY_OFF))
        end
    end
    AutoCat.RefreshCurrentList()
end
