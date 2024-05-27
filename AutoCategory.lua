----------------------
--INITIATE VARIABLES--
----------------------

local L = GetString
local SF = LibSFUtils
local AC = AutoCategory

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
    rulesByTag_svt = {}, -- [tag] {choices{rule.name}, choicesTooltips{rule.desc/name}}
    compiledRules = AC.compiledRules, -- [name] function
    tags = {}, -- [#] tagname
    bags_svt = {}, -- {choices{bagname}, choicesValues{bagid}, choicesTooltips{bagname}} -- for the bags themselves
    entriesByBag = {}, -- [bagId] {choices{ico rule.name (pri)}, choicesValues{rule.name}, choicesTooltips{rule.desc/name or missing}} --
    entriesByName = {}, -- [bagId][rulename] {priority, isHidden}
	--collapses = {},		-- from either acctSaved or charSaved collapses??
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
    d("Saved rules: " .. #saved.rules)
    d("Predefined rules: " .. #AC.predefinedRules)
    d("Combined rules: " .. #AC.rules)
    d("Compiled rules: " .. SF.GetSize(cache.compiledRules))
    d("Rules by Name: " .. SF.GetSize(cache.rulesByName))
    d("Rules by Tag: " .. SF.GetSize(cache.rulesByTag_svt))
    d("Tags: " .. SF.GetSize(cache.tags))
    d("Saved bags: " .. #saved.bags)
    d("Cache bags: " .. SF.GetSize(cache.bags_svt))
    d("Entries by Bag: " .. SF.GetSize(cache.entriesByBag))
    d("Entries by Name: " .. SF.GetSize(cache.entriesByName))
end

--unused (debug)
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
    for j,v in pairs(ruleset) do
        if ruleset[j] then
            local r = ruleset[j]
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
	if b == nil then return true end

	-- b is not nil
	if a == nil then return false end

	-- a is not nil
    if a.priority and b.priority and a.priority ~= b.priority then
        result = a.priority > b.priority

    else
		if a.name == nil then return false end
		if b.name == nil then return true end
        result = a.name < b.name
    end
    return result
end

function AutoCategory.UpdateCurrentSavedVars()
	AC.meta = SF.safeTable(AC.meta)
	SF.addonMeta(AC.meta,"AutoCategory")
	AC.logger:Debug(SF.dTable(AC.meta, 3, "meta"))
	
    -- general, and appearance are always accountWide
    saved.general = AutoCategory.acctSaved.general
    saved.appearance = AutoCategory.acctSaved.appearance

	-- AC.acctRules only has user-defined rules
	-- AC.rules will have acctRules plus the predefined rules 
    --saved.rules = AutoCategory.acctSaved.rules
    --table.sort(saved.rules, RuleSortingFunction)
	
	-- assign functions to rules
	local ruletbl = AC.rules
	local mt = { __index = AC.rulefuncs, }
    for ndx,_ in pairs(ruletbl) do
        setmetatable(ruletbl[ndx],mt)
	end
	
    AutoCategory.RecompileRules(ruletbl)

	-- bags/collapses might or might not be acct wide?
    if not AutoCategory.charSaved.accountWide then
        saved.bags = AutoCategory.charSaved.bags
        saved.collapses = AutoCategory.charSaved.collapses

    else
        saved.bags = AutoCategory.acctSaved.bags
        saved.collapses = AutoCategory.acctSaved.collapses
    end
	
	-- associate functions with bag entries
	for i = 1, #saved.bags do
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
-- returns priority, rulename from a formatted BagRuleEntry indexValue
function AutoCategory.BagRuleEntry.splitValue(value)
    return string.find(value, "%((%d+)%) (%a+)")
end

function AutoCategory.BagRuleEntry.formatValue(entry)
    return entry.name
    --return string.format("(%04d) %s", entry.priority, entry.name )
end

function AutoCategory.BagRuleEntry.formatShow(entry, rule)
    local sn = nil
    if not rule then
        -- missing rule (nil was passed in)
        sn = string.format("|cFF4444(!)|r %s (%d)", entry.name, entry.priority)

    else
        if entry.AC_isHidden then
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
    --for j = 1, #cache.bags_svt do
	for j = 1, 6 do
		local bagcol = vars.collapses[j]
		for k,v in pairs(bagcol) do
			bagcol[k] = nil
			--cache.collapses[j] = SF.safeTable(cache.collapses[j])
		end
	end
end

-- Determine if the specified category of the particular bag is collapsed or not
function AutoCategory.IsCategoryCollapsed(bagTypeId, categoryName)
	if bagTypeId == nil or categoryName == nil then return false end

	--collapsetbl = SF.safeTable(cache.collapses[bagTypeId])
	collapsetbl = SF.safeTable(saved.collapses[bagTypeId])
    return collapsetbl[categoryName] or false
end


function AutoCategory.SetCategoryCollapsed(bagTypeId, categoryName, collapsed)
	--cache.collapses[bagTypeId] = SF.safeTable(cache.collapses[bagTypeId])
	if not categoryName then return end
	--if collapsed == false then
	--	collapsed = nil
	--end
	--cache.collapses[bagTypeId][categoryName] = collapsed
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

	AutoCategory.acctSaved.appearance = SF.safeClearTable(AutoCategory.acctSaved.appearance)
    ZO_DeepTableCopy(AutoCategory.defaultAcctSettings.appearance,
			AutoCategory.acctSaved.appearance)

	AutoCategory.charSaved.bags = SF.safeClearTable(AutoCategory.charSaved.bags)
    ZO_DeepTableCopy(AutoCategory.defaultSettings.bags, AutoCategory.charSaved.bags)

    AutoCategory.charSaved.accountWide = AutoCategory.defaultSettings.accountWide

    AutoCategory.ResetCollapse(AutoCategory.charSaved)
end

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
	for i = 1, #saved.bags do
		local bag = saved.bags[i]
		local rules = bag.rules
		for j = 1, #rules do
			local rule = rules[j]
			if rule.name == oldName then
				rule.name = newName
			end
		end
	end
end

-- ----------------------------------------------------
-- assumes that saved.rules and saved.bags have entries but
-- some or all of the cache tables need (re)initializing
--
function AutoCategory.cacheInitialize()
	--AC.logger:Debug("AC.cacheInitialize()")
    -- initialize the rules-based lookups
    cache.rulesByName = SF.safeClearTable(cache.rulesByName)
    cache.rulesByTag_svt = SF.safeClearTable(cache.rulesByTag_svt)
	
    cache.tags = SF.safeClearTable(cache.tags)
	local mt = { __index = AC.rulefuncs, }
	
	--AC.logger:Debug("AC.cacheInitialize - processing rules")
	local ruletbl = AC.rules  --saved.rules
    table.sort(ruletbl, RuleDataSortingFunction ) -- already sorted by name
    for ndx,_ in pairs(ruletbl) do
        local rule = ruletbl[ndx]
		setmetatable(rule, mt)
		--AC.logger:Debug("AC.cacheInitialize - associating rule "..rule.name)
		
        local name = rule.name
        cache.rulesByName[name] = ndx
		--AC.logger:Debug("AC.cacheInitialize - updating rules by name "..name.."  "..ndx)

        local tag = rule.tag
        if tag == "" then
            tag = AC_EMPTY_TAG_NAME
        end
		--AC.logger:Debug("AC.cacheInitialize - updating rules by tag")
        --update cache for tag grouping
        if not cache.rulesByTag_svt[tag] then
            table.insert(cache.tags, tag)
            cache.rulesByTag_svt[tag] = {choices = {}, choicesValues = {}, choicesTooltips = {}}
        end
        local tooltip = rule:getDesc()
        table.insert(cache.rulesByTag_svt[tag].choices, name)
        table.insert(cache.rulesByTag_svt[tag].choicesValues, name)
        table.insert(cache.rulesByTag_svt[tag].choicesTooltips, tooltip)
    end

	--AC.logger:Debug("AC.cacheInitialize - initializing bag-based")
    -- initialize the bag-based lookups
    ZO_ClearTable(cache.entriesByName)
    ZO_ClearTable(cache.entriesByBag)
	
    -- load in the bagged rules (sorted by priority high-to-low) into the dropdown
    for bagId = 1, #saved.bags do
		AC.AssociateBagRule(saved.bags[bagId])
		if cache.entriesByBag[bagId] == nil then
			cache.entriesByBag[bagId] = {choices = {}, choicesValues = {}, choicesTooltips = {}}
		end

		cache.entriesByName[bagId] = SF.safeTable(cache.entriesByName[bagId])
        local ename = cache.entriesByName[bagId]	-- [name] { priority, isHidden }
        local ebag = cache.entriesByBag[bagId]		-- CVT

		if saved.bags[bagId] == nil then
			saved.bags[bagId] = {rules={}}
		end
		local svdbag = saved.bags[bagId]
        table.sort(svdbag.rules, BagRuleSortingFunction)
		
        for entry = 1, #svdbag.rules do
            local data = svdbag.rules[entry] -- data equals BagRule {name, priority, isHidden}

			if data  and data.name then --:isValid() then
				AC.logger:Debug("AC.cacheInitialize - updating bagrule CVT for rulename: "..tostring(data.name))
				AC.logger:Debug("AC.cacheInitialize - ename: "..tostring(ename))

				local ruleName = data.name
				ename[ruleName] = data
				AC.logger:Debug("AC.cacheInitialize - ename[data]: "..tostring(ename.data))
				table.insert(ebag.choicesValues, AC.BagRuleEntry.formatValue(data)) --data:formatValue()) --AC.BagRuleEntry.formatValue(data))

				local rule = AC.GetRuleByName(ruleName)
				local sn = AC.BagRuleEntry.formatShow(data, rule) --data:formatShow()    --AC.BagRuleEntry.formatShow(data, rule)
				local tt = AC.BagRuleEntry.formatTooltip(rule)  --data:formatTooltip() --AC.BagRuleEntry.formatTooltip(rule)
				table.insert(ebag.choices, sn)
				table.insert(ebag.choicesTooltips, tt)
			end
        end
    end

	--AC.logger:Debug("AC.cacheInitialize - clearing collapses ")
    --cache.collapses = SF.safeClearTable(cache.collapses)

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

    -- remove from entriesByBag
	--AC.logger:Debug("remove from entriesByBag "..bagId.."  "..rulename)
    local r = cache.entriesByBag[bagId]
    for i = #r.choicesValues, 1, -1 do
        local p, n = AutoCategory.BagRuleEntry.splitValue(r.choicesValues[i])
        if n == rulename then
			--AC.logger:Debug("remove from entriesByBag: found it! "..bagId.."  "..name)
            table.remove(r.choicesValues, i)
            table.remove(r.choices, i)
            table.remove(r.choicesTooltips, i)
            break
        end
    end
	
    -- remove from collapses
	--AC.logger:Debug("remove from entriesByName ["..bagId.."]  "..rulename)
    cache.entriesByName[bagId][rulename] = nil
	
	-- remove from collapses
	AC.logger:Debug("remove from collapses ["..bagId.."]  "..rulename)
	local collapsebag = saved.collapses[bagId]
	--AC.logger:Debug("collapses ["..bagId.."]  contains "..SF.GetSize(collapsebag))
	local tname = rulename.." %("
	for k,v in pairs(collapsebag) do
		--AC.logger:Debug("checking collapses["..k.."] - "..tostring(collapsebag[k]))

		if k == rulename then
			--AC.logger:Debug("collapsebag["..k.."] matched "..rulename)
			collapsebag[k] = nil
			
		elseif 1 == string.find(k,tname) then
			--AC.logger:Debug("collapsebag["..k.."] matched "..tname)
			collapsebag[k] = nil
			
		--else
			--AC.logger:Debug("collapsebag["..k.."] nomatch ")
		end
	end

    -- removed from saved.bags
	--AC.logger:Debug("remove from saved.bags "..bagId.."  "..rulename)
	local bagrules = saved.bags[bagId].rules
    for i = #bagrules, 1, -1 do
		if bagrules[i].name == rulename then
			--AC.logger:Debug("remove from saved.bags: found it! "..bagId.."  "..rulename)
            table.remove(bagrules[i])
            break
        end
    end
	
end

-- remove a rule from the saved rules stores
-- (note: does not remove associated bagrules!)
function AutoCategory.cache.RemoveRuleByName(name)
    if not name then return end
    if not cache.rulesByName[name] then return end

    local ndx = cache.rulesByName[name]
    cache.compiledRules[name] = nil
    cache.rulesByName[name] = nil

    -- remove from cache.rulesByTag_svt
    for t, s in pairs(cache.rulesByTag_svt) do
        for i = #s.choices, 1, -1 do
            if s.choices[i] == name then
                table.remove(s.choices, i)
                if s.choicesValues then
                    table.remove(s.choicesValues, i)
                end
                if s.choicesTooltips then
                    table.remove(s.choicesTooltips, i)
                end
                break
            end
        end
    end

    -- remove from entriesByBag
    for b, r in pairs(cache.entriesByBag) do
        AutoCategory.cache.RemoveRuleFromBag(b, name)
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
	
	local mt = { __index = AC.rulefuncs, }
	setmetatable(rule, mt)

	if not rule.tag or rule.tag == "" then
        rule.tag = AC_EMPTY_TAG_NAME
    end
	
    if cache.rulesByTag_svt[rule.tag] == nil then
        cache.rulesByTag_svt[rule.tag] = {choices = {}, choicesValues = {}, choicesTooltips = {}}
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
			--AC.logger:Debug("[AddRule] Adding rule to predefinedRules ".. rule.name)
			--table.insert(AC.predefinedRules, rule) 
			
		else
			--AC.logger:Debug("[AddRule] Adding rule to acctRules ".. rule.name)
			table.insert(AC.acctRules.rules, rule)
		end
		--AC.logger:Debug("[AddRule] Adding rule to AC.rules ".. rule.name)
		table.insert(AC.rules, rule)
		rule_ndx = #AC.rules
		cache.rulesByName[rule.name] = rule_ndx

		table.insert(cache.rulesByTag_svt[rule.tag].choices, rule.name)
		table.insert(cache.rulesByTag_svt[rule.tag].choicesValues, rule.name)
		table.insert(cache.rulesByTag_svt[rule.tag].choicesTooltips, rule:getDesc())
    end

	rule:compile()
end

-- unused??
--[[
function AutoCategory.cache.AddRuleToBag(bagId, rulename, priority)
    local entry = {name = rulename, priority = priority}

	-- get the entry list for the specified bag
    saved.bags[bagId] = SF.safeTable(saved.bags[bagId])
    cache.entriesByName[bagId] = SF.safeTable(cache.entriesByName[bagId])
    if not cache.entriesByName[bagId][rulename] then
        table.insert(saved.bags[bagId], entry)
		cache.entriesByName[bagId][rulename] = entry
    end

    --local rule = AC.rules[cache.rulesByName[rulename] ]

    local sn = entry:formatShow() --AutoCategory.BagRuleEntry.formatShow(entry, rule)
    local tt = entry:formatTooltip() --AutoCategory.BagRuleEntry.formatTooltip(rule)

	-- create the drop-down lists for entriesByBag
	if cache.entriesByBag[bagId] == nil then
		cache.entriesByBag[bagId] = {choices = {}, choicesValues = {}, choicesTooltips = {}}
	end
	local cbagentries = cache.entriesByBag[bagId]
    table.insert(cbagentries.choices, sn)
    table.insert(cbagentries.choicesValues, rulename)
    table.insert(cbagentries.choicesTooltips, tt)
end
--]]

-- unused??
--remove duplicated categories in bag
-- [ [
function AutoCategory.removeDuplicatedRules()
    for i = #saved.bags, 1, -1 do
        local bag = saved.bags[i]
        local keys = {}
        --traverse from back to front to remove elements while iteration
        for j = #bag.rules, 1, -1 do
            local data = bag.rules[j]
            if keys[data.name] ~= nil then
                --remove duplicated category
                --d("removed (" .. j .. ") " .. data.name)
                table.remove(saved.bags[i].rules, j)

            else
                --flag this category
                keys[data.name] = true
            end
        end
    end
end
--]]

local LCM = LibCustomMenu
local function setupContextMenu()
	-- Set up the context menu item for AutoCategory
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
        for name, v in pairs(AutoCategory.Plugins) do
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
-- The tblname is used only for logger messages - i.e. debugging.
-- If notdel is true then the rules are NOT removed from the source table.
-- The ispredef flag signals that ALL of the rules in the source table are predefines if true.
--
local function addTableRules(tbl, tblname, notdel, ispredef)
	AC.logger:Info("Adding rules from table "..(tblname or "unknown"))
	local r, rndx, newName
	if not tbl.rules then 
		AC.logger:Warn("No rules available from table "..(tblname or "unknown"))
		return 
	end
	if tbl.rules == AC.rules then
		AC.logger:Warn("Try not to be stupid. Don't load AC.rules with AC.rules.")
		return
	end
	
	-- add a rule to the combined rules list and the name-lookup
	local function addCombinedRule(rl)
		table.insert(AC.rules, rl)
		--AC.logger:Info("Adding rule "..rl.name.." to AC.rules ndx="..#AC.rules)
		cache.rulesByName[rl.name] = #AC.rules
	end
	
	-- process all of the rules in the table
	--for k, v in pairs(tbl.rules) do
	for k=#tbl.rules, 1, -1 do
		local v = tbl.rules[k]
		--AC.logger:Info((tblname or "unknown").." "..k..". "..v.name)
		if not notdel then
			table.remove(tbl.rules, k)
		end
		
		rndx = cache.rulesByName[v.name]
		if rndx then
			--AC.logger:Warn("Found duplicate rule name - "..v.name)
			r = AC.GetRuleByName(v.name)
			-- already have one
			if v.rule == r.rule then
				-- same rule, so don't add it again
				--AC.logger:Warn("1 Dropped duplicate rule - "..v.name.."  from AC.rules sourced "..(tblname or "unknown"))
				
			else
				local oldname = v.name
				-- rename different rule
				newName = AC.GetUsableRuleName(v.name)
				--AC.logger:Warn("Renaming rule "..v.name.." to "..newName)
				v.name = newName
				
				addCombinedRule(v)
				AC.renameBagRule(oldname, newName)				
				if (v.pred and v.pred == 1) or ispredef then 
					-- add to predefinedRules
					if tbl.rules ~= AC.predefinedRules then
						table.insert(AC.predefinedRules, v) 
					end
					
				else
					-- add to acctRules
					if tbl.rules ~= AC.acctRules.rules then
						table.insert(AC.acctRules.rules, v)
					end
				end
				-- add to input table (if notdel == true)
				if notdel == true then
				    table.remove(tbl.rules, k)
				    table.insert(tbl.rules, v)
					--AC.logger:Info("Inserting renamed rule "..v.name.." to "..(tblname or "unknown"))
				end
			end
			
		else
			-- brand new (never seen) rule
			if (v.pred and v.pred == 1) or ispredef then 
				-- it's a predefined rule
				if tbl.rules ~= AC.predefinedRules then
				  table.insert(AC.predefinedRules, v) 
				end
      
		    else
				-- it's a user rule
			    if tbl.rules ~= AC.acctRules.rules then
					table.insert(AC.acctRules.rules, v)
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

    AutoCategory.checkLibraryVersions()

    -- load our saved variables (no longer loads pre-defined rules)
    AC.acctSaved, AC.charSaved = SF.getAllSavedVars("AutoCategorySavedVars",
		1.1, AC.defaultAcctSettings, AC.defaultCharSettings)
	
	-- There are no char-level variables for AutoCatRules!
    AC.acctRules  = SF.getAcctSavedVars("AutoCatRules", 1.1, AutoCategory.default_rules)
	SF.defaultMissing(AC.acctRules, AutoCategory.default_rules)


    -- init bag category table only when the bag defs is missing/empty
	if AC.charSaved.accountWide == true then
		-- check acctSaved
		if SF.isEmpty(AC.acctSaved.bags) then
			AC.acctSaved.bags = SF.safeTable(AC.acctSaved.bags)
			SF.defaultMissing(AC.acctSaved.bags, AutoCategory.defaultAcctBagSettings.bags)
			AC.ResetCollapse(AC.acctSaved)
		end
	
	else
		-- check charSaved
		if SF.isEmpty(AC.charSaved.bags) then
			AC.charSaved.bags = SF.safeTable(AC.charSaved.bags)
			SF.defaultMissing(AC.charSaved.bags, AutoCategory.defaultAcctBagSettings.bags)
			AC.ResetCollapse(AC.charSaved)
		end
	end

end

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
	
	--AC.logger:Debug("1 predefined "..SF.GetSize(AC.predefinedRules))
	--AC.logger:Debug ("1 acctSaved "..SF.GetSize(AC.acctSaved.rules))
	--AC.logger:Debug ("1 charSaved "..SF.GetSize(AC.charSaved.rules))
	--AC.logger:Debug ("1 rules "..SF.GetSize(AC.rules))
	--AC.logger:Debug ("1 acctRules "..SF.GetSize(AC.acctRules.rules))

	-- add pre-defined rules first to the combined rules and name-lookup
	local pred = { rules = AC.predefinedRules, }
	addTableRules(pred, "AC.predefinedRules", true, true)
	--AC.logger:Debug("2 predefined "..SF.GetSize(AC.predefinedRules))
	
	-- add plugin predefined rules to the combined rules and name-lookup
	for name, v in pairs(AutoCategory.Plugins) do	
		--AC.logger:Debug("plugin: "..name)
		if v.predef then
			--AC.logger:Debug ("Processing predefs from".. name.." "..SF.GetSize(v.predef))
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
		local asv = SF.GetSize(tbl)	-- count that we start with
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
		if AC.acctSaved.rules then
			pruneTables(AC.acctSaved.rules, "acctSaved.rules")
		end

		
		-- prune pre-defines from charSaved
		if AC.charSaved.rules then
			pruneTables(AC.charSaved.rules, "charSaved.rules")
		end
	end
	
	-- add user-defined rules next
	addTableRules(AC.acctRules, "AC.acctRules.rules", true)	-- "real" user-defined rules, do not delete rules from AC.acctRules table
	if not AC.charSaved.nep then
		addTableRules(AC.acctSaved, "AC.acctSaved.rules")		-- old acct-wide combo rules
		addTableRules(AC.charSaved, "AC.charSaved.rules")		-- old char combo rules
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

	-- for first load with the new version we need to remove the existing collapses
	--[[
	if AC.charSaved.nep == nil then
		AC.charSaved.nep = 1
		AC.ResetCollapse(AC.acctSaved)
		AC.ResetCollapse(AC.charSaved)
	end
	--]]

    AutoCategory.UpdateCurrentSavedVars()
    AutoCategory.LoadCollapse()		-- must follow UpdateCurrentSavedVars()

    AutoCategory.LazyInit()	-- also loads in predefines for plugins
end

do
	-- register our event handler function to be called to do initialization
	AC.evtmgr:registerEvt(EVENT_ADD_ON_LOADED, AutoCategory.onLoad)
	AC.evtmgr:registerEvt(EVENT_PLAYER_ACTIVATED, AutoCategory.onPlayerActivated)
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
            --for k, v in pairs(AutoCategory.cache.collapses[bagTypeId]) do
				AC.logger:Debug("menu: x bagId "..bagTypeId)
				AC.logger:Debug("menu: x size "..SF.GetSize(saved.collapses[bagTypeId]))
            for k, v in pairs(saved.collapses[bagTypeId]) do
				AC.logger:Debug("menu: x expanding "..k)
                AutoCategory.SetCategoryCollapsed(bagTypeId,k,false)
            end
            AutoCategory.RefreshCurrentList()
        end
    )

	-- add Collapse All to menu
    AddMenuItem(
        L(SI_CONTEXT_MENU_COLLAPSE_ALL),
        function()
            --for k, v in pairs(AutoCategory.cache.collapses[bagTypeId]) do
				AC.logger:Debug("menu: ca bagId "..bagTypeId)
				AC.logger:Debug("menu: ca size "..SF.GetSize(saved.collapses[bagTypeId]))
            for k, v in pairs(saved.collapses[bagTypeId]) do
				AC.logger:Debug("menu: ca collapsing "..k)
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
