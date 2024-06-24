require "AutoCategory.test.zos"
require "AutoCategory.test.tk"
local TK = TestKit

local d = print

local INVENTORY_BACKPACK = 1
local INVENTORY_CRAFT_BAG = 2
local INVENTORY_GUILD_BANK = 3
local INVENTORY_HOUSE_BANK = 4
local INVENTORY_BANK = 5
local AC_DECON = 6
local AC_IMPROV = 7
local UV_DECON = 8

local ZO_PlayerInventory = {}

--AutoCategory = {}

require "LibSFUtils.LibSFUtils_Global"
require "LibSFUtils.SFUtils_Color"
require "LibSFUtils.LibSFUtils"
require "LibSFUtils.SFUtils_Tables"
require "LibSFUtils.SFUtils_LoadLanguage"
local SF = LibSFUtils
require "AutoCategory.AutoCategory_Global"
require "AutoCategory.AC_Classes"
--require "AutoCategory.AutoCategory_Defaults"
--require "AutoCategory.Hooks_Keyboard"
--require "AutoCategory.AutoCategory"
local AC = AutoCategory
local CVT = AutoCategory.CVT

local saved = {} --AutoCategory.saved
local cache = {} --AutoCategory.cache


local mn = "Misctest"

AC_UI = {}
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
    local tn = "testEditBagSize"
    TK.printSuite(mn,tn)
    TK.assertTrue(BagSet_EditBag_LAM:size() == 0, "has no choices")
    local newvals = {
      choices = { 1, 2, 4 },
      choicesValues = {"one","two","four"},
    }
    BagSet_EditBag_LAM:assign(newvals)
    TK.assertTrue(BagSet_EditBag_LAM:size() == 3, "has 3 choices")
end


local function CVT_testNew()
    local tn = "testCVTNew"
    TK.printSuite(mn,tn)
    local cvt = {}
     TK.assertFalse(cvt.choices, "cvt has no choices" )
     
    cvt = AC.CVT:New("myControl")
    TK.assertTrue(cvt.choices and SF.GetSize(cvt.choices) == 0, "has empty choices")
    TK.assertTrue(cvt.choicesValues and SF.GetSize(cvt.choicesValues) == 0, "has empty values")
    TK.assertTrue(cvt.choicesTooltips and SF.GetSize(cvt.choicesTooltips) == 0, "has empty tooltips")
    TK.assertTrue(cvt.controlName == "myControl", "control name "..cvt.controlName)
end

local function CVT_testAssign()
    local tn = "testCVTAssign"
    TK.printSuite(mn,tn)
    local cvt = AC.CVT:New("myControl")
    TK.assertNil(cvt.indexValue,"no such indexValue")
    local newvals = {
      choices = { 1, 2, 4 },
      choicesValues = {"one","two","four"},
    }
    cvt:assign(newvals)
    TK.assertTrue(cvt.choices[2] == 2, "choices[2] == 2")
    TK.assertTrue(cvt.choicesValues[2] == "two", "choicesValues[2] == two")
    TK.assertNil(cvt.choicesTooltips[2],"no such choicesTooltips[2]")
end

local function CVT_testAssign2()
    local tn = "testCVTAssign2"
    TK.printSuite(mn,tn)
    local cvt = AC.CVT:New("myControl")
    TK.assertNil(cvt.indexValue,"no such indexValue")
    local newvals = {
      choices = { 1, 2, 4 },
      choicesValues = {"one","two","four"},
      indexValue = "two",
    }
    cvt:assign(newvals)
    TK.assertTrue(cvt.choices[2] == 2, "choices[2] == 2")
    TK.assertTrue(cvt.choicesValues[2] == "two", "choicesValues[2] == two")
    TK.assertNil(cvt.choicesTooltips[2],"no such choicesTooltips[2]")
    TK.assertNil(cvt.indexValue, "indexValue == "..tostring(cvt.indexValue))
    cvt.indexValue = "two"
    TK.assertTrue(cvt.indexValue == "two", "indexValue == "..tostring(cvt.indexValue))
end

local function CVT_testAssign3()
    local tn = "testCVTAssign3"
    TK.printSuite(mn,tn)
    local cvt = AC.CVT:New("myControl2", "two")
    TK.assertTrue(cvt.controlName == "myControl2", "cvt.controlName == myControl2")
    cvt:select( "four" )
    TK.assertNotNil(cvt.indexValue,"indexValue = "..tostring(cvt.indexValue))
    local newvals = {
      choices = { 1, 2, 4 },
      choicesValues = {"one","two","four"},
      indexValue = "two",
    }
    cvt:assign(newvals)
    TK.assertTrue(cvt.choices[2] == 2, "choices[2] == 2")
    TK.assertTrue(cvt.choicesValues[2] == "two", "choicesValues[2] == two")
    TK.assertNil(cvt.choicesTooltips[2],"no such choicesTooltips[2]")
    TK.assertTrue(cvt.indexValue == "two", "indexValue == "..cvt.indexValue)
    cvt:select( "four" )
    TK.assertTrue(cvt.indexValue == "four", "indexValue == "..cvt.indexValue)
    TK.assertTrue(cvt.controlName == "myControl2", "cvt.controlName = "..cvt.controlName)
end

local function CVT_testSelect()
    local tn = "testCVTSelect"
    TK.printSuite(mn,tn)
    local cvt = AC.CVT:New("myControl3")
    local newvals = {
      choices = { 1, 2, 4, 3 },
      choicesValues = {"one","two","four", "three"},
      indexValue = "two", -- ignored by assign
    }
    cvt:assign(newvals)
    TK.assertFalse(cvt.indexValue == "two", "beginning indexValue (after assign) == "..tostring(cvt.indexValue))
    cvt:select("one")
    TK.assertTrue(cvt.indexValue == "one", "next indexValue == "..cvt.indexValue)
    cvt:select("four")
    TK.assertTrue(cvt.indexValue == "four", "next indexValue == "..cvt.indexValue)
    cvt:select("three")
    TK.assertTrue(cvt.indexValue == "three", "next indexValue == "..cvt.indexValue)
    cvt:select("five")  --  bad value
    TK.assertTrue(cvt.indexValue == "three", "bad (five) indexValue == "..cvt.indexValue)
end

local function CVT_testAppend()
    local tn = "testCVTAppend"
    TK.printSuite(mn,tn)
    local cvt = AC.CVT:New("myControl3")
    TK.assertTrue(cvt.controlName == "myControl3", "cvt.controlName == myControl3")
    cvt.indexValue = "four"
    TK.assertNotNil(cvt.indexValue,"indexValue ~= nil")
    local newvals = {
      choices = { 1, 2, 4 },
      choicesValues = {"one","two","four"},
      indexValue = "two",
    }
    cvt:assign(newvals)
    cvt:append( 3, "three", "")
    cvt.indexValue = "two"
    TK.assertTrue(cvt.choices[4] == 3, "choices[4] == three")
    TK.assertTrue(cvt.choicesValues[4] == "three", "choicesValues[4] == three")
    TK.assertNil(cvt.choicesTooltips[4],"no such choicesTooltips[4]")
    TK.assertTrue(cvt.indexValue == "two", "indexValue == "..cvt.indexValue)
    TK.assertTrue(cvt.controlName == "myControl3", "cvt.controlName = "..cvt.controlName)
end

local function CVT_testRemoveMid()
    local tn = "testCVTRemoveMid"
    TK.printSuite(mn,tn)
    local cvt = AC.CVT:New("myControl4")
    TK.assertTrue(cvt.controlName == "myControl4", "cvt.controlName == myControl4")
    cvt.indexValue = "four"
    TK.assertNotNil(cvt.indexValue,"indexValue ~= nil")
    local newvals = {
      choices = { 1, 2, 4, 3 },
      choicesValues = {"one","two","four", "three"},
    }
    cvt:assign(newvals)
    cvt:removeItemChoiceValue("four")
    TK.assertTrue(cvt.choices[3] == 3, "choices[3] == three")
    TK.assertTrue(cvt.choicesValues[3] == "three", "choicesValues[3] == three")
    TK.assertTrue(cvt.indexValue == "three", "indexValue == "..cvt.indexValue)
    TK.assertTrue(cvt.controlName == "myControl4", "cvt.controlName = "..cvt.controlName)
end

local function CVT_testRemoveFst()
    local tn = "testCVTRemoveFst"
    TK.printSuite(mn,tn)
    local cvt = AC.CVT:New("myControl4")
    TK.assertTrue(cvt.controlName == "myControl4", "cvt.controlName == myControl4")
    cvt.indexValue = "one"
    TK.assertNotNil(cvt.indexValue,"indexValue ~= nil")
    local newvals = {
      choices = { 1, 2, 4, 3 },
      choicesValues = {"one","two","four", "three"},
    }
    cvt:assign(newvals)
    cvt:removeItemChoiceValue("one")
    TK.assertTrue(cvt.choices[1] == 2, "choices[3] == two")
    TK.assertTrue(cvt.choicesValues[1] == "two", "choicesValues[1] == two")
    TK.assertTrue(cvt.indexValue == "two", "indexValue == "..cvt.indexValue)
    TK.assertTrue(cvt.controlName == "myControl4", "cvt.controlName = "..cvt.controlName)
end

local function CVT_testRemoveLst()
    local tn = "testCVTRemoveLst"
    TK.printSuite(mn,tn)
    local cvt = AC.CVT:New("myControl4")
    TK.assertTrue(cvt.controlName == "myControl4", "cvt.controlName == myControl4")
    cvt.indexValue = "three"
    TK.assertNotNil(cvt.indexValue,"indexValue ~= nil")
    local newvals = {
      choices = { 1, 2, 4, 3 },
      choicesValues = {"one","two","four", "three"},
    }
    cvt:assign(newvals)
    cvt:removeItemChoiceValue("three")
    TK.assertTrue(cvt.choices[1] == 1, "choices[1] == one")
    TK.assertTrue(cvt.choicesValues[1] == "one", "choicesValues[1] == one")
    TK.assertTrue(cvt.indexValue == "four", "indexValue == "..cvt.indexValue)
    TK.assertTrue(cvt.controlName == "myControl4", "cvt.controlName = "..cvt.controlName)
end

local function CVT_testClear()
    local tn = "testCVTClear"
    TK.printSuite(mn,tn)
    local cvt = AC.CVT:New("myControl4")
    TK.assertTrue(cvt.controlName == "myControl4", "cvt.controlName == myControl4")
    cvt.indexValue = "three"
    TK.assertNotNil(cvt.indexValue,"indexValue ~= nil")
    local newvals = {
      choices = { 1, 2, 4, 3 },
      choicesValues = {"one","two","four", "three"},
    }
    cvt:assign(newvals)
    TK.assertTrue(SF.GetSize(cvt.choices) == 4, "#choices == 4")
    local chc = cvt.choices
    cvt:clear()
    TK.assertTrue(SF.GetSize(cvt.choices) == 0, "#choices == 0")
    TK.assertTrue(cvt.choices == chc, "same choices table")
    TK.assertTrue(cvt.choices[1] == nil, "choices[1] == nil")
    --TK.assertTrue(cvt.indexValue == nil, "indexValue == nil")
    TK.assertTrue(cvt.controlName == "myControl4", "cvt.controlName = "..cvt.controlName)
end

local function CVT_testSetControlName()
    local tn = "testCVTAppend"
    TK.printSuite(mn,tn)
    local cvt = AC.CVT:New()
    TK.assertNil(cvt.controlName, "cvt.controlName == nil")
    cvt:setControlName("myNewControl")
    TK.assertTrue(cvt.controlName == "myNewControl", "cvt.controlName = "..cvt.controlName)
end

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
    --Cache_testIsValidRule()
--end

CVT_testNew()
EditBag_testSize()

--[[
CVT_testAssign()
CVT_testAssign2()
CVT_testAssign3()
CVT_testAppend()
CVT_testSetControlName()
CVT_testRemoveMid()
CVT_testRemoveFst()
CVT_testRemoveLst()
CVT_testClear()
CVT_testSelect()
--]]

TK.showResult(mn)
