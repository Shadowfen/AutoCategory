package.path = package.path .. ";C:/Users/scott/Documents/SFAddons/TK/?.lua;C:/Users/scott/Documents/Elder Scrolls Online/live/AddOns/LibSFUtils/?.lua"

require "zos"
require "tk"
local TK = TestKit

local AC_DECON = 6
local AC_IMPROV = 7
local UV_DECON = 8


require "LibSFUtils_Global"
require "SFUtils_Color"
require "LibSFUtils"
require "SFUtils_Strings"
require "SFUtils_Tables"
require "SFUtils_LoadLanguage"
require "SFUtils_Logger"
require "SFUtils_Events"
require "SFUtils_HookManager"
local SF = LibSFUtils

require "AutoCategory_Global"
require "lang.strings"
require "AutoCategory_Defaults"
require "Hooks_Keyboard"
require "classes.CVT"
require "classes.RuleList"
require "classes.RuleApi"
require "classes.BagRuleApi"
require "classes.BaseUI"
require "AutoCategory"

local AC_cache_addrule = AutoCategory.cache.AddRule

local AC = AutoCategory
local CVT = AutoCategory.CVT

local ZO_PlayerInventory
local saved, cache

local moduleName = "ACCache"
local mn, class


local function fillCVT(cvt, choices, values, tooltips)
    for i = 1, #choices do
        cvt:append(
            choices[i],
            values and values[i] or nil,
            tooltips and tooltips[i] or nil
        )
    end
end


local function Cache_testInit()
    ZO_PlayerInventory = {}
    mn = moduleName
    class = moduleName

    AutoCategory.saved = {
        rules = {}, -- obsolete
        bags = {}, 
        general = {},   -- from savedvars
        appearance = {}, -- from savedvars
        collapses = {},  
    }
    AutoCategory.charSaved = {
      accountWide = false,
    }
    AutoCategory.acctSaved = {
    }

    AutoCategory.cache = {
        bags_cvt = CVT:New(nil, nil, CVT.USE_VALUES + CVT.USE_TOOLTIPS),
        entriesByBag = {},
        entriesByShowBag = {},
        entriesByName = {},
    }
    AutoCategory.cache.AddRule = AC_cache_addrule

    AutoCategory.BagRuleEntry = {}
    AutoCategory.Environment = {}

    saved = AutoCategory.saved
    cache = AutoCategory.cache
end

local function Cache_testReset()
    ZO_PlayerInventory = {}

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
    local ac_rules = AutoCategory.RulesW
    AutoCategory.cacheRuleInitialize()
    AutoCategory.cache.AddRule({name="rule1", tag="group1", 
        description="nah", rule="true",})
    AutoCategory.cache.AddRule({name="Deconstruct", tag="Gears", 
        description="Gears that I want to deconstruct", rule="traitstring(\"intricate\")",})

    local  decon = AC.GetRuleByName("Deconstruct") --GetString(SI_AC_DEFAULT_CATEGORY_DECONSTRUCT))
    TK.assertNotNil(decon, "decon rule in saved.rules")
    if decon then
        TK.assertTrue(decon.name == "Deconstruct", "decon rule name is correct")
        TK.assertTrue(decon.tag == "Gears", "decon rule tag is correct")
        TK.assertTrue(decon.description == "Gears that I want to deconstruct", "decon rule description is correct")
        TK.assertTrue(decon.rule == "traitstring(\"intricate\")", "decon rule text is correct")
    end
    
    local badrule = AC.GetRuleByName("haha")
    TK.assertNil(badrule,"did not get non-existant rule")
end

local function Cache_testResetToDefaults()
    TK.printSuite(mn, "testResetToDefaults")
    d(GetString(SI_AC_DEFAULT_CATEGORY_DECONSTRUCT))
    local  decon = AC.GetRuleByName("Deconstruct")
    if decon then
    decon.name = "Deconstruct"
    end
    decon = AC.GetRuleByName("Deconstruct")
    TK.assertTrue(decon.name ~= "Deconstruct", "reassigned decon rule name")

    AutoCategory.ResetToDefaults()
    AC.cacheInitialize()    -- required because index in table changed
    decon = AC.GetRuleByName("Deconstruct")
    TK.assertTrue(decon.name == "Deconstruct", "decon rule name is reverted")
end

local function Cache_testAddRule()
    TK.printSuite(mn,"testAddRule")
    local orgr = AC.GetRuleByName("Low Level")
    TK.assertNil(orgr,"Low Level is not there")

    local cache = AutoCategory.cache
    local err = cache.AddRule({name="Low Level", rule="false"})
    TK.assertNotNil(err, "AddRule returned error")
    print(err)
    
    err = cache.AddRule({name="happy",rule="true", tag = "gear"})
    TK.assertNil(err, "AddRule for happy succeeded.")
end

local function Cache_testUpdateSavedVars()
    TK.printSuite(mn,"testUpdateSavedVars")
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

function Cache_runTests()
    Cache_testInit()
    
    Cache_testIsValidRule()
    Cache_testGetRuleByName()
    --Cache_testResetToDefaults()
    --Cache_testAddRule()
    --Cache_testUpdateSavedVars()
    
    Cache_testReset()
end

if not Suite then
    TK.init()
    
    Cache_runTests()
    
    TK.showResult("Cache Tests")
end