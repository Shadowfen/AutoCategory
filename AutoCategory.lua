----------------------
--INITIATE VARIABLES--
---------------------- 

local L = GetString
local SF = LibSFUtils
local AC = AutoCategory

AutoCategory.compiledRules = {}
AutoCategory.saved= { 
    rules = {},             -- [#] rule {name, tag, description, rule, damaged}
    bags = {},              -- [bagId] {rules{name, priority, isHidden}, isHidden}
}
AutoCategory.cache = {
    rulesByName = {},       -- [name] rule#
    rulesByTag = {},        -- [tag] {showNames{rule.name}, tooltips{rule.desc/name}}
    compiledRules = AutoCategory.compiledRules, -- [name] function
    tags = {},              -- [#] tagname
    
    bags = {},              -- {showNames{bagname}, values{bagid}, tooltips{bagname}} -- for the bags themselves
    entriesByBag = {},      -- [bagId] {showNames{ico rule.name (pri)}, values{rule.name}, tooltips{rule.desc/name or missing}} --
    entriesByName = {},     -- [bagId][rulename] {priority, isHidden}
}


AutoCategory.BagRuleEntry = {
}

local saved = AutoCategory.saved
local cache = AutoCategory.cache

local AC_EMPTY_TAG_NAME = L(SI_AC_DEFAULT_NAME_EMPTY_TAG)

function AC.listcount(tbl)
    local i = 0
    if tbl then
        for k,v in pairs(tbl) do
            i = i + 1
        end
    end
    return i
end

function AutoCategory.debugCache()
    d("Saved rules: "..#saved.rules)
    d("Compiled rules: "..AC.listcount(cache.compiledRules))
    d("Rules by Name: "..AC.listcount(cache.rulesByName))
    d("Rules by Tag: "..AC.listcount(cache.rulesByTag))
    d("Tags: "..AC.listcount(cache.tags))
    d("Saved bags: "..#saved.bags)
    d("Cache bags: "..AC.listcount(cache.bags))
    d("Entries by Bag: "..AC.listcount(cache.entriesByBag))
    d("Entries by Name: "..AC.listcount(cache.entriesByName))
end

-- -------------------------------------------------
-- Compile an individual Rule
-- Return a string that is either empty (good compile)
-- or an error string returned from the compile
--
function AutoCategory.CompileRule(rule)
  if rule == nil then return end
  
	local logger = LibDebugLogger("AutoCategory")
	logger:SetEnabled(true)
	local rulestr = "return("..rule.rule..")"
	local compiledfunc,err = zo_loadstring(rulestr)
    if not compiledfunc then
		rule.damaged = true
		logger:Error("Failure to compile rule "..rulestr..". ERROR: "..err)
		logger:SetEnabled(false)
      return err
    end
	logger:SetEnabled(false)
    AC.compiledRules[rule.name] = compiledfunc
    return ""
end

-- -----------------------------------------------------
-- Compile all of the rules that we know
-- Mark those that failed to compile as damaged
--
function AutoCategory.RecompileRules(ruleset)
    if not AutoCategory.compiledRules then
        AutoCategory.compiledRules = {}
    else
        ZO_ClearTable(AutoCategory.compiledRules)
    end
    if ruleset == nil then return end
    
	local logger = LibDebugLogger("AutoCategory")
	logger:SetEnabled(true)
    local compiled = AutoCategory.compiledRules
    for j = 1, #ruleset do
        if ruleset[j] then 
            local r = ruleset[j]
            local n = r.name
			if r.compiled then
			    compiled[n] = r.compiled
            else
				if not r.rule then
				    r.damaged = nil
                end
				local rulestr = "return(" .. r.rule .. ")"
                compiled[n],err = zo_loadstring(rulestr)
                if not compiled[n] then
                    r.damaged = true 
					logger:Error("Failure to compile rule "..rulestr..". ERROR: "..err)
                end
            end
        end
    end
	logger:SetEnabled(false)
end

-- ----------------------------- Sorting comparators ------------------
-- for sorting rules by name
-- returns true if the a should come before b
local function RuleSortingFunction(a, b)
    --alphabetical sort, cannot have same name rules
    if not (a and b and a.name and b.name ) then return false end
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
local function BagDataSortingFunction(a, b)
	local result = false
    if not a or not b or not a.name or not b.name then return false end
	if a.priority ~= b.priority then
		result = a.priority > b.priority
	else
		result = a.name < b.name
	end
	return result
end 

function AutoCategory.UpdateCurrentSavedVars()
    -- rules, general, and appearance are always accountWide
    saved.rules = AutoCategory.acctSaved.rules
	table.sort(saved.rules, RuleSortingFunction)
    AutoCategory.RecompileRules(saved.rules)
    
    saved.general = AutoCategory.acctSaved.general
    saved.appearance = AutoCategory.acctSaved.appearance
    
	if not AutoCategory.charSaved.accountWide  then
		saved.bags = AutoCategory.charSaved.bags 
		saved.collapses = AutoCategory.charSaved.collapses 
	else 
		saved.bags = AutoCategory.acctSaved.bags  
		saved.collapses = AutoCategory.acctSaved.collapses 
	end

    AC.cacheInitialize()
end 

-- ----------------------------------------------------------------------------
-- specialty Bag entry formatting functions
-- returns priority, rulename from a formatted BagRuleEntry indexValue
function AutoCategory.BagRuleEntry.splitValue(value)
    return string.find(value,"%((%d+)%) (%a+)")
end

function AutoCategory.BagRuleEntry.formatValue(entry)
    return entry.name
    --return string.format("(%03d) %s", entry.priority, entry.name )
end

function AutoCategory.BagRuleEntry.formatShow(entry, rule)
    local sn = nil
    if not rule then
        -- missing rule (nil was passed in)
        sn = string.format("|cFF4444(!)|r %s (%d)", entry.name, entry.priority)			
    else 
        if entry.isHidden then
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
        tt = rule.description
        if not tt or tt == "" then
            tt = rule.name
        end 
    end
    return tt
end

-- --------------------------------------------
-- Create a new Bag Entry
-- Rulename parameter is required, priority is optional.
-- If a priority is not provided, default to 100
-- Returns a table {name=, priority=} or nil
--
function AutoCategory.BagRuleEntry.createNew(rulename, priority)
    if not rulename then return nil end
    
    if priority == nil then priority = 100 end
    return { name = rulename, priority = priority }
end


-- -----------------------------------------------------------
-- Manage collapses
function AutoCategory.LoadCollapse()
	if not saved.general["SAVE_CATEGORY_COLLAPSE_STATUS"] then
		--init
		AutoCategory.ResetCollapse(saved)
	end
end

function AutoCategory.ResetCollapse(vars)
    for i=1,#cache.bags do
        ZO_ClearTable(vars.collapses[i])
    end
end

function AutoCategory.IsCategoryCollapsed(bagTypeId, categoryName)
    saved.collapses[bagTypeId][categoryName] = SF.nilDefault(AC.saved.collapses[bagTypeId][categoryName],false)
	return saved.collapses[bagTypeId][categoryName]
end

function AutoCategory.SetCategoryCollapsed(bagTypeId, categoryName, collapsed)
	saved.collapses[bagTypeId][categoryName] = collapsed 
end
-- -----------------------------------------------------------
 
function AutoCategory.ResetToDefaults()
    if AutoCategory.acctSaved.rules then 
        ZO_ClearTable(AutoCategory.acctSaved.rules)
    else
        AutoCategory.acctSaved.rules = {}
    end
    ZO_DeepTableCopy(AutoCategory.defaultAcctSettings.rules, AutoCategory.acctSaved.rules)
	
    if AutoCategory.acctSaved.bags then 
        ZO_ClearTable(AutoCategory.acctSaved.bags)
    else
        AutoCategory.acctSaved.bags = {}
    end
    ZO_DeepTableCopy(AutoCategory.defaultAcctSettings.bags, AutoCategory.acctSaved.bags)
	
    if AutoCategory.acctSaved.appearance then 
        ZO_ClearTable(AutoCategory.acctSaved.appearance)
    else
        AutoCategory.acctSaved.appearance = {}
    end
    ZO_DeepTableCopy(AutoCategory.defaultAcctSettings.appearance, AutoCategory.acctSaved.appearance)
    
    if AutoCategory.charSaved.bags then 
        ZO_ClearTable(AutoCategory.charSaved.bags)
    else
        AutoCategory.charSaved.bags = {}
    end
    ZO_DeepTableCopy(AutoCategory.defaultSettings.bags, AutoCategory.charSaved.bags)
	
    AutoCategory.charSaved.accountWide = AutoCategory.defaultSettings.accountWide
    
	AutoCategory.ResetCollapse(AutoCategory.charSaved)
	AutoCategory.ResetCollapse(AutoCategory.acctSaved)
end


-- ----------------------------------------------------
-- assumes that saved.rules and saved.bags have entries but
-- some or all of the cache tables need (re)initializing
--
function AutoCategory.cacheInitialize()
    
    -- initialize the rules-based lookups
    ZO_ClearTable(cache.rulesByName)
    ZO_ClearTable(cache.rulesByTag)
    ZO_ClearTable(cache.tags)
    --table.sort(saved.rules, RuleDataSortingFunction ) -- already sorted by name
	for ndx = 1, #saved.rules do
		local rule = saved.rules[ndx]
		local name = rule.name
		cache.rulesByName[name] = ndx
        
		local tag = rule.tag
		if tag == "" then
			tag = AC_EMPTY_TAG_NAME
		end
		--update cache for tag grouping 
		if not cache.rulesByTag[tag] then
			table.insert(cache.tags, tag)
			cache.rulesByTag[tag] = {showNames = {}, values = {}, tooltips = {}}
		end
		local tooltip = rule.description
		if rule.description == "" then
			tooltip = rule.name
		end
		table.insert(cache.rulesByTag[tag].showNames, name)
		table.insert(cache.rulesByTag[tag].values, name)
		table.insert(cache.rulesByTag[tag].tooltips, tooltip)
	end

    -- initialize the bag-based lookups
 	ZO_ClearTable(cache.entriesByName)
	ZO_ClearTable(cache.entriesByBag)
    -- load in the bagged rules (sorted by priority high-to-low)
    for bagId = 1, #saved.bags do
        cache.entriesByBag[bagId] = cache.entriesByBag[bagId] or {showNames = {}, values = {}, tooltips = {}}
        local ebag = cache.entriesByBag[bagId]
        
        cache.entriesByName[bagId] = cache.entriesByName[bagId] or {}
        local ename = cache.entriesByName[bagId]
        
		local ibag = saved.bags[bagId] or {}
		table.sort(ibag.rules, BagDataSortingFunction )
        for entry = 1, #ibag.rules do
			local data = ibag.rules[entry] -- data equals {name, priority}
            
			local ruleName = data.name
			ename[ruleName] = data
            table.insert(ebag.values, AC.BagRuleEntry.formatValue(data))
			
            local rule = AC.GetRuleByName(ruleName)
            local sn = AC.BagRuleEntry.formatShow(data, rule)
            local tt = AC.BagRuleEntry.formatTooltip(rule)
            table.insert(ebag.showNames, sn)				
            table.insert(ebag.tooltips, tt)
		end
	end
end

function AutoCategory.GetRuleByName(name)
    if not name then return nil end
    
    local ndx = cache.rulesByName[name]
    if not ndx then return nil end
    
    return saved.rules[ndx]
end

function AutoCategory.cache.RemoveRuleFromBag(bagId, name)
    if not name then return end
    
    -- remove from entriesByBag
    local r = cache.entriesByBag[bagId]
    for i = 1, #r.values do
        local p,n = AutoCategory.BagRuleEntry.splitValue(r.values[i])
        if  n == name then
            table.remove(r.values,i)
            table.remove(r.showNames,i)
            table.remove(r.tooltips,i)
            break
        end
    end
    -- remove from entriesByName
    cache.entriesByName[bagId][name] = nil
    -- removed from saved.bags
    for i = 1, #saved.bags[bagId] do
        if saved.bags[bagId][i].name == name then
            saved.bags[bagId][i] = nil
            break
        end
    end
end

function AutoCategory.cache.RemoveRuleByName(name)
    if not name then return end
    if not cache.rulesByName[name] then return end
    
    local ndx = cache.rulesByName[name]
    cache.compiledRules[name] = nil
    cache.rulesByName[name] = nil
    
    -- remove from cache.rulesByTag
    for t,s in pairs(cache.rulesByTag) do
        for i = 1, #s.showNames do
            if s.showNames[i] == name then
                table.remove(s.showNames,i)
                if s.values then
                    table.remove(s.values,i)
                end
                if s.tooltips then
                    table.remove(s.tooltips,i)
                end
                break
            end
        end
    end
    
    -- remove from entriesByBag
    for b,r in pairs(cache.entriesByBag) do
        AutoCategory.cache.RemoveRuleFromBag(b,name)
    end
end

function AutoCategory.isValidRule(ruledef)
    --make sure rule is well-formed
    if( not ruledef or not ruledef.name or type(ruledef.name) ~= "string" or ruledef.name == ""  ) then
        return false, "name is required"
    end
    if( not ruledef.rule or type(ruledef.rule) ~= "string" or ruledef.rule == ""  ) then
        return false, "rule text is required"
    end
    if ruledef.description then   -- description is optional
        if( type(ruledef.description) ~= "string" ) then
            return false, "non-nil description must be a string"
        end
    end
    if ruledef.tag then   -- tag is optional
        if( type(ruledef.tag) ~= "string" ) then
            return false, "non-nil tag must be a string"
        end
    end
    if ruledef.compiled then   -- compiled is optional
        if( type(ruledef.compiled) ~= "function" ) then
            --d("AddPredefinedRules: compiled is not a function")
            return false, "non-nil compiled must be a lua function"
        end
    end
    return true
end

-- when we add a new rule to saved.rules, also add it to the various lookups and dropdowns
function AutoCategory.cache.AddRule(rule)
    if not rule or not rule.name then 
        return "AddRule: Rule or name of rule was nil"
    end -- can't use nil rule
    
    -- rule already exists
    if cache.rulesByName[rule.name] then 
        return "AddRule: Rule ("..rule.name..") already exists. Ignoring"
    end
    
    table.insert(saved.rules, rule)
    
    cache.rulesByName[rule.name] = #saved.rules
    
    if not rule.tag or rule.tag == "" then
        rule.tag = AC_EMPTY_TAG_NAME
    end
    if cache.rulesByTag[rule.tag] == nil then
        cache.rulesByTag[rule.tag] = { showNames = {}, values = {}, tooltips = {} }
    end
    
    local tt = rule.description
    if not tt or tt == "" then
        tt = rule.name
    end
    table.insert(cache.rulesByTag[rule.tag].showNames, rule.name)
    table.insert(cache.rulesByTag[rule.tag].values, rule.name)
    table.insert(cache.rulesByTag[rule.tag].tooltips, tt)
    
    AC.CompileRule(rule)
end

function AutoCategory.cache.AddRuleToBag(bagId, rulename, priority)
    local entry = { name = rulename, priority = priority, }
    
    saved.bags[bagId] = saved.bags[bagId] or {}
    cache.entriesByName[bagId] = cache.entriesByName[bagId] or {}
    if not cache.entriesByName[bagId][rulename] then
        table.insert(saved.bags[bagId], entry)
    end
    
    local rule = saved.rules[cache.rulesByName[rulename] ]
    
    cache.entriesByName[bagId][rulename] = entry
    
    local sn = AutoCategory.BagRuleEntry.formatShow(entry,rule)
    local tt = AutoCategory.BagRuleEntry.formatTooltip(rule)
    
    cache.entriesByBag[bagId] = cache.entriesByBag[bagId] or { showNames = {}, values = {}, tooltips = {} }
    table.insert(cache.entriesByBag[bagId].showNames, sn)				
    table.insert(cache.entriesByBag[bagId].values, rulename)				
    table.insert(cache.entriesByBag[bagId].tooltips, tt)
end

--remove duplicated categories in bag
function AutoCategory.removeDuplicatedRules()
    for i = 1, #saved.bags do
        local bag = saved.bags[i]
        local keys = {}
        --traverse from back to front to remove elements while iteration
        for j = #bag.rules, 1, -1 do
            local data = bag.rules[j]
            if keys[data.name] ~= nil then
                --remove duplicated category
                d("removed ("..j..") "..data.name)
                table.remove(saved.bags[i].rules, j)
            else
                --flag this category
                keys[data.name] = true
            end
        end
    end
end

function AutoCategory.LazyInit()
	if not AutoCategory.Inited then
		 
		-- initialize plugins
        for name, initfunc in pairs(AutoCategory.Plugins) do
            if initfunc then
                initfunc()
            end
        end

		AutoCategory.AddonMenuInit() 
        AutoCategory.RecompileRules(saved.rules)
		
		-- hooks
		AutoCategory.HookGamepadMode()
		AutoCategory.HookKeyboardMode()
		
		--capabilities with other add-ons
		IntegrateInventoryGridView()
		IntegrateQuickMenu()

		AutoCategory.Inited = true
	end
end

function AutoCategory.onLoad(event, addon)
	if addon ~= AutoCategory.name then return end
    
    EVENT_MANAGER:UnregisterForEvent(AutoCategory.name, EVENT_ADD_ON_LOADED)
    
    AutoCategory.checkLibraryVersions()  
    
    -- load our saved variables
    AC.acctSaved, AC.charSaved = SF.getAllSavedVars("AutoCategorySavedVars", 1.1, AC.defaultAcctSettings)
    
    -- init bag category table only when the bag is missing
    for k,v in pairs(AC.defaultAcctBagSettings.bags) do
        if AC.acctSaved.bags[k] then
            if not AC.acctSaved.bags[k].rules or #AC.acctSaved.bags[k].rules == 0 then
                AC.acctSaved.bags[k] = v
            end
        else
            AC.acctSaved.bags[k] = v
        end
	end
    

    AutoCategory.UpdateCurrentSavedVars()
    AutoCategory.LoadCollapse()
    
    AutoCategory.LazyInit()
end

-- register our event handler function to be called to do initialization
EVENT_MANAGER:RegisterForEvent(AutoCategory.name, EVENT_ADD_ON_LOADED, AutoCategory.onLoad)



--== Interface ==-- 
function AutoCategory.RefreshCurrentList()
	local function RefreshList(inventoryType) 
		local UPDATE_IF_NOT_HIDDEN = false
		PLAYER_INVENTORY:UpdateList(inventoryType, UPDATE_IF_NOT_HIDDEN)
	end
	
	if not ZO_PlayerInventory:IsHidden() then
		RefreshList(INVENTORY_BACKPACK)
		RefreshList(INVENTORY_QUEST_ITEM)
	elseif not ZO_CraftBag:IsHidden() then
		RefreshList(INVENTORY_CRAFT_BAG)
	elseif not ZO_GuildBank:IsHidden() then
		RefreshList(INVENTORY_GUILD_BANK)
	elseif not ZO_HouseBank:IsHidden() then
		RefreshList(INVENTORY_HOUSE_BANK)
	elseif not ZO_PlayerBank:IsHidden() then
		RefreshList(INVENTORY_BANK)
	elseif not SMITHING.deconstructionPanel.control:IsHidden() then
		SMITHING.deconstructionPanel.inventory:PerformFullRefresh()
	elseif not SMITHING.improvementPanel.control:IsHidden() then
		SMITHING.improvementPanel.inventory:PerformFullRefresh()
	end
end

function AutoCategory.RefreshAllLists()
    PLAYER_INVENTORY:UpdateList(INVENTORY_BACKPACK)
    PLAYER_INVENTORY:UpdateList(INVENTORY_QUEST_ITEM)
    PLAYER_INVENTORY:UpdateList(INVENTORY_CRAFT_BAG)
    PLAYER_INVENTORY:UpdateList(INVENTORY_GUILD_BANK)
    PLAYER_INVENTORY:UpdateList(INVENTORY_HOUSE_BANK)
    PLAYER_INVENTORY:UpdateList(INVENTORY_BANK)
    
    SMITHING.deconstructionPanel.inventory:PerformFullRefresh()
    SMITHING.improvementPanel.inventory:PerformFullRefresh()
end

function AC_ItemRowHeader_OnMouseEnter(header)
	local cateName = header.slot.dataEntry.bestItemTypeName
	local bagTypeId = header.slot.dataEntry.bagTypeId

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

function AC_ItemRowHeader_OnMouseExit(header)  
	local markerBG = header:GetNamedChild("CollapseMarkerBG")
	markerBG:SetHidden(true)
end

function AC_ItemRowHeader_OnMouseClicked(header)
    if (AutoCategory.acctSaved.general["SHOW_CATEGORY_COLLAPSE_ICON"] == false) then return end

	local cateName = header.slot.dataEntry.bestItemTypeName
	local bagTypeId = header.slot.dataEntry.bagTypeId
	
	local collapsed = AutoCategory.IsCategoryCollapsed(bagTypeId, cateName) 
	AutoCategory.SetCategoryCollapsed(bagTypeId, cateName, not collapsed)
	AutoCategory.RefreshCurrentList()
end

function AC_ItemRowHeader_OnShowContextMenu(header)
	ClearMenu()
	local cateName = header.slot.dataEntry.bestItemTypeName
	local bagTypeId = header.slot.dataEntry.bagTypeId
	
	local collapsed = AutoCategory.IsCategoryCollapsed(bagTypeId, cateName) 
	if collapsed then
		AddMenuItem(L(SI_CONTEXT_MENU_EXPAND), function()
			AutoCategory.SetCategoryCollapsed(bagTypeId, cateName, false)
			AutoCategory.RefreshCurrentList()
		end)
	else
		AddMenuItem(L(SI_CONTEXT_MENU_COLLAPSE), function()
			AutoCategory.SetCategoryCollapsed(bagTypeId, cateName, true)
			AutoCategory.RefreshCurrentList()
		end)
	end
	AddMenuItem(L(SI_CONTEXT_MENU_EXPAND_ALL), function()
		for k, v in pairs (AutoCategory.saved.collapses[bagTypeId]) do
			AutoCategory.saved.collapses[bagTypeId][k] = false
		end
		AutoCategory.RefreshCurrentList()
	end)
	AddMenuItem(L(SI_CONTEXT_MENU_COLLAPSE_ALL), function()
		for k, v in pairs (AutoCategory.saved.collapses[bagTypeId]) do
			AutoCategory.saved.collapses[bagTypeId][k] = true
		end
		AutoCategory.RefreshCurrentList()
	end) 
	ShowMenu()
end

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