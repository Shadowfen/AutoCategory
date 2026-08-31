package.path = package.path .. ";C:/Users/scott/Documents/SFAddons/TK/?.lua;C:/Users/scott/Documents/Elder Scrolls Online/live/AddOns/LibSFUtils/?.lua"

require "zos"
require "tk"
local TK = TestKit

local d = print

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
require "AutoCategory_Defaults"
require "Hooks_Keyboard"
require "classes.CVT"
require "classes.RuleList"
require "classes.RuleApi"
require "AutoCategory"
local AC = AutoCategory
local CVT = AutoCategory.CVT

local ZO_PlayerInventory
local saved, cache


local mn, moduleName, class

local function Misc_testInit()
    ZO_PlayerInventory = {}
    moduleName = "Misc Test"
    mn = moduleName
    class = moduleName

    AutoCategory.saved = {
        rules = {}, -- obsolete
        bags = {}, 
        general = {},   -- from savedvars
        appearance = {}, -- from savedvars
        collapses = {},  
    }

    AutoCategory.cache = {
        bags_cvt = CVT:New(nil, nil, CVT.USE_VALUES + CVT.USE_TOOLTIPS),
        entriesByBag = {},
        entriesByShowBag = {},
        entriesByName = {},
    }

    AutoCategory.BagRuleEntry = {}


    saved = AutoCategory.saved
    cache = AutoCategory.cache
end

local function Misc_testReset()
    ZO_PlayerInventory = {}
    moduleName = ""

    saved = {}
    cache = {}
    AC.saved = {}
    AC.cache = {}
end

local BagSet_EditRule_LAM = AC_UI.BagSet_EditRule_LAM

AC_UI.BagSet_EditBag_LAM = {
	editBag_cvt = CVT:New("AC_DROPDOWN_EDITBAG_BAG", AC_BAG_TYPE_BACKPACK),
	
	select = function(self, val)
			self.editBag_cvt:select(val)
		end,
	assign = function( self, cvtTbl)
			self.editBag_cvt:assign(cvtTbl)
		end,
	updateControl = function(self)
			self.editBag_cvt:updateControl()
		end,
    
  size = function(self)
      return #self.editBag_cvt.choices
    end,
}
local BagSet_EditBag_LAM = AC_UI.BagSet_EditBag_LAM

AC_UI.BagSet_EditRule_LAM = {
}

local function EditBag_testSize()
    TK.printSuite(mn, "testEditBagSize")
    
    TK.assertTrue(BagSet_EditBag_LAM:size() == 0, "has no choices")
    local newvals = {
      choices = { 1, 2, 4 },
      choicesValues = {"one","two","four"},
    }
    BagSet_EditBag_LAM:assign(newvals)
    TK.assertTrue(BagSet_EditBag_LAM:size() == 3, "has 3 choices")
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
     rslt, err = AutoCategory.isValidRule(rule)
     TK.assertTrue(rslt and not err, "name and text make a valid rule")
end

local function Cache_testGetRuleByName()
    TK.printSuite(mn, "testGetRuleByName")
    local ac_rules = AutoCategory.RulesW
    AutoCategory.cacheRuleInitialize()
    AutoCategory.cache.AddRule({name="rule1", tag="group1", description="nah", rule="true",})
    AutoCategory.cache.AddRule({name="Deconstruct", tag="Gears", description="Gears that I want to deconstruct", rule="traitstring(\"intricate\")",})
    
    local  decon = AC.GetRuleByName("Deconstruct")
    TK.assertNotNil(decon, "decon rule in saved.rules")
    TK.assertTrue(decon.name == "Deconstruct", "decon rule name is correct")
    TK.assertTrue(decon.tag == "Gears", "decon rule tag is correct")
    TK.assertTrue(decon.description == "Gears that I want to deconstruct", 
        "decon rule description is correct")
    TK.assertTrue(decon.rule == "traitstring(\"intricate\")", "decon rule text is correct")
    
    local badrule = AC.GetRuleByName("haha")
    TK.assertNil(badrule,"did not get non-existant rule")
end

local function Cache_testResetToDefaults()
    TK.printSuite(mn,"testResetToDefaults")
    local ac_rules = AutoCategory.RulesW
    AutoCategory.cacheRuleInitialize()
    AutoCategory.cache.AddRule({name="rule1", tag="group1", description="nah", rule="true",})
    AutoCategory.cache.AddRule({name="Deconstruct", tag="Gears", description="Gears that I want to deconstruct", rule="traitstring(\"intricate\")",})
    
    local  decon = AC.GetRuleByName("Deconstruct")
    decon.name = "Destroy"
    decon = AC.GetRuleByName("Deconstruct")
    TK.assertTrue(decon.name ~= "Deconstruct", "reassigned decon rule name")

    AutoCategory.ResetToDefaults()
    AC.cacheInitialize()    -- required because index in table changed
    decon = AC.GetRuleByName("Deconstruct")
    TK.assertTrue(decon.name == "Deconstruct", "decon rule name is reverted")
end

local function Cache_testAddRule()
    TK.printSuite(mn,"testAddRule")
    local ac_rules = AutoCategory.RulesW
    AutoCategory.cacheRuleInitialize()
    AutoCategory.cache.AddRule({name="Low Level", tag="group1", description="nah", rule="true",})
    AutoCategory.cache.AddRule({name="Deconstruct", tag="Gears", description="Gears that I want to deconstruct", rule="traitstring(\"intricate\")",})

    local orgr = AC.GetRuleByName("Low Level")
    TK.assertNotNil(orgr,"Low Level is there")

    local err = AC.cache.AddRule({name="Low Level", rule="false"})
    TK.assertNotNil(err, "AddRule returned error")
    print(err)
    
    err = AC.cache.AddRule({name="happy",rule="true"})
    TK.assertNil(err, "AddRule for happy succeeded.")
end

local function Cache_testUpdateSavedVars()
    TK.printSuite(mn, "testUpdateSavedVars")
    
    local happy = AC.GetRuleByName("happy")
    TK.assertNotNil(happy,"still have rule happy defined")
    
    --AC.charSaved.accountWide = false
    --TK.assertFalse(AC.charSaved.accountWide,"Settings are toon-only")

    AutoCategory.UpdateCurrentSavedVars()
    TK.assertNotNil(AutoCategory.saved.rules, "saved.rules has entries")
    TK.assertNotNil(AutoCategory.compiledRules, "compiled rules has entries")
    TK.assertTrue(AC.listcount(saved.rules) > 0, "saved.rules has "..AC.listcount(saved.rules).." entries")
    TK.assertTrue(AC.listcount(saved.rules) == AC.listcount(AC.compiledRules), "#saved.rules == #compiledRules")

    --AC.charSaved.accountWide = true
    --TK.assertTrue(AC.charSaved.accountWide,"Settings are account-wide")

    AutoCategory.UpdateCurrentSavedVars()
    TK.assertNotNil(AutoCategory.saved.rules, "saved.rules has entries")
    TK.assertNotNil(AutoCategory.compiledRules, "compiled rules has entries")
    TK.assertTrue(AC.listcount(saved.rules) > 0, "saved.rules has "..AC.listcount(saved.rules).." entries")
    TK.assertTrue(AC.listcount(saved.rules) == AC.listcount(AC.compiledRules), "#saved.rules == #compiledRules")
end


function misc_runTests()
  Misc_testInit()
  Cache_testIsValidRule()
  --Cache_testGetRuleByName()
  --Cache_testResetToDefaults()
  --Cache_testAddRule()
  --Cache_testUpdateSavedVars()
  
  EditBag_testSize()
  Misc_testReset()
end

if not Suite then
    TK.init()
    
    misc_runTests()
    
    TK.showResult("Misc Cache Tests")
end
