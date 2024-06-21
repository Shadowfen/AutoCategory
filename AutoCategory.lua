----------------------
--INITIATE VARIABLES--
----------------------

local L = GetString
local SF = LibSFUtils
local AC = AutoCategory
local CVT = AC.CVT

AC.rules = {}	--  [#] rule {rkey, name, tag, description, rule, pred, damaged, err}
AutoCategory.compiledRules = SF.safeTable(AC.compiledRules)

-- AC.saved contains table references from the appropriate saved variables - either acctSaved or charSaved
-- depending on the setting of charSaved.accountWide
AutoCategory.saved = {
    rules = {}, -- [#] rule {rkey, name, tag, description, rule, damaged, err} -- obsolete
    bags = {}, -- [bagId] {rules{name, priority, isHidden}, isOtherHidden} -- pairs with collapses
	general = {},   -- from savedvars
	appearance = {}, -- from savedvars
	collapses = {},  -- from savedvars -- charSaved.collapses or acctSaved.collapses -- pairs with bags
}

AutoCategory.cache = {
    rulesByName = {}, -- [name] rule#
    rulesByTag_cvt = {}, -- [tag] CVT{choices{rule.name}, choicesTooltips{rule.desc/name}}
    compiledRules = AC.compiledRules, -- [name] function
    tags = {}, -- [#] tagname
    bags_cvt = CVT:New(nil, nil, CVT.USE_VALUES + CVT.USE_TOOLTIPS), -- {choices{bagname}, choicesValues{bagid}, choicesTooltips{bagname}} -- for the bags themselves
							-- used for both the EditBag_cvt and ImportBag dropdowns
    entriesByBag = {}, -- [bagId] {choices{ico rule.name (pri)}, choicesValues{rule.name}, choicesTooltips{rule.desc/name or missing}} --
    entriesByName = {}, -- [bagId][rulename]  (BagRule){ name, priority, isHidden } 
}

AutoCategory.BagRuleEntry = {}

local saved = AutoCategory.saved
local cache = AutoCategory.cache

local AC_EMPTY_TAG_NAME = L(SI_AC_DEFAULT_NAME_EMPTY_TAG)

local function getBagTypeId(header)
	SF.dTable(header,5,"getBagTypeId - header")
	local bagTypeId = header.slot.dataEntry.data.AC_bagTypeId
    if not bagTypeId then
		bagTypeId = header.slot.dataEntry.AC_bagTypeId
	end
	return bagTypeId
end

function AutoCategory.debugCache()
    d("Saved rules: " .. #saved.rules)						-- should be 0 after conversion
    d("Predefined rules: " .. #AC.predefinedRules)			-- predefined rules from base and plugins
    d("Combined rules: " .. #AC.rules)						-- complete list of user rules and predefined rules
    d("Compiled rules: " .. SF.GetSize(cache.compiledRules))
    d("Rules by Name: " .. SF.GetSize(cache.rulesByName))	-- lookup table for rules by rule name
    d("Rules by Tag: " .. SF.GetSize(cache.rulesByTag_cvt))	-- actually returns the # of Tags defined
    d("Tags: " .. SF.GetSize(cache.tags))					-- returns the # of Tags defined
    d("Saved bags: " .. #saved.bags)						-- returns # of bags, collections of bagrules by bagId
    d("Cache bags: " .. SF.GetSize(cache.bags_cvt))			-- CVT of bags for bag id dropdowns, returns 3 for CVT
    d("Entries by Bag: " .. SF.GetSize(cache.entriesByBag))		-- CVT of bagrules by bagid, so always returns # bags
    d("Entries by Name: " .. SF.GetSize(cache.entriesByName))	-- bagrules lookup by bagid and rule name, returns # bags
end

--unused (debug) - Not sure why called "EBT" since it uses entriesByName!!
function AutoCategory.debugEBT()
	for k, v in pairs(cache.entriesByName[1]) do
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

function AutoCategory.debugTags()
	d("cache.tags:")
	for k, v in pairs(cache.tags) do
		if type(v) == "table" then
			for k1,v1 in pairs(v) do
				d("k = "..k.."   k1="..k1.."  v1="..SF.str(v1))
			end
		else
		    d("k = "..k.." v= "..SF.str(v))
		end
	end
end



-- -----------------------------------------------------
-- Compile all of the rules that we know (if necessary)
-- Mark those that failed to compile as damaged
--
function AutoCategory.RecompileRules(ruleset)
	-- reset AutoCategory.compiledRules to empty, creating only if necessary
	AutoCategory.compiledRules = SF.safeClearTable(AutoCategory.compiledRules)

    if ruleset == nil then
		-- there are no rules to compile
		return
    end
	-- compile and store each of the rules in the ruleset
    for j,_ in pairs(ruleset) do
        if ruleset[j] then
            ruleset[j]:compile()
		end
    end
end

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

function AutoCategory.UpdateCurrentSavedVars()
	AC.meta = SF.safeTable(AC.meta)
	SF.addonMeta(AC.meta,"AutoCategory")
	--AC.logger:Debug(SF.dTable(AC.meta, 3, "meta"))
	
    -- general, and appearance are always accountWide
    saved.general = AutoCategory.acctSaved.general
    saved.appearance = AutoCategory.acctSaved.appearance

	-- AC.acctRules only has user-defined rules
	-- AC.rules will have acctRules plus the predefined rules 
	
	-- assign functions to rules
	local ruletbl = AC.rules
	for ndx,_ in pairs(ruletbl) do
		AC.AssociateRule(ruletbl[ndx])
    end
	
    AutoCategory.RecompileRules(ruletbl)

	-- bags/collapses might or might not be acct wide
    if not AutoCategory.charSaved.accountWide then
        saved.bags = AutoCategory.charSaved.bags
        saved.collapses = AutoCategory.charSaved.collapses

    else
        saved.bags = AutoCategory.acctSaved.bags
        saved.collapses = AutoCategory.acctSaved.collapses
    end
	
	-- associate functions with bag entries
	for i = 1, 6 do --#saved.bags do
		local bag = saved.bags[i]
		local rules = bag.rules
		for j = 1, #rules do
			AC.AssociateBagRule(rules[j])
		end
	end


    AC.cacheInitialize()
end

-- ----------------------------------------------------------------------------
-- specialty Bag entry formatting functions
-- returns priority, rulename from a formatted BagRuleEntry indexValueindexValue
function AutoCategory.BagRuleEntry.splitValue(value)
    return string.find(value, "%((%d+)%) (%a+)")
end

function AutoCategory.BagRuleEntry.formatValue(entry)
    return entry.name
end

function AutoCategory.BagRuleEntry.formatShow(entry, bagrule)
    local sn = nil
    if not bagrule then
        -- missing bagrule (nil was passed in)
        sn = string.format("|cFF4444(!)|r %s (%d)", entry.name, entry.priority)

    else
        if entry.isHidden then
			-- grey out the "hidden" category header
            sn = string.format("|c626250%s (%d)|r", entry.name, entry.priority)

        else
            sn = string.format("%s (%d)", entry.name, entry.priority)
        end
    end
    return sn
end

function AutoCategory.BagRuleEntry.formatTooltip(rule)
    local tt = nil
    if not rule then
        -- missing rule (nil was passed in)
        tt = L(SI_AC_WARNING_CATEGORY_MISSING)

    else
		tt = rule:getDesc()
    end
    return tt
end

-- -----------------------------------------------------------
-- Manage collapses
-- -----------------------------------------------------------
function AutoCategory.LoadCollapse()
    if not saved.general["SAVE_CATEGORY_COLLAPSE_STATUS"] then
        --init
        AutoCategory.ResetCollapse(saved)
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

	local collapsetbl = SF.safeTable(saved.collapses[bagTypeId])
    return collapsetbl[categoryName] or false
end


function AutoCategory.SetCategoryCollapsed(bagTypeId, categoryName, collapsed)
	if not categoryName then return end
	saved.collapses[bagTypeId][categoryName] = collapsed
end
-- -----------------------------------------------------------

-- will need to rebuild AC.rules after this
function AutoCategory.ResetToDefaults()
	
	AutoCategory.acctRules.rules = SF.safeClearTable(AutoCategory.acctRules.rules)
    ZO_DeepTableCopy(AutoCategory.defaultAcctSettings.rules, AutoCategory.acctRules.rules)
	
	AutoCategory.acctSaved.rules = nil
	AutoCategory.charSaved.rules = nil 

	AutoCategory.acctSaved.bags = SF.safeClearTable(AutoCategory.acctSaved.bags)
    ZO_DeepTableCopy(AutoCategory.defaultAcctSettings.bags, AutoCategory.acctSaved.bags)
	
    AutoCategory.ResetCollapse(AutoCategory.acctSaved)
    AutoCategory.ResetCollapse(AutoCategory.charSaved)

	AutoCategory.acctSaved.appearance = SF.safeClearTable(AutoCategory.acctSaved.appearance)
    ZO_DeepTableCopy(AutoCategory.defaultAcctSettings.appearance,
			AutoCategory.acctSaved.appearance)

	AutoCategory.charSaved.bags = SF.safeClearTable(AutoCategory.charSaved.bags)
    ZO_DeepTableCopy(AutoCategory.defaultSettings.bags, AutoCategory.charSaved.bags)

    AutoCategory.charSaved.accountWide = AutoCategory.defaultSettings.accountWide
end

-- rename a rule
function AutoCategory.renameRule(oldName, newName)
	if oldName == newName then return end
	
	local rule = AC.GetRuleByName(oldName)
	if rule == nil then return end		-- no such rule to rename
	
	local oldrndx = cache.rulesByName[oldName]
	cache.rulesByName[oldName] = nil
	
	newName = AC.GetUsableRuleName(newName)
	
	rule.name = newName
	cache.rulesByName[rule.name] = oldrndx
	
	AutoCategory.renameBagRule(oldName, newName)
end

-- When a rule changes names, referencees to in the bag rules also need to change
function AutoCategory.renameBagRule(oldName, newName)
	if oldName == newName then return end

	--Update bags so that every entry has the same name, should be changed to new name.
	for i = 1, 6 do --#saved.bags do	-- for all bags
		local bag = saved.bags[i]
		local rules = bag.rules
		for j = 1, #rules do   -- for all bagrules in the bag
			local rule = rules[j]
			if rule.name == oldName then
				rule.name = newName
			end
		end
	end
end

function AutoCategory.cacheRuleInitialize()
	-- initialize the rules-based lookups
    cache.rulesByName = SF.safeClearTable(cache.rulesByName)
    cache.rulesByTag_cvt = SF.safeClearTable(cache.rulesByTag_cvt)
    cache.tags = SF.safeClearTable(cache.tags)

	-- fill the rules-based lookups
	local ruletbl = AC.rules
    table.sort(ruletbl, RuleDataSortingFunction ) -- already sorted by name
    for ndx,_ in pairs(ruletbl) do
		-- associate rule functions with a rule struct
		AC.AssociateRule(ruletbl[ndx])
		
		-- add rule to rulesByName lookup
        local rule = ruletbl[ndx]
        local name = rule.name
        cache.rulesByName[name] = ndx

		-- ensure tag value is valid
        local tag = rule.tag
        if tag == "" then
            tag = AC_EMPTY_TAG_NAME
        end
		
        --update tag grouping lookups
        if not cache.rulesByTag_cvt[tag] then
			cache.tags[#cache.tags+1] = tag
            --table.insert(cache.tags, tag)
            cache.rulesByTag_cvt[tag] = AC.CVT:New(nil,nil,CVT.USE_TOOLTIPS) -- uses choicesTooltips
        end
        cache.rulesByTag_cvt[tag]:append(name, name, rule:getDesc())
    end
	
end

-- populate the entriesByName and entriesByBag lists in the cache from the saved.bags table
function AutoCategory.cacheBagInitialize()
	-- initialize the bag-based lookups
    ZO_ClearTable(cache.entriesByName)
    ZO_ClearTable(cache.entriesByBag)

	-- fill the bag-based lookups
    -- load in the bagged rules (sorted by priority high-to-low) into the dropdown
    for bagId = 1, 6 do --#saved.bags do
		if cache.entriesByBag[bagId] == nil then
			cache.entriesByBag[bagId] = AC.CVT:New(nil,nil,CVT.USE_VALUES + CVT.USE_TOOLTIPS)
		end

		cache.entriesByName[bagId] = SF.safeTable(cache.entriesByName[bagId])
		
        local ename = cache.entriesByName[bagId]	-- { [name] BagRule{ name, priority, isHidden } }
        local ebag = cache.entriesByBag[bagId]		-- CVT

		if saved.bags[bagId] == nil then
			saved.bags[bagId] = {rules={}}
		end
		local svdbag = saved.bags[bagId]
        table.sort(svdbag.rules, BagRuleSortingFunction)
		
        for entry = 1, #svdbag.rules do
            local bagrule = svdbag.rules[entry] -- BagRule {name, priority, isHidden}
			if not bagrule then break end
			AC.AssociateBagRule(bagrule)

			if bagrule.name then
				local ruleName = bagrule.name
				if not ename[ruleName] then
					ename[ruleName] = bagrule
					if ebag.choicesValues then
						ebag.choicesValues[#ebag.choicesValues+1] = bagrule:formatValue()
						--table.insert(ebag.choicesValues, bagrule:formatValue())
					end

					local sn = bagrule:formatShow()
					local tt = bagrule:formatTooltip()
					ebag.choices[#ebag.choices+1] = sn
					--table.insert(ebag.choices, sn)
					if ebag.choicesTooltips then
						ebag.choicesTooltips[#ebag.choicesTooltips+1] = tt
						--table.insert(ebag.choicesTooltips, tt)
					end
				end
			end
        end
    end
end

-- ----------------------------------------------------
-- assumes that saved.rules and saved.bags have entries but
-- some or all of the cache tables need (re)initializing
--
function AutoCategory.cacheInitialize()
	AutoCategory.cacheRuleInitialize()
	AutoCategory.cacheBagInitialize()
end

-- find and return the rule referenced by name
function AutoCategory.GetRuleByName(name)
    if not name then
        return nil
    end

    local ndx = cache.rulesByName[name]
    if not ndx then
        return nil
    end

	return AC.rules[ndx]
end

-- remove bagrule (referenced by rulename) from a bag
function AutoCategory.cache.RemoveRuleFromBag(bagId, rulename)
    if not rulename then
        return
    end

    -- remove from entriesByBag (CVT)
	local removeIndex = -1
	local r = cache.entriesByBag[bagId]
    for i = #r.choices, 1, -1 do
        local _, n = AutoCategory.BagRuleEntry.splitValue(r.choicesValues[i])
        if n == rulename then
			--r.dirty = 1		-- does not have associated control
			removeIndex = i
            table.remove(r.choices, removeIndex)
			if r.choicesValues then
				table.remove(r.choicesValues, removeIndex)
			end
			if r.choicesTooltips then
				table.remove(r.choicesTooltips, removeIndex)
			end
            break
        end
    end

    -- remove from collapses
	cache.entriesByName[bagId][rulename] = nil

	-- remove from collapse bag
	local collapsebag = saved.collapses[bagId]
	local tname = rulename.." %("
	for k,_ in pairs(collapsebag) do

		if k == rulename then
			collapsebag[k] = nil

		elseif 1 == string.find(k,tname) then
			collapsebag[k] = nil
		end
	end

    -- removed from saved.bags
	local bagrules = saved.bags[bagId].rules
    for i = #bagrules, 1, -1 do
		if bagrules[i].name == rulename then
			table.remove(bagrules[i])
            break
        end
    end
	
end

-- check that all required fields are set and rule is already compiled (optional)
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
	-- validate compiled rule function if available
	local compiled = AutoCategory.compiledRules[ruledef.name]
    if compiled then -- compiled is optional
        if (type(compiled) ~= "function") then
			ruledef.setError(true, "non-nil compiled must be a lua function")
			AutoCategory.compiledRules[ruledef.name] = nil
            return false, ruledef.err
        end
    end
    return true
end

-- when we add a new rule to AC.rules, also add it to the various lookups and dropdowns
-- returns nil on success or error message
function AutoCategory.cache.AddRule(rule)
    if not rule or not rule.name then
        return "AddRule: Rule or name of rule was nil"
    end -- can't use a nil rule
	
	AC.AssociateRule(rule)

	if not rule.tag or rule.tag == "" then
        rule.tag = AC_EMPTY_TAG_NAME
    end
	
    if cache.rulesByTag_cvt[rule.tag] == nil then
        cache.rulesByTag_cvt[rule.tag] = CVT:New(nil, nil, CVT.USE_TOOLTIPS) -- uses choicesTooltips
    end

	local rule_ndx = cache.rulesByName[rule.name]
    if rule_ndx then
		-- rule already exists
		-- save overwritten rule??
		
		-- overwrite rule with new one
		--AC.rules[rule_ndx] = rule
     
	else
		-- add the new rule
		if rule.pred and rule.pred == 1 then 
			--table.insert(AC.predefinedRules, rule) 
			
		else
			AC.acctRules.rules[#AC.acctRules.rules+1] = rule
			--table.insert(AC.acctRules.rules, rule)
		end
		AC.rules[#AC.rules+1] = rule
		--table.insert(AC.rules, rule)
		rule_ndx = #AC.rules
		cache.rulesByName[rule.name] = rule_ndx

		cache.rulesByTag_cvt[rule.tag]:append(rule.name, nil, rule:getDesc()) --rule.name, rule:getDesc())
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
		d("[AC] "..tostring(name).."   itemId = "..tostring(itemId))
	end
	local function AC_AddMenuItem(rowControl, slotActions)
		AddCustomMenuItem("AC: Get itemId", function() AC_GetItem(rowControl) end, MENU_ADD_OPTION_LABEL)
		  --Show the context menu entries at the inventory row now
		  ShowMenu(rowControl)
	end
	LCM:RegisterContextMenu(AC_AddMenuItem, LibCustomMenu.CATEGORY_LATE )
end

function AutoCategory.LazyInit()
    if not AutoCategory.Inited then
        AutoCategory.Inited = true

        -- initialize plugins
        for _, v in pairs(AutoCategory.Plugins) do
            if v.init then
                v.init()
            end
        end

        AutoCategory.AddonMenuInit()
		AutoCategory.RecompileRules(AC.rules)
		
		-- Set up the context menu item for AutoCategory
		setupContextMenu()
		
        -- hooks
        AutoCategory.HookGamepadMode()
        AutoCategory.HookKeyboardMode()

        --capabilities with other (older) add-ons
        IntegrateQuickMenu()
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
local function addTableRules(tbl, tblname, notdel, ispredef)
	if not tbl.rules or tbl.rules == AC.rules then return end

	--AC.logger:Info("Adding rules from table "..(tblname or "unknown").."  count = "..#tbl.rules)
	local rndx, newName

	-- add a rule to the combined rules list and the name-lookup
	local function addCombinedRule(rl)
		AC.rules[#AC.rules+1] = rl
		--table.insert(AC.rules, rl)
		--AC.logger:Info("Adding rule "..rl.name.." to AC.rules ndx="..#AC.rules)
		cache.rulesByName[rl.name] = #AC.rules
	end

	-- process all of the rules in the table
	local v, r
	for k=#tbl.rules, 1, -1 do
		v = tbl.rules[k]
		--.logger:Info((tblname or "unknown").." "..k..". "..v.name)
		--if not notdel then
		--	table.remove(tbl.rules, k)
		--end
		if ispredef == true then
			v.pred=1
		end

		r = AC.GetRuleByName(v.name)
		if r then
			--AC.logger:Warn("Found duplicate rule name - "..v.name)
			-- already have one
			if v.rule == r.rule then
				-- same rule, so don't add it again
				--AC.logger:Warn("1 Dropped duplicate rule - "..v.name.."  from AC.rules sourced "..(tblname or "unknown"))

			else
				local oldname = v.name
				-- rename different rule
				newName = AC.GetUsableRuleName(v.name)
				v.name = newName

				addCombinedRule(v)
				AC.renameBagRule(oldname, newName)
				if (v.pred and v.pred == 1) or ispredef then 
					-- add to predefinedRules
					if tbl.rules ~= AC.predefinedRules then
						AC.predefinedRules[#AC.predefinedRules+1] = v
						--table.insert(AC.predefinedRules, v) 
					end

				else
					-- add to acctRules
					if tbl.rules ~= AC.acctRules.rules then
						AC.acctRules.rules[#AC.acctRules.rules+1] = v
						--table.insert(AC.acctRules.rules, v)
					end
				end
				-- add to input table (if notdel == true)
				if notdel == true then
				    --table.remove(tbl.rules, k)
					tbl.rules[k] = v
				end
			end

		else
			-- brand new (never seen) rule
			if (v.pred and v.pred == 1) or ispredef then 
				-- it's a predefined rule
				if tbl.rules ~= AC.predefinedRules then
					AC.predefinedRules[#AC.predefinedRules+1] = v
					--table.insert(AC.predefinedRules, v) 
				end

		    else
				-- it's a user rule
			    if tbl.rules ~= AC.acctRules.rules then
					AC.acctRules.rules[#AC.acctRules.rules+1] = v
					--table.insert(AC.acctRules.rules, v)
			    end
			end
			-- add it to the combined (AC.rule) list
			addCombinedRule(v)
        end
    end
end
	
-- setup that needs to be done when the addon is loaded into the game
function AutoCategory.onLoad(event, addon)
    if addon ~= AutoCategory.name then
        return
    end

	-- make sure we are not called again
	AC.evtmgr:unregEvt(EVENT_ADD_ON_LOADED)

    AC.checkLibraryVersions()

    -- load our saved variables (no longer loads pre-defined rules)
    AC.acctSaved, AC.charSaved = SF.getAllSavedVars("AutoCategorySavedVars",
		1.1, AC.defaultAcctSettings, AC.defaultCharSettings)
	
	-- There are no char-level variables for AutoCatRules!
    AC.acctRules  = SF.getAcctSavedVars("AutoCatRules", 1.1, AutoCategory.default_rules)
	SF.defaultMissing(AC.acctRules, AutoCategory.default_rules)


	if not AC.charSaved.colld then
		AC.charSaved.colld =  true
		AC.ResetCollapse(AC.acctSaved)
		AC.ResetCollapse(AC.charSaved)
	end
	
    -- init bag category table only when the bag defs is missing/empty
	if AC.charSaved.accountWide == true then
		-- check acctSaved
		AC.acctSaved.bags = SF.safeTable(AC.acctSaved.bags)
		if SF.isEmpty(AC.acctSaved.bags) then
			SF.defaultMissing(AC.acctSaved.bags, AC.defaultAcctBagSettings.bags)
			AC.ResetCollapse(AC.acctSaved)
		end
		
	else
		-- check charSaved
		AC.charSaved.bags = SF.safeTable(AC.charSaved.bags)
		if SF.isEmpty(AC.charSaved.bags) then
			SF.defaultMissing(AC.charSaved.bags, AutoCategory.defaultAcctBagSettings.bags)
			AC.ResetCollapse(AC.charSaved)
		end
	end

end

-- --------------------------------------------------------------------
-- keep track of registered events for AutoCategory
AC.evtmgr = SF.EvtMgr:New("AutoCategory")

-- only runs once
-- continues initialization after all addons are loaded into the game
function AutoCategory.onPlayerActivated()
	local evtmgr = AC.evtmgr

	-- make sure we are only called once
	evtmgr:unregEvt(EVENT_PLAYER_ACTIVATED)

	evtmgr:registerEvt(EVENT_CLOSE_GUILD_BANK, function () AC.BulkMode = false end)
	evtmgr:registerEvt(EVENT_CLOSE_BANK, function () AC.BulkMode = false end)

	-- combine the user-defined and pre-defined into a single set for use
	AC.rules = SF.safeClearTable(AutoCategory.rules) -- start empty

	-- add pre-defined rules first to the combined rules and name-lookup
	local pred = { rules = AC.predefinedRules, }
	addTableRules(pred, "AC.predefinedRules", true, true)
	--AC.logger:Debug("2 predefined "..SF.GetSize(AC.predefinedRules))

	-- add plugin predefined rules to the combined rules and name-lookup
	for name, v in pairs(AutoCategory.Plugins) do
		AC.logger:Debug("plugin: "..name)
		if v.predef then
			AC.logger:Debug ("Processing predefs from".. name.." "..SF.GetSize(v.predef))
			local pred = { rules = v.predef, }
			addTableRules(pred, name..".predefinedRules", true, true)
		end
	end
	--AC.logger:Debug("2.5 predefined "..SF.GetSize(AC.predefinedRules))

	-- load lookup for predefines
	local lpred = {}
	for k, v in pairs(AC.predefinedRules) do
		if lpred[v.name] then
			--AC.logger:Info("Found duplicate predefine: "..v.name.." ("..k..") - original k = "..lpred[v.name])

		else
			lpred[v.name] = k
		end
	end
	--AC.logger:Debug("2 lpred "..SF.GetSize(lpred))

	-- debug output function to display rule tables in log
	local function printRuleTbl(tbl, tblname)
		for k,v in pairs(tbl) do
			AC.logger:Debug(tblname.."["..k.."] = "..v.name)
		end

	end

	-- remove predefines from the passed-in table
	--     note: tblname is only used for logger messages.
	local function pruneTables(tbl, tblname)
		if not tbl or SF.GetSize(tbl) == 0 then return end

		local v
		for k=#tbl,1, -1 do
			v= tbl[k]
			if lpred[v.name] then
				-- delete dupe
				--AC.logger:Warn("Deleting pre-def from acctSaved.rules: "..v.name)
				table.remove(tbl, k)
			end
		end
		--AC.logger:Info(tblname.." # went from "..asv.." to "..SF.GetSize(tbl)) -- count that we end with
		--printRuleTbl(tbl,tblname)

	end

	if not AC.charSaved.nep then
		-- prune pre-defines from acctSaved
		if AC.acctSaved.rules and #AC.acctSaved.rules > 0 then
			pruneTables(AC.acctSaved.rules, "acctSaved.rules")
		end

		-- prune pre-defines from charSaved
		if AC.charSaved.rules and #AC.charSaved.rules > 0 then
			pruneTables(AC.charSaved.rules, "charSaved.rules")
		end
	end

	-- add user-defined rules next
	addTableRules(AC.acctRules, "AC.acctRules.rules", true)	-- "real" user-defined rules, do not delete rules from AC.acctRules table
	if not AC.charSaved.nep then
		addTableRules(AC.acctSaved, "AC.acctSaved.rules")		-- old acct-wide combo rules
		AC.acctSaved.rules = nil
		addTableRules(AC.charSaved, "AC.charSaved.rules")		-- old char combo rules
		AC.charSaved.rules = nil
	end

	-- cannot use printRuleTbl() because this is NOT a table of rules
	--for k,v in pairs(lpred) do
	--    AC.logger:Debug("lpredrules["..k.."] = "..v)
	--end


	--printRuleTbl(AC.rules, "combrules")
	--printRuleTbl(AC.acctRules.rules,"acctRules.rules")

	--AC.logger:Debug("lpred "..#lpred)
	--AC.logger:Debug("3 predefined "..SF.GetSize(AC.predefinedRules))
	--AC.logger:Debug ("3 acctSaved "..SF.GetSize(AC.acctSaved.rules))
	--AC.logger:Debug ("3 charSaved "..SF.GetSize(AC.charSaved.rules))
	--AC.logger:Debug ("3 rules "..SF.GetSize(AC.rules))
	--AC.logger:Debug ("3 acctRules "..SF.GetSize(AC.acctRules.rules))

	if AC.charSaved.nep == nil then
		AC.charSaved.nep = 1
	end

    AC.UpdateCurrentSavedVars()
    AC.LoadCollapse()		-- must follow UpdateCurrentSavedVars()

    AC.LazyInit()	-- also loads in predefines for plugins
end

do
	-- register our event handler function to be called to do initialization
	AC.evtmgr:registerEvt(EVENT_ADD_ON_LOADED, 		AutoCategory.onLoad)
	AC.evtmgr:registerEvt(EVENT_PLAYER_ACTIVATED, 	AutoCategory.onPlayerActivated)
end


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

local function RefreshList(inventoryType, even_if_hidden)
	if even_if_hidden == nil then
		even_if_hidden = false
	end

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

AutoCategory.RefreshList = RefreshList

function AutoCategory.RefreshCurrentList(even_if_hidden)
	if not even_if_hidden then even_if_hidden = false end

	RefreshList(INVENTORY_BACKPACK, even_if_hidden)
	RefreshList(INVENTORY_CRAFT_BAG, even_if_hidden)
	RefreshList(INVENTORY_GUILD_BANK, even_if_hidden)
	RefreshList(INVENTORY_HOUSE_BANK, even_if_hidden)
	RefreshList(INVENTORY_BANK, even_if_hidden)
	RefreshList(AC_DECON, even_if_hidden)
	RefreshList(AC_IMPROV, even_if_hidden)
	RefreshList(UV_DECON, even_if_hidden)
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
function AC_ItemRowHeader_OnMouseClicked(header)
    if (AutoCategory.acctSaved.general["SHOW_CATEGORY_COLLAPSE_ICON"] == false) then
        return
    end

    local cateName = header.slot.dataEntry.data.AC_categoryName
    local bagTypeId = getBagTypeId(header)

    local collapsed = AutoCategory.IsCategoryCollapsed(bagTypeId, cateName)
    AutoCategory.SetCategoryCollapsed(bagTypeId, cateName, not collapsed)
    AutoCategory.RefreshCurrentList()
end

-- called from AutoCategory.xml
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
                AutoCategory.SetCategoryCollapsed(bagTypeId, cateName, false)
                AutoCategory.RefreshCurrentList()
            end
        )

    else
        AddMenuItem(
            L(SI_CONTEXT_MENU_COLLAPSE),
            function()
                AutoCategory.SetCategoryCollapsed(bagTypeId, cateName, true)
                AutoCategory.RefreshCurrentList()
            end
        )
    end
	
	-- add Expand All to menu
    AddMenuItem(
        L(SI_CONTEXT_MENU_EXPAND_ALL),
        function()
            for k, _ in pairs(saved.collapses[bagTypeId]) do
				AutoCategory.SetCategoryCollapsed(bagTypeId,k,false)
            end
            AutoCategory.RefreshCurrentList()
        end
    )

	-- add Collapse All to menu
    AddMenuItem(
        L(SI_CONTEXT_MENU_COLLAPSE_ALL),
        function()
            for k, _ in pairs(saved.collapses[bagTypeId]) do
				AutoCategory.SetCategoryCollapsed(bagTypeId,k,true)
            end
			AutoCategory.SetCategoryCollapsed(bagTypeId,saved.appearance["CATEGORY_OTHER_TEXT"],true)
            AutoCategory.RefreshCurrentList()
        end
    )
    ShowMenu()
end

-- called from binding.xml
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
