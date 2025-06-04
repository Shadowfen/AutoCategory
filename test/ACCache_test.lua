require "AutoCategory.test.zos"
require "AutoCategory.test.tk"
local TK = TestKit

local d = print

local INVENTORY_BACKPACK = 1
local INVENTORY_CRAFT_BAG = 2
local INVENTORY_GUILD_BANK = 3
local INVENTORY_HOUSE_BANK = 4
local INVENTORY_BANK = 5
local INVENTORY_FURNITURE_VAULT = 7
local AC_DECON = 6
local AC_IMPROV = 7
local UV_DECON = 8

local ZO_PlayerInventory = {}

require "LibSFUtils.LibSFUtils_Global"
require "LibSFUtils.SFUtils_Color"
require "LibSFUtils.LibSFUtils"
require "LibSFUtils.SFUtils_Tables"
require "LibSFUtils.SFUtils_LoadLanguage"
local SF = LibSFUtils
--require "AutoCategory.AutoCategory_Global"
--require "AutoCategory.AutoCategory_Defaults"
--require "AutoCategory.Hooks_Keyboard"
require "AutoCategory.AutoCategory"
local AC = AutoCategory

local saved = AutoCategory.saved
local cache = AutoCategory.cache


local mn = "Class"

local function Cache_testIsValidRule()
    local tn = "testIsValidRule"
    TK.printSuite(mn,tn)
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
    local tn = "testGetRuleByName"
    TK.printSuite(mn,tn)
   local  decon = AC.GetRuleByName(GetString(SI_AC_DEFAULT_CATEGORY_DECONSTRUCT))
    --TR.printRule(decon)
    TK.assertNotNil(decon, "decon rule in saved.rules")
    TK.assertTrue(decon.name == GetString(SI_AC_DEFAULT_CATEGORY_DECONSTRUCT), "decon rule name is correct")
    TK.assertTrue(decon.tag == GetString(SI_AC_DEFAULT_TAG_GEARS), "decon rule tag is correct")
    TK.assertTrue(decon.description == GetString(SI_AC_DEFAULT_CATEGORY_DECONSTRUCT_DESC), "decon rule description is correct")
    TK.assertTrue(decon.rule == "traitstring(\"intricate\")", "decon rule text is correct")
    
    local badrule = AC.GetRuleByName("haha")
    TK.assertNil(badrule,"did not get non-existant rule")
end

local function Cache_testResetToDefaults()
    TK.printSuite(mn,"testResetToDefaults")
    local  decon = AC.GetRuleByName(GetString(SI_AC_DEFAULT_CATEGORY_DECONSTRUCT))
    decon.name = "Destroy"
    decon = AC.GetRuleByName(GetString(SI_AC_DEFAULT_CATEGORY_DECONSTRUCT))
    --printRule(decon)
    TK.assertTrue(decon.name ~= GetString(SI_AC_DEFAULT_CATEGORY_DECONSTRUCT), "reassigned decon rule name")

    AutoCategory.ResetToDefaults()
    AC.cacheInitialize()    -- required because index in table changed
    decon = AC.GetRuleByName(GetString(SI_AC_DEFAULT_CATEGORY_DECONSTRUCT))
    --printRule(decon)
    TK.assertTrue(decon.name == GetString(SI_AC_DEFAULT_CATEGORY_DECONSTRUCT), "decon rule name is reverted")
end

local function Cache_testAddRule()
    TK.printSuite(mn,"testAddRule")
    local orgr = AC.GetRuleByName("Low Level")
    TK.assertNotNil(orgr,"Low Level is there")
    --printTable(orgr)

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

--function Cache_runTests()
    Cache_testIsValidRule()
    Cache_testGetRuleByName()
    Cache_testResetToDefaults()
    Cache_testAddRule()
    Cache_testUpdateSavedVars()
--end