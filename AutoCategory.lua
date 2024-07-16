----------------------
-- Aliases
local L = GetString
local SF = LibSFUtils
local AC = AutoCategory

local CVT = AC.CVT
local logger = AutoCategory.logger
local RuleApi = AC.RuleApi
local BagRuleApi = AC.BagRuleApi

----------------------
-- Lists and variables

AC.rules = {}	--  [#] rule {rkey, name, tag, description, rule, pred, damaged, err}
AutoCategory.compiledRules = SF.safeTable(AC.compiledRules)
AutoCategory.ARW = SF.safeTable(AC.ARW)

-- AC.saved contains table references from the appropriate saved variables - either acctSaved or charSaved
-- depending on the setting of charSaved.accountWide
AutoCategory.saved = {
    rules = {}, -- [#] rule {rkey, name, tag, description, rule, damaged, err} -- obsolete
    bags = {}, -- [bagId] {rules={name, priority, isHidden}, isUngroupedHidden} -- pairs with collapses
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

function AutoCategory.debugCache()
    d("User rules: " .. AC.ARW:size()) --#AC.acctRules.rules)
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
    for j = 1, #ruleset do
        if ruleset[j] then
            RuleApi.compile(ruleset[j])
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
    -- general, and appearance are always accountWide
    saved.general = AutoCategory.acctSaved.general
    saved.appearance = AutoCategory.acctSaved.appearance

	-- AC.acctRules only has user-defined rules
	-- AC.rules will have acctRules plus the predefined rules

	-- assign functions to rules
    table.sort(AC.rules, RuleSortingFunction)
	local ruletbl = AC.rules

    AutoCategory.RecompileRules(ruletbl)

	-- bags/collapses might or might not be acct wide
    if not AutoCategory.charSaved.accountWide then
        saved.bags = AutoCategory.charSaved.bags
        saved.collapses = AutoCategory.charSaved.collapses

    else
        saved.bags = AutoCategory.acctSaved.bags
        saved.collapses = AutoCategory.acctSaved.collapses
    end

    AC.cacheInitialize()
end

-- -----------------------------------------------------------
-- Manage collapses
-- -----------------------------------------------------------
function AutoCategory.LoadCollapse()
    if not AutoCategory.acctSaved.general["SAVE_CATEGORY_COLLAPSE_STATUS"] then
        --init
        AutoCategory.ResetCollapse(AC.saved)
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

	ARW.clear()
	--AutoCategory.acctRules.rules = SF.safeClearTable(AutoCategory.acctRules.rules)
    ZO_DeepTableCopy(AutoCategory.defaultAcctSettings.rules, AutoCategory.acctRules.rules)
	ARW = AC.RuleList:New(AC.acctRules.rules)

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
		if not bag then 
			bag = { rules = {}, }
			saved.bags[i] = bag
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

-- initialize the rulesByName, rulesByTag_cvt, and the cache.tags tables from AC.rules
function AutoCategory.cacheRuleInitialize()
	-- initialize the rules-based lookups
    cache.rulesByName = SF.safeClearTable(cache.rulesByName)
    cache.rulesByTag_cvt = SF.safeClearTable(cache.rulesByTag_cvt)
    cache.tags = SF.safeClearTable(cache.tags)

	-- fill the rules-based lookups
	local ruletbl = AC.rules
    table.sort(ruletbl, RuleDataSortingFunction ) -- already sorted by name
    for ndx = 1, #ruletbl do
		-- associate rule functions with a rule struct
		--AC.AssociateRule(ruletbl[ndx])

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
            cache.rulesByTag_cvt[tag] = AC.CVT:New(nil,nil,CVT.USE_TOOLTIPS) -- uses choicesTooltips
        end
        cache.rulesByTag_cvt[tag]:append(name, nil, RuleApi.getDesc(rule))
    end
end


-- populate the entriesByName and entriesByBag lists in the cache from the saved.bags table
-- bagId needs to be between 1 and 6 (inclusive)
function AutoCategory.cacheInitBag(bagId)
	if bagId == nil or bagId < 1 or bagId > 6 then 
		return
	elseif bagId < 1 or bagId > 6 then 
		return
	end

	-- initialize the bag-based lookups for this bag
	cache.entriesByName[bagId] = SF.safeTable(cache.entriesByName[bagId])
    ZO_ClearTable(cache.entriesByName[bagId])

	cache.entriesByBag[bagId] = AC.CVT:New(nil, nil, CVT.USE_VALUES + CVT.USE_TOOLTIPS)

	local ename = cache.entriesByName[bagId]	-- { [name] BagRule{ name, priority, isHidden } }
	local ebag = cache.entriesByBag[bagId]		-- CVT

	-- fill the bag-based lookups
    -- load in the bagged rules (sorted by priority high-to-low) into the dropdown
	if saved.bags[bagId] == nil then
		saved.bags[bagId] = {rules={}}
	end
	local svdbag = saved.bags[bagId]
	table.sort(svdbag.rules, BagRuleSortingFunction)

	logger:Debug("Initializing bag "..bagId.." with bagrules")
	for entry = 1, #svdbag.rules do
		local bagrule = svdbag.rules[entry] -- BagRule {name, priority, isHidden}
		if not bagrule then break end
		--AC.AssociateBagRule(bagrule)

		local ruleName = bagrule.name
		logger:Debug("bag "..entry.." bagrule.name "..tostring(bagrule.name))
		if not ename[ruleName] then
			ename[ruleName] = bagrule
			ebag.choicesValues[#ebag.choicesValues+1] = BagRuleApi.formatValue(bagrule)

			local sn = BagRuleApi.formatShow(bagrule)
			local tt = BagRuleApi.formatTooltip(bagrule)
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
    for bagId = 1, 6 do --#saved.bags do
		AutoCategory.cacheInitBag(bagId)
    end
end


-- ----------------------------------------------------
-- assumes that AC.rules and saved.bags have entries but
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

    local ndx = cache.rulesByName[name]
    if not ndx then
        return nil
    end

    --return saved.rules[ndx]
    return AC.rules[ndx]
end

-- when we add a new rule to AC.rules, also add it to the various lookups and dropdowns
-- returns nil on success or error message
function AutoCategory.cache.AddRule(rule)
    if not rule or not rule.name then
        return "AddRule: Rule or name of rule was nil"
    end -- can't use a nil rule

	--AC.AssociateRule(rule)

    if not rule.tag or rule.tag == "" then
        rule.tag = AC_EMPTY_TAG_NAME
    end

    if cache.rulesByTag_cvt[rule.tag] == nil then
        cache.rulesByTag_cvt[rule.tag] = CVT:New(nil, nil, CVT.USE_TOOLTIPS) -- uses choicesTooltips
    end

	local rule_ndx = cache.rulesByName[rule.name]
    if rule_ndx then
		-- rule already exists
		-- overwrite rule with new one
		AC.rules[rule_ndx] = rule

	else
		-- add the new rule
		AC.rules[#AC.rules+1] = rule
		rule_ndx = #AC.rules
		cache.rulesByName[rule.name] = rule_ndx
		cache.rulesByTag_cvt[rule.tag]:append(rule.name, nil, RuleApi.getDesc(rule))
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
local function addTableRules(tbl, tblname, notdel, ispredef)
	if not tbl.rules or tbl.rules == AC.rules then return end

	--AC.logger:Info("Adding rules from table "..(tblname or "unknown").."  count = "..#tbl.rules)

	-- create name lookup for acctRules
	local lkacctRules = AC.ARW:getLookup()
	--[[
	local lkacctRules = {}
	local arrules = AC.acctRules.rules
	for k = #arrules,1,-1 do
		if not lkacctRules[arrules[k].name ] then
			lkacctRules[arrules[k].name] = k
		end
	end
	--]]
	local newName

	-- add a rule to the combined rules list and the name-lookup
	local function addCombinedRule(rl)
		AC.rules = SF.safeTable(AC.rules)
		local n = cache.rulesByName[rl.name]
		if not n then
			AC.rules[#AC.rules+1] = rl
			--logger:Info("Adding rule "..rl.name.." to AC.rules ndx="..#AC.rules)
			cache.rulesByName[rl.name] = #AC.rules
			return true
		else
			AC.rules[n] = rl
			--logger:Info("Overwriting rule "..rl.name.." to AC.rules ndx="..n)
			cache.rulesByName[rl.name] = n
		end
		return false
	end

	local function addPredef(tbl, rule)
		-- add to predefinedRules list
		if tbl.rules ~= AC.predefinedRules then
			AC.predefinedRules[#AC.predefinedRules+1] = rule
		end
	end

	local function addUserRule(tbl, rule)
		-- add to acctRules list
		if tbl.rules ~= AC.acctRules.rules then
			ARW:AddRule(rule)
			--[[
			if not lkacctRules[rule.name] then
				--logger:Info("Adding user rule "..rule.name.." to AC.acctRules")
				AC.acctRules.rules[#AC.acctRules.rules+1] = rule
			end
			--]]
		end
	end

	-- process all of the rules in the table
	local v, r
	for k=#tbl.rules, 1, -1 do
		v = tbl.rules[k]
		if ispredef == true then
			v.pred=1
		end

		r = AC.GetRuleByName(v.name)
		if r then
			--logger:Warn("Found duplicate rule name - "..v.name)
			-- already have one
			if v.rule == r.rule then
				-- same rule def, so don't add it again
				--logger:Warn("1 Dropped duplicate rule - "..v.name.."  from AC.rules sourced "..(tblname or "unknown"))

			else
				local oldname = v.name
				-- rename different rule
				newName = AC.GetUsableRuleName(v.name)
				v.name = newName
				--logger:Warn("Renaming duplicate rule name - "..oldname.." to "..v.name)

				addCombinedRule(v)
				AC.renameBagRule(oldname, newName)
				if AC.RuleApi.isPredefined(v) then 
					addPredef(tbl, v)

				else
					-- add to acctRules
					addUserRule(tbl, v)
					--logger:Warn("adding to user rules - "..v.name.."  from sourced "..(tblname or "unknown"))
				end
				-- add to input table (if notdel == true)
				if notdel == true then
				    tbl.rules[k] = v
				end
			end

		else
			-- brand new (never seen) rule
			-- add it to the combined (AC.rule) list
			addCombinedRule(v)

			if AC.RuleApi.isPredefined(v) then 
				-- it's a predefined rule
				addPredef(tbl, v)
				logger:Warn("adding to predefined rules - "..v.name.."  from sourced "..(tblname or "unknown"))

		    else
				-- it's a user rule
				addUserRule(tbl, v)
				logger:Warn("adding to user rules - "..v.name.."  from sourced "..(tblname or "unknown"))
			end
        end
    end
end

local function pruneUserRules()
	local arrules = AC.acctRules.rules
	local lkacctRules = AC.ARW:getLookup()
	--[[
	 k = #arrules,1,-1 do
		if not lkacctRules[arrules[k].name] then
			lkacctRules[arrules[k].name] = k
		end
	end
	--]]
	for k = #arrules,1,-1 do
		local ndx = lkacctRules[arrules[k].name]
		if  ndx and k ~= ndx then
			ARW.removeRule(ndx)
			--table.remove(arrules, k)
		end
	end
end

-- cannot use this until after addons are finally loaded!!
local function loadPluginPredefines()
	-- add plugin predefined rules to the base predefined rules
	for name, plugin in pairs(AutoCategory.Plugins) do
		if plugin.predef then
			logger:Debug ("Processing predefs from plugin ".. name.." "..SF.GetSize(plugin.predef))

			-- process all of the rules in the table
			addTableRules(plugin.predef, name..".predefinedRules", true, true)
		end
	end
	logger:Debug("2.5 predefined "..SF.GetSize(AC.predefinedRules))
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
	AC.ARW = AutoCategory.RuleList:New(AC.acctRules.rules)

	AutoCategory.LoadCollapse()

	-- Set up the context menu item for AutoCategory
	setupContextMenu()

	-- hooks
	AutoCategory.HookGamepadMode()
	AutoCategory.HookKeyboardMode()
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

	--capabilities with other (older) add-ons
	IntegrateQuickMenu()

	if LibDebugLogger then
		AutoCategory.logger = LibDebugLogger.Create("AutoCategory")
		AutoCategory.logger:SetEnabled(true)
	end

	AC.meta = SF.safeTable(AC.meta)
	SF.addonMeta(AC.meta,"AutoCategory")

	-- add plugin predefined rules to the combined rules and name-lookup
	loadPluginPredefines()

	local pd = { rules = AC.predefinedRules, }
	addTableRules(pd, ".predefinedRules", true, true)
	pruneUserRules()

	addTableRules(AC.acctRules, ".acctRules", true, false)
	addTableRules(AC.acctSaved, ".acctSaved", true, false)
	addTableRules(AC.charSaved, ".charSaved", true, false)

	logger:Debug("2.5 predefined "..SF.GetSize(AC.predefinedRules))

    AutoCategory.UpdateCurrentSavedVars()
	AutoCategory.initializePlugins()
	AC.cacheInitialize()
	AutoCategory.AddonMenuInit()
    --AutoCategory.LoadCollapse()
end

do
	-- register our event handler function to be called to do initialization
	AC.evtmgr:registerEvt(EVENT_ADD_ON_LOADED, 		AutoCategory.onLoad)
	AC.evtmgr:registerEvt(EVENT_PLAYER_ACTIVATED, 	AutoCategory.onPlayerActivated)
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

-- make accessible
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
    AutoCategory.SetCategoryCollapsed(bagTypeId, cateName, not collapsed)
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
-- toggle AutoCategory on or off?
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
