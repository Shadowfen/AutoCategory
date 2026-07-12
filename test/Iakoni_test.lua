package.path = package.path .. ";C:/Users/scott/Documents/SFAddons/TK/?.lua;C:/Users/scott/Documents/Elder Scrolls Online/live/AddOns/LibSFUtils/?.lua"

require "zos"
require "tk"
local TK = TestKit

local TR = test_run
local d = print

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
require "AutoCategory_Defaults"
require "Hooks_Keyboard"
require "classes.CVT"
require "classes.RuleList"
require "classes.RuleApi"
require "AutoCategory"
require "Plugin_API"
local AC = AutoCategory
require "plugins.Iakoni_GearChanger_Plugin"

local moduleName = "Iakoni"
local mn = moduleName

local function Iakoni_testLoadLanguage()
    local fn = "testLoadLanguage"
    TK.printSuite(moduleName,fn)
    AutoCategory_Iakoni.LoadLanguage("en")
    local str = GetString(AC_IAKONI_CATEGORY_SET_1)
    --d("AC_IAKONI_CATEGORY_SET_1 = "..str)
    TK.assertNotNil(str, "found IAKONI_CATEGORY_SET_1 string")
    TK.assertTrue(str == "Set#1","IAKONI_CATEGORY_SET_1 value is correct")
    local L = GetString
    str = L(AC_IAKONI_CATEGORY_SET_8)
    --d("AC_IAKONI_CATEGORY_SET_8 = "..str)
    TK.assertNotNil(str, "found AC_IAKONI_CATEGORY_SET_8 string")
    TK.assertTrue(str == "Set#8","AC_IAKONI_CATEGORY_SET_8 value is correct")
end

-- make sure the entire list of predefinedRules for Iakoni GearChanger gets loaded without any
-- reported errors.
local function Iakoni_testPredefines()
    local fn = "testPredefines"
    TK.printSuite(moduleName,fn)
    
    local ac_rules = AutoCategory.RulesW
    SF.safeClearTable(ac_rules.ruleList)
    d("before = "..#ac_rules.ruleList)
    AutoCategory._addTableRules({rules=AutoCategory_Iakoni.predefinedRules},"Iakoni.predefinedRules", true)
    local added = #ac_rules.ruleList
    TK.assertTrue(added == 10,"testAddPredefineRule - Successfully added 10 rules")
end

function Iakoni_runTests()
    Iakoni_testLoadLanguage()
    Iakoni_testPredefines()
end


TK.init()

Iakoni_runTests()

TK.showResult(mn)
