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
require "plugins.FCOIS_Plugin"

local moduleName = "FCOIS"
local mn = moduleName

local function FCOIS_testLoadLanguage()
    local fn = "testLoadLanguage"
    TK.printSuite(moduleName,fn)
    AutoCategory_FCOIS.LoadLanguage("en")
    local str = GetString(SI_AC_DEFAULT_CATEGORY_FCOIS_DYNAMIC_1)
    --d("SI_AC_DEFAULT_CATEGORY_FCOIS_DYNAMIC_1 = "..str)
    TK.assertNotNil(str, "FCOIS_testLoadLanguage: found FCOIS_DYNAMIC_1 string")
    TK.assertTrue(str == "Dynamic 1","FCOIS_testLoadLanguage: FCOIS_DYNAMIC_1 value is correct")
    local L = GetString
    str = L(SI_AC_DEFAULT_CATEGORY_FCOIS_DECONSTRUCTION_MARK)
    --d("SI_AC_DEFAULT_CATEGORY_FCOIS_DECONSTRUCTION_MARK = "..str)
    TK.assertNotNil(str, "FCOIS_testLoadLanguage: found FCOIS_DECONSTRUCTION_MARK string")
    TK.assertTrue(str == "Deconstruction Mark","FCOIS_testLoadLanguage: FCOIS_DECONSTRUCTION_MARK value is correct")
end

-- make sure the entire list of predefinedRules for FCOIS gets loaded without any
-- reported errors.
local function FCOIS_testPredefines()
    local fn = "testPredefines"
    TK.printSuite(moduleName,fn)
    
    local ac_rules = AutoCategory.RulesW
    SF.safeClearTable(ac_rules.ruleList)
    d("before = "..#ac_rules.ruleList)
    AutoCategory._addTableRules({rules=AutoCategory_FCOIS.predefinedRules},"FCOIS.predefinedRules", true)
    local added = #ac_rules.ruleList
    TK.assertTrue(added == 43,"testAddPredefineRule - Successfully added 43 rules")
end

function FCOIS_runTests()
  FCOIS_testLoadLanguage()
  FCOIS_testPredefines()
end

TK.init()

FCOIS_runTests()

TK.showResult(mn)
