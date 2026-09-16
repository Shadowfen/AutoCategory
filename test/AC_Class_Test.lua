package.path = package.path .. ";C:/Users/scott/Documents/SFAddons/TK/?.lua;C:/Users/scott/Documents/Elder Scrolls Online/live/AddOns/LibSFUtils/?.lua"

require "zos"
require "tk"
local TK = TestKit

local AC_DECON = 880
local AC_IMPROV = 881
local UV_DECON = 882


require "LibSFUtils_Global"
require "SFUtils_Color"
require "LibSFUtils"
require "SFUtils_Tables"
require "SFUtils_LoadLanguage"
require "SFUtils_Logger"
require "SFUtils_Events"
require "SFUtils_HookManager"
local SF = LibSFUtils

require "AutoCategory_Global"
require "lang.strings"
require "classes.CVT"
require "classes.RuleList"
require "classes.RuleApi"
require "classes.BagRuleApi"
require "classes.BaseUI"
require "AutoCategory"

local AC = AutoCategory
local AutoCat = AutoCategory

local ZO_PlayerInventory
local saved, cache


local mn, moduleName

local function Cache_testInit()
    ZO_PlayerInventory = {}
    moduleName = "Cache"
    mn = moduleName

    saved = {} --AutoCategory.saved
    cache = {} --AutoCategory.cache
    AC.saved = {}
    AC.saved.collapses = {}
end

local function Cache_testReset()
    ZO_PlayerInventory = {}
    moduleName = ""

    saved = {}
    cache = {} --AutoCategory.cache
    AC.saved = {}
end




local function Cache_testIsValidRule()
    TK.printSuite(mn, "testIsValidRule")
    local rule = {}
    TK.assertFalse(AutoCategory.isValidRule(nil), "nil rule is not valid" )
    TK.assertFalse(AutoCategory.isValidRule(rule), "empty rule is not valid" )
    
    rule.name = "test1"
    local rslt,err = AutoCategory.isValidRule(rule)
    TK.assertTrue(rslt == false and err == "rule text is required", "name-only rule is not valid")
    
    rule.rule = "false"
    rslt,err = AutoCategory.isValidRule(rule)
    TK.assertTrue(rslt and not err, "name and text make a valid rule")
end

local function Cache_testGetRuleByName()
    TK.printSuite(mn, "testGetRuleByName")
    local oldRules = AutoCat.RulesW

    AutoCat.RulesW = {
        ruleNames = {
            Alpha = 1,
            Beta = 2,
        },
        ruleList = {
            { name = "Alpha" },
            { name = "Beta" },
        },
    }

    TK.assertNil(AutoCat.GetRuleByName(nil), "nil name returns nil")
    TK.assertNil(AutoCat.GetRuleByName("Missing"), "unknown rule name returns nil")
    do
        local rule = AutoCat.GetRuleByName("Alpha")

        TK.assertNotNil(rule, "existing rule returns rule")
        TK.assertEquals("Alpha", rule.name, "existing rule has correct name")
        TK.assertTrue(rule == AutoCat.RulesW.ruleList[1], "existing rule returns ruleList entry")
    end

    do
        local rule = AutoCat.GetRuleByName("Beta")

        TK.assertTrue(rule == AutoCat.RulesW.ruleList[2], "second rule returns correct ruleList entry")
    end
end

local function TestGetBagRuleByName()
    TK.printSuite(mn, "GetBagRuleByName")

    local oldCache = cache
    local oldRules = ac_rules
    local oldCacheInitBag = AutoCat.cacheInitBag

    local rule1 = { name = "Alpha" }
    local rule2 = { name = "Beta" }

    ac_rules = {
        ruleNames = {
            Alpha = 1,
            Beta = 2,
        },
    }

    local bagRules = {
        choicesValues = {
            "Alpha",
            "Beta",
        },
        bagrules = {
            rule1,
            rule2,
        },
    }

    cache = {
        entriesByShowBag = {
            [BAG_BACKPACK] = bagRules,
        },
    }

    -- ---------------------------------------------------
    -- nil name
    -- ---------------------------------------------------

    do
        local rule, ndx =
            AutoCat.GetBagRuleByName(BAG_BACKPACK, nil)

        TK.assertNil(rule, "nil name returns nil rule")
        TK.assertNil(ndx, "nil name returns nil index")
    end

    -- ---------------------------------------------------
    -- unknown bag
    -- ---------------------------------------------------

    do
        local rule, ndx =
            AutoCat.GetBagRuleByName(9999, "Alpha")

        TK.assertNil(rule, "unknown bag returns nil rule")
        TK.assertNil(ndx, "unknown bag returns nil index")
    end

    -- ---------------------------------------------------
    -- stale rule
    -- ---------------------------------------------------

    do
        local cleanupBagId = nil

        AutoCat.cacheInitBag = function(bagId)
            cleanupBagId = bagId
        end

        local rule, ndx = AutoCat.GetBagRuleByName(BAG_BACKPACK, "Deleted")

        TK.assertNil(rule, "stale rule returns nil rule")
        TK.assertNil(ndx, "stale rule returns nil index")

        TK.assertEquals(BAG_BACKPACK, cleanupBagId,
            "stale rule triggers bag cleanup")
    end

    -- ---------------------------------------------------
    -- rule exists globally but not in this bag
    -- ---------------------------------------------------

    do
        ac_rules.ruleNames.Gamma = 3

        local rule, ndx =
            AutoCat.GetBagRuleByName(BAG_BACKPACK, "Gamma")

        TK.assertNil(rule, "rule absent from bag returns nil rule")
        TK.assertNil(ndx, "rule absent from bag returns nil index")
    end

    -- ---------------------------------------------------
    -- successful lookup
    -- ---------------------------------------------------

    do
        local rule, ndx =
            AutoCat.GetBagRuleByName(BAG_BACKPACK, "Beta")

        TK.assertTrue(rule == rule2, "lookup returns correct bag rule")
        TK.assertEquals(2, ndx, "lookup returns correct index")
    end

    AutoCat.cacheInitBag = oldCacheInitBag
    cache = oldCache
    ac_rules = oldRules
end

local function Cache_testResetToDefaults()
    TK.printSuite(mn,"testResetToDefaults")
    local  decon = AC.GetRuleByName(GetString(SI_AC_DEFAULT_CATEGORY_DECONSTRUCT))
    decon.name = "Destroy"
    decon = AC.GetRuleByName(GetString(SI_AC_DEFAULT_CATEGORY_DECONSTRUCT))
    TK.assertTrue(decon.name ~= GetString(SI_AC_DEFAULT_CATEGORY_DECONSTRUCT), "reassigned decon rule name")

    AutoCategory.ResetToDefaults()
    AC.cacheInitialize()    -- required because index in table changed
    decon = AC.GetRuleByName(GetString(SI_AC_DEFAULT_CATEGORY_DECONSTRUCT))
    TK.assertTrue(decon.name == GetString(SI_AC_DEFAULT_CATEGORY_DECONSTRUCT), "decon rule name is reverted")
end

local function Cache_testAddRule()
    TK.printSuite(mn,"testAddRule")
    local orgr = AC.GetRuleByName("Low Level")
    TK.assertNotNil(orgr,"Low Level is there")
    
    local err = AC.cache.AddRule({name="Low Level", rule="false"})
    TK.assertNotNil(err, "AddRule returned error")
    print(err)
    
    err = AC.cache.AddRule({name="happy",rule="true"})
    TK.assertNil(err, "AddRule for happy succeeded.")
end

local function Cache_testUpdateSavedVars()
    local happy = AC.GetRuleByName("happy")
    TK.assertNotNil(happy,"still have rule happy defined")
    AC.charSaved.accountWide = false
    TK.assertFalse(AC.charSaved.accountWide,"Settings are toon-only")

    AutoCategory.UpdateCurrentSavedVars()
    TK.assertNotNil(AutoCategory.saved.rules, "saved.rules has entries")
    TK.assertNotNil(AutoCategory.compiledRules, "compiled rules has entries")
    TK.assertTrue(AC.listcount(saved.rules) > 0, "saved.rules has "..AC.listcount(saved.rules).." entries")
    TK.assertTrue(AC.listcount(saved.rules) == AC.listcount(AC.compiledRules), "#saved.rules == #compiledRules")

    AC.charSaved.accountWide = true
    TK.assertTrue(AC.charSaved.accountWide,"Settings are account-wide")

    AutoCategory.UpdateCurrentSavedVars()
    TK.assertNotNil(AutoCategory.saved.rules, "saved.rules has entries")
    TK.assertNotNil(AutoCategory.compiledRules, "compiled rules has entries")
    TK.assertTrue(AC.listcount(saved.rules) > 0, "saved.rules has "..AC.listcount(saved.rules).." entries")
    TK.assertTrue(AC.listcount(saved.rules) == AC.listcount(AC.compiledRules), "#saved.rules == #compiledRules")
end

function ACClass_runTests()
    Cache_testInit()
    
    Cache_testIsValidRule()
    Cache_testGetRuleByName()
    --TestGetBagRuleByName()
    --Cache_testResetToDefaults()
    --Cache_testAddRule()
    --Cache_testUpdateSavedVars()
    
    Cache_testReset()
end

if not Suite then
    TK.init()
    
    ACClass_runTests()
    
    TK.showResult("AC Class Tests")
end